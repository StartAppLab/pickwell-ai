-- T02.3: short, serialized admission transactions; no provider I/O inside SQL.
create table public.plans (
 code text primary key check (code in ('free','premium')),
 display_name text not null, enabled boolean not null
);
insert into public.plans values ('free','Free',true),('premium','Premium',false);
create table public.plan_limits (
 plan_code text not null references public.plans(code),
 metric text not null check(metric in ('barcode_lookup','ai_analysis')),
 daily_limit integer not null check(daily_limit between 0 and 100000),
 effective_at timestamptz not null default clock_timestamp(),
 version bigint not null default 1, updated_at timestamptz not null default clock_timestamp(),
 change_reason text not null check(length(btrim(change_reason)) between 1 and 200),
 primary key(plan_code,metric)
);
insert into public.plan_limits(plan_code,metric,daily_limit,change_reason) values
 ('free','barcode_lookup',30,'Approved initial Free allowance'),('free','ai_analysis',3,'Approved initial Free allowance');
alter table public.user_entitlements add foreign key(plan_code) references public.plans(code);

-- Fail closed until a reviewed model, token/image bounds and worst-case cost are configured.
create table public.quota_controls (
 id boolean primary key default true check(id),
 billing_enabled boolean not null default false check(not billing_enabled),
 inference_enabled boolean not null default false,
 approved_model text,
 daily_spend_usd numeric(12,6) not null default 1 check(daily_spend_usd > 0 and daily_spend_usd::text not in ('NaN','Infinity','-Infinity')),
 call_ceiling_usd numeric(12,6) not null default 0.05 check(call_ceiling_usd > 0 and call_ceiling_usd <= daily_spend_usd),
 global_concurrency integer not null default 2 check(global_concurrency between 1 and 20),
 user_concurrency integer not null default 1 check(user_concurrency between 1 and 5),
 ip_concurrency integer not null default 1 check(ip_concurrency between 1 and 10),
 global_calls_daily integer not null default 100 check(global_calls_daily between 1 and 10000),
 user_calls_daily integer not null default 9 check(user_calls_daily between 1 and 100),
 ip_calls_daily integer not null default 20 check(ip_calls_daily between 1 and 500),
 barcode_calls_daily integer not null default 3 check(barcode_calls_daily between 1 and 10),
 job_attempts integer not null default 3 check(job_attempts between 1 and 5),
 guest_per_minute integer not null default 10 check(guest_per_minute between 1 and 100),
 guest_per_day integer not null default 30 check(guest_per_day between 1 and 1000),
 user_per_minute integer not null default 20 check(user_per_minute between 1 and 200),
 ip_per_minute integer not null default 60 check(ip_per_minute between 1 and 1000),
 version bigint not null default 1, updated_at timestamptz not null default clock_timestamp(),
 change_reason text not null default 'Conservative development defaults; inference disabled',
 check(not inference_enabled or coalesce(length(btrim(approved_model)) > 0,false))
);
insert into public.quota_controls(id) values(true);
create table public.quota_config_audit (
 id uuid primary key default gen_random_uuid(), object_name text not null,
 changed_at timestamptz not null default clock_timestamp(), changed_by text not null default current_user,
 old_value jsonb, new_value jsonb
);
create function public.pickwell_audit_quota_config() returns trigger language plpgsql set search_path='' as $$
begin
 -- Serialize configuration edits with admission; an updated cap applies on the next call.
 perform pg_advisory_xact_lock(725021003);
 if tg_op='UPDATE' then new.version:=old.version+1; new.updated_at:=clock_timestamp(); end if;
 insert into public.quota_config_audit(object_name,old_value,new_value)
 values(tg_table_name,case when tg_op='INSERT' then null else to_jsonb(old) end,to_jsonb(new));
 return new;
end; $$;
create trigger pickwell_limits_audit before insert or update on public.plan_limits
 for each row execute function public.pickwell_audit_quota_config();
create trigger pickwell_controls_audit before insert or update on public.quota_controls
 for each row execute function public.pickwell_audit_quota_config();
insert into public.quota_config_audit(object_name,new_value)
 select 'plan_limits',to_jsonb(l) from public.plan_limits l;
insert into public.quota_config_audit(object_name,new_value) select 'quota_controls',to_jsonb(c) from public.quota_controls c;

