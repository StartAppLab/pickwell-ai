-- T05.1: image-bound request identities and a private handoff to T05.2/T05.3.
-- Never store original photos, data URLs, private tokens or unvalidated public facts.
create table public.analysis_requests (
 user_id uuid not null references auth.users(id) on delete cascade,
 idempotency_key uuid not null,
 barcode text not null check(barcode=public.pickwell_normalize_barcode(barcode)),
 input_digest text not null check(input_digest ~ '^[0-9a-f]{64}$'),
 reservation_id uuid references public.usage_reservations(id) on delete set null,
 job_id uuid references public.analysis_jobs(id) on delete set null,
 created_at timestamptz not null default clock_timestamp(),
 primary key(user_id,idempotency_key)
);
create table public.analysis_candidates (
 job_id uuid primary key references public.analysis_jobs(id) on delete cascade,
 candidate jsonb not null check(coalesce(octet_length(candidate::text)<=65536
   and candidate->>'status'='extracted' and public.pickwell_valid_nutrition(candidate->'nutrition')
   and public.pickwell_valid_ingredients(candidate->'ingredients'),false)),
 model_version text not null check(length(model_version) between 1 and 100),
 prompt_version text not null check(length(prompt_version) between 1 and 100),
 created_at timestamptz not null default clock_timestamp(),
 expires_at timestamptz not null default (clock_timestamp()+interval '24 hours')
);
alter table public.analysis_requests enable row level security;
alter table public.analysis_candidates enable row level security;
revoke all on public.analysis_requests,public.analysis_candidates from public,anon,authenticated;
grant select,insert,update,delete on public.analysis_requests,public.analysis_candidates to service_role;

-- Shared outcomes expose only an owner's job ID. Cross-user barcode contenders
-- receive processing without any other user's job/submission/candidate identity.
create function public.pickwell_analysis_reply(p_user uuid,p_key uuid) returns jsonb
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
   'barcode',r.barcode,'job_id',j.id,'retake_target',j.retake_target,'error',j.error_code,
   'stage',case when exists(select 1 from public.analysis_candidates where job_id=j.id) then 'validation_pending'
    when exists(select 1 from public.ai_usage where job_id=j.id and
      (state='unknown' or (state='inflight' and j.lease_expires_at<clock_timestamp()))) then 'provider_reconciliation_required' else null end);
end; $$;

create function public.pickwell_prune_analysis() returns integer language plpgsql set search_path='' as $$
declare row record; n integer:=0;
begin
 perform pg_advisory_xact_lock(725021003);
 for row in select c.job_id,r.id as reservation_id from public.analysis_candidates c
   join public.usage_reservations r on r.job_id=c.job_id and r.state='reserved'
   join public.ai_usage a on a.reservation_id=r.id and a.state='succeeded'
   where c.expires_at<clock_timestamp() loop
  perform public.pickwell_finish_usage(row.reservation_id,'failed');
  update public.analysis_jobs set error_code='candidate_expired' where id=row.job_id;
  n:=n+1;
 end loop;
 delete from public.analysis_candidates where expires_at<clock_timestamp();
 delete from public.analysis_requests q where created_at<clock_timestamp()-interval '30 days'
  and not exists(select 1 from public.analysis_jobs j where j.id=q.job_id and j.state in ('queued','processing'))
  and not exists(select 1 from public.usage_reservations r where r.id=q.reservation_id and r.state='reserved');
 return n;
end; $$;

create function public.pickwell_admit_analysis(p_user uuid,p_key uuid,p_barcode text,p_digest text)
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

create function public.pickwell_stage_analysis(p_user uuid,p_key uuid,p_candidate jsonb,p_model text,p_prompt text)
 returns jsonb language plpgsql set search_path='' as $$
declare q public.analysis_requests; a public.ai_usage; j public.analysis_jobs;
begin
 perform pg_advisory_xact_lock(725021003);
 perform public.pickwell_require_identity(p_user,true);
 select * into strict q from public.analysis_requests where user_id=p_user and idempotency_key=p_key;
 select * into strict j from public.analysis_jobs where id=q.job_id and user_id=p_user;
 select * into strict a from public.ai_usage where reservation_id=q.reservation_id;
 if a.state<>'succeeded' or a.model is distinct from p_model or j.state<>'processing' then
  raise exception 'Completed owned provider attempt required' using errcode='23514'; end if;
 if exists(select 1 from public.analysis_candidates where job_id=j.id and
  (candidate is distinct from p_candidate or model_version is distinct from p_model or prompt_version is distinct from p_prompt)) then
  raise exception 'Candidate is immutable' using errcode='23514'; end if;
 insert into public.analysis_candidates(job_id,candidate,model_version,prompt_version) values(j.id,p_candidate,p_model,p_prompt)
  on conflict(job_id) do nothing;
 return public.pickwell_analysis_reply(p_user,p_key);
end; $$;

create function public.pickwell_settle_analysis(p_user uuid,p_key uuid,p_outcome text,p_error text default null,p_retake text default null)
 returns jsonb language plpgsql set search_path='' as $$
declare q public.analysis_requests;
begin
 perform pg_advisory_xact_lock(725021003);
 perform public.pickwell_require_identity(p_user,true);
 if p_outcome is null or p_outcome not in ('failed','retake','cancelled','cache_hit')
   or (p_error is not null and p_error not in ('provider_failed','invalid_model_output','service_unavailable','inference_disabled','provider_attempt_limit','retry_denied','service_budget_exceeded','concurrency_limited'))
   or (p_outcome='retake' and (p_retake is null or p_retake not in ('nutrition','ingredients','both'))) then
  raise exception 'Invalid settlement' using errcode='22023'; end if;
 select * into strict q from public.analysis_requests where user_id=p_user and idempotency_key=p_key;
 perform public.pickwell_finish_usage(q.reservation_id,p_outcome);
 if p_outcome='retake' then update public.analysis_jobs set retake_target=p_retake where id=q.job_id;
 elsif p_outcome='failed' then update public.analysis_jobs set error_code=coalesce(p_error,'analysis_failed') where id=q.job_id; end if;
 return public.pickwell_analysis_reply(p_user,p_key);
end; $$;

revoke all on function public.pickwell_analysis_reply(uuid,uuid),public.pickwell_prune_analysis(),
 public.pickwell_admit_analysis(uuid,uuid,text,text),public.pickwell_stage_analysis(uuid,uuid,jsonb,text,text),
 public.pickwell_settle_analysis(uuid,uuid,text,text,text) from public,anon,authenticated;
grant execute on function public.pickwell_analysis_reply(uuid,uuid),public.pickwell_prune_analysis(),
 public.pickwell_admit_analysis(uuid,uuid,text,text),public.pickwell_stage_analysis(uuid,uuid,jsonb,text,text),
 public.pickwell_settle_analysis(uuid,uuid,text,text,text) to service_role;
-- Ops must call prune_analysis alongside prune_telemetry; admission also runs it.
-- No scheduler or live inference is enabled by this migration.
comment on table public.analysis_candidates is 'Private 24h extraction handoff; never published without T05.2 rules and T05.3 atomic publication. No photos.';
