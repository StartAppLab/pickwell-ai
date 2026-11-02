-- T02.4: optional, fixed-field operational events and mandatory private cost ledger.
create table public.operational_events (
 id uuid primary key default gen_random_uuid(),
 event_type text not null check(event_type in ('barcode_scanned','product_cache_hit','product_not_found',
  'capture_completed','analysis_started','analysis_completed','analysis_failed','analysis_retake_required','quota_exceeded')),
 source_id uuid not null,
 metric text check(metric in ('barcode_lookup','ai_analysis')),
 duration_ms integer check(duration_ms between 0 and 3600000),
 created_at timestamptz not null default clock_timestamp(),
 unique(event_type,source_id)
);
create index operational_events_created_idx on public.operational_events(created_at);

-- No context/raw JSON, barcode, email, token, photo, user or IP column.
-- Analytics errors are contained in a subtransaction, not the quota transaction.
create function public.pickwell_try_event(p_event text,p_source uuid,p_metric text default null,p_duration integer default null)
 returns boolean language plpgsql set search_path='' set lock_timeout='100ms' as $$
begin
 insert into public.operational_events(event_type,source_id,metric,duration_ms)
 values(p_event,p_source,p_metric,p_duration) on conflict(event_type,source_id) do nothing;
 return true;
exception when others or query_canceled then
 return false;
end; $$;

create function public.pickwell_reservation_event() returns trigger language plpgsql set search_path='' as $$
declare v_event text;
begin
 if tg_op='INSERT' then
  if new.metric='barcode_lookup' then perform public.pickwell_try_event('barcode_scanned',new.id,new.metric); end if;
 elsif new.state is distinct from old.state and new.state in ('consumed','released') then
  v_event:=case
   when new.metric='barcode_lookup' and new.outcome='ready' then 'product_cache_hit'
   when new.metric='barcode_lookup' and new.outcome='not_found' then 'product_not_found'
   when new.metric='ai_analysis' and new.outcome='published' then 'analysis_completed'
   when new.metric='ai_analysis' and new.outcome='cache_hit' then 'product_cache_hit'
   when new.metric='ai_analysis' and new.outcome='failed' then 'analysis_failed'
   when new.metric='ai_analysis' and new.outcome='retake' then 'analysis_retake_required' end;
  if v_event is not null then perform public.pickwell_try_event(v_event,new.id,new.metric); end if;
 end if;
 return new;
exception when others or query_canceled then return new;
end; $$;
create trigger pickwell_reservation_event after insert or update on public.usage_reservations
 for each row execute function public.pickwell_reservation_event();

alter table public.ai_usage add column provider text not null default 'meta' check(provider='meta'),
 add column estimated_cost_usd numeric(12,6) check(estimated_cost_usd>=0 and estimated_cost_usd::text not in ('NaN','Infinity','-Infinity'));
-- Cost estimates are trusted server calculations, not model-provided prose/prices.
-- Any higher estimate increases the mandatory budget hold; it can never refund it.
create function public.pickwell_ledger_bound() returns trigger language plpgsql set search_path='' as $$
begin
 new.held_usd:=greatest(new.held_usd,coalesce(new.estimated_cost_usd,0));
 if tg_op='UPDATE' then new.held_usd:=greatest(old.held_usd,new.held_usd); end if;
 return new;
end; $$;
create trigger pickwell_ledger_bound before insert or update on public.ai_usage
 for each row execute function public.pickwell_ledger_bound();

create function public.pickwell_provider_event() returns trigger language plpgsql set search_path='' as $$
begin
 if tg_op='INSERT' then
  perform public.pickwell_try_event('analysis_started',coalesce(new.reservation_id,new.id),'ai_analysis');
 elsif new.state='failed' and new.state is distinct from old.state then
  perform public.pickwell_try_event('analysis_failed',coalesce(new.reservation_id,new.id),'ai_analysis',new.duration_ms);
 end if;
 return new;
exception when others or query_canceled then return new;
end; $$;
create trigger pickwell_provider_event after insert or update on public.ai_usage
 for each row execute function public.pickwell_provider_event();

-- Required accounting: errors MUST reach the worker; no best-effort catch here.
create function public.pickwell_record_provider_metrics(p_attempt uuid,p_state text,p_cost numeric default null,
 p_input bigint default null,p_output bigint default null,p_duration integer default null,p_estimate numeric default null)
 returns jsonb language plpgsql set search_path='' as $$