alter table public.usage_reservations add column barcode text,
 add column outcome text, add column config_version bigint;
create index usage_reservations_expiry_idx on public.usage_reservations(lease_expires_at) where state='reserved';
create unique index usage_reservations_one_active_job on public.usage_reservations(job_id)
 where state='reserved' and job_id is not null;
create table public.lookup_throttles (
 bucket text not null, window_start timestamptz not null, hits integer not null check(hits>=0),
 primary key(bucket,window_start)
);
-- Minimal admission ledger only; broader operational analytics remain T02.4.
create table public.ai_usage (
 id uuid primary key default gen_random_uuid(), reservation_id uuid unique references public.usage_reservations(id) on delete set null,
 job_id uuid references public.analysis_jobs(id) on delete set null,
 user_id uuid references auth.users(id) on delete set null,
 barcode text not null, ip_bucket text not null check(ip_bucket ~ '^[0-9a-f]{64}$'),
 day_utc date not null, model text not null,
 state text not null default 'inflight' check(state in ('inflight','succeeded','failed','unknown')),
 held_usd numeric(12,6) not null check(held_usd>0),
 actual_cost_usd numeric(12,6) check(actual_cost_usd>=0 and actual_cost_usd::text not in ('NaN','Infinity','-Infinity')),
 input_tokens bigint check(input_tokens>=0), output_tokens bigint check(output_tokens>=0),
 duration_ms integer check(duration_ms>=0),
 created_at timestamptz not null default clock_timestamp(), completed_at timestamptz,
 check((state in ('succeeded','failed'))=(completed_at is not null))
);
create index ai_usage_day_idx on public.ai_usage(day_utc);
create index ai_usage_barcode_day_idx on public.ai_usage(barcode,day_utc);

create function public.pickwell_utc_day(p_time timestamptz) returns date
 language sql immutable strict set search_path='' as $$select (p_time at time zone 'UTC')::date$$;
-- Standard service_role cannot read Auth, and postgres cannot delegate Auth
-- schema USAGE. Keep one fixed-query, server-only definer under the migration
-- owner; it returns no user fields and has no dynamic SQL or write capability.
create function public.pickwell_require_identity(p_user uuid,p_verified boolean) returns void
 language plpgsql security definer set search_path='' as $$
begin
 if p_user is null or not exists(select 1 from auth.users where id=p_user and not is_anonymous
   and (not p_verified or (email is not null and email_confirmed_at is not null))) then
  raise exception 'Persistent verified identity required' using errcode='28000'; end if;
end; $$;
revoke all on function public.pickwell_require_identity(uuid,boolean) from public,anon,authenticated;

-- Only a trusted Edge adapter may supply these arguments; clients have no EXECUTE.
-- Unknown/untrusted proxy identity uses one conservative shared bucket, never a caller-selected header.
create function public.pickwell_lookup_throttle(p_ip_bucket text,p_user uuid default null)
 returns jsonb language plpgsql set search_path='' as $$
declare c public.quota_controls; v_now timestamptz:=clock_timestamp(); v_min timestamptz; v_day timestamptz; n integer;
begin
 perform pg_advisory_xact_lock(725021003);
 if p_ip_bucket is null or p_ip_bucket !~ '^[0-9a-f]{64}$' then raise exception 'Invalid network bucket' using errcode='22023'; end if;
 if p_user is not null then perform public.pickwell_require_identity(p_user,false); end if;
 select * into strict c from public.quota_controls where id;
 v_min:=date_trunc('minute',v_now); v_day:=public.pickwell_utc_day(v_now)::timestamp at time zone 'UTC';
 -- Count attempts (including retries/errors) for abuse controls, not daily product quota.
 insert into public.lookup_throttles values('ip:'||p_ip_bucket,v_min,1)
 on conflict(bucket,window_start) do update set hits=public.lookup_throttles.hits+1 returning hits into n;
 if n>c.ip_per_minute then return jsonb_build_object('allowed',false,'error','rate_limited'); end if;
 if p_user is null then
  insert into public.lookup_throttles values('guest-minute:'||p_ip_bucket,v_min,1)
  on conflict(bucket,window_start) do update set hits=public.lookup_throttles.hits+1 returning hits into n;
  if n>c.guest_per_minute then return jsonb_build_object('allowed',false,'error','rate_limited'); end if;
  insert into public.lookup_throttles values('guest-day:'||p_ip_bucket,v_day,1)
  on conflict(bucket,window_start) do update set hits=public.lookup_throttles.hits+1 returning hits into n;
  if n>c.guest_per_day then return jsonb_build_object('allowed',false,'error','rate_limited'); end if;
 else
  insert into public.lookup_throttles values('user:'||p_user,v_min,1)
  on conflict(bucket,window_start) do update set hits=public.lookup_throttles.hits+1 returning hits into n;
  if n>c.user_per_minute then return jsonb_build_object('allowed',false,'error','rate_limited'); end if;
 end if;
 return jsonb_build_object('allowed',true,'guest_best_effort',p_user is null);
