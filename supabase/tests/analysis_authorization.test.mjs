import {test} from 'node:test';
import assert from 'node:assert/strict';
import {createAnalysisAuthorizationHandler} from '../functions/_shared/analysis_authorization.mjs';
const env={SUPABASE_URL:'https://example.supabase.co',SUPABASE_ANON_KEY:'public-fixture'};
const req=(token='fake.header.signature',body={})=>new Request('https://example.invalid',{method:'POST',headers:{'content-type':'application/json',...(token?{authorization:`Bearer ${token}`}:{})},body:JSON.stringify(body)});
const user={id:'10000000-0000-4000-8000-000000000001',is_anonymous:false,email:'fixture@example.invalid',email_confirmed_at:'2026-11-02T00:00:00Z'};
test('guest, malformed and expired tokens cannot pass identity gate',async()=>{
 let calls=0;const h=createAnalysisAuthorizationHandler(env,async()=>{calls++;return new Response('{}',{status:401});});
 for(const token of [null,'publishable-fixture','fake.header.signature'])assert.equal((await h(req(token))).status,401);
 assert.equal(calls,1);
});
test('verified persistent email passes only after Auth validation; response contains no identity or capability',async()=>{
 let calls=0;const h=createAnalysisAuthorizationHandler(env,async(url,options)=>{
  calls++;assert.equal(url,env.SUPABASE_URL+'/auth/v1/user');assert.equal(options.headers.Authorization,'Bearer fake.header.signature');
  return Response.json(user);
 });
 const r=await h(req());assert.equal(r.status,200);assert.deepEqual(await r.json(),{status:'authorized'});assert.equal(calls,1);
 assert.equal(r.headers.get('cache-control'),'no-store');
});
test('anonymous, unverified and client metadata verification flags are refused',async()=>{
 for(const overrides of [{is_anonymous:true},{is_anonymous:undefined},{email_confirmed_at:null},{email:''},{id:'bad'},
  {email_confirmed_at:null,user_metadata:{verified:true,premium:true},role:'authenticated'}]){
  const h=createAnalysisAuthorizationHandler(env,async()=>Response.json({...user,...overrides}));
  assert.equal((await h(req())).status,403);
 }
});
test('Auth outage, timeout and excessive Auth response fail closed without leaking payloads',async()=>{
 for(const fn of [()=>new Response('PRIVATE',{status:500}),()=>{throw Error('PRIVATE');},()=>new Response('x'.repeat(32769))]){
  const r=await createAnalysisAuthorizationHandler(env,fn)(req());assert.equal(r.status,503);assert.deepEqual(await r.json(),{error:'service_unavailable'});
 }
});
test('forged bodies, image payloads and unsupported methods are refused',async()=>{
 const h=createAnalysisAuthorizationHandler(env,async()=>Response.json(user));
 for(const body of [{verified:true},{user_id:user.id},{image:'x'.repeat(2048)},[],null])assert.equal((await h(req('fake.header.signature',body))).status,400);
 assert.equal((await h(new Request('https://example.invalid'))).status,405);
});
