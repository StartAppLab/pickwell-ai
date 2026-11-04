-- T07.1C.3: private validated results are charged once; shared publication remains reviewed.
-- No live quota values, billing, inference flags or deployment are changed.
begin;
alter table public.analysis_jobs add column private_result_ready boolean not null default false;
drop index public.analysis_jobs_active_barcode_idx;
create unique index analysis_jobs_active_barcode_idx on public.analysis_jobs(barcode)
 where state in ('queued','processing') and not private_result_ready;
create table public.private_analysis_results (
 job_id uuid primary key references public.analysis_jobs(id) on delete cascade,
 user_id uuid not null references auth.users(id) on delete cascade,
 payload jsonb not null check(jsonb_typeof(payload)='object' and octet_length(payload::text)<=65536),
 created_at timestamptz not null default now(),
 expires_at timestamptz not null default now()+interval '24 hours',
 check(expires_at>created_at and expires_at<=created_at+interval '24 hours')
);
alter table public.private_analysis_results enable row level security;
revoke all on public.private_analysis_results from public,anon,authenticated;
grant select,insert,delete on public.private_analysis_results to service_role;
create function public.pickwell_private_result_immutable() returns trigger language plpgsql set search_path='' as $$begin
 raise exception 'Private result is immutable' using errcode='23514';end;$$;
create trigger pickwell_private_result_immutable before update on public.private_analysis_results for each row execute function public.pickwell_private_result_immutable();
create function public.pickwell_private_flag() returns trigger language plpgsql set search_path='' as $$begin
 if tg_op='UPDATE' and old.private_result_ready and not new.private_result_ready then raise exception 'Private delivery cannot be reversed' using errcode='23514';end if;
 if new.private_result_ready and (tg_op='INSERT' or not old.private_result_ready) and not exists(
  select 1 from public.private_analysis_results p join public.usage_reservations r on r.job_id=p.job_id
  where p.job_id=new.id and p.user_id=new.user_id and r.state='consumed' and r.outcome='private_ready') then
  raise exception 'Atomic charged private result required' using errcode='23514';end if;return new;end;$$;
create trigger pickwell_private_flag before insert or update on public.analysis_jobs for each row execute function public.pickwell_private_flag();
create or replace function public.pickwell_reserve_usage(p_user uuid,p_metric text,p_key uuid,p_barcode text,p_job uuid default null)
 returns jsonb language plpgsql set search_path='' as $$
declare d date:=public.pickwell_utc_day(clock_timestamp()); l public.plan_limits;
 u public.usage_daily; r public.usage_reservations; j public.analysis_jobs; c public.quota_controls;
 code text:=public.pickwell_normalize_barcode(p_barcode); v_job uuid;
