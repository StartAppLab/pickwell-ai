-- T02.1: additive catalog/job foundation. No inference, quotas or billing activation.
-- Forward migration: apply once through the migration runner, not ad-hoc replays.

create type public.product_status as enum ('processing', 'ready', 'invalidated');
create type public.finding_severity as enum ('green', 'yellow', 'red');
create type public.analysis_job_state as enum ('queued', 'processing', 'needs_retake', 'ready', 'failed', 'cancelled');

-- Canonical GTIN-14 collapses UPC-A / leading-zero EAN-13 aliases.
-- Eight-digit input means EAN-8. Compressed UPC-E must be expanded by the scanner
-- before this function; barcode text alone cannot distinguish UPC-E from EAN-8.
create function public.pickwell_normalize_barcode(value text)
returns text language plpgsql immutable strict set search_path = '' as $$
declare
  code text := btrim(value);
  checksum integer := 0;
  position integer;
begin
  if code !~ '^([0-9]{8}|[0-9]{12}|[0-9]{13}|[0-9]{14})$' then
    raise exception 'Invalid GTIN format' using errcode = '22023';
  end if;
  for position in 1..length(code) - 1 loop
    checksum := checksum + substring(code, length(code) - position, 1)::integer
      * case when position % 2 = 1 then 3 else 1 end;
  end loop;
  if (10 - checksum % 10) % 10 <> right(code, 1)::integer then
    raise exception 'Invalid GTIN check digit' using errcode = '22023';
  end if;
  return lpad(code, 14, '0');
end;
$$;

-- Storage-shape checks supplement (do not replace) the later evidence/rules validator.
create function public.pickwell_valid_nutrition(value jsonb)
returns boolean language plpgsql immutable set search_path = '' as $$
declare nutrient jsonb;
begin
  if value is null or jsonb_typeof(value) <> 'object'
    or coalesce(jsonb_typeof(value->'raw') <> 'string', true)
    or coalesce(length(btrim(value->>'raw')), 0) = 0
    or coalesce(value->>'basis' not in ('per_100g', 'per_100ml', 'per_serving'), true)
    or coalesce(jsonb_typeof(value->'nutrients') <> 'array', true) then return false; end if;
  if jsonb_array_length(value->'nutrients') = 0 then return false; end if;
  if value->>'basis' = 'per_serving' and
    (coalesce(jsonb_typeof(value->'serving_size') <> 'string', true)
      or coalesce(length(btrim(value->>'serving_size')), 0) = 0) then return false; end if;
  for nutrient in select * from jsonb_array_elements(value->'nutrients') loop
    if jsonb_typeof(nutrient) <> 'object'
      or coalesce(jsonb_typeof(nutrient->'name') <> 'string', true)
      or coalesce(length(btrim(nutrient->>'name')), 0) = 0
      or coalesce(nutrient->>'unit' not in ('g', 'mg', 'ug', 'kcal', 'kJ', 'unknown'), true)
      or coalesce(jsonb_typeof(nutrient->'value') not in ('number', 'null'), true) then return false; end if;
    if jsonb_typeof(nutrient->'value') = 'number' then
      if (nutrient->>'value')::numeric < 0 or nutrient->>'unit' = 'unknown'
        or coalesce(jsonb_typeof(nutrient->'source') <> 'string', true)
        or coalesce(length(btrim(nutrient->>'source')), 0) = 0 then return false; end if;
    end if;
  end loop;
  return true;
end;
$$;

