import {test} from 'node:test';
import assert from 'node:assert/strict';
import {createGetProductHandler,normalizeBarcode} from '../functions/_shared/get_product.mjs';
const env={SUPABASE_URL:'https://example.supabase.co',SUPABASE_ANON_KEY:'public-fixture',SUPABASE_SERVICE_ROLE_KEY:'server-fixture',PICKWELL_NETWORK_HASH_SECRET:'local-fixture-only-'.repeat(4)};
const code='02900000000018',key='a1260000-0000-4000-8000-000000000001';
const request=(body={barcode:'2900000000018'},headers={})=>new Request('https://example.invalid/functions/v1/get-product',{method:'POST',headers:{'content-type':'application/json','idempotency-key':key,...headers},body:JSON.stringify(body)});
function backend(result={status:'not_found',barcode:code},overrides={}){
 const trace=[];
 const fetcher=async(url,options)=>{
  trace.push(url);assert.equal(new URL(url).origin,env.SUPABASE_URL,'No external/provider request permitted');
  if(url.endsWith('pickwell_lookup_throttle'))return Response.json({allowed:true});
  if(url.endsWith('pickwell_try_event'))return new Response('true');
  if(url.endsWith('pickwell_get_product'))return overrides.lookup?overrides.lookup():Response.json(result);
  if(url.endsWith('/auth/v1/user'))return new Response('{}',{status:overrides.authStatus??401});
  throw Error('Unexpected request');
 };return {handler:createGetProductHandler(env,fetcher),trace};
}
test('canonicalization matches GTIN aliases and validates formats/check digits',()=>{
 assert.equal(normalizeBarcode('036000291452'),'00036000291452');assert.equal(normalizeBarcode('0036000291452'),'00036000291452');
 assert.equal(normalizeBarcode('96385074'),'00000096385074');
 for(const value of [null,123,'96385075','123','ABCD1234','036000291452x'])assert.throws(()=>normalizeBarcode(value));
});
test('malformed or forged bodies and oversized inputs fail before privileged reads',async()=>{
 const {handler,trace}=backend();
 for(const body of [{barcode:'bad'},{barcode:code,user_id:key},{barcode:code,premium:true},{barcode:'x'.repeat(1500)},[],null]){
  assert.equal((await handler(request(body))).status,400);
 }
 assert.equal(trace.length,0);
 assert.equal((await handler(new Request('https://example.invalid',{method:'GET'}))).status,405);
});
test('ready result is sanitized, guest usage is best effort and trace has no model call',async()=>{
 const {handler,trace}=backend({status:'ready',barcode:code,product:{barcode:code,id:key,is_demo:true,
  summary:'SYNTHETIC',user_id:'PRIVATE',prompt_version:'PRIVATE',nutrition:{raw:'label',basis:'per_100g',nutrients:[]},
  ingredients:{raw:'oats',items:['oats'],declared_allergens:null},findings:[]}});
 const response=await handler(request());const body=await response.json();assert.equal(response.status,200);assert.equal(body.status,'ready');
 assert.equal(JSON.stringify(body).includes('PRIVATE'),false);assert.equal(body.guest_best_effort,true);assert.equal(body.quota,undefined);
 assert.ok(trace.every(url=>!url.includes('provider')));
});
test('definitive miss and processing are explicit, not generic errors',async()=>{
 for(const status of ['not_found','processing']){
  const {handler}=backend({status,barcode:code});const response=await handler(request());const body=await response.json();
  assert.equal(response.status,200);assert.equal(body.status,status);if(status==='processing')assert.equal(body.retry_after_seconds,4);
 }
});
test('DB failure, timeout, malformed result and Auth service failure never become a miss',async()=>{
 for(const lookup of [()=>new Response('PRIVATE',{status:503}),()=>{throw new DOMException('PRIVATE','TimeoutError');},()=>new Response('not JSON')]){
  const {handler}=backend(undefined,{lookup});const response=await handler(request());assert.equal(response.status,503);assert.equal((await response.json()).status,'error');
 }
 const {handler}=backend(undefined,{authStatus:503});assert.equal((await handler(request(undefined,{authorization:'Bearer fake.header.signature'}))).status,503);
});
test('invalid sessions never fall back to guest, while known public anon bearer remains guest',async()=>{
 const {handler,trace}=backend();assert.equal((await handler(request(undefined,{authorization:'Bearer fake.header.signature'}))).status,401);
 assert.equal(trace.length,1);
 assert.equal((await handler(request(undefined,{authorization:'Bearer public-fixture'}))).status,200);
});
test('throttle denial stops catalogue lookup and replay expiry is typed conflict',async()=>{
 let calls=0;
 const handler=createGetProductHandler(env,async()=>{calls++;return Response.json({allowed:false});});
 const r=await handler(request());assert.equal(r.status,429);assert.equal((await r.json()).status,'rate_limited');assert.equal(calls,1);
 const expired=await backend({status:'retry_expired'}).handler(request());assert.equal(expired.status,409);assert.equal((await expired.json()).error,'idempotency_expired');
});