begin
 perform pg_advisory_xact_lock(725021003);
 if p_key is null or p_metric not in ('barcode_lookup','ai_analysis') or p_metric is null or code is null then
  raise exception 'Invalid quota request' using errcode='22023'; end if;
 perform public.pickwell_require_identity(p_user,p_metric='ai_analysis');
 perform public.pickwell_reconcile_expired();
 select * into r from public.usage_reservations where user_id=p_user and metric=p_metric and idempotency_key=p_key;
 if found then
  if r.barcode is distinct from code or (p_job is not null and r.job_id is distinct from p_job) then
   raise exception 'Idempotency request mismatch' using errcode='22023'; end if;
  return jsonb_build_object('status',r.state,'reservation_id',r.id,'job_id',r.job_id,'replay',true,'outcome',r.outcome);
 end if;
 select * into strict c from public.quota_controls where id;
 if p_metric='ai_analysis' then
  if exists(select 1 from public.published_products where barcode=code) then
   return jsonb_build_object('status','cache_hit'); end if;
  if exists(select 1 from public.ai_usage where barcode=code and state in ('inflight','unknown')) or
     exists(select 1 from public.analysis_jobs where barcode=code and state in ('queued','processing') and not private_result_ready) then
   return jsonb_build_object('status','processing'); end if;
  if p_job is not null then
   select * into j from public.analysis_jobs where id=p_job and user_id=p_user and barcode=code;
   if not found or j.state not in ('failed','needs_retake') or j.attempts>=c.job_attempts then
    return jsonb_build_object('status','retry_denied'); end if;
   if exists(select 1 from public.ai_usage where job_id=p_job and state in ('inflight','unknown')) then
    return jsonb_build_object('status','reconciliation_required'); end if;
  end if;
 elsif p_job is not null then raise exception 'Lookup has no job' using errcode='22023';
 end if;
 select * into strict l from public.plan_limits where plan_code='free' and metric=p_metric and effective_at<=clock_timestamp();
 insert into public.usage_daily(user_id,day_utc,metric) values(p_user,d,p_metric) on conflict do nothing;
 select * into strict u from public.usage_daily where user_id=p_user and day_utc=d and metric=p_metric for update;
 if u.used+u.reserved>=l.daily_limit then return public.pickwell_quota_snapshot(p_user,p_metric)||jsonb_build_object('status','quota_exceeded'); end if;
 if p_metric='ai_analysis' then
  if p_job is null then
   insert into public.analysis_jobs(barcode,user_id,idempotency_key) values(code,p_user,p_key) returning id into v_job;
  else
   update public.analysis_jobs set state='queued',error_code=null where id=p_job;
   v_job:=p_job;
  end if;
 end if;
 insert into public.usage_reservations(user_id,day_utc,metric,idempotency_key,job_id,barcode,config_version,lease_expires_at)
 values(p_user,d,p_metric,p_key,v_job,code,l.version,clock_timestamp()+interval '5 minutes') returning * into r;
 update public.usage_daily set reserved=reserved+1 where user_id=p_user and day_utc=d and metric=p_metric;
 return public.pickwell_quota_snapshot(p_user,p_metric)||jsonb_build_object('status','reserved','reservation_id',r.id,'job_id',v_job,'replay',false);
end; $$;

create or replace function public.pickwell_admit_analysis(p_user uuid,p_key uuid,p_barcode text,p_digest text)
 returns jsonb language plpgsql set search_path='' as $$
declare code text:=public.pickwell_normalize_barcode(p_barcode); q public.analysis_requests; r jsonb; result jsonb;
begin
 perform pg_advisory_xact_lock(725021003);
 perform public.pickwell_require_identity(p_user,true);
 if code is null or p_key is null or p_digest is null or p_digest !~ '^[0-9a-f]{64}$' then
  raise exception 'Invalid request' using errcode='22023'; end if;
 perform public.pickwell_prune_analysis();
 select * into q from public.analysis_requests where user_id=p_user and idempotency_key=p_key;
 if found then
  if q.barcode is distinct from code or q.input_digest is distinct from p_digest then
   raise exception 'Idempotency mismatch' using errcode='22023'; end if;
  if q.reservation_id is not null and exists(select 1 from public.usage_reservations where id=q.reservation_id and state='reserved')
     and exists(select 1 from public.analysis_jobs where id=q.job_id and state='queued') then
   return jsonb_build_object('status','reserved','reservation_id',q.reservation_id,'job_id',q.job_id,'barcode',code,'replay',true);
  end if;
  -- A contender's image-bound key waits without borrowing another owner's result.
  -- Once inference is finished, the same key can acquire its own reservation.
  if q.job_id is null and q.reservation_id is null and not exists(select 1 from public.published_products where barcode=code) then
   if not(select inference_enabled from public.quota_controls where id) then return jsonb_build_object('status','inference_disabled');end if;
   r:=public.pickwell_reserve_usage(p_user,'ai_analysis',p_key,code);
   if r->>'status'='reserved' then
    update public.analysis_requests set reservation_id=(r->>'reservation_id')::uuid,job_id=(r->>'job_id')::uuid where user_id=p_user and idempotency_key=p_key;
   end if;
   return r||jsonb_build_object('barcode',code);
  end if;
  return public.pickwell_analysis_reply(p_user,p_key);
 end if;
 select to_jsonb(v) into result from public.published_products v where barcode=code;
 if result is not null then
  insert into public.analysis_requests(user_id,idempotency_key,barcode,input_digest) values(p_user,p_key,code,p_digest);
  return jsonb_build_object('status','already_exists','barcode',code,'product',result);
 end if;
 -- No failed/queued jobs or user reservations are created while inference is off.
 if not (select inference_enabled from public.quota_controls where id) then
  return jsonb_build_object('status','inference_disabled'); end if;
 r:=public.pickwell_reserve_usage(p_user,'ai_analysis',p_key,code);
 if r->>'status'='processing' then
  insert into public.analysis_requests(user_id,idempotency_key,barcode,input_digest) values(p_user,p_key,code,p_digest);
  return jsonb_build_object('status','processing','barcode',code);
 end if;
 if r->>'status'='cache_hit' then raise exception 'Unexpected cache state'; end if;
 if r->>'status' in ('reserved','released','consumed','expired') then
  insert into public.analysis_requests(user_id,idempotency_key,barcode,input_digest,reservation_id,job_id)
   values(p_user,p_key,code,p_digest,(r->>'reservation_id')::uuid,(r->>'job_id')::uuid);
  if r->>'status'<>'reserved' then return public.pickwell_analysis_reply(p_user,p_key); end if;
 end if;
 return r||jsonb_build_object('barcode',code);