create function public.pickwell_valid_ingredients(value jsonb)
returns boolean language plpgsql immutable set search_path = '' as $$
declare item jsonb;
begin
  if value is null or jsonb_typeof(value) <> 'object'
    or coalesce(jsonb_typeof(value->'raw') <> 'string', true)
    or coalesce(length(btrim(value->>'raw')), 0) = 0
    or coalesce(jsonb_typeof(value->'items') <> 'array', true)
    or coalesce(jsonb_typeof(value->'declared_allergens') not in ('string', 'null'), true)
    then return false; end if;
  if jsonb_array_length(value->'items') = 0 then return false; end if;
  for item in select * from jsonb_array_elements(value->'items') loop
    if jsonb_typeof(item) <> 'string' or length(btrim(item #>> '{}')) = 0 then return false; end if;
  end loop;
  return true;
end;
$$;

create table public.products (
  id uuid primary key default gen_random_uuid(),
  barcode text not null unique,
  name text,
  brand text,
  status public.product_status not null default 'processing',
  current_analysis_id uuid,
  is_demo boolean not null default false,
  published_at timestamptz,
  invalidated_at timestamptz,
  invalidation_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (barcode, id),
  check (barcode ~ '^[0-9]{14}$' and barcode = public.pickwell_normalize_barcode(barcode)),
  check (status <> 'ready' or (current_analysis_id is not null and published_at is not null)),
  check (status <> 'invalidated' or (invalidated_at is not null and
    coalesce(length(btrim(invalidation_reason)), 0) > 0))
);

create table public.product_analyses (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id),
  contributor_id uuid references auth.users(id) on delete set null,
  schema_version integer not null default 1 check (schema_version > 0),
  nutrition jsonb not null check (public.pickwell_valid_nutrition(nutrition)),
  ingredients jsonb not null check (public.pickwell_valid_ingredients(ingredients)),
  summary text not null check (length(btrim(summary)) > 0),
  model_version text not null check (length(btrim(model_version)) > 0),
  prompt_version text not null check (length(btrim(prompt_version)) > 0),
  rules_version text not null check (length(btrim(rules_version)) > 0),
  validated_at timestamptz not null,
  sealed_at timestamptz,
  created_at timestamptz not null default now(),
  unique (product_id, id)
);
alter table public.products add constraint products_current_analysis_fk
  foreign key (id, current_analysis_id) references public.product_analyses(product_id, id);
create index product_analyses_product_created_idx on public.product_analyses(product_id, created_at desc);

create table public.analysis_findings (
  id uuid primary key default gen_random_uuid(),
  analysis_id uuid not null references public.product_analyses(id),
  severity public.finding_severity not null,
  title text not null check (length(btrim(title)) > 0),
  explanation text not null check (length(btrim(explanation)) > 0),
  source_details jsonb not null check ((jsonb_typeof(source_details) = 'object'
    and jsonb_typeof(source_details->'rule_id') = 'string'
    and length(btrim(source_details->>'rule_id')) > 0
    and case when jsonb_typeof(source_details->'evidence') = 'array'
      then jsonb_array_length(source_details->'evidence') > 0 else false end) is true),
  sort_order integer not null default 0 check (sort_order >= 0),
  created_at timestamptz not null default now(),
  unique (analysis_id, sort_order)
);

create table public.analysis_jobs (
  id uuid primary key default gen_random_uuid(),
  barcode text not null,
  user_id uuid not null references auth.users(id) on delete cascade,
  idempotency_key uuid not null,
  state public.analysis_job_state not null default 'queued',
  attempts integer not null default 0 check (attempts >= 0),
  lease_expires_at timestamptz,
  retake_target text check (retake_target in ('nutrition', 'ingredients', 'both')),
  error_code text check (error_code ~ '^[a-z][a-z0-9_]{0,63}$'),
  result_product_id uuid,
  result_analysis_id uuid,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, idempotency_key),
  foreign key (barcode, result_product_id) references public.products(barcode, id),
  foreign key (result_product_id, result_analysis_id) references public.product_analyses(product_id, id),
  check (barcode ~ '^[0-9]{14}$' and barcode = public.pickwell_normalize_barcode(barcode)),
  check (state <> 'processing' or (attempts > 0 and lease_expires_at is not null)),
  check (state <> 'needs_retake' or retake_target is not null),
  check (state <> 'failed' or error_code is not null),
  check (state <> 'ready' or (result_product_id is not null and result_analysis_id is not null)),
  check ((state in ('ready', 'failed', 'cancelled', 'needs_retake')) = (completed_at is not null))
);
create unique index analysis_jobs_active_barcode_idx on public.analysis_jobs(barcode)
  where state in ('queued', 'processing');
