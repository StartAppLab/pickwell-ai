import { readBoundedJson } from './catalog_boundary.mjs';
const keys=['plan','limit','version','used','reserved','remaining','reset_at'];
// Display-only metadata. Failure never changes admission, publication or accounting.
export async function attachAnalysisQuota(response,user,env,fetcher=fetch){
 if(!user||![200,202,422,429,502,503].includes(response.status))return response;
 const body=await response.clone().json();
 if(body.status==='rate_limited')return response;
 let quota=body.quota;
 if(!quota){
  try{
   const result=await fetcher(new URL(env.SUPABASE_URL).origin+'/rest/v1/rpc/pickwell_quota_snapshot',{
    method:'POST',headers:{apikey:env.SUPABASE_SERVICE_ROLE_KEY,Authorization:`Bearer ${env.SUPABASE_SERVICE_ROLE_KEY}`,'content-type':'application/json'},
    body:JSON.stringify({p_user:user,p_metric:'ai_analysis'}),redirect:'error',signal:AbortSignal.timeout(1000),
   });
   if(!result.ok)throw Error();
   quota=await readBoundedJson(result.body,8192);
  }catch{return Response.json({...body,quota_unavailable:true},{status:response.status,headers:response.headers});}
 }
 if(!quota||typeof quota!=='object'||Array.isArray(quota))return response;
 return Response.json({...body,quota:Object.fromEntries(keys.filter(k=>Object.hasOwn(quota,k)).map(k=>[k,quota[k]])),
  quota_observed_at:new Date().toISOString()},{status:response.status,headers:response.headers});
}