end; $$;

create or replace function public.pickwell_analysis_reply(p_user uuid,p_key uuid) returns jsonb
 language plpgsql set search_path='' as $$
declare r public.analysis_requests; j public.analysis_jobs; result jsonb; private public.private_analysis_results; review_state text;
begin
 perform public.pickwell_require_identity(p_user,true);
 select * into strict r from public.analysis_requests where user_id=p_user and idempotency_key=p_key;
 select to_jsonb(v) into result from public.published_products v where barcode=r.barcode;
 select * into private from public.private_analysis_results where job_id=r.job_id and user_id=p_user and expires_at>clock_timestamp();
 if found then
  select case when state in ('pending','approved') and expires_at<=clock_timestamp() then 'expired' else state end into review_state from public.product_trust_reviews where job_id=r.job_id;
  return jsonb_build_object('status','private_ready','barcode',r.barcode,'job_id',r.job_id,'request_id',r.idempotency_key,
   'product',private.payload,'private_expires_at',private.expires_at,'publication_status',coalesce(review_state,'unavailable'),'canonical_product',result);
 end if;
 if result is not null then return jsonb_build_object('status','already_exists','barcode',r.barcode,'product',result); end if;
 if exists(select 1 from public.analysis_jobs where id=r.job_id and user_id=p_user and private_result_ready) then
  return jsonb_build_object('status','private_expired','barcode',r.barcode,'job_id',r.job_id);end if;
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
 for row in select c.job_id from public.analysis_candidates c join public.usage_reservations r on r.job_id=c.job_id
  join public.analysis_jobs j on j.id=c.job_id
  where r.state='consumed' and r.outcome='private_ready' and j.state='processing' and c.expires_at<clock_timestamp() loop
  update public.product_trust_reviews set state='expired',closed_at=clock_timestamp() where job_id=row.job_id and state in ('pending','approved');
  update public.analysis_jobs set state='failed',error_code='review_expired' where id=row.job_id;
  n:=n+1;
 end loop;
 delete from public.private_analysis_results where expires_at<=clock_timestamp();
 delete from public.analysis_candidates where expires_at<clock_timestamp();
 delete from public.analysis_requests q where created_at<clock_timestamp()-interval '30 days'
  and not exists(select 1 from public.analysis_jobs j where j.id=q.job_id and j.state in ('queued','processing'))
  and not exists(select 1 from public.usage_reservations r where r.id=q.reservation_id and r.state='reserved');
 delete from public.product_trust_reviews where state in ('rejected','cancelled','expired') and coalesce(closed_at,created_at)<clock_timestamp()-interval '30 days';
 return n;
end; $$;

create or replace function public.pickwell_read_analysis_candidate(p_user uuid,p_key uuid) returns jsonb
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
 where c.job_id=q.job_id and j.user_id=p_user and j.state='processing' and (r.state='reserved' or r.state='consumed' and r.outcome='private_ready')
 and c.expires_at>clock_timestamp();
 return result;
end; $$;

create or replace function public.pickwell_publication_gate(p_user uuid,p_key uuid) returns jsonb
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
 if not found or not(r.state='reserved' or r.state='consumed' and r.outcome='private_ready') then return public.pickwell_analysis_reply(p_user,p_key); end if;
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

