import{test}from'node:test';import assert from'node:assert/strict';
import{createPrivateAnalysisHandler,privateResultFields}from'../functions/_shared/private_analysis.mjs';
const uid='10000000-0000-4000-8000-000000000001',job='20000000-0000-4000-8000-000000000002',key='30000000-0000-4000-8000-000000000003';
const env={PICKWELL_NETWORK_HASH_SECRET:'fixture-network-bucket-'.repeat(3),SUPABASE_URL:'https://project.example.invalid',SUPABASE_ANON_KEY:'public-fixture',SUPABASE_SERVICE_ROLE_KEY:'server-fixture'};
const raw=()=>({status:'private_ready',job_id:job,request_id:key,barcode:'00036000291452',private_expires_at:new Date(Date.now()+86400000).toISOString(),publication_status:'pending',product:{barcode:'00036000291452',summary:'Label-derived preliminary facts',nutrition:{raw:'Protein 3 g',basis:'per_serving',nutrients:[]},ingredients:{raw:'Oats',items:['Oats'],declared_allergens:null},findings:[],provenance:{identity_verification:'unverified'},email:'private@example.invalid',input_digest:'private',front_image:'private'}});
const request=(body={job_id:job},auth=true)=>new Request('https://app.invalid',{method:'POST',headers:{'content-type':'application/json',...(auth?{Authorization:'Bearer e30.e30.fixture'}:{})},body:JSON.stringify(body)});
function harness(result=raw(),auth={id:uid,is_anonymous:false,email:'fixture@example.invalid',email_confirmed_at:'2026-11-04T00:00:00Z'}){
 const calls=[];return {calls,handler:createPrivateAnalysisHandler(env,async(url,options)=>{
  calls.push({name:url.split('/').at(-1),body:options?.body?JSON.parse(options.body):null});
  if(url.endsWith('/auth/v1/user'))return Response.json(auth);
  if(url.endsWith('/pickwell_lookup_throttle'))return Response.json({allowed:true});
  if(url.endsWith('/pickwell_quota_snapshot'))return Response.json({used:1,reserved:0,remaining:2,limit:3});
  assert.equal(options.headers.apikey,'server-fixture');assert.equal(url.endsWith('/pickwell_private_analysis'),true,'Owner result read never invokes provider or approval');
  assert.deepEqual(JSON.parse(options.body),{p_user:uid,p_job:job});return Response.json(result);
 })};
}
test('guest cannot read a private result or touch the database',async()=>{const h=harness();assert.equal((await h.handler(request({},false))).status,401);assert.equal(h.calls.length,0);});
test('persistent anonymous/unverified Auth identity is rejected before private read',async()=>{for(const auth of [{id:uid,is_anonymous:true},{id:uid,email:'fixture@example.invalid'}]){const h=harness(raw(),auth);assert.equal((await h.handler(request())).status,403);assert.equal(h.calls.length,1);}});
test('client cannot select another owner or supply approval/payload authority',async()=>{const h=harness();for(const extra of [{p_user:uid},{approved:true},{product:{}}])assert.equal((await h.handler(request({job_id:job,...extra}))).status,400);assert.equal(h.calls.filter(c=>c.name==='pickwell_private_analysis').length,0);});
test('owner result is sanitized and never cacheable; no model or publication on ordinary read',async()=>{const h=harness(),r=await h.handler(request()),body=await r.json();assert.equal(r.status,200);assert.equal(r.headers.get('cache-control'),'no-store');assert.equal(body.status,'private_ready');assert.equal(body.quota.used,1);assert.ok(!/private@example|input_digest|front_image|server-fixture/.test(JSON.stringify(body)));assert.notEqual(body.product.provenance.identity_verification,'verified');});
test('another owner is not distinguishable from a missing job',async()=>{const h=harness({status:'not_found'}),r=await h.handler(request());assert.equal(r.status,404);assert.deepEqual(await r.json(),{status:'not_found'});});
test('review rejection and expiry do not hide valid private extraction',async()=>{for(const state of ['rejected','cancelled','expired']){const h=harness({...raw(),publication_status:state}),r=await h.handler(request());assert.equal((await r.json()).publication_status,state);}});
test('expired result has no stale payload or raw private image',async()=>{const h=harness({status:'private_expired',barcode:'00036000291452',product:raw().product});const b=await(await h.handler(request())).json();assert.equal(b.status,'private_expired');assert.equal(b.product,undefined);});
test('invalid private response binding fails closed',()=>{for(const field of ['job_id','request_id','private_expires_at'])assert.throws(()=>privateResultFields({...raw(),[field]:'bad'}));});
