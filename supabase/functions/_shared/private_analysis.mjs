import {createQuotaService, networkBucket} from './quota_boundary.mjs';
import { requireVerifiedEmail, IdentityError } from './analysis_authorization.mjs';
import { readBoundedJson, sanitizePublishedProduct } from './catalog_boundary.mjs';
import { attachAnalysisQuota } from './analysis_quota_response.mjs';
import { publishAnalysis } from './analysis_publication.mjs';
const uuid=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
// Same product projection as shared results, but authority is explicitly private.
// Never pass this object to public lookup, shared thumbnail storage or local recents.
export function privateResultFields(raw){
 if(!uuid.test(raw.job_id??'')||!uuid.test(raw.request_id??'')||!Number.isFinite(Date.parse(raw.private_expires_at)))throw Error();
 return {job_id:raw.job_id,request_id:raw.request_id,private_expires_at:raw.private_expires_at,
  publication_status:['pending','approved','published','rejected','cancelled','expired'].includes(raw.publication_status)?raw.publication_status:'expired',
  product:sanitizePublishedProduct(raw.product),
  ...(raw.canonical_product?{canonical_product:sanitizePublishedProduct(raw.canonical_product)}:{})};
}
export function createPrivateAnalysisHandler(env,fetcher=fetch){
 const reply=(body,status=200)=>Response.json(body,{status,headers:{'Cache-Control':'no-store','X-Content-Type-Options':'nosniff'}});
 return async request=>{
  if(request.method!=='POST')return reply({status:'error',error:'method_not_allowed'},405);
  try{
   const user=await requireVerifiedEmail(request,env,fetcher);
   const bucket=await networkBucket(request,{secret:env.PICKWELL_NETWORK_HASH_SECRET,trustedHeader:env.PICKWELL_TRUSTED_IP_HEADER||undefined,trustedProxyHops:env.PICKWELL_TRUSTED_PROXY_HOPS?Number(env.PICKWELL_TRUSTED_PROXY_HOPS):undefined});
   if((await createQuotaService(env,fetcher).throttle(bucket,user)).allowed!==true)return reply({status:'rate_limited',error:'rate_limited',retry_after_seconds:60},429);
   let body;try{body=await readBoundedJson(request.body,1024);if(!body||Object.keys(body).join(',')!=='job_id'||!uuid.test(body.job_id??''))throw Error();}
   catch{return reply({status:'error',error:'invalid_input'},400);}
   const rpc=async(name,args)=>{
    const response=await fetcher(new URL(env.SUPABASE_URL).origin+'/rest/v1/rpc/'+name,{method:'POST',
     headers:{apikey:env.SUPABASE_SERVICE_ROLE_KEY,Authorization:`Bearer ${env.SUPABASE_SERVICE_ROLE_KEY}`,'content-type':'application/json'},
     body:JSON.stringify(args),redirect:'error',signal:AbortSignal.timeout(5000)});
    if(!response.ok)throw Error();return readBoundedJson(response.body,131072);
   };
   let result=await rpc('pickwell_private_analysis',{p_user:user,p_job:body.job_id});
   // An explicit owner check may finish approved publication, never inference.
   if(result.status==='private_ready'&&result.publication_status==='approved'){
    const identity={p_user:user,p_key:result.request_id};
    await publishAnalysis(rpc,identity,(outcome,error)=>rpc('pickwell_settle_analysis',{...identity,p_outcome:outcome,p_error:error,p_retake:null}));
    result=await rpc('pickwell_private_analysis',{p_user:user,p_job:body.job_id});
   }
   if(result.status==='not_found')return reply({status:'not_found'},404);
   const safe={status:result.status,barcode:result.barcode};
   if(result.status==='private_ready')Object.assign(safe,privateResultFields(result));
   else if(['ready','already_exists'].includes(result.status))safe.product=sanitizePublishedProduct(result.product);
   else if(result.status!=='private_expired')return reply({status:'error',error:'result_unavailable'},409);
   return attachAnalysisQuota(reply(safe),user,env,fetcher);
  }catch(error){return reply({status:'error',error:error instanceof IdentityError?error.message:'service_unavailable'},error instanceof IdentityError?error.status:503);}
 };
}
