-- T07.1C: bounded operator review, exact evidence/candidate binding and fail-closed publication.
-- No images, new client grants, paid calls, live configuration or deployment activation.
begin;
create table public.product_trust_reviews (
 id uuid primary key default gen_random_uuid(),
 job_id uuid unique references public.analysis_jobs(id) on delete set null,
 barcode text not null check(barcode=public.pickwell_normalize_barcode(barcode)),
 input_digest text not null check(input_digest ~ '^[0-9a-f]{64}$'),
 candidate_digest text not null check(candidate_digest ~ '^[0-9a-f]{64}$'),
 policy_version text not null check(policy_version='trust-publication-v1'),
 state text not null default 'pending' check(state in ('pending','approved','published','rejected','cancelled','expired')),
 created_at timestamptz not null default clock_timestamp(),
 expires_at timestamptz not null,
 review_ref text check(review_ref ~ '^[A-Za-z0-9][A-Za-z0-9._-]{7,99}$'),
 review_basis text check(review_basis in ('package_barcode_evidence','trusted_product_reference','controlled_demo_evidence')),
 resolution text check(resolution in ('no_discrepancy','wording_variation_reviewed','conflict_unresolved')),
 reviewed_at timestamptz,closed_at timestamptz,
 check(state not in ('approved','published','rejected') or (review_ref is not null and reviewed_at is not null and review_basis is not null and resolution is not null)),
 check(state not in ('approved','published') or resolution<>'conflict_unresolved'),
 check(expires_at>created_at)
);
alter table public.product_trust_reviews enable row level security;
revoke all on public.product_trust_reviews from public,anon,authenticated;
grant select,insert,update,delete on public.product_trust_reviews to service_role;
create index product_trust_reviews_expiry on public.product_trust_reviews(expires_at) where state in ('pending','approved');

create function public.pickwell_review_immutable() returns trigger language plpgsql set search_path='' as $$
begin
 if old.job_id is not null and new.job_id is null and (to_jsonb(new)-'job_id')=(to_jsonb(old)-'job_id') then return new; end if;
 if (to_jsonb(new)-array['state','review_ref','review_basis','resolution','reviewed_at','closed_at'])
    is distinct from (to_jsonb(old)-array['state','review_ref','review_basis','resolution','reviewed_at','closed_at']) then
  raise exception 'Review evidence bindings are immutable' using errcode='23514'; end if;
 if not(old.state='pending' and new.state in ('approved','rejected','cancelled','expired')
   or old.state='approved' and new.state in ('published','cancelled','expired')) then
  raise exception 'Review decision is immutable' using errcode='23514'; end if;
 if old.state='approved' and (new.review_ref,new.review_basis,new.resolution,new.reviewed_at)
   is distinct from (old.review_ref,old.review_basis,old.resolution,old.reviewed_at) then
  raise exception 'Approved review attribution is immutable' using errcode='23514'; end if;
 return new;
end; $$;
create trigger pickwell_review_immutable before update on public.product_trust_reviews
 for each row execute function public.pickwell_review_immutable();

-- Empty structured items are valid when raw partial transcription remains readable.
create or replace function public.pickwell_valid_ingredients(value jsonb) returns boolean
 language plpgsql immutable set search_path='' as $$