create index analysis_jobs_user_created_idx on public.analysis_jobs(user_id, created_at desc);
create index analysis_jobs_barcode_state_idx on public.analysis_jobs(barcode, state);

create function public.pickwell_catalog_lifecycle()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.barcode := public.pickwell_normalize_barcode(new.barcode);
  new.updated_at := clock_timestamp();
  if tg_op = 'UPDATE' then
    if new.id <> old.id or new.barcode <> old.barcode or new.created_at <> old.created_at then
      raise exception 'Catalog identity is immutable' using errcode = '23514';
    end if;
  end if;
  if new.status = 'ready' then
    -- Serialize publication with finding insertion; later inserts must see the
    -- published pointer instead of changing an already published revision.
    perform 1 from public.product_analyses where id = new.current_analysis_id for update;
    if not exists (select 1 from public.analysis_findings where analysis_id = new.current_analysis_id) then
      raise exception 'Ready product requires findings' using errcode = '23514';
    end if;
    update public.product_analyses set sealed_at = clock_timestamp()
      where id = new.current_analysis_id and sealed_at is null;
  end if;
  return new;
end;
$$;
create trigger pickwell_product_lifecycle before insert or update on public.products
  for each row execute function public.pickwell_catalog_lifecycle();

create function public.pickwell_revision_immutable()
returns trigger language plpgsql set search_path = '' as $$
begin
  -- Account erasure may detach a contributor, while preserving nonpersonal facts.
  if tg_table_name = 'product_analyses' and tg_op = 'UPDATE' then
    if new.contributor_id is null and (to_jsonb(new) - 'contributor_id') =
      (to_jsonb(old) - 'contributor_id') then return new; end if;
    -- One-way sealing records publication even after the current pointer moves.
    if old.sealed_at is null and new.sealed_at is not null and
      (to_jsonb(new) - 'sealed_at') = (to_jsonb(old) - 'sealed_at') then return new; end if;
  end if;
  raise exception 'Analysis revisions and findings are immutable; create a revision'
    using errcode = '23514';
end;
$$;
create trigger pickwell_analysis_immutable before update or delete on public.product_analyses
  for each row execute function public.pickwell_revision_immutable();
create trigger pickwell_finding_immutable before update or delete on public.analysis_findings
  for each row execute function public.pickwell_revision_immutable();

create function public.pickwell_finding_insert()
returns trigger language plpgsql set search_path = '' as $$
begin
  perform 1 from public.product_analyses where id = new.analysis_id for update;
  if exists (select 1 from public.product_analyses where id = new.analysis_id and sealed_at is not null) then
    raise exception 'Published revision requires a new revision for changed findings' using errcode = '23514';
  end if;
  return new;
end;
$$;
create trigger pickwell_finding_insert before insert on public.analysis_findings
  for each row execute function public.pickwell_finding_insert();

