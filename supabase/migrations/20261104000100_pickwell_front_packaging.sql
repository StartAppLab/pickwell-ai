-- T07.1C.1: three-photo identity observations, NOT barcode verification or an approval gate.
-- No images, new public grants, live inference, billing or deployment activation.
begin;
alter table public.analysis_jobs drop constraint analysis_jobs_retake_target_check;
alter table public.analysis_jobs add constraint analysis_jobs_retake_target_check
 check(retake_target in ('front','nutrition','ingredients','both','front_nutrition','front_ingredients','all'));
alter table public.product_analyses drop constraint product_analyses_provenance_check;
alter table public.product_analyses add constraint product_analyses_provenance_check
 check(jsonb_typeof(provenance)='object' and octet_length(provenance::text)<=8192);

create or replace function public.pickwell_valid_retake_details(value jsonb) returns boolean
 language plpgsql immutable set search_path='' as $$
declare item jsonb;
begin
 if value is null or jsonb_typeof(value)<>'array' or octet_length(value::text)>4096 then return false; end if;
 if jsonb_array_length(value)>12 then return false; end if;
 for item in select * from jsonb_array_elements(value) loop
  if jsonb_typeof(item)<>'object' then return false; end if;
  if not(item ?& array['photo','source','code','field']) or (select count(*) from jsonb_object_keys(item))<>4 then return false; end if;
  if coalesce(item->>'photo' not in ('front','nutrition','ingredients'),true)
   or coalesce(item->>'source' not in ('model','validation','legacy'),true)
   or coalesce(item->>'code' not in ('allergen_source','blur_or_glare','contradictory_energy','contradictory_mass','contradictory_totals','cropped_label','duplicate_nutrient','incomplete_ingredients','ingredient_order_or_source','missing_ingredients','missing_nutrition','model_requested','no_readable_values','numeric_range','numeric_source','other','product_mismatch','reason_unavailable','unit_mismatch','unreadable_text','unspecified_retake','wrong_photo'),true)
   or coalesce(item->>'field' not in ('nutrition_panel','ingredients_list','product_identity','serving_basis','serving_size','allergens','energy','fat','saturates','carbohydrate','sugars','added_sugars','protein','salt','sodium','fibre','other'),true) then return false; end if;
 end loop;
 return true;
end; $$;

create or replace function public.pickwell_settle_analysis(p_user uuid,p_key uuid,p_outcome text,p_error text default null,p_retake text default null)
 returns jsonb language plpgsql set search_path='' as $$
declare q public.analysis_requests;
begin
 perform pg_advisory_xact_lock(725021003);
 perform public.pickwell_require_identity(p_user,true);
 if p_outcome is null or p_outcome not in ('failed','retake','cancelled','cache_hit')
   or (p_error is not null and p_error not in ('provider_failed','invalid_model_output','service_unavailable','inference_disabled','provider_attempt_limit','retry_denied','service_budget_exceeded','concurrency_limited'))
   or (p_outcome='retake' and (p_retake is null or p_retake not in ('front','nutrition','ingredients','both','front_nutrition','front_ingredients','all'))) then
  raise exception 'Invalid settlement' using errcode='22023'; end if;
 select * into strict q from public.analysis_requests where user_id=p_user and idempotency_key=p_key;
 perform public.pickwell_finish_usage(q.reservation_id,p_outcome);
 if p_outcome='retake' then update public.analysis_jobs set retake_target=p_retake where id=q.job_id;
 elsif p_outcome='failed' then update public.analysis_jobs set error_code=coalesce(p_error,'analysis_failed') where id=q.job_id; end if;
 return public.pickwell_analysis_reply(p_user,p_key);
end; $$;

create or replace function public.pickwell_record_analysis_retake(p_user uuid,p_key uuid,p_retake text,p_details jsonb)
 returns jsonb language plpgsql set search_path='' as $$
declare request public.analysis_requests; job public.analysis_jobs;
begin
 perform pg_advisory_xact_lock(725021003);
 perform public.pickwell_require_identity(p_user,true);
 if p_retake is null or p_retake not in ('front','nutrition','ingredients','both','front_nutrition','front_ingredients','all')
  or not public.pickwell_valid_retake_details(p_details) then raise exception 'Invalid retake details' using errcode='22023'; end if;
 select * into strict request from public.analysis_requests where user_id=p_user and idempotency_key=p_key;
 select * into strict job from public.analysis_jobs where id=request.job_id and user_id=p_user for update;
 if job.state in ('ready','needs_retake','failed','cancelled') then return public.pickwell_analysis_reply(p_user,p_key); end if;
 -- Details and quota release/retake settlement share the same transaction and advisory lock.
 update public.analysis_jobs set retake_details=p_details where id=job.id;
 return public.pickwell_settle_analysis(p_user,p_key,'retake',null,p_retake);
end; $$;