create or replace function public.pickwell_finish_usage(p_reservation uuid,p_outcome text,p_product uuid default null,p_analysis uuid default null)
 returns jsonb language plpgsql set search_path='' as $$
declare r public.usage_reservations; j public.analysis_jobs; a public.ai_usage; v_charge boolean:=false; v_target text; precharged boolean:=false;
begin
 perform pg_advisory_xact_lock(725021003);
 select * into strict r from public.usage_reservations where id=p_reservation for update;
 precharged:=r.state='consumed' and r.outcome='private_ready';
 if r.state<>'reserved' and not precharged then
  if r.outcome is distinct from p_outcome then raise exception 'Finalization mismatch' using errcode='23514'; end if;
  return jsonb_build_object('status',r.state,'replay',true);
 end if;
 if precharged and p_outcome<>'published' then
  if p_outcome is null or p_outcome not in ('cache_hit','failed','retake','cancelled') then raise exception 'Invalid private settlement' using errcode='22023';end if;
  select * into strict j from public.analysis_jobs where id=r.job_id and private_result_ready;
  if j.state='processing' then
   if p_outcome='retake' then update public.analysis_jobs set state='needs_retake',retake_target='both',error_code='label_retake' where id=j.id;
   else update public.analysis_jobs set state=case when p_outcome in ('cache_hit','cancelled') then 'cancelled'::public.analysis_job_state else 'failed'::public.analysis_job_state end,error_code='analysis_failed' where id=j.id;end if;
  end if;
  return jsonb_build_object('status','consumed','private_credit_preserved',true);
 end if;
 if precharged and exists(select 1 from public.analysis_jobs where id=r.job_id and state='ready' and result_product_id=p_product and result_analysis_id=p_analysis) then
  return jsonb_build_object('status','consumed','replay',true);end if;
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
 if precharged then return jsonb_build_object('status','consumed','already_charged_privately',true);end if;
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
 if not(r.state='reserved' or r.state='consumed' and r.outcome='private_ready') then return public.pickwell_analysis_reply(p_user,p_key); end if;
 select * into strict j from public.analysis_jobs where id=q.job_id and user_id=p_user;
 if j.state='ready' and r.state='consumed' and r.outcome='private_ready' then return public.pickwell_analysis_reply(p_user,p_key);end if;
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
  or c.prompt_version='label-analysis-v3' and p_validated#>>'{provenance,trust_policy_version}' is distinct from 'trust-publication-v1') then
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

create or replace function public.pickwell_cancel_analysis_review(p_user uuid,p_key uuid) returns jsonb
 language plpgsql set search_path='' as $$
declare q public.analysis_requests; v public.product_trust_reviews;
begin
 perform pg_advisory_xact_lock(725021003);
 perform public.pickwell_require_identity(p_user,true);perform public.pickwell_prune_analysis();
 select * into strict q from public.analysis_requests where user_id=p_user and idempotency_key=p_key;
 select * into v from public.product_trust_reviews where job_id=q.job_id;
 if not found then return public.pickwell_analysis_reply(p_user,p_key); end if;
 if v.state='cancelled' then if exists(select 1 from public.private_analysis_results where job_id=q.job_id and user_id=p_user and expires_at>clock_timestamp()) then return public.pickwell_analysis_reply(p_user,p_key);end if;return jsonb_build_object('status','review_cancelled','barcode',q.barcode); end if;
 if v.state not in ('pending','approved') then return public.pickwell_analysis_reply(p_user,p_key); end if;
 update public.product_trust_reviews set state='cancelled',closed_at=clock_timestamp() where id=v.id;
 perform public.pickwell_finish_usage(q.reservation_id,'cancelled');
 if exists(select 1 from public.private_analysis_results where job_id=q.job_id and user_id=p_user and expires_at>clock_timestamp()) then return public.pickwell_analysis_reply(p_user,p_key);end if;
 return jsonb_build_object('status','review_cancelled','barcode',q.barcode);
end; $$;


