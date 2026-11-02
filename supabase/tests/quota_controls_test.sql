begin;
create extension if not exists pgtap with schema extensions;
select no_plan();
select is((select daily_limit from public.plan_limits where plan_code='free' and metric='barcode_lookup'),30,'Free starts at 30 lookups');
select is((select daily_limit from public.plan_limits where plan_code='free' and metric='ai_analysis'),3,'Free starts at 3 successful analyses');
select ok((select not enabled from public.plans where code='premium'),'Premium remains disabled without invented limits');
select ok((select not inference_enabled and not billing_enabled from public.quota_controls where id),'Inference and billing fail closed');
select is(public.pickwell_utc_day('2026-11-03 00:00:00+00'),date '2026-11-03','Exactly UTC midnight starts new day');
select is(public.pickwell_utc_day('2026-11-02 23:59:59.999+00'),date '2026-11-02','Just before UTC midnight is prior day');
set local timezone='Pacific/Honolulu';
select is(public.pickwell_utc_day('2026-11-03 00:00:00+00'),date '2026-11-03','Session timezone cannot shift UTC quota date');
select throws_ok($$update public.plan_limits set daily_limit=-1$$,'23514',null,'Negative limits denied');
select throws_ok($$update public.quota_controls set billing_enabled=true$$,'23514',null,'Billing cannot be activated');
select throws_ok($$update public.quota_controls set inference_enabled=true,approved_model=null$$,'23514',null,'Inference needs explicit model');
select throws_ok($$update public.quota_controls set daily_spend_usd='NaN'$$,'23514',null,'NaN cannot disable budget');
select throws_ok($$update public.quota_controls set global_concurrency=0$$,'23514',null,'Concurrency must be bounded');
update public.plan_limits set daily_limit=20,change_reason='pgTAP development fixture' where plan_code='free' and metric='barcode_lookup';
select is((select version::integer from public.plan_limits where plan_code='free' and metric='barcode_lookup'),2,'Limit edits increment version');
select ok(exists(select 1 from public.quota_config_audit where old_value->>'daily_limit'='30' and new_value->>'daily_limit'='20'),'Limit edits preserve before/after audit');
select is((select count(*)::integer from pg_class where relnamespace='public'::regnamespace and relkind in ('r','p') and not relrowsecurity),0,'All exposed tables retain RLS');
select ok(not exists(select 1 from pg_proc p where pronamespace='public'::regnamespace and proname in
 ('pickwell_reserve_usage','pickwell_finish_usage','pickwell_begin_provider','pickwell_lookup_throttle') and prosecdef),'Quota functions use invoker permissions');
set local role anon;
select throws_ok($$select public.pickwell_reserve_usage(null,'ai_analysis',gen_random_uuid(),'96385074')$$,'42501',null,'Guest cannot forge quota reservation RPC');
select throws_ok('select * from public.quota_controls','42501',null,'Guest cannot inspect private operational config');
select throws_ok('select * from public.ai_usage','42501',null,'Guest cannot inspect provider spending');
reset role;
set local role authenticated;
select throws_ok('update public.plan_limits set daily_limit=100','42501',null,'User cannot raise limits');
select throws_ok('delete from public.ai_usage','42501',null,'User cannot remove provider costs');
select throws_ok('update public.quota_controls set inference_enabled=true','42501',null,'User cannot enable inference');
select throws_ok('select public.pickwell_reconcile_expired()','42501',null,'User cannot refund reservations');
reset role;
insert into auth.users(id,email,is_anonymous,raw_user_meta_data) values
 ('e1230000-0000-4000-8000-000000000001','unconfirmed@example.invalid',false,'{}'),
 ('e1230000-0000-4000-8000-000000000002',null,true,'{}');
select throws_ok($$select public.pickwell_reserve_usage('e1230000-0000-4000-8000-000000000001','ai_analysis',gen_random_uuid(),'96385074')$$,
 '28000',null,'Unconfirmed identity cannot reserve AI');
select throws_ok($$select public.pickwell_reserve_usage('e1230000-0000-4000-8000-000000000002','barcode_lookup',gen_random_uuid(),'96385074')$$,
 '28000',null,'Anonymous Auth identity cannot claim an attributable account allowance');
select ok(not has_function_privilege('authenticated','public.pickwell_require_identity(uuid,boolean)','execute'),
 'The sole fixed-query Auth definer is server-only');
select * from finish();
rollback;
