begin;
create extension if not exists pgtap with schema extensions;
select no_plan();
select ok((select relrowsecurity from pg_class where oid='public.operational_events'::regclass),'Events have RLS');
select ok((select relrowsecurity from pg_class where oid='public.provider_usage_daily'::regclass),'Archived aggregates have RLS');
select ok(not exists(select 1 from information_schema.columns where table_schema='public' and table_name='operational_events'
 and column_name in ('context','image','payload','email','user_id','barcode','token','ip_bucket')),'No raw payload or personal identifier event columns');
select ok(public.pickwell_try_event('capture_completed','a1240000-0000-4000-8000-000000000001','ai_analysis',100),'Explicit optional capture event accepted');
select ok(public.pickwell_try_event('capture_completed','a1240000-0000-4000-8000-000000000001','ai_analysis',100),'Event replay is safe');
select is((select count(*)::integer from public.operational_events where event_type='capture_completed'),1,'Replay counts event once');
select ok(not public.pickwell_try_event('Bearer private-token',gen_random_uuid()),'Unknown/raw event text not stored');
select ok(not public.pickwell_try_event('analysis_failed',gen_random_uuid(),'secret@example.invalid'),'Invalid metric not stored');
select ok(not public.pickwell_try_event('analysis_failed',gen_random_uuid(),null,-1),'Negative duration not stored');

insert into auth.users(id,email,email_confirmed_at,is_anonymous,raw_user_meta_data) values
 ('a1240000-0000-4000-8000-000000000002','telemetry-test@example.invalid',now(),false,'{}');
create temp table event_test_ids(k text primary key,id uuid);
grant select,insert on event_test_ids to service_role;
insert into event_test_ids select 'lookup',(public.pickwell_reserve_usage('a1240000-0000-4000-8000-000000000002',
 'barcode_lookup','a1240000-0000-4000-8000-000000000003','96385074')->>'reservation_id')::uuid;
select public.pickwell_finish_usage((select id from event_test_ids where k='lookup'),'ready');
select public.pickwell_finish_usage((select id from event_test_ids where k='lookup'),'ready');
select is((select count(*)::integer from public.operational_events where event_type='barcode_scanned'),1,'Committed lookup emits scan once');
select is((select count(*)::integer from public.operational_events where event_type='product_cache_hit'),1,'Counted cache hit emits once');

-- Real privilege failure inside optional event write must not change quota truth.
revoke insert on public.operational_events from service_role;
set local role service_role;
select ok(not public.pickwell_try_event('analysis_failed',gen_random_uuid()),'Missing analytics privilege returns false');
insert into event_test_ids select 'outage',(public.pickwell_reserve_usage('a1240000-0000-4000-8000-000000000002',
 'barcode_lookup','a1240000-0000-4000-8000-000000000004','96385074')->>'reservation_id')::uuid;
select is(public.pickwell_finish_usage((select id from event_test_ids where k='outage'),'not_found')->>'status','consumed',
 'Analytics outage does not deny a valid lookup or prevent its quota charge');
reset role;
select is((select used from public.usage_daily where user_id='a1240000-0000-4000-8000-000000000002' and metric='barcode_lookup'),2,'Quota still exact during analytics outage');
update public.plan_limits set daily_limit=2,change_reason='Test denial during analytics outage' where plan_code='free' and metric='barcode_lookup';
set local role service_role;
select is(public.pickwell_reserve_usage('a1240000-0000-4000-8000-000000000002','barcode_lookup',
 gen_random_uuid(),'96385074')->>'status','quota_exceeded','Analytics outage cannot bypass exhausted quota');
reset role;
update public.plan_limits set daily_limit=30,change_reason='Restore test allowance' where plan_code='free' and metric='barcode_lookup';
grant insert on public.operational_events to service_role;

update public.quota_controls set inference_enabled=true,approved_model='fixture:no-network',change_reason='Transactional test only' where id;
insert into event_test_ids select 'analysis',(public.pickwell_reserve_usage('a1240000-0000-4000-8000-000000000002',
 'ai_analysis','a1240000-0000-4000-8000-000000000005','96385074')->>'reservation_id')::uuid;
insert into event_test_ids select 'attempt',(public.pickwell_begin_provider((select id from event_test_ids where k='analysis'),repeat('a',64))->>'attempt_id')::uuid;
select is((select count(*)::integer from public.operational_events where event_type='analysis_started'),1,'Provider admission emits analysis start');
revoke update on public.ai_usage from service_role;
set local role service_role;
select throws_ok($$select public.pickwell_record_provider_metrics((select id from event_test_ids where k='attempt'),'failed',null,10,2,150,0.2)$$,
 '42501',null,'Mandatory cost ledger failure is not swallowed like analytics');