end; $$;

create function public.pickwell_quota_snapshot(p_user uuid,p_metric text)
 returns jsonb language plpgsql set search_path='' as $$
declare l public.plan_limits; u public.usage_daily; d date:=public.pickwell_utc_day(clock_timestamp());
begin
 perform public.pickwell_require_identity(p_user,p_metric='ai_analysis');
 -- Billing is locked off. All users use Free, including sandbox/admin Premium.
 select * into strict l from public.plan_limits where plan_code='free' and metric=p_metric
   and effective_at<=clock_timestamp();
 select * into u from public.usage_daily where user_id=p_user and day_utc=d and metric=p_metric;
 return jsonb_build_object('plan','free','limit',l.daily_limit,'version',l.version,
  'used',coalesce(u.used,0),'reserved',coalesce(u.reserved,0),
  'remaining',greatest(0,l.daily_limit-coalesce(u.used,0)-coalesce(u.reserved,0)),
  'reset_at',(d+1)::timestamp at time zone 'UTC');
end; $$;

create function public.pickwell_reserve_usage(p_user uuid,p_metric text,p_key uuid,p_barcode text,p_job uuid default null)
 returns jsonb language plpgsql set search_path='' as $$
declare d date:=public.pickwell_utc_day(clock_timestamp()); l public.plan_limits;
 u public.usage_daily; r public.usage_reservations; j public.analysis_jobs; c public.quota_controls;
 code text:=public.pickwell_normalize_barcode(p_barcode); v_job uuid;
begin
 perform pg_advisory_xact_lock(725021003);
 if p_key is null or p_metric not in ('barcode_lookup','ai_analysis') or p_metric is null or code is null then
  raise exception 'Invalid quota request' using errcode='22023'; end if;
 perform public.pickwell_require_identity(p_user,p_metric='ai_analysis');
 perform public.pickwell_reconcile_expired();
 select * into r from public.usage_reservations where user_id=p_user and metric=p_metric and idempotency_key=p_key;
 if found then
  if r.barcode is distinct from code or (p_job is not null and r.job_id is distinct from p_job) then
   raise exception 'Idempotency request mismatch' using errcode='22023'; end if;
  return jsonb_build_object('status',r.state,'reservation_id',r.id,'job_id',r.job_id,'replay',true,'outcome',r.outcome);
 end if;
 select * into strict c from public.quota_controls where id;
 if p_metric='ai_analysis' then
  if exists(select 1 from public.published_products where barcode=code) then
   return jsonb_build_object('status','cache_hit'); end if;
  if exists(select 1 from public.ai_usage where barcode=code and state in ('inflight','unknown')) or
     exists(select 1 from public.analysis_jobs where barcode=code and state in ('queued','processing')) then
   return jsonb_build_object('status','processing'); end if;
  if p_job is not null then
   select * into j from public.analysis_jobs where id=p_job and user_id=p_user and barcode=code;
   if not found or j.state not in ('failed','needs_retake') or j.attempts>=c.job_attempts then
    return jsonb_build_object('status','retry_denied'); end if;
   if exists(select 1 from public.ai_usage where job_id=p_job and state in ('inflight','unknown')) then
    return jsonb_build_object('status','reconciliation_required'); end if;
  end if;
 elsif p_job is not null then raise exception 'Lookup has no job' using errcode='22023';
 end if;
 select * into strict l from public.plan_limits where plan_code='free' and metric=p_metric and effective_at<=clock_timestamp();
 insert into public.usage_daily(user_id,day_utc,metric) values(p_user,d,p_metric) on conflict do nothing;
 select * into strict u from public.usage_daily where user_id=p_user and day_utc=d and metric=p_metric for update;
 if u.used+u.reserved>=l.daily_limit then return public.pickwell_quota_snapshot(p_user,p_metric)||jsonb_build_object('status','quota_exceeded'); end if;
 if p_metric='ai_analysis' then
  if p_job is null then
   insert into public.analysis_jobs(barcode,user_id,idempotency_key) values(code,p_user,p_key) returning id into v_job;
  else
   update public.analysis_jobs set state='queued',error_code=null where id=p_job;
   v_job:=p_job;
  end if;
 end if;
 insert into public.usage_reservations(user_id,day_utc,metric,idempotency_key,job_id,barcode,config_version,lease_expires_at)
 values(p_user,d,p_metric,p_key,v_job,code,l.version,clock_timestamp()+interval '5 minutes') returning * into r;
 update public.usage_daily set reserved=reserved+1 where user_id=p_user and day_utc=d and metric=p_metric;
 return public.pickwell_quota_snapshot(p_user,p_metric)||jsonb_build_object('status','reserved','reservation_id',r.id,'job_id',v_job,'replay',false);