create function public.pickwell_private_analysis(p_user uuid,p_job uuid) returns jsonb language plpgsql set search_path='' as $$
declare j public.analysis_jobs;
begin
 perform public.pickwell_require_identity(p_user,true);perform public.pickwell_prune_analysis();
 select * into j from public.analysis_jobs where id=p_job and user_id=p_user;
 if not found then return jsonb_build_object('status','not_found');end if;
 return public.pickwell_analysis_reply(p_user,j.idempotency_key);
end;$$;
create function public.pickwell_deliver_private_analysis(p_user uuid,p_key uuid,p_validated jsonb) returns jsonb
 language plpgsql set search_path='' as $$
declare q public.analysis_requests;r public.usage_reservations;j public.analysis_jobs;c public.analysis_candidates;a public.ai_usage; payload jsonb;
begin
 perform pg_advisory_xact_lock(725021003);perform public.pickwell_require_identity(p_user,true);
 select * into strict q from public.analysis_requests where user_id=p_user and idempotency_key=p_key;
 select * into strict r from public.usage_reservations where id=q.reservation_id;
 if r.state='consumed' and r.outcome='private_ready' then return public.pickwell_analysis_reply(p_user,p_key);end if;
 if r.state<>'reserved' then return public.pickwell_analysis_reply(p_user,p_key);end if;
 select * into strict j from public.analysis_jobs where id=q.job_id and user_id=p_user and state='processing';
 select * into strict c from public.analysis_candidates where job_id=j.id and expires_at>clock_timestamp();
 select * into strict a from public.ai_usage where reservation_id=r.id and state='succeeded';
 if (p_validated->>'schema_version')::integer is distinct from 2
  or jsonb_typeof(p_validated->'findings') is distinct from 'array'
  or jsonb_typeof(p_validated->'explanations') is distinct from 'array'
  or jsonb_typeof(p_validated->'missing_information') is distinct from 'array'
  or p_validated is distinct from c.candidate->'validation' or p_validated->>'status' is distinct from 'validated'
  or p_validated->'nutrition' is distinct from c.candidate->'nutrition' or p_validated->'ingredients' is distinct from c.candidate->'ingredients'
  or p_validated#>>'{provenance,model_version}' is distinct from a.model or c.model_version is distinct from a.model
  or p_validated#>>'{provenance,prompt_version}' is distinct from c.prompt_version
  or c.prompt_version='label-analysis-v3' and p_validated#>>'{provenance,trust_policy_version}' is distinct from 'trust-publication-v1'
  or p_validated#>>'{provenance,rules_version}' is distinct from 'uk-fop-2016-conservative-v1'
  or c.prompt_version not in ('label-analysis-v2','label-analysis-v3') then
  raise exception 'Validated exact owned candidate required' using errcode='23514';end if;
 payload:=jsonb_build_object('id',j.id,'barcode',q.barcode,'name',p_validated#>>'{provenance,identity,front,product_name}',
  'brand',p_validated#>>'{provenance,identity,front,brand}','is_demo',false,'schema_version',p_validated->'schema_version',
  'summary',p_validated->'summary','nutrition',p_validated->'nutrition','ingredients',p_validated->'ingredients',
  'findings',p_validated->'findings','explanations',p_validated->'explanations','missing_information',p_validated->'missing_information',
  'model_version',c.model_version,'rules_version',p_validated#>>'{provenance,rules_version}',
  'analyzed_at',p_validated#>>'{provenance,validated_at}','provenance',(p_validated->'provenance')-'barcode_association');
 insert into public.private_analysis_results(job_id,user_id,payload) values(j.id,p_user,payload);
 update public.usage_daily set used=used+1,reserved=reserved-1 where user_id=r.user_id and day_utc=r.day_utc and metric='ai_analysis';
 if not found then raise exception 'Missing reservation counter';end if;
 update public.usage_reservations set state='consumed',outcome='private_ready' where id=r.id;
 update public.analysis_jobs set private_result_ready=true where id=j.id;
 perform public.pickwell_publication_gate(p_user,p_key);
 return public.pickwell_analysis_reply(p_user,p_key);
end;$$;

revoke all on function public.pickwell_private_result_immutable(),public.pickwell_private_flag(),
 public.pickwell_private_analysis(uuid,uuid),public.pickwell_deliver_private_analysis(uuid,uuid,jsonb) from public,anon,authenticated;
grant execute on function public.pickwell_private_analysis(uuid,uuid),public.pickwell_deliver_private_analysis(uuid,uuid,jsonb) to service_role;
comment on table public.private_analysis_results is 'Owner-only validated preliminary result, max 24h, no images. Atomic successful private delivery consumes one allowance; publication never double charges.';
create or replace function public.pickwell_reservation_event() returns trigger language plpgsql set search_path='' as $$
declare v_event text;
begin
 if tg_op='INSERT' then
  if new.metric='barcode_lookup' then perform public.pickwell_try_event('barcode_scanned',new.id,new.metric); end if;
 elsif new.state is distinct from old.state and new.state in ('consumed','released') then
  v_event:=case
   when new.metric='barcode_lookup' and new.outcome='ready' then 'product_cache_hit'
   when new.metric='barcode_lookup' and new.outcome='not_found' then 'product_not_found'
   when new.metric='ai_analysis' and new.outcome in ('published','private_ready') then 'analysis_completed'
   when new.metric='ai_analysis' and new.outcome='cache_hit' then 'product_cache_hit'
   when new.metric='ai_analysis' and new.outcome='failed' then 'analysis_failed'
   when new.metric='ai_analysis' and new.outcome='retake' then 'analysis_retake_required' end;
  if v_event is not null then perform public.pickwell_try_event(v_event,new.id,new.metric); end if;
 end if;
 return new;
exception when others or query_canceled then return new;
end; $$;

-- A private review is not a shared cache hit or active inference. Guest capture stays available.
create or replace function public.pickwell_get_product(p_user uuid,p_key uuid,p_barcode text)
 returns jsonb language plpgsql set search_path='' as $$
declare code text:=public.pickwell_normalize_barcode(p_barcode); admission jsonb;
 receipt public.lookup_receipts; product jsonb; v_status text; rid uuid;
begin
 perform pg_advisory_xact_lock(725021003);
 if code is null or p_key is null then raise exception 'Invalid lookup' using errcode='22023'; end if;
 -- Receipts are ephemeral references, not copies of label data or credentials.
 delete from public.lookup_receipts where expires_at<=clock_timestamp();
 if p_user is not null then
  admission:=public.pickwell_reserve_usage(p_user,'barcode_lookup',p_key,code);
  if admission->>'status'='quota_exceeded' then return admission; end if;
  rid:=(admission->>'reservation_id')::uuid;
  if admission->>'replay'='true' then
   select * into receipt from public.lookup_receipts where reservation_id=rid;
   if not found then return jsonb_build_object('status','retry_expired'); end if;
   v_status:=receipt.status;
   if v_status='ready' then
    select to_jsonb(p) into product from public.published_products p where p.id=receipt.product_id and p.analysis_id=receipt.analysis_id;
    if product is null then return jsonb_build_object('status','retry_expired'); end if;
   end if;
   return jsonb_build_object('status',v_status,'barcode',code,'product',product,'replay',true,
    'quota',public.pickwell_quota_snapshot(p_user,'barcode_lookup'));
  end if;
  if admission->>'status'<>'reserved' then return jsonb_build_object('status','retry_expired'); end if;
 end if;
 select to_jsonb(p) into product from public.published_products p where p.barcode=code;
 v_status:=case when product is not null then 'ready'
  when exists(select 1 from public.products where barcode=code and status='processing')
    or exists(select 1 from public.analysis_jobs where barcode=code and state in ('queued','processing') and not private_result_ready)
    or exists(select 1 from public.ai_usage where barcode=code and state in ('inflight','unknown')) then 'processing'
  else 'not_found' end;
 if p_user is not null then
  insert into public.lookup_receipts(reservation_id,status,product_id,analysis_id)
  values(rid,v_status,(product->>'id')::uuid,(product->>'analysis_id')::uuid);
  perform public.pickwell_finish_usage(rid,v_status);
 end if;
 return jsonb_build_object('status',v_status,'barcode',code,'product',product,'replay',false,
  'quota',case when p_user is null then null else public.pickwell_quota_snapshot(p_user,'barcode_lookup') end);
end; $$;

commit;