create function public.pickwell_job_lifecycle()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.barcode := public.pickwell_normalize_barcode(new.barcode);
  new.updated_at := clock_timestamp();
  if tg_op = 'INSERT' and (new.state <> 'queued' or new.attempts <> 0
    or new.result_product_id is not null or new.result_analysis_id is not null) then
    raise exception 'New jobs start queued without a result' using errcode = '23514';
  end if;
  if tg_op = 'UPDATE' then
    if (new.id, new.user_id, new.barcode, new.idempotency_key, new.created_at) is distinct from
      (old.id, old.user_id, old.barcode, old.idempotency_key, old.created_at)
      or new.attempts < old.attempts then
      raise exception 'Job identity and attempt history are immutable' using errcode = '23514';
    end if;
    if new.state <> old.state and not (
      (old.state = 'queued' and new.state in ('processing', 'failed', 'cancelled')) or
      (old.state = 'processing' and new.state in ('ready', 'needs_retake', 'failed', 'cancelled')) or
      (old.state in ('needs_retake', 'failed') and new.state in ('queued', 'cancelled'))
    ) then raise exception 'Invalid job transition' using errcode = '23514'; end if;
    if old.state in ('ready', 'cancelled') and to_jsonb(new) - 'updated_at' <>
      to_jsonb(old) - 'updated_at' then
      raise exception 'Terminal job is immutable' using errcode = '23514';
    end if;
    if new.state = 'processing' and old.state <> 'processing' and new.attempts <> old.attempts + 1 then
      raise exception 'Starting an attempt increments attempts exactly once' using errcode = '23514';
    end if;
  end if;
  if new.state in ('ready', 'failed', 'cancelled', 'needs_retake') then
    new.completed_at := coalesce(new.completed_at, clock_timestamp());
    new.lease_expires_at := null;
  else new.completed_at := null;
  end if;
  if new.state <> 'needs_retake' then new.retake_target := null; end if;
  return new;
end;
$$;
create trigger pickwell_job_lifecycle before insert or update on public.analysis_jobs
  for each row execute function public.pickwell_job_lifecycle();

-- Do not leave newly created catalog objects exposed pending T02.2.
alter table public.products enable row level security;
alter table public.product_analyses enable row level security;
alter table public.analysis_findings enable row level security;
alter table public.analysis_jobs enable row level security;
revoke all on public.products, public.product_analyses, public.analysis_findings, public.analysis_jobs
  from public, anon, authenticated;
grant select, insert, update on public.products, public.product_analyses, public.analysis_findings, public.analysis_jobs
  to service_role;
grant delete on public.analysis_jobs to service_role;

-- A read contract for the future controlled lookup, not a guest table endpoint.
-- Invoker semantics preserve underlying privileges/RLS on PostgreSQL 15+.
create view public.published_products with (security_invoker = true) as
select p.id, p.barcode, p.name, p.brand, p.is_demo, p.published_at,
  a.id as analysis_id, a.schema_version, a.nutrition, a.ingredients, a.summary,
  a.model_version, a.prompt_version, a.rules_version, a.validated_at as analyzed_at,
  (select jsonb_agg(jsonb_build_object('severity', f.severity, 'title', f.title,
    'explanation', f.explanation, 'source_details', f.source_details, 'sort_order', f.sort_order)
    order by f.sort_order) from public.analysis_findings f where f.analysis_id = a.id) as findings
from public.products p join public.product_analyses a
  on a.product_id = p.id and a.id = p.current_analysis_id
where p.status = 'ready';
revoke all on public.published_products from public, anon, authenticated;
grant select on public.published_products to service_role;

revoke all on function public.pickwell_normalize_barcode(text), public.pickwell_valid_nutrition(jsonb),
  public.pickwell_valid_ingredients(jsonb), public.pickwell_catalog_lifecycle(),
  public.pickwell_revision_immutable(), public.pickwell_finding_insert(), public.pickwell_job_lifecycle()
  from public, anon, authenticated;
grant execute on function public.pickwell_normalize_barcode(text), public.pickwell_valid_nutrition(jsonb),
  public.pickwell_valid_ingredients(jsonb), public.pickwell_catalog_lifecycle(),
  public.pickwell_revision_immutable(), public.pickwell_finding_insert(), public.pickwell_job_lifecycle()
  to service_role;

comment on table public.products is 'Server-owned shared catalog. Only ready rows with their current validated revision may be published by a future Edge API.';
comment on table public.analysis_jobs is 'Private job lifecycle/claim foundation. Does not implement quota reservations, spend accounting or automatic lease recovery.';
