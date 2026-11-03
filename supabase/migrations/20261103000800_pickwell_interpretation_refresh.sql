-- Operator-only immutable interpretation refresh. No inference, quota reset,
-- client write grant, or change to ordinary barcode lookup admission.
create function public.pickwell_refresh_interpretation(
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
  (a.provenance||(p_payload->'provenance'))-'identity') returning id into revision;
 for fact in select value from jsonb_array_elements(existing_findings) loop
  insert into public.analysis_findings(analysis_id,severity,title,explanation,source_details,sort_order)
  values(revision,(fact->>'severity')::public.finding_severity,fact->>'title',fact->>'explanation',fact->'source_details',(fact->>'sort_order')::integer);
 end loop;
 update public.products set current_analysis_id=revision where id=p.id;
 return jsonb_build_object('status','refreshed','analysis_id',revision,'previous_analysis_id',a.id);
end; $$;
revoke all on function public.pickwell_refresh_interpretation(uuid,uuid,text,jsonb) from public,anon,authenticated;
grant execute on function public.pickwell_refresh_interpretation(uuid,uuid,text,jsonb) to service_role;
comment on function public.pickwell_refresh_interpretation(uuid,uuid,text,jsonb) is
 'Trusted operator only: compare-and-swap immutable reference-only refresh. No new AI, label fact changes or user-credit consumption.';