reset role;
grant update on public.ai_usage to service_role;
select is((select state from public.ai_usage where id=(select id from event_test_ids where k='attempt')),'inflight','Failed ledger recording keeps original provider hold');
select public.pickwell_record_provider_metrics((select id from event_test_ids where k='attempt'),'failed',null,10,2,150,0.2);
select public.pickwell_finish_usage((select id from event_test_ids where k='analysis'),'failed');
select is((select count(*)::integer from public.operational_events where event_type='analysis_failed'),1,'Provider failure plus release deduplicates one failure event');
select is((select held_usd from public.ai_usage where id=(select id from event_test_ids where k='attempt')),0.2::numeric,'Estimate above original bound increases mandatory spend hold');
select is((select used from public.usage_daily where user_id='a1240000-0000-4000-8000-000000000002' and metric='ai_analysis'),0,'Failed extraction spends provider budget but no successful-analysis credit');
select is((select provider from public.ai_usage where id=(select id from event_test_ids where k='attempt')),'meta','Provider name recorded explicitly');
select is((select estimated_cost_usd from public.ai_usage where id=(select id from event_test_ids where k='attempt')),0.2::numeric,'Available estimate is distinct from unreported actual cost');
select is((select actual_cost_usd from public.ai_usage where id=(select id from event_test_ids where k='attempt')),null::numeric,'Unknown reported cost stays null');
select is((select token_reports::integer from public.daily_provider_costs where model='fixture:no-network'),1,'Daily view includes token-report coverage');
select throws_ok($$select public.pickwell_record_provider_metrics((select id from event_test_ids where k='attempt'),'failed',null,10,2,150,-1)$$,'22023',null,'Negative estimates fail closed');
select throws_ok($$select public.pickwell_record_provider_metrics((select id from event_test_ids where k='attempt'),'failed',null,10,2,150,0.01)$$,'23514',null,'Retry cannot lower a recorded estimate');

-- Synthetic old ledger rows test retention without altering server time.
insert into public.ai_usage(id,barcode,ip_bucket,day_utc,model,state,held_usd,estimated_cost_usd,input_tokens,output_tokens,created_at,completed_at) values
 ('a1240000-0000-4000-8000-000000000006','00000096385074',repeat('b',64),public.pickwell_utc_day(now())-31,'fixture:archived','failed',0.05,0.02,5,2,now()-interval '31 days',now()-interval '31 days'),
 ('a1240000-0000-4000-8000-000000000007','00000096385074',repeat('c',64),public.pickwell_utc_day(now())-40,'fixture:unknown','unknown',0.05,null,null,null,now()-interval '40 days',null);
insert into public.operational_events(event_type,source_id,created_at) values('quota_exceeded',gen_random_uuid(),now()-interval '31 days');
insert into event_test_ids select 'pending',(public.pickwell_reserve_usage('a1240000-0000-4000-8000-000000000002',
 'ai_analysis',gen_random_uuid(),'036000291452')->>'reservation_id')::uuid;
insert into public.ai_usage(reservation_id,job_id,barcode,ip_bucket,day_utc,model,state,held_usd,created_at,completed_at)
 select r.id,r.job_id,r.barcode,repeat('d',64),public.pickwell_utc_day(now())-31,'fixture:pending','succeeded',0.05,
 now()-interval '31 days',now()-interval '31 days' from public.usage_reservations r where r.id=(select id from event_test_ids where k='pending');
insert into public.ai_usage(barcode,ip_bucket,day_utc,model,state,held_usd,created_at,completed_at) values
 ('00000096385074',repeat('e',64),public.pickwell_utc_day(now())-3,'fixture:private-ip','failed',0.05,now()-interval '3 days',now()-interval '3 days'),
 ('00000096385074',repeat('f',64),public.pickwell_utc_day(now()),'fixture:current-budget','failed',0.05,now()-interval '31 days',now()-interval '31 days'),
 ('00000096385074',repeat('f',64),public.pickwell_utc_day(now())-400,'fixture:expired-summary','failed',0.05,now()-interval '400 days',now()-interval '400 days');
select public.pickwell_prune_telemetry();
select is((select count(*)::integer from public.operational_events where created_at<now()-interval '30 days'),0,'Events older than 30 days removed');
select is((select count(*)::integer from public.ai_usage where model='fixture:archived'),0,'Old closed provider detail removed');
select is((select admitted::integer from public.provider_usage_daily where model='fixture:archived'),1,'Provider aggregate retained without request/account/IP identifiers');
select is((select accounted_spend_usd from public.daily_provider_costs where model='fixture:archived'),0.05::numeric,'Archived daily spend remains inspectable');
select is((select state from public.ai_usage where model='fixture:unknown'),'unknown','Old unresolved provider holds are never deleted');
select is((select state from public.ai_usage where model='fixture:pending'),'succeeded','Successful publication-pending work retains ledger detail');
select is((select ip_bucket from public.ai_usage where model='fixture:private-ip'),repeat('0',64),'Closed IP hash scrubbed after two days');
select is((select count(*)::integer from public.ai_usage where model='fixture:current-budget'),1,'Cleanup cannot remove current-day spend');
select is((select count(*)::integer from public.provider_usage_daily where model='fixture:expired-summary'),0,'Aggregated history expires after 365 days');
select public.pickwell_prune_telemetry();
select is((select admitted::integer from public.provider_usage_daily where model='fixture:archived'),1,'Repeated cleanup does not double count archive');

set local role anon;
select throws_ok('select * from public.operational_events','42501',null,'Guest cannot read events');
select throws_ok('select * from public.daily_provider_costs','42501',null,'Guest cannot read spending');
select throws_ok($$select public.pickwell_try_event('analysis_completed',gen_random_uuid())$$,'42501',null,'Guest cannot forge analytics RPC');
reset role;
set local role authenticated;
select throws_ok('select * from public.provider_usage_daily','42501',null,'User cannot read archives');
select throws_ok('select * from public.daily_operational_counts','42501',null,'User cannot read operational aggregates');
select throws_ok('select public.pickwell_prune_telemetry()','42501',null,'User cannot delete logs or cost evidence');
reset role;
select diag('Supabase Cron installed: '||exists(select 1 from pg_extension where extname='pg_cron')::text);
select * from finish();
rollback;