declare a public.ai_usage; result jsonb;
begin
 perform pg_advisory_xact_lock(725021003);
 select * into strict a from public.ai_usage where id=p_attempt for update;
 if p_estimate is not null then
  if p_estimate<0 or p_estimate::text in ('NaN','Infinity','-Infinity') then raise exception 'Invalid cost estimate' using errcode='22023'; end if;
  if a.estimated_cost_usd is not null and a.estimated_cost_usd<>p_estimate then
   raise exception 'Cost estimate is immutable' using errcode='23514'; end if;
  update public.ai_usage set estimated_cost_usd=p_estimate where id=a.id;
 end if;
 result:=public.pickwell_record_provider(p_attempt,p_state,p_cost,p_input,p_output,p_duration);
 return result||jsonb_build_object('over_cost_bound',coalesce(p_cost>a.held_usd,false) or coalesce(p_estimate>a.held_usd,false));
end; $$;

-- Closed detail: 30 days. Daily nonpersonal aggregates: 365 days.
-- Unresolved work and publication-pending successful attempts are never expired.
create table public.provider_usage_daily (
 day_utc date not null, provider text not null check(provider='meta'), model text not null,
 admitted bigint not null, succeeded bigint not null, failed bigint not null,
 input_tokens numeric not null, output_tokens numeric not null,
 input_reports bigint not null, output_reports bigint not null, token_reports bigint not null, reported_cost_usd numeric not null, cost_reports bigint not null,
 estimated_cost_usd numeric not null, estimate_reports bigint not null,
 accounted_spend_usd numeric not null, duration_ms numeric not null, duration_reports bigint not null,
 primary key(day_utc,provider,model)
);
create function public.pickwell_prune_telemetry() returns jsonb language plpgsql set search_path='' as $$
declare v_events integer; v_rows integer;
begin
 perform pg_advisory_xact_lock(725021003);
 delete from public.operational_events where created_at<clock_timestamp()-interval '30 days';
 get diagnostics v_events=row_count;
 -- Old closed IP hashes are no longer needed for current-day abuse controls.
 update public.ai_usage set ip_bucket=repeat('0',64) where completed_at<clock_timestamp()-interval '2 days'
  and ip_bucket<>repeat('0',64) and state in ('succeeded','failed');
 with expired as (
  delete from public.ai_usage a where a.state in ('succeeded','failed')
   and a.completed_at<clock_timestamp()-interval '30 days' and a.day_utc<public.pickwell_utc_day(clock_timestamp())
   and not exists(select 1 from public.usage_reservations r where r.id=a.reservation_id and r.state='reserved')
   and not exists(select 1 from public.analysis_jobs j where j.id=a.job_id and j.state in ('queued','processing'))
  returning a.*
 )
 insert into public.provider_usage_daily
 select day_utc,provider,model,count(*),count(*) filter(where state='succeeded'),count(*) filter(where state='failed'),
  coalesce(sum(input_tokens),0),coalesce(sum(output_tokens),0),count(input_tokens),count(output_tokens),count(*) filter(where input_tokens is not null or output_tokens is not null),
  coalesce(sum(actual_cost_usd),0),count(actual_cost_usd),coalesce(sum(estimated_cost_usd),0),count(estimated_cost_usd),
  sum(greatest(held_usd,coalesce(actual_cost_usd,0))),coalesce(sum(duration_ms),0),count(duration_ms)
 from expired group by day_utc,provider,model
 on conflict(day_utc,provider,model) do update set
  admitted=public.provider_usage_daily.admitted+excluded.admitted,
  succeeded=public.provider_usage_daily.succeeded+excluded.succeeded,failed=public.provider_usage_daily.failed+excluded.failed,
  input_tokens=public.provider_usage_daily.input_tokens+excluded.input_tokens,output_tokens=public.provider_usage_daily.output_tokens+excluded.output_tokens,
  input_reports=public.provider_usage_daily.input_reports+excluded.input_reports,output_reports=public.provider_usage_daily.output_reports+excluded.output_reports,
  token_reports=public.provider_usage_daily.token_reports+excluded.token_reports,
  reported_cost_usd=public.provider_usage_daily.reported_cost_usd+excluded.reported_cost_usd,cost_reports=public.provider_usage_daily.cost_reports+excluded.cost_reports,
  estimated_cost_usd=public.provider_usage_daily.estimated_cost_usd+excluded.estimated_cost_usd,estimate_reports=public.provider_usage_daily.estimate_reports+excluded.estimate_reports,
  accounted_spend_usd=public.provider_usage_daily.accounted_spend_usd+excluded.accounted_spend_usd,
  duration_ms=public.provider_usage_daily.duration_ms+excluded.duration_ms,duration_reports=public.provider_usage_daily.duration_reports+excluded.duration_reports;
 get diagnostics v_rows=row_count;
 delete from public.provider_usage_daily where day_utc<public.pickwell_utc_day(clock_timestamp())-365;
 delete from public.lookup_throttles where window_start<clock_timestamp()-interval '2 days';
 return jsonb_build_object('events_deleted',v_events,'provider_groups_archived',v_rows);
