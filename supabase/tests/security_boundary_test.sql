begin;
create extension if not exists pgtap with schema extensions;
select no_plan();

select is((select count(*)::integer from pg_class where relnamespace='public'::regnamespace
  and relkind in ('r','p') and not relrowsecurity), 0, 'All current exposed base tables have RLS');
select is((select count(*)::integer from pg_proc where pronamespace='public'::regnamespace
  and prosecdef and not (coalesce(proconfig,'{}'::text[]) @> array['search_path=""'])),
  0, 'Every public security-definer has a fixed empty search path');
select ok(not has_function_privilege('anon','public.handle_new_user()','execute'), 'Guest cannot call signup definer');
select ok(not has_function_privilege('authenticated','public.handle_new_user()','execute'), 'User cannot call signup definer');

insert into auth.users(id,email,raw_user_meta_data) values
 ('f0000000-0000-4000-8000-000000000001','boundary-alice@example.invalid','{}'),
 ('f0000000-0000-4000-8000-000000000002','boundary-bob@example.invalid','{}');
insert into public.analysis_jobs(id,barcode,user_id,idempotency_key) values
 ('f0000000-0000-4000-8000-000000000003','96385074','f0000000-0000-4000-8000-000000000001',gen_random_uuid());
select throws_ok($$insert into public.usage_reservations(user_id,day_utc,metric,idempotency_key,job_id)
 values ('f0000000-0000-4000-8000-000000000002',current_date,'ai_analysis',gen_random_uuid(),'f0000000-0000-4000-8000-000000000003')$$,
 '23503',null,'A reservation cannot reference another user job');

insert into public.revenuecat_events(event_id,environment,event_type,occurred_at,verified) values
 ('sandbox-fixture','SANDBOX','fixture',now(),true),
 ('unverified-production-fixture','PRODUCTION','fixture',now(),false);
select lives_ok($$insert into public.user_entitlements(user_id,environment,plan_code,source,status,valid_until)
 values ('f0000000-0000-4000-8000-000000000001','SANDBOX','premium','admin_test','active',now()+interval '1 hour')$$,
 'Privileged test grant can exist only in sandbox');
select is((select count(*)::integer from public.user_entitlements where environment='PRODUCTION'),0,
 'Sandbox test grant creates no production entitlement');
select throws_ok($$insert into public.user_entitlements(user_id,environment,plan_code,source,status,valid_until)
 values ('f0000000-0000-4000-8000-000000000002','PRODUCTION','premium','admin_test','active',now()+interval '1 hour')$$,
 '23514',null,'Admin test grant cannot masquerade as production');
select throws_ok($$insert into public.user_entitlements(user_id,environment,plan_code,source,status,valid_until,event_id)
 values ('f0000000-0000-4000-8000-000000000002','PRODUCTION','premium','revenuecat','active',now()+interval '1 hour','sandbox-fixture')$$,
 '23514',null,'Sandbox event cannot authorize a production grant');
select throws_ok($$insert into public.user_entitlements(user_id,environment,plan_code,source,status,valid_until,event_id)
 values ('f0000000-0000-4000-8000-000000000002','PRODUCTION','premium','revenuecat','active',now()+interval '1 hour','unverified-production-fixture')$$,
 '23514',null,'Unverified webhook cannot authorize a grant');
select throws_ok($$update public.revenuecat_events set environment='PRODUCTION' where event_id='sandbox-fixture'$$,
 '23514',null,'Event environment cannot be rewritten');

create table public.boundary_default_table(id integer);
create function public.boundary_default_function() returns boolean language sql as $$select true$$;
select ok(not has_table_privilege('anon','public.boundary_default_table','select,insert,update,delete'),
 'New tables have no default public client grants');
select ok(not has_function_privilege('anon','public.boundary_default_function()','execute'),
 'New functions have no default PUBLIC execute');

set local role anon;
select throws_ok('select * from public.usage_daily','42501',null,'Guest cannot inspect counters');
select throws_ok('delete from public.usage_reservations','42501',null,'Guest cannot release reservations');
select throws_ok('select * from public.user_entitlements','42501',null,'Guest cannot read entitlements');
select throws_ok('select * from public.revenuecat_events','42501',null,'Guest cannot read webhook metadata');
reset role;
set local role authenticated;
select throws_ok($$insert into public.user_entitlements(user_id,environment,plan_code,source,status,valid_until)
 values ('f0000000-0000-4000-8000-000000000001','SANDBOX','premium','admin_test','active',now()+interval '1 hour')$$,
 '42501',null,'Signed-in user cannot grant Premium');
select throws_ok('update public.usage_daily set used=0,reserved=0','42501',null,'User cannot reset quotas');
select throws_ok('update public.revenuecat_events set verified=true','42501',null,'User cannot mark a webhook verified');
select throws_ok('select * from public.analysis_jobs','42501',null,'User cannot inspect another job directly');
reset role;

delete from auth.users where id='f0000000-0000-4000-8000-000000000001';
select is((select count(*)::integer from public.user_entitlements
 where user_id='f0000000-0000-4000-8000-000000000001'),0,'Account erasure removes security mapping');
select * from finish();
rollback;