end; $$;

-- One provider call per reservation. A replay NEVER authorizes another network call.
create function public.pickwell_begin_provider(p_reservation uuid,p_ip_bucket text)
 returns jsonb language plpgsql set search_path='' as $$
declare r public.usage_reservations; j public.analysis_jobs; c public.quota_controls; a public.ai_usage;
 d date:=public.pickwell_utc_day(clock_timestamp()); v_spend numeric; v_count integer;
begin
 perform pg_advisory_xact_lock(725021003);
 select * into strict r from public.usage_reservations where id=p_reservation;
 select * into a from public.ai_usage where reservation_id=r.id;
 if found then return jsonb_build_object('call_allowed',false,'status','replay','attempt_id',a.id); end if;
 if r.metric<>'ai_analysis' or r.state<>'reserved' or r.lease_expires_at<=clock_timestamp() then
  return jsonb_build_object('call_allowed',false,'status','reservation_inactive'); end if;
 if p_ip_bucket is null or p_ip_bucket !~ '^[0-9a-f]{64}$' then raise exception 'Invalid network bucket' using errcode='22023'; end if;
 perform public.pickwell_require_identity(r.user_id,true);
 select * into strict c from public.quota_controls where id;
 if not c.inference_enabled then return jsonb_build_object('call_allowed',false,'status','inference_disabled'); end if;
 select * into strict j from public.analysis_jobs where id=r.job_id;
 if j.state<>'queued' or j.attempts>=c.job_attempts then return jsonb_build_object('call_allowed',false,'status','retry_denied'); end if;
 if exists(select 1 from public.published_products where barcode=r.barcode) then
  return jsonb_build_object('call_allowed',false,'status','cache_hit'); end if;
 if exists(select 1 from public.ai_usage where barcode=r.barcode and state in ('inflight','unknown')) then
  return jsonb_build_object('call_allowed',false,'status','reconciliation_required'); end if;
 select count(*) into v_count from public.ai_usage where state in ('inflight','unknown');
 if v_count>=c.global_concurrency or
  (select count(*) from public.ai_usage where user_id=r.user_id and state in ('inflight','unknown'))>=c.user_concurrency or
  (select count(*) from public.ai_usage where ip_bucket=p_ip_bucket and state in ('inflight','unknown'))>=c.ip_concurrency then
  return jsonb_build_object('call_allowed',false,'status','concurrency_limited'); end if;
 select coalesce(sum(greatest(held_usd,coalesce(actual_cost_usd,0))),0),count(*) into v_spend,v_count from public.ai_usage where day_utc=d;
 -- Keep the full cost bound even on known cheap calls: conservative hard admission ceiling.
 if v_spend+c.call_ceiling_usd>c.daily_spend_usd or v_count>=c.global_calls_daily then
  return jsonb_build_object('call_allowed',false,'status','service_budget_exceeded'); end if;
 if (select count(*) from public.ai_usage where day_utc=d and user_id=r.user_id)>=c.user_calls_daily or
  (select count(*) from public.ai_usage where day_utc=d and ip_bucket=p_ip_bucket)>=c.ip_calls_daily or
  (select count(*) from public.ai_usage where day_utc=d and barcode=r.barcode)>=c.barcode_calls_daily then
  return jsonb_build_object('call_allowed',false,'status','provider_attempt_limit'); end if;
 insert into public.ai_usage(reservation_id,job_id,user_id,barcode,ip_bucket,day_utc,model,held_usd)
 values(r.id,j.id,r.user_id,r.barcode,p_ip_bucket,d,c.approved_model,c.call_ceiling_usd) returning * into a;
 update public.analysis_jobs set state='processing',attempts=attempts+1,lease_expires_at=clock_timestamp()+interval '5 minutes' where id=j.id;
 return jsonb_build_object('call_allowed',true,'status','started','attempt_id',a.id,'model',a.model,'cost_bound_usd',a.held_usd);