declare item jsonb;
begin
 if value is null or jsonb_typeof(value)<>'object'
  or coalesce(jsonb_typeof(value->'raw')<>'string',true) or coalesce(length(btrim(value->>'raw')),0)=0
  or coalesce(jsonb_typeof(value->'items')<>'array',true)
  or coalesce(jsonb_typeof(value->'declared_allergens') not in ('string','null'),true) then return false; end if;
 for item in select * from jsonb_array_elements(value->'items') loop
  if jsonb_typeof(item)<>'string' or length(btrim(item#>>'{}'))=0 then return false; end if;
 end loop;
 return true;
end; $$;

create or replace function public.pickwell_prune_analysis() returns integer language plpgsql set search_path='' as $$
declare row record; n integer:=0;
begin
 perform pg_advisory_xact_lock(725021003);
 update public.product_trust_reviews set state='expired',closed_at=clock_timestamp()
  where state in ('pending','approved') and expires_at<clock_timestamp();
 for row in select c.job_id,r.id as reservation_id from public.analysis_candidates c
   join public.usage_reservations r on r.job_id=c.job_id and r.state='reserved'
   join public.ai_usage a on a.reservation_id=r.id and a.state='succeeded'
   where c.expires_at<clock_timestamp() loop
  perform public.pickwell_finish_usage(row.reservation_id,'failed');
  update public.analysis_jobs set error_code=case when exists(select 1 from public.product_trust_reviews where job_id=row.job_id) then 'review_expired' else 'candidate_expired' end where id=row.job_id;
  n:=n+1;
 end loop;
 delete from public.analysis_candidates where expires_at<clock_timestamp();
 delete from public.analysis_requests q where created_at<clock_timestamp()-interval '30 days'
  and not exists(select 1 from public.analysis_jobs j where j.id=q.job_id and j.state in ('queued','processing'))
  and not exists(select 1 from public.usage_reservations r where r.id=q.reservation_id and r.state='reserved');
 delete from public.product_trust_reviews where state in ('rejected','cancelled','expired') and coalesce(closed_at,created_at)<clock_timestamp()-interval '30 days';
 return n;
end; $$;

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
 if j.state='cancelled' and exists(select 1 from public.product_trust_reviews where job_id=j.id and state='cancelled') then return jsonb_build_object('status','review_cancelled','barcode',r.barcode); end if;
 if j.state='processing' and exists(select 1 from public.product_trust_reviews where job_id=j.id and state in ('pending','approved') and expires_at>clock_timestamp()) then
  return jsonb_build_object('status','review_required','barcode',r.barcode,'job_id',j.id,
   'review_expires_at',(select expires_at from public.product_trust_reviews where job_id=j.id));
 end if;
 return jsonb_build_object('status',case when j.state='needs_retake' then 'needs_retake'
   when j.state in ('failed','cancelled') then 'analysis_failed' else 'processing' end,
   'barcode',r.barcode,'job_id',j.id,'retake_target',j.retake_target,'retake_details',j.retake_details,'error',j.error_code,
   'stage',case when exists(select 1 from public.analysis_candidates where job_id=j.id) then 'validation_pending'
    when exists(select 1 from public.ai_usage where job_id=j.id and
      (state='unknown' or (state='inflight' and j.lease_expires_at<clock_timestamp()))) then 'provider_reconciliation_required' else null end);
end; $$;

create function public.pickwell_publication_gate(p_user uuid,p_key uuid) returns jsonb
 language plpgsql set search_path='' as $$
declare q public.analysis_requests; c public.analysis_candidates; r public.usage_reservations; v public.product_trust_reviews; d text; result jsonb; until_time timestamptz;
begin
 perform pg_advisory_xact_lock(725021003);
 perform public.pickwell_require_identity(p_user,true);
 perform public.pickwell_prune_analysis();
 select * into strict q from public.analysis_requests where user_id=p_user and idempotency_key=p_key;
 select to_jsonb(p) into result from public.published_products p where barcode=q.barcode;
 if result is not null then return public.pickwell_analysis_reply(p_user,p_key); end if;
 select * into r from public.usage_reservations where id=q.reservation_id;
 if not found or r.state<>'reserved' then return public.pickwell_analysis_reply(p_user,p_key); end if;
 select c1.* into c from public.analysis_candidates c1 join public.analysis_jobs j on j.id=c1.job_id
  where c1.job_id=q.job_id and j.user_id=p_user and j.state='processing' and c1.expires_at>clock_timestamp();
 if not found then return public.pickwell_analysis_reply(p_user,p_key); end if;
 if c.candidate#>>'{validation,provenance,trust_policy_version}' is distinct from 'trust-publication-v1' then
  perform public.pickwell_finish_usage(r.id,'failed');
  update public.analysis_jobs set error_code='review_policy_changed' where id=q.job_id;
  return public.pickwell_analysis_reply(p_user,p_key);
 end if;
 d:=encode(sha256(convert_to(c.candidate::text,'UTF8')),'hex');
 select * into v from public.product_trust_reviews where job_id=q.job_id;
 if not found then
  until_time:=least(c.expires_at,clock_timestamp()+interval '30 minutes');
  insert into public.product_trust_reviews(job_id,barcode,input_digest,candidate_digest,policy_version,expires_at)
   values(q.job_id,q.barcode,q.input_digest,d,'trust-publication-v1',until_time) returning * into v;
  update public.analysis_candidates set expires_at=until_time where job_id=q.job_id;
  update public.usage_reservations set lease_expires_at=until_time where id=r.id;
  update public.analysis_jobs set lease_expires_at=until_time where id=q.job_id;
 end if;
 if (v.barcode,v.input_digest,v.candidate_digest,v.policy_version) is distinct from
    (q.barcode,q.input_digest,d,'trust-publication-v1'::text) then
  raise exception 'Review evidence mismatch' using errcode='23514'; end if;
 if v.state='approved' and v.expires_at>clock_timestamp() then
  return jsonb_build_object('status','approved','review_id',v.id,'barcode',v.barcode,'input_digest',v.input_digest,
   'candidate_digest',v.candidate_digest,'policy_version',v.policy_version);
 end if;
 return public.pickwell_analysis_reply(p_user,p_key);
end; $$;

-- Operator-only inspection: no photos, contributor email, JWTs or credentials.
create function public.pickwell_inspect_product_review(p_review uuid default null) returns jsonb
 language plpgsql set search_path='' as $$
declare result jsonb;
begin
 perform public.pickwell_prune_analysis();
 if p_review is null then
  select coalesce(jsonb_agg(jsonb_build_object('review_id',id,'barcode',barcode,'state',state,'expires_at',expires_at)),'[]'::jsonb)
   into result from (select * from public.product_trust_reviews where state='pending' order by created_at limit 100) v;
 else
  select jsonb_build_object('review_id',v.id,'barcode',v.barcode,'input_digest',v.input_digest,'candidate_digest',v.candidate_digest,
   'policy_version',v.policy_version,'state',v.state,'expires_at',v.expires_at,'candidate',c.candidate)
   into result from public.product_trust_reviews v left join public.analysis_candidates c on c.job_id=v.job_id where v.id=p_review;
 end if;
 return result;
end; $$;

create function public.pickwell_decide_product_review(p_review uuid,p_barcode text,p_input_digest text,p_candidate_digest text,
 p_policy_version text,p_decision text,p_review_ref text,p_review_basis text,p_resolution text) returns jsonb
 language plpgsql set search_path='' as $$
declare v public.product_trust_reviews; q public.analysis_requests; c public.analysis_candidates; job public.analysis_jobs;
begin
 perform pg_advisory_xact_lock(725021003);
 perform public.pickwell_prune_analysis();
 select * into strict v from public.product_trust_reviews where id=p_review for update;
 if (v.barcode,v.input_digest,v.candidate_digest,v.policy_version) is distinct from
  (public.pickwell_normalize_barcode(p_barcode),p_input_digest,p_candidate_digest,p_policy_version) then
  raise exception 'Review binding mismatch' using errcode='23514'; end if;
 if p_decision is null or p_decision not in ('approve','reject') or p_review_ref is null
  or p_review_ref !~ '^[A-Za-z0-9][A-Za-z0-9._-]{7,99}$'
  or p_review_basis is null or p_review_basis not in ('package_barcode_evidence','trusted_product_reference','controlled_demo_evidence')
  or p_resolution is null or p_resolution not in ('no_discrepancy','wording_variation_reviewed','conflict_unresolved') then
  raise exception 'Explicit operator decision required' using errcode='22023'; end if;
 if v.state<>'pending' then
  if (p_decision='approve' and v.state in ('approved','published') or p_decision='reject' and v.state='rejected')
   and (v.review_ref,v.review_basis,v.resolution) is not distinct from (p_review_ref,p_review_basis,p_resolution) then
   return jsonb_build_object('status',v.state,'review_id',v.id,'replay',true); end if;
  raise exception 'Review closed' using errcode='23514';
 end if;
 select * into strict c from public.analysis_candidates where job_id=v.job_id and expires_at>clock_timestamp();
 select * into strict job from public.analysis_jobs where id=v.job_id and state='processing';
 select * into strict q from public.analysis_requests where job_id=v.job_id and user_id=job.user_id;
 if v.candidate_digest is distinct from encode(sha256(convert_to(c.candidate::text,'UTF8')),'hex')
  or (v.barcode,v.input_digest) is distinct from (q.barcode,q.input_digest) then
  raise exception 'Current evidence differs' using errcode='23514'; end if;
 if p_decision='approve' and (p_resolution='conflict_unresolved' or
  c.candidate#>>'{validation,provenance,cross_image_consistency}'='review_required' and p_resolution<>'wording_variation_reviewed') then
  raise exception 'Resolve observed discrepancy or reject' using errcode='23514'; end if;
 update public.product_trust_reviews set state=case when p_decision='approve' then 'approved' else 'rejected' end,
  review_ref=p_review_ref,review_basis=p_review_basis,resolution=p_resolution,reviewed_at=clock_timestamp(),
  closed_at=case when p_decision='reject' then clock_timestamp() else null end where id=v.id;
 if p_decision='reject' then
  perform public.pickwell_finish_usage(q.reservation_id,'failed');
  update public.analysis_jobs set error_code='review_rejected' where id=v.job_id;
 end if;
 return jsonb_build_object('status',case when p_decision='approve' then 'approved' else 'rejected' end,'review_id',v.id);
end; $$;

create function public.pickwell_cancel_analysis_review(p_user uuid,p_key uuid) returns jsonb
 language plpgsql set search_path='' as $$
declare q public.analysis_requests; v public.product_trust_reviews;
begin
 perform pg_advisory_xact_lock(725021003);
 perform public.pickwell_require_identity(p_user,true);perform public.pickwell_prune_analysis();
 select * into strict q from public.analysis_requests where user_id=p_user and idempotency_key=p_key;
 select * into v from public.product_trust_reviews where job_id=q.job_id;
 if not found then return public.pickwell_analysis_reply(p_user,p_key); end if;
 if v.state='cancelled' then return jsonb_build_object('status','review_cancelled','barcode',q.barcode); end if;
 if v.state not in ('pending','approved') then return public.pickwell_analysis_reply(p_user,p_key); end if;
 update public.product_trust_reviews set state='cancelled',closed_at=clock_timestamp() where id=v.id;
 perform public.pickwell_finish_usage(q.reservation_id,'cancelled');
 return jsonb_build_object('status','review_cancelled','barcode',q.barcode);
end; $$;

create or replace function public.pickwell_finish_usage(p_reservation uuid,p_outcome text,p_product uuid default null,p_analysis uuid default null)
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
   if not exists(select 1 from public.product_trust_reviews v
    join public.analysis_requests q on q.job_id=v.job_id and q.reservation_id=r.id
    join public.analysis_candidates c on c.job_id=v.job_id
    join public.product_analyses x on x.id=p_analysis and x.product_id=p_product
    where v.job_id=r.job_id and v.state='approved' and v.expires_at>clock_timestamp()
     and v.barcode=r.barcode and v.input_digest=q.input_digest
     and v.candidate_digest=encode(sha256(convert_to(c.candidate::text,'UTF8')),'hex')
     and v.policy_version='trust-publication-v1'
     and x.provenance#>>'{barcode_association,review_id}'=v.id::text
     and x.nutrition=c.candidate#>'{validation,nutrition}' and x.ingredients=c.candidate#>'{validation,ingredients}'
     and x.summary=c.candidate#>>'{validation,summary}'
     and x.explanations=c.candidate#>'{validation,explanations}' and x.missing_information=c.candidate#>'{validation,missing_information}'
     and x.model_version=c.model_version and x.prompt_version=c.prompt_version
     and x.rules_version=c.candidate#>>'{validation,provenance,rules_version}'
     and coalesce((select jsonb_agg(jsonb_build_object('severity',f.severity,'title',f.title,'explanation',f.explanation,'source_details',f.source_details,'sort_order',f.sort_order) order by f.sort_order) from public.analysis_findings f where f.analysis_id=x.id),'[]'::jsonb)=c.candidate#>'{validation,findings}'
     and x.provenance-'barcode_association'=c.candidate#>'{validation,provenance}') then
    raise exception 'Bound operator approval required' using errcode='23514'; end if;
   if a.state is distinct from 'succeeded' or j.state<>'processing' or not exists(
    select 1 from public.product_analyses x join public.products p on p.id=x.product_id
    where x.id=p_analysis and p.id=p_product and p.barcode=r.barcode and x.contributor_id=r.user_id
      and x.sealed_at is null and p.status<>'ready') then
    raise exception 'Publication requires validated owned revision and successful provider attempt' using errcode='23514'; end if;
   update public.products set status='ready',current_analysis_id=p_analysis,published_at=clock_timestamp() where id=p_product;
   update public.analysis_jobs set state='ready',result_product_id=p_product,result_analysis_id=p_analysis where id=j.id;
   update public.product_trust_reviews set state='published',closed_at=clock_timestamp() where job_id=r.job_id;
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

create or replace function public.pickwell_publish_analysis(p_user uuid,p_key uuid,p_validated jsonb) returns jsonb
 language plpgsql set search_path='' as $$
declare q public.analysis_requests; c public.analysis_candidates; r public.usage_reservations;
 j public.analysis_jobs; a public.ai_usage; p public.products; revision uuid; fact jsonb; result jsonb; gate jsonb; review public.product_trust_reviews; trusted_provenance jsonb;
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
 gate:=public.pickwell_publication_gate(p_user,p_key);
 if gate->>'status'<>'approved' then return gate; end if;
 select * into strict review from public.product_trust_reviews where id=(gate->>'review_id')::uuid and state='approved';
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
  or p_validated#>>'{provenance,trust_policy_version}' is distinct from 'trust-publication-v1') then
  raise exception 'Unverified, nonconflicting identity observations required' using errcode='23514'; end if;
 trusted_provenance:=(p_validated->'provenance')||jsonb_build_object('barcode_association',jsonb_build_object(
  'status','operator_reviewed','method','operator_evidence_review','policy_version',review.policy_version,
  'review_id',review.id,'review_ref',review.review_ref,'reviewed_at',review.reviewed_at,'review_basis',review.review_basis));
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
  p_validated->'missing_information',trusted_provenance) returning id into revision;
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
  a.provenance||((p_payload->'provenance')-array['identity','identity_verification','identity_policy_version','barcode_association','trust_policy_version','validation_method','ingredient_evidence_method','cross_image_consistency','identity_review_photos'])) returning id into revision;
 for fact in select value from jsonb_array_elements(existing_findings) loop
  insert into public.analysis_findings(analysis_id,severity,title,explanation,source_details,sort_order)
  values(revision,(fact->>'severity')::public.finding_severity,fact->>'title',fact->>'explanation',fact->'source_details',(fact->>'sort_order')::integer);
 end loop;
 update public.products set current_analysis_id=revision where id=p.id;
 return jsonb_build_object('status','refreshed','analysis_id',revision,'previous_analysis_id',a.id);
end; $$;

-- No ordinary client/model can inspect, approve, cancel or publish via SQL.
revoke all on function public.pickwell_review_immutable(),public.pickwell_publication_gate(uuid,uuid),
 public.pickwell_inspect_product_review(uuid),
 public.pickwell_decide_product_review(uuid,text,text,text,text,text,text,text,text),
 public.pickwell_cancel_analysis_review(uuid,uuid),public.pickwell_valid_ingredients(jsonb),
 public.pickwell_prune_analysis(),public.pickwell_analysis_reply(uuid,uuid),
 public.pickwell_finish_usage(uuid,text,uuid,uuid),public.pickwell_publish_analysis(uuid,uuid,jsonb),
 public.pickwell_refresh_interpretation(uuid,uuid,text,jsonb) from public,anon,authenticated;
grant execute on function public.pickwell_review_immutable(),public.pickwell_publication_gate(uuid,uuid),
 public.pickwell_inspect_product_review(uuid),
 public.pickwell_decide_product_review(uuid,text,text,text,text,text,text,text,text),
 public.pickwell_cancel_analysis_review(uuid,uuid),public.pickwell_valid_ingredients(jsonb),
 public.pickwell_prune_analysis(),public.pickwell_analysis_reply(uuid,uuid),
 public.pickwell_finish_usage(uuid,text,uuid,uuid),public.pickwell_publish_analysis(uuid,uuid,jsonb),
 public.pickwell_refresh_interpretation(uuid,uuid,text,jsonb) to service_role;
comment on table public.product_trust_reviews is 'Bounded private operator decisions, not independent verification. No images/PII. Pending evidence expires in 30 minutes; published bindings survive as minimal provenance.';
commit;
