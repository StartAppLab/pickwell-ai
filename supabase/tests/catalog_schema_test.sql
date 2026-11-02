-- Native/Docker Supabase pgTAP checks; all test changes roll back.
begin;
create extension if not exists pgtap with schema extensions;
select plan(31);

select has_table('public', 'products', 'Catalog exists');
select has_table('public', 'product_analyses', 'Analysis revisions exist');
select has_table('public', 'analysis_findings', 'Findings exist');
select has_table('public', 'analysis_jobs', 'Private jobs exist');
select is((select count(*)::integer from pg_class where relnamespace = 'public'::regnamespace
  and relname in ('products','product_analyses','analysis_findings','analysis_jobs') and relrowsecurity),
  4, 'Every catalog/job table has RLS');
select is(public.pickwell_normalize_barcode('036000291452'), '00036000291452', 'UPC-A normalizes to GTIN-14');
select is(public.pickwell_normalize_barcode('0036000291452'), '00036000291452', 'EAN alias has same canonical identity');
select throws_ok($$select public.pickwell_normalize_barcode('036000291453')$$,
  '22023', null, 'Bad check digit is rejected');
select is((select count(*)::integer from public.products where barcode='02900000000018'
  and is_demo and name like 'DEMO%'), 1, 'Local seed explicitly labels a synthetic demo');
select is((select count(*)::integer from public.published_products), 1, 'Only seeded ready record is published');
select is((select model_version from public.product_analyses where id='d0000000-0000-4000-8000-000000000002'),
  'fixture:no-provider-call', 'Demo never claims a live provider analysis');
select throws_ok($$insert into public.products(barcode) values ('2900000000018')$$,
  '23505', null, 'Canonical duplicate barcode is rejected');

insert into public.products(id,barcode) values ('e0000000-0000-4000-8000-000000000001','4006381333931');
select throws_ok($$update public.products set status='ready' where id='e0000000-0000-4000-8000-000000000001'$$,
  '23514', null, 'Cannot publish without analysis/findings');
select throws_ok($$update public.products set current_analysis_id='d0000000-0000-4000-8000-000000000002'
  where id='e0000000-0000-4000-8000-000000000001'$$,
  '23503', null, 'Current analysis must belong to the same product');
select throws_ok($$insert into public.product_analyses(product_id,nutrition,ingredients,summary,
  model_version,prompt_version,rules_version,validated_at)
  values ('e0000000-0000-4000-8000-000000000001','{}','{}','test','m','p','r',now())$$,
  '23514', null, 'Incomplete structured evidence is rejected');
select throws_ok($$update public.product_analyses set summary='forged'$$,
  '23514', null, 'Analysis revisions cannot be overwritten');
select throws_ok($$update public.analysis_findings set explanation='forged'$$,
  '23514', null, 'Findings cannot be overwritten');

insert into auth.users(id,email,raw_user_meta_data)
  values ('e0000000-0000-4000-8000-000000000010','catalog-test@example.invalid','{}');
insert into public.analysis_jobs(id,barcode,user_id,idempotency_key)
  values ('e0000000-0000-4000-8000-000000000020','4006381333931',
    'e0000000-0000-4000-8000-000000000010','e0000000-0000-4000-8000-000000000030');
select throws_ok($$insert into public.analysis_jobs(barcode,user_id,idempotency_key)
  values ('4006381333931','e0000000-0000-4000-8000-000000000010',gen_random_uuid())$$,
  '23505', null, 'A second active job cannot claim the same barcode');
select throws_ok($$update public.analysis_jobs set state='ready' where id='e0000000-0000-4000-8000-000000000020'$$,
  '23514', null, 'Queued job cannot skip directly to ready');
select lives_ok($$update public.analysis_jobs set state='processing',attempts=1,
  lease_expires_at=now()+interval '1 minute' where id='e0000000-0000-4000-8000-000000000020'$$,
  'A real attempt starts with an increment and lease');
select throws_ok($$update public.analysis_jobs set state='needs_retake' where id='e0000000-0000-4000-8000-000000000020'$$,
  '23514', null, 'Retake must identify a label');
select lives_ok($$update public.analysis_jobs set state='needs_retake',retake_target='ingredients'
  where id='e0000000-0000-4000-8000-000000000020'$$, 'Retake releases active claim and records target');
select throws_ok($$insert into public.analysis_jobs(barcode,user_id,idempotency_key)
  values ('036000291452','e0000000-0000-4000-8000-000000000010','e0000000-0000-4000-8000-000000000030')$$,
  '23505', null, 'Idempotency cannot be reused for another barcode');
select lives_ok($$update public.products set status='invalidated',invalidated_at=now(),
  invalidation_reason='pgTAP fixture' where id='d0000000-0000-4000-8000-000000000001'$$,
  'Trusted invalidation records a reason');
select is((select count(*)::integer from public.published_products), 0, 'Invalidated/processing products are not published');

set local role anon;
select throws_ok('select * from public.products', '42501', null, 'Guest cannot read internal catalog directly');
select throws_ok($$insert into public.products(barcode) values ('96385074')$$,
  '42501', null, 'Guest cannot insert catalog data');
select throws_ok('select * from public.published_products', '42501', null, 'Guest must use controlled lookup, not the view');
reset role;
set local role authenticated;
select throws_ok('select * from public.analysis_jobs', '42501', null, 'Signed-in client cannot inspect private jobs directly');
select throws_ok($$update public.analysis_findings set title='forged'$$,
  '42501', null, 'Signed-in client cannot forge findings');
reset role;
delete from auth.users where id='e0000000-0000-4000-8000-000000000010';
select is((select count(*)::integer from public.analysis_jobs
  where user_id='e0000000-0000-4000-8000-000000000010'), 0, 'Account deletion clears its private jobs');

select * from finish();
rollback;
