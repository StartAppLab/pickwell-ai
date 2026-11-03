-- Owner-only, bounded enum diagnostics; never store images or raw label/provider text.
begin;
create function public.pickwell_valid_retake_details(value jsonb) returns boolean
 language plpgsql immutable set search_path='' as $$
declare item jsonb;
begin
 if value is null or jsonb_typeof(value)<>'array' or octet_length(value::text)>4096 then return false; end if;
 if jsonb_array_length(value)>12 then return false; end if;
 for item in select * from jsonb_array_elements(value) loop
  if jsonb_typeof(item)<>'object' then return false; end if;
  if not(item ?& array['photo','source','code','field']) or (select count(*) from jsonb_object_keys(item))<>4 then return false; end if;
  if coalesce(item->>'photo' not in ('nutrition','ingredients'),true)
   or coalesce(item->>'source' not in ('model','validation','legacy'),true)
   or coalesce(item->>'code' not in ('allergen_source','blur_or_glare','contradictory_energy','contradictory_mass','contradictory_totals','cropped_label','duplicate_nutrient','incomplete_ingredients','ingredient_order_or_source','missing_ingredients','missing_nutrition','model_requested','no_readable_values','numeric_range','numeric_source','other','product_mismatch','reason_unavailable','unit_mismatch','unreadable_text','unspecified_retake','wrong_photo'),true)
   or coalesce(item->>'field' not in ('nutrition_panel','ingredients_list','product_identity','serving_basis','serving_size','allergens','energy','fat','saturates','carbohydrate','sugars','added_sugars','protein','salt','sodium','fibre','other'),true) then return false; end if;
 end loop;
 return true;
end; $$;
alter table public.analysis_jobs add column retake_details jsonb not null default '[]'::jsonb
 check(public.pickwell_valid_retake_details(retake_details));
create or replace function public.pickwell_analysis_reply(p_user uuid,p_key uuid) returns jsonb
 language plpgsql set search_path='' as $$
declare r public.analysis_requests; j public.analysis_jobs; result jsonb;
begin
 perform public.pickwell_require_identity(p_user,true);
 select * into strict r from public.analysis_requests where user_id=p_user and idempotency_key=p_key;
 select to_jsonb(v) into result from public.published_products v where barcode=r.barcode;
 if result is not null then return jsonb_build_object('status','already_exists','barcode',r.barcode,'product',result); end if;
 if r.job_id is null then
  return jsonb_build_object('status',case when exists(select 1 from public.analysis_jobs where barcode=r.barcode and state in ('queued','processing'))
    or exists(select 1 from public.ai_usage where barcode=r.barcode and state in ('inflight','unknown')) then 'processing' else 'analysis_failed' end,
    'barcode',r.barcode);
 end if;
 select * into strict j from public.analysis_jobs where id=r.job_id and user_id=p_user;
 return jsonb_build_object('status',case when j.state='needs_retake' then 'needs_retake'
   when j.state in ('failed','cancelled') then 'analysis_failed' else 'processing' end,
   'barcode',r.barcode,'job_id',j.id,'retake_target',j.retake_target,'retake_details',j.retake_details,'error',j.error_code,
   'stage',case when exists(select 1 from public.analysis_candidates where job_id=j.id) then 'validation_pending'
    when exists(select 1 from public.ai_usage where job_id=j.id and
      (state='unknown' or (state='inflight' and j.lease_expires_at<clock_timestamp()))) then 'provider_reconciliation_required' else null end);
end; $$;

create function public.pickwell_record_analysis_retake(p_user uuid,p_key uuid,p_retake text,p_details jsonb)
 returns jsonb language plpgsql set search_path='' as $$
declare request public.analysis_requests; job public.analysis_jobs;
begin
 perform pg_advisory_xact_lock(725021003);
 perform public.pickwell_require_identity(p_user,true);
 if p_retake is null or p_retake not in ('nutrition','ingredients','both')
  or not public.pickwell_valid_retake_details(p_details) then raise exception 'Invalid retake details' using errcode='22023'; end if;
 select * into strict request from public.analysis_requests where user_id=p_user and idempotency_key=p_key;
 select * into strict job from public.analysis_jobs where id=request.job_id and user_id=p_user for update;
 if job.state in ('ready','needs_retake','failed','cancelled') then return public.pickwell_analysis_reply(p_user,p_key); end if;
 -- Details and quota release/retake settlement share the same transaction and advisory lock.
 update public.analysis_jobs set retake_details=p_details where id=job.id;
 return public.pickwell_settle_analysis(p_user,p_key,'retake',null,p_retake);
end; $$;
revoke all on function public.pickwell_valid_retake_details(jsonb),
 public.pickwell_record_analysis_retake(uuid,uuid,text,jsonb) from public,anon,authenticated;
grant execute on function public.pickwell_valid_retake_details(jsonb),
 public.pickwell_record_analysis_retake(uuid,uuid,text,jsonb) to service_role;
comment on column public.analysis_jobs.retake_details is 'Owner-scoped bounded diagnostic enums only; no raw label text, images or provider messages.';
commit;