end; $$;

create view public.daily_operational_counts with(security_invoker=true) as
 select public.pickwell_utc_day(created_at) as day_utc,event_type,count(*) as events
 from public.operational_events group by 1,2;
create view public.daily_provider_costs with(security_invoker=true) as
 select day_utc,provider,model,sum(admitted) as admitted,sum(succeeded) as succeeded,sum(failed) as failed,
 sum(inflight) as inflight,sum(unknown) as unknown,sum(input_tokens) as input_tokens,sum(output_tokens) as output_tokens,
 sum(input_reports) as input_reports,sum(output_reports) as output_reports,sum(token_reports) as token_reports,sum(reported_cost_usd) as reported_cost_usd,sum(cost_reports) as cost_reports,
 sum(estimated_cost_usd) as estimated_cost_usd,sum(estimate_reports) as estimate_reports,
 sum(accounted_spend_usd) as accounted_spend_usd,sum(duration_ms) as duration_ms,sum(duration_reports) as duration_reports
 from (
  select day_utc,provider,model,count(*) as admitted,count(*) filter(where state='succeeded') as succeeded,
   count(*) filter(where state='failed') as failed,count(*) filter(where state='inflight') as inflight,count(*) filter(where state='unknown') as unknown,
   coalesce(sum(input_tokens),0) as input_tokens,coalesce(sum(output_tokens),0) as output_tokens,
   count(input_tokens) as input_reports,count(output_tokens) as output_reports,
   count(*) filter(where input_tokens is not null or output_tokens is not null) as token_reports,
   coalesce(sum(actual_cost_usd),0) as reported_cost_usd,count(actual_cost_usd) as cost_reports,
   coalesce(sum(estimated_cost_usd),0) as estimated_cost_usd,count(estimated_cost_usd) as estimate_reports,
   sum(greatest(held_usd,coalesce(actual_cost_usd,0))) as accounted_spend_usd,
   coalesce(sum(duration_ms),0) as duration_ms,count(duration_ms) as duration_reports
  from public.ai_usage group by day_utc,provider,model
  union all select day_utc,provider,model,admitted,succeeded,failed,0,0,input_tokens,output_tokens,
   input_reports,output_reports,token_reports,reported_cost_usd,cost_reports,estimated_cost_usd,estimate_reports,accounted_spend_usd,duration_ms,duration_reports
  from public.provider_usage_daily
 ) ledger group by day_utc,provider,model;

alter table public.operational_events enable row level security;
alter table public.provider_usage_daily enable row level security;
revoke all on public.operational_events,public.provider_usage_daily,public.daily_operational_counts,public.daily_provider_costs from public,anon,authenticated;
grant select,insert,delete on public.operational_events to service_role;
grant select,insert,update,delete on public.provider_usage_daily to service_role;
grant select on public.daily_operational_counts,public.daily_provider_costs to service_role;
-- Retention deletes provider details only through the server-owned workflow.
grant delete on public.ai_usage to service_role;
do $$declare sig regprocedure;
begin
 for sig in select p.oid::regprocedure from pg_proc p where p.pronamespace='public'::regnamespace and p.proname in
  ('pickwell_try_event','pickwell_reservation_event','pickwell_provider_event','pickwell_ledger_bound',
   'pickwell_record_provider_metrics','pickwell_prune_telemetry') loop
  execute format('revoke all on function %s from public,anon,authenticated',sig);
  execute format('grant execute on function %s to service_role',sig);
 end loop;
end; $$;
comment on table public.operational_events is 'Optional 30-day fixed-field telemetry. Not quota truth; no arbitrary context, photos, barcode, email, IP or token columns. Deduplicated by event and server correlation UUID.';
comment on view public.daily_provider_costs is 'Restricted accounting: admitted is authorizations, not proof of billed network requests; report counts distinguish unavailable metrics from known zero. Accounted spend includes conservative holds.';

-- Do not silently install services/extensions. Existing Supabase Cron can schedule
-- maintenance under the migration owner; otherwise deployment must enable/schedule it.
do $$begin
 if exists(select 1 from pg_extension where extname='pg_cron') then
  execute $schedule$select cron.schedule('pickwell-telemetry-retention','17 0 * * *',
   'select public.pickwell_prune_telemetry()')$schedule$;
 end if;
end; $$;
