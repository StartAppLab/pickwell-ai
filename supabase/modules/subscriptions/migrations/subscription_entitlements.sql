-- Optional consumer subscription module. Install before deploying its functions.
create table public.user_entitlements (
  user_id uuid not null references auth.users(id) on delete cascade,
  entitlement_id text not null check (length(entitlement_id) between 1 and 200),
  environment text not null check (environment in ('PRODUCTION', 'SANDBOX')),
  product_id text not null,
  is_active boolean not null,
  is_non_expiring boolean not null default false,
  expires_at timestamptz,
  verified_until timestamptz not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, entitlement_id, environment),
  check (not is_non_expiring or expires_at is null)
);
alter table public.user_entitlements enable row level security;
revoke all on public.user_entitlements from anon, authenticated;
grant select on public.user_entitlements to authenticated;
grant all on public.user_entitlements to service_role;
create policy "Read own entitlements" on public.user_entitlements
  for select to authenticated using (user_id = (select auth.uid()));

-- No client policies or grants. A short lease serializes RevenueCat reads and writes.
create table public.entitlement_sync_leases (
  user_id uuid primary key references auth.users(id) on delete cascade,
  token uuid not null,
  lease_until timestamptz not null,
  last_attempted_at timestamptz not null default now()
);
create table public.revenuecat_webhook_events (
  event_id text primary key check (length(event_id) between 1 and 200),
  processed_at timestamptz not null default now()
);
alter table public.entitlement_sync_leases enable row level security;
alter table public.revenuecat_webhook_events enable row level security;
revoke all on public.entitlement_sync_leases, public.revenuecat_webhook_events from anon, authenticated;
grant all on public.entitlement_sync_leases, public.revenuecat_webhook_events to service_role;

-- Production-only helper. The authenticated subject always comes from the JWT.
create function public.has_entitlement(p_entitlement_id text)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.user_entitlements e
    where e.user_id = auth.uid() and e.entitlement_id = p_entitlement_id
      and not coalesce((auth.jwt()->>'is_anonymous')::boolean, false)
      and e.environment = 'PRODUCTION' and e.is_active
      and e.verified_until > now()
      and ((e.expires_at is not null and e.expires_at > now())
        or (e.expires_at is null and e.is_non_expiring))
  );
$$;
revoke all on function public.has_entitlement(text) from public, anon;
grant execute on function public.has_entitlement(text) to authenticated;

-- Zero min interval for trusted webhooks, 30 seconds for user-triggered refreshes.
create function public.claim_entitlement_sync(p_user_id uuid, p_min_interval integer default 30)
returns uuid language plpgsql security definer set search_path = '' as $$
declare v_token uuid;
begin
  insert into public.entitlement_sync_leases(user_id, token, lease_until)
    values (p_user_id, gen_random_uuid(), now() + interval '30 seconds')
    on conflict (user_id) do update set token = gen_random_uuid(),
      lease_until = now() + interval '30 seconds', last_attempted_at = now()
    where public.entitlement_sync_leases.lease_until <= now()
      and public.entitlement_sync_leases.last_attempted_at <= now() - make_interval(secs => greatest(p_min_interval, 0))
    returning token into v_token;
  return v_token;
end;
$$;

-- Atomic replacement, including deleting entitlements removed/revoked by RevenueCat.
-- An expired/replaced lease cannot overwrite newer customer state.
create function public.apply_entitlement_snapshot(
  p_user_id uuid, p_token uuid, p_environment text, p_grants jsonb
) returns boolean language plpgsql security definer set search_path = '' as $$
begin
  perform 1 from public.entitlement_sync_leases where user_id = p_user_id
    and token = p_token and lease_until > now() for update;
  if not found then return false; end if;
  if p_environment is null or p_grants is null
    or p_environment not in ('PRODUCTION', 'SANDBOX') or jsonb_typeof(p_grants) <> 'array' then
    raise exception 'Invalid entitlement snapshot';
  end if;
  delete from public.user_entitlements where user_id = p_user_id and environment = p_environment;
  insert into public.user_entitlements
    (user_id, entitlement_id, environment, product_id, is_active, is_non_expiring, expires_at, verified_until)
    select p_user_id, g.entitlement_id, p_environment, g.product_id,
      g.is_active, g.is_non_expiring, g.expires_at, now() + interval '1 hour'
    from jsonb_to_recordset(p_grants) as g(entitlement_id text, product_id text,
      is_active boolean, is_non_expiring boolean, expires_at timestamptz);
  update public.entitlement_sync_leases set lease_until = now()
    where user_id = p_user_id and token = p_token;
  return true;
end;
$$;
create function public.release_entitlement_sync(p_user_id uuid, p_token uuid)
returns void language sql security definer set search_path = '' as $$
  update public.entitlement_sync_leases set lease_until = now()
    where user_id = p_user_id and token = p_token;
$$;
revoke all on function public.claim_entitlement_sync(uuid, integer),
  public.apply_entitlement_snapshot(uuid, uuid, text, jsonb),
  public.release_entitlement_sync(uuid, uuid) from public, anon, authenticated;
grant execute on function public.claim_entitlement_sync(uuid, integer),
  public.apply_entitlement_snapshot(uuid, uuid, text, jsonb),
  public.release_entitlement_sync(uuid, uuid) to service_role;
