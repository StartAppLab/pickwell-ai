-- T02.2 security foundations only. No quota consumption, paid grants or webhook deployment.
-- Tables required for negative authorization tests precede their later business logic.
create table public.usage_daily (
  user_id uuid not null references auth.users(id) on delete cascade,
  day_utc date not null,
  metric text not null check (metric in ('barcode_lookup', 'ai_analysis')),
  used integer not null default 0 check (used >= 0),
  reserved integer not null default 0 check (reserved >= 0),
  primary key (user_id, day_utc, metric)
);

alter table public.analysis_jobs add constraint analysis_jobs_user_id_id_key unique (user_id, id);
create table public.usage_reservations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  day_utc date not null,
  metric text not null check (metric in ('barcode_lookup', 'ai_analysis')),
  idempotency_key uuid not null,
  state text not null default 'reserved' check (state in ('reserved', 'consumed', 'released', 'expired')),
  job_id uuid,
  lease_expires_at timestamptz,
  created_at timestamptz not null default now(),
  unique (user_id, metric, idempotency_key),
  foreign key (user_id, job_id) references public.analysis_jobs(user_id, id)
);

create table public.revenuecat_events (
  event_id text primary key check (length(event_id) between 1 and 200),
  environment text not null check (environment in ('PRODUCTION', 'SANDBOX')),
  event_type text not null,
  occurred_at timestamptz not null,
  received_at timestamptz not null default now(),
  verified boolean not null default false,
  sanitized_payload jsonb not null default '{}' check (jsonb_typeof(sanitized_payload) = 'object'),
  unique (event_id, environment)
);

create table public.user_entitlements (
  user_id uuid not null references auth.users(id) on delete cascade,
  environment text not null check (environment in ('PRODUCTION', 'SANDBOX')),
  plan_code text not null check (plan_code in ('free', 'premium')),
  source text not null check (source in ('admin_test', 'revenuecat')),
  status text not null check (status in ('active', 'expired', 'revoked')),
  valid_from timestamptz not null default now(),
  valid_until timestamptz not null,
  event_id text,
  updated_at timestamptz not null default now(),
  primary key (user_id, environment),
  foreign key (event_id, environment) references public.revenuecat_events(event_id, environment),
  check (valid_until > valid_from),
  check ((source = 'admin_test' and environment = 'SANDBOX' and event_id is null)
    or (source = 'revenuecat' and event_id is not null))
);

-- An immutable event identity/environment prevents reclassifying sandbox history.
create function public.pickwell_event_identity()
returns trigger language plpgsql set search_path = '' as $$
begin
  if (new.event_id, new.environment, new.event_type, new.occurred_at, new.received_at) is distinct from
    (old.event_id, old.environment, old.event_type, old.occurred_at, old.received_at) then
    raise exception 'Webhook event identity is immutable' using errcode = '23514';
  end if;
  return new;
end;
$$;
create trigger pickwell_event_identity before update on public.revenuecat_events
  for each row execute function public.pickwell_event_identity();

create function public.pickwell_entitlement_boundary()
returns trigger language plpgsql set search_path = '' as $$
begin
  if new.source = 'revenuecat' and not exists (
    select 1 from public.revenuecat_events e where e.event_id = new.event_id
      and e.environment = new.environment and e.verified
  ) then raise exception 'Entitlement requires verified same-environment event' using errcode = '23514'; end if;
  new.updated_at := clock_timestamp();
  return new;
end;
$$;
create trigger pickwell_entitlement_boundary before insert or update on public.user_entitlements
  for each row execute function public.pickwell_entitlement_boundary();

alter table public.usage_daily enable row level security;
alter table public.usage_reservations enable row level security;
alter table public.revenuecat_events enable row level security;
alter table public.user_entitlements enable row level security;
revoke all on public.usage_daily, public.usage_reservations, public.revenuecat_events, public.user_entitlements
  from public, anon, authenticated;
grant select, insert, update, delete on public.usage_daily, public.usage_reservations, public.user_entitlements
  to service_role;
grant select, insert, update on public.revenuecat_events to service_role;

revoke all on function public.pickwell_event_identity(), public.pickwell_entitlement_boundary()
  from public, anon, authenticated;
grant execute on function public.pickwell_event_identity(), public.pickwell_entitlement_boundary() to service_role;

-- Trigger invocation does not require callers to have direct RPC EXECUTE access.
-- Preserve the existing hardened signup trigger while removing a callable definer.
alter function public.handle_new_user() set search_path = '';
revoke all on function public.handle_new_user() from public, anon, authenticated;

-- Future migrations must opt into access instead of relying on default exposure.
alter default privileges for role postgres in schema public revoke all on tables from public, anon, authenticated;
alter default privileges for role postgres in schema public revoke all on sequences from public, anon, authenticated;
-- Function PUBLIC EXECUTE is a global default: a schema-only revoke cannot remove it.
alter default privileges for role postgres revoke execute on functions from public, anon, authenticated;
alter default privileges for role postgres in schema public revoke execute on functions from public, anon, authenticated;

-- Old starter migrations relied on implicit platform grants. Make their existing
-- RLS-controlled capabilities explicit so a later clean reset under hardened
-- defaults does not break profiles, sample CRUD or account preferences.
grant select on public.profiles, public.posts, public.comments, public.likes, public.follows,
  public.categories, public.tags, public.post_categories, public.post_tags to anon, authenticated;
grant insert, delete on public.profiles to authenticated;
grant update (username, full_name, avatar_url, bio, website, location) on public.profiles to authenticated;
grant insert, update, delete on public.posts, public.comments, public.categories,
  public.post_categories, public.post_tags, public.notifications to authenticated;
grant select on public.notifications to authenticated;
grant insert, delete on public.likes, public.follows to authenticated;
grant insert on public.tags to authenticated;
grant execute on function public.generate_slug(text) to authenticated;
do $$
declare function_schema text;
begin
  for function_schema in select n.nspname from pg_proc p join pg_namespace n on p.pronamespace=n.oid
    where p.proname='uuid_generate_v4' and p.pronargs=0 and n.nspname in ('public','extensions') loop
    execute format('grant execute on function %I.uuid_generate_v4() to authenticated, service_role', function_schema);
  end loop;
end;
$$;

comment on table public.usage_daily is 'Server-only counters; atomic quota/reservation operations and initial 30/3 plan limits are T02.3, not implemented here.';
comment on table public.user_entitlements is 'Server-only environment-separated security storage. No plan resolver or billing activation; normal users remain Free.';
comment on table public.revenuecat_events is 'Protected future webhook audit storage; presence/verified flag alone is not authoritative entitlement reconciliation.';