test('HTTP endpoint core with native Supabase Auth/REST and zero provider admissions',
 {skip:!process.env.PICKWELL_NATIVE_STATUS},async t=>{
 const {readFile}=await import('node:fs/promises');const {createServer}=await import('node:http');
 const s=JSON.parse(await readFile(process.env.PICKWELL_NATIVE_STATUS,'utf8'));const origin=new URL(s.env.API_URL);
 assert.ok(s.runtime==='native'&&origin.hostname==='127.0.0.1');
 const local={...env,SUPABASE_URL:origin.origin,SUPABASE_ANON_KEY:s.env.PUBLISHABLE_KEY??s.env.ANON_KEY,SUPABASE_SERVICE_ROLE_KEY:s.env.SERVICE_ROLE_KEY};
 const serverHeaders={apikey:local.SUPABASE_SERVICE_ROLE_KEY,Authorization:`Bearer ${local.SUPABASE_SERVICE_ROLE_KEY}`,'content-type':'application/json'};
 const trace=[];let failure=false;
 const fetcher=async(url,options)=>{
  assert.equal(new URL(url).origin,origin.origin,'Endpoint may call only isolated Supabase');trace.push(new URL(url).pathname);
  if(failure&&url.endsWith('/pickwell_get_product'))throw new DOMException('test timeout','TimeoutError');
  return fetch(url,options);
 };
 const handler=createGetProductHandler(local,fetcher);
 const server=createServer(async(req,res)=>{
  try{
   const input=new Request(`http://127.0.0.1${req.url}`,{method:req.method,headers:req.headers,body:req,duplex:'half'});
   const output=await handler(input);res.writeHead(output.status,Object.fromEntries(output.headers));res.end(await output.text());
  }catch{res.writeHead(500);res.end();}
 });
 await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));const url=`http://127.0.0.1:${server.address().port}/functions/v1/get-product`;
 async function rest(path,method='GET',body){
  const r=await fetch(origin.origin+'/rest/v1/'+path,{method,headers:{...serverHeaders,Prefer:'return=representation'},body:body===undefined?undefined:JSON.stringify(body)});
  assert.ok(r.ok,`Local REST ${method} failed ${r.status}`);return r.status===204?null:r.json();
 }
 const call=(barcode='2900000000018',token=null,idem=crypto.randomUUID())=>fetch(url,{method:'POST',headers:{'content-type':'application/json','idempotency-key':idem,...(token?{Authorization:`Bearer ${token}`}:{})},body:JSON.stringify({barcode})});
 let user;
 try{
  await rest('quota_controls?id=eq.true','PATCH',{user_per_minute:200,ip_per_minute:1000,guest_per_minute:100,guest_per_day:1000,change_reason:'Disposable endpoint tests'});
  const before=(await rest('ai_usage?select=id')).length;
  const signup=await fetch(origin.origin+'/auth/v1/signup',{method:'POST',headers:{apikey:local.SUPABASE_ANON_KEY,'content-type':'application/json'},body:JSON.stringify({email:`lookup-${crypto.randomUUID()}@example.invalid`,password:crypto.randomUUID()+'Aa1!'})});
  assert.equal(signup.status,200);user=await signup.json();assert.ok(user.access_token);
  await t.test('guest HTTP ready includes complete demo, miss is explicit and active product is processing',async()=>{
   const found=await call();assert.equal(found.status,200);const body=await found.json();assert.equal(body.product.is_demo,true);assert.equal(body.product.nutrition.nutrients.length,8);assert.ok(body.product.findings.length);
   assert.equal(body.product.prompt_version,undefined);assert.equal(body.quota,undefined);
   assert.equal((await (await call('96385074')).json()).status,'not_found');
   await rest('products','POST',{barcode:'96385074',name:'SYNTHETIC PROCESSING TEST',is_demo:true});
   const processing=await (await call('96385074')).json();assert.equal(processing.status,'processing');assert.equal(processing.job_id,undefined);
  });
  await t.test('signed-in exact quota, same-key concurrency, mutable limit and 30/31 enforcement',async()=>{
   const key=crypto.randomUUID();const responses=await Promise.all(Array.from({length:8},()=>call('2900000000018',user.access_token,key)));
   assert.ok(responses.every(r=>r.status===200));const values=await Promise.all(responses.map(r=>r.json()));assert.ok(values.every(r=>r.quota.used===1));
   failure=true;
   const outage=await call('2900000000018',user.access_token);assert.equal(outage.status,503);failure=false;
   assert.equal((await rest('usage_daily?user_id=eq.'+user.user.id+'&metric=eq.barcode_lookup'))[0].used,1,'Known pre-transaction failure adds no charge');
   const mismatch=await call('96385074',user.access_token,key);assert.equal(mismatch.status,409);
   await rest('plan_limits?plan_code=eq.free&metric=eq.barcode_lookup','PATCH',{daily_limit:1,change_reason:'Native endpoint mutable limit'});
   const limited=await call('2900000000018',user.access_token);assert.equal(limited.status,429);assert.equal((await limited.json()).quota.limit,1);
   await rest('plan_limits?plan_code=eq.free&metric=eq.barcode_lookup','PATCH',{daily_limit:30,change_reason:'Restore endpoint quota'});
   await rest('usage_daily?user_id=eq.'+user.user.id+'&metric=eq.barcode_lookup','PATCH',{used:29});
   const last=await (await call('2900000000018',user.access_token)).json();assert.equal(last.quota.used,30);assert.equal(last.quota.remaining,0);assert.match(last.quota.reset_at,/T00:00:00\+00:00$/);
   const denied=await call('2900000000018',user.access_token);assert.equal(denied.status,429);assert.equal((await denied.json()).status,'quota_exceeded');
  });
  await t.test('HTTP malformed/session/rate errors and DB timeout fail safely without charge',async()=>{
   assert.equal((await call('bad')).status,400);assert.equal((await call('2900000000018','fake.header.signature')).status,401);
   failure=true;const failed=await call();assert.equal(failed.status,503);assert.equal((await failed.json()).status,'error');failure=false;
   await rest('quota_controls?id=eq.true','PATCH',{guest_per_minute:1,change_reason:'Native endpoint throttle fixture'});
   const denied=await call();assert.equal(denied.status,429);assert.equal((await denied.json()).status,'rate_limited');
  });
  assert.equal((await rest('ai_usage?select=id')).length,before,'Zero Meta admissions from all lookups');
  assert.ok(trace.every(path=>!path.includes('begin_provider')&&!path.includes('record_provider')),'No model operation in fetch trace');
 }finally{
  server.closeAllConnections();await new Promise(resolve=>server.close(resolve));
  await rest('quota_controls?id=eq.true','PATCH',{user_per_minute:20,ip_per_minute:60,guest_per_minute:10,guest_per_day:30,change_reason:'Restore operational defaults'});
  await rest('plan_limits?plan_code=eq.free&metric=eq.barcode_lookup','PATCH',{daily_limit:30,change_reason:'Restore Free default'});
  if(user?.user)await fetch(origin.origin+'/auth/v1/admin/users/'+user.user.id,{method:'DELETE',headers:serverHeaders});
 }
});
