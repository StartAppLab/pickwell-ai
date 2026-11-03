import { requireVerifiedEmail, IdentityError } from './analysis_authorization.mjs';
import { readBoundedJson, sanitizePublishedProduct } from './catalog_boundary.mjs';
import { createQuotaService, networkBucket } from './quota_boundary.mjs';
import { createOperationalEvents } from './operational_events.mjs';
import { readAnalysisInput, AnalysisInputError } from './analysis_input.mjs';
import { analysisProfile, validateAnalysis, PROMPT_VERSION } from './analysis_validation.mjs';
import { invokeMetaLabels, META_URL } from '../../spikes/meta-vision/core.mjs';

const reply=(body,status=200)=>Response.json(body,{status,headers:{'Cache-Control':'no-store','X-Content-Type-Options':'nosniff'}});
const failure=(error,status=503)=>reply({status:'error',error},status);
export function createAnalyzeProductHandler(env,fetcher=fetch){
 return async request=>{
  if(request.method!=='POST')return failure('method_not_allowed',405);
  let user,q,input,bucket;
  try{
   user=await requireVerifiedEmail(request,env,fetcher);
   q=createQuotaService(env,fetcher);
   bucket=await networkBucket(request,{secret:env.PICKWELL_NETWORK_HASH_SECRET,
    trustedHeader:env.PICKWELL_TRUSTED_IP_HEADER||undefined,
    trustedProxyHops:env.PICKWELL_TRUSTED_PROXY_HOPS?Number(env.PICKWELL_TRUSTED_PROXY_HOPS):undefined});
   if((await q.throttle(bucket,user)).allowed!==true)return reply({status:'rate_limited',error:'rate_limited'},429);
   input=await readAnalysisInput(request);
  }catch(error){
   if(error instanceof IdentityError)return failure(error.message,error.status);
   if(error instanceof AnalysisInputError)return failure(error.message,error.message==='input_timeout'?408:400);
   return failure('service_unavailable');
  }
  const origin=new URL(env.SUPABASE_URL).origin;
  async function rpc(name,body){
   const r=await fetcher(origin+'/rest/v1/rpc/'+name,{method:'POST',
    headers:{apikey:env.SUPABASE_SERVICE_ROLE_KEY,Authorization:`Bearer ${env.SUPABASE_SERVICE_ROLE_KEY}`,'content-type':'application/json'},
    body:JSON.stringify(body),redirect:'error',signal:AbortSignal.timeout(5000)});
   if(!r.ok){if(name==='pickwell_admit_analysis'&&r.status===400)throw new Error('idempotency_conflict');throw new Error('service_unavailable');}
   return readBoundedJson(r.body,131072);
  }
  const identity={p_user:user,p_key:input.key};
  const current=()=>rpc('pickwell_analysis_reply',identity);
  const settle=(outcome,error=null,retake=null)=>rpc('pickwell_settle_analysis',{
   ...identity,p_outcome:outcome,p_error:error,p_retake:retake});
  function safe(result,http=200){
   if(!['already_exists','processing','analysis_failed','needs_retake'].includes(result.status))throw Error();
   const body={status:result.status,barcode:input.barcode,request_id:input.key};
   if(result.job_id)body.job_id=result.job_id; // Only owner IDs are returned by RPC.
   if(result.status==='already_exists')body.product=sanitizePublishedProduct(result.product);
   if(result.status==='needs_retake')body.retake=result.retake_target==='both'?['nutrition','ingredients']:[result.retake_target];
   if(result.status==='processing'){
    body.retry_after_seconds=4;
    if(['validation_pending','provider_reconciliation_required'].includes(result.stage))body.stage=result.stage;
    if(result.stage==='provider_reconciliation_required'){body.error='provider_outcome_unknown';body.retryable=false;body.retry_after_seconds=30;}
   }
   if(result.status==='analysis_failed')body.error=result.error||'analysis_failed';
   return reply(body,http);
  }
  try{
   const admitted=await rpc('pickwell_admit_analysis',{...identity,p_barcode:input.barcode,p_digest:input.digest});
   if(admitted.status==='quota_exceeded'){
    await createOperationalEvents(env,fetcher).record('quota_exceeded',input.key,{metric:'ai_analysis'});
    return reply({status:'quota_exceeded',quota:Object.fromEntries(
    ['plan','limit','version','used','reserved','remaining','reset_at'].filter(k=>Object.hasOwn(admitted,k)).map(k=>[k,admitted[k]]))},429);
   }
   if(admitted.status==='inference_disabled')return failure('inference_disabled');
   if(admitted.status!=='reserved')return safe(admitted);
   // Missing/mismatched credentials cannot spend a provider-attempt claim.
   if(!env.META_API_KEY||env.META_API_URL!==META_URL||env.META_MODEL!=='muse-spark-1.3'){
    await settle('failed','service_unavailable');return failure('service_unavailable');
   }
   const claim=await q.beginProvider(admitted.reservation_id,bucket);
   if(claim.call_allowed!==true){
    if(claim.status==='replay')return safe(await current());
    if(claim.status==='cache_hit')return safe(await settle('cache_hit'));
    const allowed=new Set(['inference_disabled','provider_attempt_limit','retry_denied','service_budget_exceeded','concurrency_limited']);
    await settle('failed',allowed.has(claim.status)?claim.status:'service_unavailable');
    return failure(allowed.has(claim.status)?claim.status:'service_unavailable',claim.status==='inference_disabled'?503:429);
   }
   if(claim.model!==env.META_MODEL){
    await q.recordProvider(claim.attempt_id,'failed',0,null,null,0);
    await settle('failed','service_unavailable');return failure('service_unavailable');
   }
   const metadata={model:claim.model,usage:null};let extracted;
   try{
    extracted=await invokeMetaLabels(env,input.images,metadata,fetcher,analysisProfile);
    extracted.validation=validateAnalysis(extracted.candidate,{model:claim.model});
   }catch(error){
    const uncertain=['TimeoutError','AbortError','TypeError'].includes(error?.name)||!metadata.provider_status;
    await q.recordProvider(claim.attempt_id,uncertain?'unknown':'failed',null,
     metadata.usage?.input_tokens??null,metadata.usage?.output_tokens??null,metadata.duration_ms??null);
    if(uncertain)return reply({status:'processing',barcode:input.barcode,job_id:admitted.job_id,
     request_id:input.key,error:'provider_outcome_unknown',stage:'provider_reconciliation_required',retryable:false,retry_after_seconds:30},503);
    const code=error?.code==='invalid_model_output'?'invalid_model_output':'provider_failed';
    return safe(await settle('failed',code),502);
   }finally{
    // Images are request-local only. Never place data URLs in DB, analytics or logs.
    input.images=null;
   }
   await q.recordProvider(claim.attempt_id,'succeeded',null,metadata.usage?.input_tokens??null,
    metadata.usage?.output_tokens??null,metadata.duration_ms??null);
   if(extracted.validation.status==='needs_retake'){
    const targets=extracted.validation.retake;
    return safe(await settle('retake',null,targets.length===1?targets[0]:'both'),422);
   }
   // Validated private handoff only. Publication and successful credit remain T05.3.
   return safe(await rpc('pickwell_stage_analysis',{...identity,p_candidate:{...extracted.candidate,validation:extracted.validation},
    p_model:claim.model,p_prompt:PROMPT_VERSION}),202);
  }catch(error){
   return failure(error?.message==='idempotency_conflict'?'idempotency_conflict':'service_unavailable',
    error?.message==='idempotency_conflict'?409:503);
  }
 };
}