end; $$;

create function public.pickwell_record_provider(p_attempt uuid,p_state text,p_cost numeric default null,
 p_input bigint default null,p_output bigint default null,p_duration integer default null)
 returns jsonb language plpgsql set search_path='' as $$
declare a public.ai_usage;
begin
 perform pg_advisory_xact_lock(725021003);
 if p_cost::text in ('NaN','Infinity','-Infinity') or p_state is null or p_state not in ('succeeded','failed','unknown') or p_cost<0 or p_input<0 or p_output<0 or p_duration<0 then
  raise exception 'Invalid provider result' using errcode='22023'; end if;
 select * into strict a from public.ai_usage where id=p_attempt;
 if a.state in ('succeeded','failed') then
  if (a.state,a.actual_cost_usd,a.input_tokens,a.output_tokens,a.duration_ms) is distinct from
    (p_state,p_cost,p_input,p_output,p_duration) then raise exception 'Provider result immutable' using errcode='23514'; end if;
  return jsonb_build_object('status',a.state,'replay',true);
 end if;
 update public.ai_usage set state=p_state,actual_cost_usd=p_cost,input_tokens=p_input,output_tokens=p_output,duration_ms=p_duration,
 completed_at=case when p_state='unknown' then null else clock_timestamp() end where id=a.id;
 return jsonb_build_object('status',p_state,'over_cost_bound',coalesce(p_cost>a.held_usd,false));
end; $$;

-- Publish/credit in the SAME transaction. Already prepared revisions/findings must
-- pass catalog constraints. No extraction or rule validation is invented here.
create function public.pickwell_finish_usage(p_reservation uuid,p_outcome text,p_product uuid default null,p_analysis uuid default null)
 returns jsonb language plpgsql set search_path='' as $$