create or replace function public.pickwell_publish_analysis(p_user uuid,p_key uuid,p_validated jsonb) returns jsonb
 language plpgsql set search_path='' as $$
declare q public.analysis_requests; c public.analysis_candidates; r public.usage_reservations;
 j public.analysis_jobs; a public.ai_usage; p public.products; revision uuid; fact jsonb; result jsonb;
begin
 perform pg_advisory_xact_lock(725021003);
 perform public.pickwell_require_identity(p_user,true);
 select * into strict q from public.analysis_requests where user_id=p_user and idempotency_key=p_key;
 select * into strict r from public.usage_reservations where id=q.reservation_id;
 if r.state<>'reserved' then return public.pickwell_analysis_reply(p_user,p_key); end if;
 select * into strict j from public.analysis_jobs where id=q.job_id and user_id=p_user;
 select * into strict a from public.ai_usage where reservation_id=r.id;
 if a.state<>'succeeded' or j.state<>'processing' then
  raise exception 'Successful owned provider attempt required' using errcode='23514'; end if;
 select to_jsonb(v) into result from public.published_products v where barcode=q.barcode;
 if result is not null then
  perform public.pickwell_finish_usage(r.id,'cache_hit');
  delete from public.analysis_candidates where job_id=j.id;
  return public.pickwell_analysis_reply(p_user,p_key);
 end if;
 select * into strict c from public.analysis_candidates where job_id=j.id;
 -- Service handler recomputes the pure validator. Bind that result to the exact
 -- immutable staged handoff and all version/ownership metadata before any write.
 if c.expires_at<=clock_timestamp() or c.model_version is distinct from a.model
  or c.prompt_version not in ('label-analysis-v2','label-analysis-v3') or p_validated is distinct from c.candidate->'validation'
  or coalesce(p_validated->>'status'<>'validated',true)
  or coalesce((p_validated->>'schema_version')::integer<>2,true)
  or p_validated->'nutrition' is distinct from c.candidate->'nutrition'
  or p_validated->'ingredients' is distinct from c.candidate->'ingredients'
  or p_validated#>>'{provenance,model_version}' is distinct from c.model_version
  or p_validated#>>'{provenance,prompt_version}' is distinct from c.prompt_version
  or p_validated#>>'{provenance,rules_version}' is distinct from 'uk-fop-2016-conservative-v1'
  or jsonb_typeof(p_validated->'findings') is distinct from 'array'
  or jsonb_typeof(p_validated->'explanations') is distinct from 'array'
  or jsonb_typeof(p_validated->'missing_information') is distinct from 'array' then
  raise exception 'Validated current candidate required' using errcode='23514'; end if;
 -- Legacy accepted results/candidates remain readable. New v3 publication retains
 -- observations, always explicitly unverified; this does not establish GTIN ownership.
 if c.prompt_version='label-analysis-v3' and (
  jsonb_typeof(p_validated#>'{provenance,identity,front}') is distinct from 'object'
  or jsonb_typeof(p_validated#>'{provenance,identity,nutrition}') is distinct from 'object'
  or jsonb_typeof(p_validated#>'{provenance,identity,ingredients}') is distinct from 'object'
  or p_validated#>>'{provenance,identity_verification}' is distinct from 'unverified'
  or p_validated#>>'{provenance,identity_policy_version}' is distinct from 'front-observations-v1'
  or c.candidate#>>'{identity,consistency}' is not distinct from 'mismatch'
  or coalesce(c.candidate#>'{identity,conflicts}','[]'::jsonb)<>'[]'::jsonb) then
  raise exception 'Unverified, nonconflicting identity observations required' using errcode='23514'; end if;
 select * into p from public.products where barcode=q.barcode for update;
 if found and (p.status<>'processing' or p.current_analysis_id is not null) then
  perform public.pickwell_finish_usage(r.id,'failed');
  update public.analysis_jobs set error_code='correction_review_required' where id=j.id;
  return public.pickwell_analysis_reply(p_user,p_key); end if;
 if p.id is null then
  insert into public.products(barcode,name,brand) values(q.barcode,
   nullif(p_validated#>>'{provenance,identity,front,product_name}',''),
   nullif(p_validated#>>'{provenance,identity,front,brand}','')) returning * into p;
 end if;
 insert into public.product_analyses(product_id,contributor_id,schema_version,nutrition,ingredients,summary,
  model_version,prompt_version,rules_version,validated_at,explanations,missing_information,provenance)
 values(p.id,p_user,2,p_validated->'nutrition',p_validated->'ingredients',p_validated->>'summary',
  c.model_version,c.prompt_version,p_validated#>>'{provenance,rules_version}',
  (p_validated#>>'{provenance,validated_at}')::timestamptz,p_validated->'explanations',
  p_validated->'missing_information',case when c.prompt_version='label-analysis-v3' then p_validated->'provenance' else (p_validated->'provenance')-'identity' end) returning id into revision;
 for fact in select value from jsonb_array_elements(p_validated->'findings') loop
  insert into public.analysis_findings(analysis_id,severity,title,explanation,source_details,sort_order)
  values(revision,(fact->>'severity')::public.finding_severity,fact->>'title',fact->>'explanation',
   fact->'source_details',(fact->>'sort_order')::integer);
 end loop;
 -- Existing finalizer seals revision, marks job ready and settles credit in this transaction.
 perform public.pickwell_finish_usage(r.id,'published',p.id,revision);
 delete from public.analysis_candidates where job_id=j.id;
 select to_jsonb(v) into strict result from public.published_products v where id=p.id;
 return jsonb_build_object('status','ready','barcode',q.barcode,'product',result);
end; $$;

create or replace function public.pickwell_refresh_interpretation(
 p_product uuid,p_expected_analysis uuid,p_expected_version text,p_payload jsonb)
returns jsonb language plpgsql set search_path='' as $$
declare p public.products; a public.product_analyses; revision uuid; fact jsonb; existing_findings jsonb;
begin
 perform pg_advisory_xact_lock(725021003);
 select * into strict p from public.products where id=p_product for update;
 if p.status<>'ready' then raise exception 'Published product required' using errcode='23514'; end if;
 select * into strict a from public.product_analyses where id=p.current_analysis_id and product_id=p.id;
 if p_payload#>>'{provenance,interpretation_version}' is null
  or p_payload#>>'{provenance,interpretation_version}' !~ '^evidence-composition-v[0-9]+$'
  or p_payload#>>'{provenance,reference_version}' is null
  or coalesce(p_payload->>'summary','')=''
  or jsonb_typeof(p_payload->'explanations') is distinct from 'array'
  or jsonb_typeof(p_payload->'missing_information') is distinct from 'array' then
  raise exception 'Versioned interpretation required' using errcode='23514'; end if;
 if a.provenance->>'interpretation_version'=p_payload#>>'{provenance,interpretation_version}'
  and a.provenance->>'reference_version'=p_payload#>>'{provenance,reference_version}' then
  return jsonb_build_object('status','already_current','analysis_id',a.id); end if;
 if a.id is distinct from p_expected_analysis
  or a.provenance->>'interpretation_version' is distinct from p_expected_version then
  raise exception 'Interpretation revision conflict' using errcode='40001'; end if;
 select coalesce(v.findings,'[]'::jsonb) into existing_findings from public.published_products v where id=p.id;
 if p_payload->'nutrition' is distinct from a.nutrition
  or p_payload->'ingredients' is distinct from a.ingredients
  or p_payload->'findings' is distinct from existing_findings then
  raise exception 'Refresh cannot change label facts or classifications' using errcode='23514'; end if;
 insert into public.product_analyses(product_id,contributor_id,schema_version,nutrition,ingredients,summary,
  model_version,prompt_version,rules_version,validated_at,explanations,missing_information,provenance)
 values(p.id,a.contributor_id,greatest(a.schema_version,2),a.nutrition,a.ingredients,p_payload->>'summary',
  a.model_version,a.prompt_version,a.rules_version,a.validated_at,p_payload->'explanations',p_payload->'missing_information',
  ((a.provenance||(p_payload->'provenance'))-'identity'-'identity_verification'-'identity_policy_version') ||
   case when a.provenance ? 'identity' then jsonb_build_object('identity',a.provenance->'identity',
    'identity_verification','unverified','identity_policy_version','front-observations-v1') else '{}'::jsonb end) returning id into revision;
 for fact in select value from jsonb_array_elements(existing_findings) loop
  insert into public.analysis_findings(analysis_id,severity,title,explanation,source_details,sort_order)
  values(revision,(fact->>'severity')::public.finding_severity,fact->>'title',fact->>'explanation',fact->'source_details',(fact->>'sort_order')::integer);
 end loop;
 update public.products set current_analysis_id=revision where id=p.id;
 return jsonb_build_object('status','refreshed','analysis_id',revision,'previous_analysis_id',a.id);
end; $$;

-- CREATE OR REPLACE preserves existing service-only ACLs. Assert/restate them explicitly.
revoke all on function public.pickwell_valid_retake_details(jsonb),
 public.pickwell_settle_analysis(uuid,uuid,text,text,text),
 public.pickwell_record_analysis_retake(uuid,uuid,text,jsonb),
 public.pickwell_publish_analysis(uuid,uuid,jsonb),
 public.pickwell_refresh_interpretation(uuid,uuid,text,jsonb) from public,anon,authenticated;
grant execute on function public.pickwell_valid_retake_details(jsonb),
 public.pickwell_settle_analysis(uuid,uuid,text,text,text),
 public.pickwell_record_analysis_retake(uuid,uuid,text,jsonb),
 public.pickwell_publish_analysis(uuid,uuid,jsonb),
 public.pickwell_refresh_interpretation(uuid,uuid,text,jsonb) to service_role;
commit;
