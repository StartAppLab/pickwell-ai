-- T05.3: private validated handoff -> immutable published revision + one credit.
-- No inference, billing, Storage bucket, scheduler or client privilege is enabled.
alter table public.product_analyses
 add column explanations jsonb not null default '[]'::jsonb check(jsonb_typeof(explanations)='array' and octet_length(explanations::text)<=16384),
 add column missing_information jsonb not null default '[]'::jsonb check(jsonb_typeof(missing_information)='array' and octet_length(missing_information::text)<=16384),
 add column provenance jsonb not null default '{}'::jsonb check(jsonb_typeof(provenance)='object' and octet_length(provenance::text)<=4096);

create or replace view public.published_products with (security_invoker = true) as
select p.id,p.barcode,p.name,p.brand,p.is_demo,p.published_at,
 a.id as analysis_id,a.schema_version,a.nutrition,a.ingredients,a.summary,
 a.model_version,a.prompt_version,a.rules_version,a.validated_at as analyzed_at,
 (select jsonb_agg(jsonb_build_object('severity',f.severity,'title',f.title,
 'explanation',f.explanation,'source_details',f.source_details,'sort_order',f.sort_order)
 order by f.sort_order) from public.analysis_findings f where f.analysis_id=a.id) as findings,
 a.explanations,a.missing_information,a.provenance
from public.products p join public.product_analyses a on a.product_id=p.id and a.id=p.current_analysis_id
where p.status='ready';

create function public.pickwell_read_analysis_candidate(p_user uuid,p_key uuid) returns jsonb
 language plpgsql set search_path='' as $$
declare q public.analysis_requests; result jsonb;
begin
 perform pg_advisory_xact_lock(725021003);
 perform public.pickwell_require_identity(p_user,true);
 perform public.pickwell_prune_analysis();
 select * into strict q from public.analysis_requests where user_id=p_user and idempotency_key=p_key;
 select jsonb_build_object('candidate',c.candidate,'model_version',c.model_version,'prompt_version',c.prompt_version)
 into result from public.analysis_candidates c join public.analysis_jobs j on j.id=c.job_id
 join public.usage_reservations r on r.id=q.reservation_id
 where c.job_id=q.job_id and j.user_id=p_user and j.state='processing' and r.state='reserved'
 and c.expires_at>clock_timestamp();
 return result;
end; $$;

create function public.pickwell_publish_analysis(p_user uuid,p_key uuid,p_validated jsonb) returns jsonb
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
  or c.prompt_version<>'label-analysis-v2' or p_validated is distinct from c.candidate->'validation'
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
 select * into p from public.products where barcode=q.barcode for update;
 if found and (p.status<>'processing' or p.current_analysis_id is not null) then
  perform public.pickwell_finish_usage(r.id,'failed');
  update public.analysis_jobs set error_code='correction_review_required' where id=j.id;
  return public.pickwell_analysis_reply(p_user,p_key); end if;
 if p.id is null then
  insert into public.products(barcode) values(q.barcode) returning * into p;
 end if;
 insert into public.product_analyses(product_id,contributor_id,schema_version,nutrition,ingredients,summary,
  model_version,prompt_version,rules_version,validated_at,explanations,missing_information,provenance)
 values(p.id,p_user,2,p_validated->'nutrition',p_validated->'ingredients',p_validated->>'summary',
  c.model_version,c.prompt_version,p_validated#>>'{provenance,rules_version}',
  (p_validated#>>'{provenance,validated_at}')::timestamptz,p_validated->'explanations',
  p_validated->'missing_information',(p_validated->'provenance') - 'identity') returning id into revision;
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

revoke all on function public.pickwell_read_analysis_candidate(uuid,uuid),public.pickwell_publish_analysis(uuid,uuid,jsonb)
 from public,anon,authenticated;
grant execute on function public.pickwell_read_analysis_candidate(uuid,uuid),public.pickwell_publish_analysis(uuid,uuid,jsonb) to service_role;

-- Known terminal outcomes remove their private structured handoff immediately.
create function public.pickwell_cleanup_closed_candidate() returns trigger language plpgsql set search_path='' as $$
begin
 if new.state in ('ready','failed','needs_retake','cancelled') then
  delete from public.analysis_candidates where job_id=new.id;
 end if;
 return new;
end; $$;
create trigger pickwell_cleanup_closed_candidate after update of state on public.analysis_jobs
 for each row execute function public.pickwell_cleanup_closed_candidate();
revoke all on function public.pickwell_cleanup_closed_candidate() from public,anon,authenticated;
grant execute on function public.pickwell_cleanup_closed_candidate() to service_role;

-- V2 may truthfully omit all colours for unsupported contexts; legacy V1 still requires findings.
create or replace function public.pickwell_catalog_lifecycle()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.barcode := public.pickwell_normalize_barcode(new.barcode);
  new.updated_at := clock_timestamp();
  if tg_op = 'UPDATE' then
    if new.id <> old.id or new.barcode <> old.barcode or new.created_at <> old.created_at then
      raise exception 'Catalog identity is immutable' using errcode = '23514';
    end if;
  end if;
  if new.status = 'ready' then
    -- Serialize publication with finding insertion; later inserts must see the
    -- published pointer instead of changing an already published revision.
    perform 1 from public.product_analyses where id = new.current_analysis_id for update;
    if not exists (select 1 from public.analysis_findings where analysis_id = new.current_analysis_id)
      and not exists (select 1 from public.product_analyses where id=new.current_analysis_id and schema_version>=2) then
      raise exception 'Ready product requires findings' using errcode = '23514';
    end if;
    update public.product_analyses set sealed_at = clock_timestamp()
      where id = new.current_analysis_id and sealed_at is null;
  end if;
  return new;
end;
$$;