declare r public.usage_reservations; j public.analysis_jobs; a public.ai_usage; v_charge boolean:=false; v_target text;
begin
 perform pg_advisory_xact_lock(725021003);
 select * into strict r from public.usage_reservations where id=p_reservation for update;
 if r.state<>'reserved' then
  if r.outcome is distinct from p_outcome then raise exception 'Finalization mismatch' using errcode='23514'; end if;
  return jsonb_build_object('status',r.state,'replay',true);
 end if;
 if r.metric='barcode_lookup' then
  if p_outcome is null or p_outcome not in ('ready','not_found','processing','transport_error') then raise exception 'Invalid lookup outcome' using errcode='22023'; end if;
  v_charge:=p_outcome<>'transport_error';
 else
  if p_outcome is null or p_outcome not in ('published','cache_hit','failed','retake','cancelled') then raise exception 'Invalid analysis outcome' using errcode='22023'; end if;
  select * into strict j from public.analysis_jobs where id=r.job_id;
  select * into a from public.ai_usage where reservation_id=r.id;
  if a.state in ('inflight','unknown') then raise exception 'Provider reconciliation required' using errcode='23514'; end if;
  if p_outcome='published' then
   if a.state is distinct from 'succeeded' or j.state<>'processing' or not exists(
    select 1 from public.product_analyses x join public.products p on p.id=x.product_id
    where x.id=p_analysis and p.id=p_product and p.barcode=r.barcode and x.contributor_id=r.user_id
      and x.sealed_at is null and p.status<>'ready') then
    raise exception 'Publication requires validated owned revision and successful provider attempt' using errcode='23514'; end if;
   update public.products set status='ready',current_analysis_id=p_analysis,published_at=clock_timestamp() where id=p_product;
   update public.analysis_jobs set state='ready',result_product_id=p_product,result_analysis_id=p_analysis where id=j.id;
   v_charge:=true;
  elsif p_outcome='cache_hit' then
   if not exists(select 1 from public.published_products where barcode=r.barcode) then raise exception 'No published cache' using errcode='23514'; end if;
   update public.analysis_jobs set state='cancelled' where id=j.id;
  elsif p_outcome='retake' then
   if j.state<>'processing' then raise exception 'Retake requires processed attempt' using errcode='23514'; end if;
   update public.analysis_jobs set state='needs_retake',retake_target='both',error_code='label_retake' where id=j.id;
  else
   update public.analysis_jobs set state=case when p_outcome='cancelled' then 'cancelled'::public.analysis_job_state else 'failed'::public.analysis_job_state end,
    error_code='analysis_failed' where id=j.id;
  end if;
 end if;
 update public.usage_daily set reserved=reserved-1,used=used+case when v_charge then 1 else 0 end
  where user_id=r.user_id and day_utc=r.day_utc and metric=r.metric;
 update public.usage_reservations set state=case when v_charge then 'consumed' else 'released' end,outcome=p_outcome where id=r.id;
 return jsonb_build_object('status',case when v_charge then 'consumed' else 'released' end,'replay',false);
end; $$;

-- Expire only work proven not to have an unresolved provider call. Unknown or
-- inflight calls keep barcode/concurrency/cost holds until operator reconciliation.
create function public.pickwell_reconcile_expired() returns integer language plpgsql set search_path='' as $$
declare r public.usage_reservations; n integer:=0;
begin
 perform pg_advisory_xact_lock(725021003);
 for r in select * from public.usage_reservations where state='reserved' and lease_expires_at<clock_timestamp() loop
  if exists(select 1 from public.ai_usage where reservation_id=r.id and state in ('inflight','unknown')) then continue; end if;
  if r.metric='ai_analysis' and exists(select 1 from public.ai_usage where reservation_id=r.id and state='succeeded') then continue; end if;
  perform public.pickwell_finish_usage(r.id,case when r.metric='barcode_lookup' then 'transport_error' else 'failed' end);
  update public.usage_reservations set state='expired' where id=r.id;
  n:=n+1;
 end loop;
 -- Network hashes are short-lived abuse identifiers, not permanent identity.
 delete from public.lookup_throttles where window_start<clock_timestamp()-interval '2 days';
 return n;
end; $$;

-- Opt-in server privileges only. Only the narrow Auth guard is definer-security.
do $$declare obj text; sig regprocedure;
begin
 foreach obj in array array['plans','plan_limits','quota_controls','quota_config_audit','lookup_throttles','ai_usage'] loop
  execute format('alter table public.%I enable row level security',obj);
  execute format('revoke all on public.%I from public,anon,authenticated',obj);
  execute format('grant select,insert,update on public.%I to service_role',obj);
 end loop;
 grant delete on public.lookup_throttles to service_role;
 for sig in select p.oid::regprocedure from pg_proc p join pg_namespace n on n.oid=p.pronamespace
  where n.nspname='public' and p.proname in ('pickwell_audit_quota_config','pickwell_utc_day','pickwell_require_identity',
   'pickwell_lookup_throttle','pickwell_quota_snapshot','pickwell_reserve_usage','pickwell_begin_provider',
   'pickwell_record_provider','pickwell_finish_usage','pickwell_reconcile_expired') loop
  execute format('revoke all on function %s from public,anon,authenticated',sig);
  execute format('grant execute on function %s to service_role',sig);
 end loop;
end; $$;
revoke update on public.quota_config_audit from service_role;
comment on table public.ai_usage is 'Provider admission ledger: full held worst-case cost remains charged to daily budget even on failure; unknown calls block retries pending reconciliation. Operational analytics extend in T02.4.';
comment on table public.usage_daily is 'Atomic server-only UTC quota counters. Free limits live in audited plan_limits; publication and credit finalization share a transaction.';
