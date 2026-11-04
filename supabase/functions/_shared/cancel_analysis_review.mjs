import { privateResultFields } from './private_analysis.mjs';
import { requireVerifiedEmail, IdentityError } from './analysis_authorization.mjs';
import { readBoundedJson, sanitizePublishedProduct } from './catalog_boundary.mjs';
import { createQuotaService, networkBucket } from './quota_boundary.mjs';
import { attachAnalysisQuota } from './analysis_quota_response.mjs';
export function createCancelAnalysisReviewHandler(env,fetcher=fetch){
 const reply=(body,status=200)=>Response.json(body,{status,headers:{'Cache-Control':'no-store','X-Content-Type-Options':'nosniff'}});
 return async request=>{
  if(request.method!=='POST')return reply({status:'error',error:'method_not_allowed'},405);
  let user;
  try{
   user=await requireVerifiedEmail(request,env,fetcher);
   const q=createQuotaService(env,fetcher),bucket=await networkBucket(request,{secret:env.PICKWELL_NETWORK_HASH_SECRET,
    trustedHeader:env.PICKWELL_TRUSTED_IP_HEADER||undefined,trustedProxyHops:env.PICKWELL_TRUSTED_PROXY_HOPS?Number(env.PICKWELL_TRUSTED_PROXY_HOPS):undefined});
   if((await q.throttle(bucket,user)).allowed!==true)return reply({status:'rate_limited',error:'rate_limited'},429);
   let body;try{body=await readBoundedJson(request.body,1024);
    if(!body||Object.keys(body).join(',')!=='request_id'||!/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(body.request_id??''))throw Error();
   }catch{return reply({status:'error',error:'invalid_input'},400);}
   const result=await fetcher(new URL(env.SUPABASE_URL).origin+'/rest/v1/rpc/pickwell_cancel_analysis_review',{
    method:'POST',headers:{apikey:env.SUPABASE_SERVICE_ROLE_KEY,Authorization:`Bearer ${env.SUPABASE_SERVICE_ROLE_KEY}`,'content-type':'application/json'},
    body:JSON.stringify({p_user:user,p_key:body.request_id}),redirect:'error',signal:AbortSignal.timeout(5000)});
   if(!result.ok)return reply({status:'error',error:result.status===406?'not_found':'service_unavailable'},result.status===406?404:503);
   const raw=await readBoundedJson(result.body,131072);
   if(!['review_cancelled','ready','already_exists','analysis_failed','processing','private_ready','private_expired'].includes(raw.status))throw Error();
   const safe={status:raw.status,barcode:raw.barcode};
   if(raw.status==='private_ready')Object.assign(safe,privateResultFields(raw));
   if(['ready','already_exists'].includes(raw.status))safe.product=sanitizePublishedProduct(raw.product);
   if(raw.status==='analysis_failed')safe.error=['review_rejected','review_expired','review_cancelled'].includes(raw.error)?raw.error:'analysis_failed';
   return attachAnalysisQuota(reply(safe),user,env,fetcher);
  }catch(error){return reply({status:'error',error:error instanceof IdentityError?error.message:'service_unavailable'},error instanceof IdentityError?error.status:503);}
 };
}
