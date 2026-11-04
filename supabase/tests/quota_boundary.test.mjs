import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { networkBucket, createQuotaService } from '../functions/_shared/quota_boundary.mjs';
import {frontLabelFixture} from './fixtures/label_analysis.mjs';
import {validateAnalysis,PROMPT_VERSION} from '../functions/_shared/analysis_validation.mjs';
const secret = 'local-test-only-'.repeat(4);
test('network attribution ignores caller proxy headers unless trust is explicitly configured', async () => {
 const a=new Request('https://example.invalid',{headers:{'x-forwarded-for':'1.2.3.4'}});
 const b=new Request('https://example.invalid',{headers:{'x-forwarded-for':'5.6.7.8'}});
 assert.equal(await networkBucket(a,{secret}),await networkBucket(b,{secret}));
 const opts={secret,trustedHeader:'x-forwarded-for',trustedProxyHops:1};
 assert.notEqual(await networkBucket(a,opts),await networkBucket(b,opts));
 const spoof=new Request('https://example.invalid',{headers:{'x-forwarded-for':'9.9.9.9, 1.2.3.4'}});
 assert.equal(await networkBucket(a,opts),await networkBucket(spoof,opts));
 for(const raw of ['garbage','999.1.1.1','[::1]','1.2.3.4:80']) {
  assert.equal(await networkBucket(new Request('https://example.invalid',{headers:{'x-real-ip':raw}}),
   {secret,trustedHeader:'x-real-ip',trustedProxyHops:1}),await networkBucket(a,{secret}));
 }
 await assert.rejects(networkBucket(a,{secret:'weak'}),/secret/);
});

test('native quota RPCs: exact limits, races, publication, retry and spending',
 {skip:!process.env.PICKWELL_NATIVE_STATUS},async t=>{
 const s=JSON.parse(await readFile(process.env.PICKWELL_NATIVE_STATUS,'utf8'));
 const url=new URL(s.env.API_URL);
 assert.ok(s.runtime==='native'&&url.hostname==='127.0.0.1','Only disposable native loopback is authorized');
 const env={SUPABASE_URL:url.origin,SUPABASE_ANON_KEY:s.env.PUBLISHABLE_KEY??s.env.ANON_KEY,SUPABASE_SERVICE_ROLE_KEY:s.env.SERVICE_ROLE_KEY};
 const q=createQuotaService(env), users=[];
 const h={apikey:env.SUPABASE_SERVICE_ROLE_KEY,Authorization:`Bearer ${env.SUPABASE_SERVICE_ROLE_KEY}`,'content-type':'application/json'};
 const id=()=>crypto.randomUUID();
 const ip='a'.repeat(64), ip2='b'.repeat(64);
 let barcodeSeq=100;
 const barcode=()=>{
  const base='298'+String(++barcodeSeq).padStart(9,'0');
  let sum=0;for(let i=0;i<12;i++)sum+=Number(base[11-i])*(i%2===0?3:1);
  return base+((10-sum%10)%10);
 };
 async function rest(path,method='GET',body){
  const r=await fetch(url.origin+'/rest/v1/'+path,{method,headers:{...h,Prefer:'return=representation'},body:body===undefined?undefined:JSON.stringify(body)});
  const text=await r.text();assert.ok(r.ok,`Local server REST ${method} failed (${r.status})`);return text?JSON.parse(text):null;
 }
 async function patchConfig(p){await rest('quota_controls?id=eq.true','PATCH',{...p,change_reason:'native quota test fixture only'});}
 async function makeUser(){
  const r=await fetch(url.origin+'/auth/v1/signup',{method:'POST',headers:{apikey:env.SUPABASE_ANON_KEY,'content-type':'application/json'},
   body:JSON.stringify({email:`quota-${id()}@example.invalid`,password:id()+'Aa1!'})});
  assert.equal(r.status,200);const v=await r.json();assert.ok(v.access_token&&v.user.id);users.push(v.user.id);return v;
 }
 async function prepare(key,user){
  const candidate=frontLabelFixture(),model='fixture:no-live-provider';
  const validation=validateAnalysis(candidate,{model,requireFront:true});
  assert.equal(validation.status,'validated');
  const staged={...candidate,nutrition:validation.nutrition,ingredients:validation.ingredients,validation};
  await rest('rpc/pickwell_stage_analysis','POST',{p_user:user,p_key:key,p_candidate:staged,p_model:model,p_prompt:PROMPT_VERSION});
  const gate=await rest('rpc/pickwell_publication_gate','POST',{p_user:user,p_key:key});assert.equal(gate.status,'review_required');
  const request=(await rest(`analysis_requests?user_id=eq.${user}&idempotency_key=eq.${key}`))[0];
  const review=(await rest('product_trust_reviews?job_id=eq.'+request.job_id))[0];
  await rest('rpc/pickwell_decide_product_review','POST',{p_review:review.id,p_barcode:review.barcode,p_input_digest:review.input_digest,
   p_candidate_digest:review.candidate_digest,p_policy_version:review.policy_version,p_decision:'approve',p_review_ref:'native-quota-review',
   p_review_basis:'controlled_demo_evidence',p_resolution:'no_discrepancy'});
  return {p_user:user,p_key:key,p_validated:validation};
 }

 try{
 const alice=await makeUser(),bob=await makeUser();const u=alice.user.id,v=bob.user.id;
 await t.test('Auth adapter verifies identities and never accepts a fake session',async()=>{
  assert.equal(await q.identity(new Request('https://example.invalid',{headers:{authorization:`Bearer ${alice.access_token}`}}),{verified:true}),u);
  await assert.rejects(q.identity(new Request('https://example.invalid',{headers:{authorization:'Bearer fake.header.signature'}})),/unauthorized/);
  for(const name of ['pickwell_reserve_usage','pickwell_begin_provider','pickwell_finish_usage','pickwell_record_provider','pickwell_lookup_throttle']){
   for(const token of [null,alice.access_token]){
    const r=await fetch(url.origin+'/rest/v1/rpc/'+name,{method:'POST',headers:{apikey:env.SUPABASE_ANON_KEY,'content-type':'application/json',...(token?{Authorization:`Bearer ${token}`}:{})},body:'{}'});
    assert.ok([401,403,404].includes(r.status),'No client quota RPC is exposed');
   }
  }
 });
 await t.test('guest and verified clients cannot read or mutate the six new private tables',async()=>{
  for(const token of [null,alice.access_token])for(const [table,key,value,field,patch] of [
   ['plans','code','free','enabled',true],['plan_limits','plan_code','free','daily_limit',999],
   ['quota_controls','id','true','global_calls_daily',999],['quota_config_audit','id',id(),'object_name','forged'],
   ['lookup_throttles','bucket','fixture','hits',0],['ai_usage','id',id(),'model','forged']]){
    for(const method of ['GET','POST','PATCH','DELETE']){
     const filter=['PATCH','DELETE'].includes(method)?`?${key}=eq.${value}`:'';
     const response=await fetch(url.origin+'/rest/v1/'+table+filter,{method,headers:{apikey:env.SUPABASE_ANON_KEY,'content-type':'application/json',
      ...(token?{Authorization:`Bearer ${token}`}:{})},...(['POST','PATCH'].includes(method)?{body:JSON.stringify({[field]:patch})}:{})});
     assert.ok([401,403].includes(response.status),`${table} ${method} is private`);
    }
   }
 });
 await t.test('30th lookup allowed, 31st denied; completed status and replay count exactly once',async()=>{
  for(let n=1;n<=30;n++){
   const key=id(),r=await q.reserve(u,'barcode_lookup',key,'96385074');assert.equal(r.status,'reserved');
   assert.equal((await q.reserve(u,'barcode_lookup',key,'96385074')).reservation_id,r.reservation_id);
   assert.equal((await q.finish(r.reservation_id,['ready','not_found','processing'][n%3])).status,'consumed');
  }
  assert.equal((await q.reserve(u,'barcode_lookup',id(),'96385074')).status,'quota_exceeded');
  const snap=await q.snapshot(u,'barcode_lookup');assert.equal(snap.used,30);assert.equal(snap.reserved,0);assert.equal(snap.remaining,0);
  assert.match(snap.reset_at,/T00:00:00\+00:00$/);
 });
 await t.test('mutable limit applies immediately without a mobile release; audit version advances',async()=>{
  await rest('plan_limits?plan_code=eq.free&metric=eq.barcode_lookup','PATCH',{daily_limit:20,change_reason:'Native lower-limit test'});
  assert.equal((await q.snapshot(u,'barcode_lookup')).limit,20);
  assert.equal((await q.reserve(u,'barcode_lookup',id(),'96385074')).status,'quota_exceeded');
  assert.equal((await q.snapshot(u,'barcode_lookup')).remaining,0);
  assert.ok((await q.snapshot(u,'barcode_lookup')).version>1);
  await rest('plan_limits?plan_code=eq.free&metric=eq.barcode_lookup','PATCH',{daily_limit:30,change_reason:'Restore initial test limit'});
 });
 await t.test('transport errors release; new day uses a separate counter; old reservation settles old day',async()=>{
  const r=await q.reserve(v,'barcode_lookup',id(),'96385074');
  await q.finish(r.reservation_id,'transport_error');await q.finish(r.reservation_id,'transport_error');
  assert.equal((await q.snapshot(v,'barcode_lookup')).used,0);assert.equal((await q.snapshot(v,'barcode_lookup')).reserved,0);
  const old=await q.reserve(v,'barcode_lookup',id(),'96385074');
  const yesterday=new Date(Date.now()-86400000).toISOString().slice(0,10);
  // Controlled server fixture models a request crossing UTC midnight, not a caller-supplied clock.
  await rest('usage_daily','POST',{user_id:v,day_utc:yesterday,metric:'barcode_lookup',used:0,reserved:1});
  await rest('usage_reservations?id=eq.'+old.reservation_id,'PATCH',{day_utc:yesterday});
  await rest('usage_daily?user_id=eq.'+v+'&day_utc=eq.'+new Date().toISOString().slice(0,10)+'&metric=eq.barcode_lookup','PATCH',{reserved:0});
  await q.finish(old.reservation_id,'ready');
  assert.equal((await q.snapshot(v,'barcode_lookup')).used,0);
  assert.equal((await rest('usage_daily?user_id=eq.'+v+'&day_utc=eq.'+yesterday))[0].used,1);
 });
 await t.test('concurrent lookup admission admits only remaining capacity and repeated key reserves once',async()=>{
  await rest('usage_daily?user_id=eq.'+v+'&metric=eq.barcode_lookup&day_utc=eq.'+new Date().toISOString().slice(0,10),'PATCH',{used:29});
  const results=await Promise.all(Array.from({length:12},()=>q.reserve(v,'barcode_lookup',id(),'96385074')));
  assert.equal(results.filter(r=>r.status==='reserved').length,1);
  const winner=results.find(r=>r.status==='reserved');await q.finish(winner.reservation_id,'transport_error');
  const key=id(),same=await Promise.all(Array.from({length:10},()=>q.reserve(v,'barcode_lookup',key,'96385074')));
  assert.equal(new Set(same.map(r=>r.reservation_id)).size,1);
  await q.finish(same[0].reservation_id,'transport_error');
 });
 await t.test('guest throttling is network best effort; authenticated requests share IP abuse cap',async()=>{
  const bucket='c'.repeat(64);
  for(let i=0;i<10;i++)assert.equal((await q.throttle(bucket)).allowed,true);
  assert.equal((await q.throttle(bucket)).error,'rate_limited');
  for(let i=0;i<20;i++)assert.equal((await q.throttle(ip,u)).allowed,true);
  assert.equal((await q.throttle(ip,u)).error,'rate_limited');
  for(let i=0;i<40;i++)await q.throttle(ip,v);
  const r=await q.throttle(ip);assert.equal(r.allowed,false);
 });
 await t.test('cache bypasses AI quota; inference disabled until operator config',async()=>{
  assert.equal((await q.reserve(u,'ai_analysis',id(),'2900000000018')).status,'cache_hit');
  const r=await q.reserve(u,'ai_analysis',id(),barcode());
  assert.equal((await q.beginProvider(r.reservation_id,ip)).status,'inference_disabled');
  await q.finish(r.reservation_id,'failed');
  assert.equal((await q.snapshot(u,'ai_analysis')).used,0);
  await patchConfig({inference_enabled:true,approved_model:'fixture:no-live-provider',daily_spend_usd:10,global_calls_daily:100});
 });
 await t.test('one active barcode job across users, one provider call across races, unknown holds and reconciliation',async()=>{
  const code=barcode();const rs=await Promise.all([q.reserve(u,'ai_analysis',id(),code),q.reserve(v,'ai_analysis',id(),code)]);
  assert.equal(rs.filter(r=>r.status==='reserved').length,1);assert.equal(rs.filter(r=>r.status==='processing').length,1);
  const r=rs.find(r=>r.status==='reserved');
  const starts=await Promise.all(Array.from({length:10},()=>q.beginProvider(r.reservation_id,ip)));
  assert.equal(starts.filter(a=>a.call_allowed).length,1);
  const a=starts.find(a=>a.call_allowed);
  await q.recordProvider(a.attempt_id,'unknown');
  await assert.rejects(q.finish(r.reservation_id,'failed'),/operation_failed/);
  await rest('usage_reservations?id=eq.'+r.reservation_id,'PATCH',{lease_expires_at:'2000-01-01T00:00:00Z'});
  await q.reconcileExpired();
  assert.equal((await rest('usage_reservations?id=eq.'+r.reservation_id))[0].state,'reserved');
  await q.recordProvider(a.attempt_id,'failed',0.01,10,2,100);
  await q.finish(r.reservation_id,'failed');
  assert.equal((await rest('ai_usage?id=eq.'+a.attempt_id))[0].actual_cost_usd,0.01);
  assert.equal((await rest('usage_reservations?id=eq.'+r.reservation_id))[0].state,'released');
 });
 await t.test('concurrency cap denies other call; failed and retake attempts release credit and retries are bounded',async()=>{
  const code=barcode();let r=await q.reserve(u,'ai_analysis',id(),code), job=r.job_id;
  for(let n=1;n<=3;n++){
   const a=await q.beginProvider(r.reservation_id,ip);assert.equal(a.call_allowed,true);
   if(n===1){
    const other=await q.reserve(u,'ai_analysis',id(),barcode());
    assert.equal((await q.beginProvider(other.reservation_id,ip2)).status,'concurrency_limited');
    await q.finish(other.reservation_id,'cancelled');
   }
   await q.recordProvider(a.attempt_id,'succeeded',0.001,10,5,100);
   await q.finish(r.reservation_id,'retake');
   assert.equal((await q.snapshot(u,'ai_analysis')).used,0);
   if(n<3)r=await q.reserve(u,'ai_analysis',id(),code,job);
  }
  assert.equal((await q.reserve(u,'ai_analysis',id(),code,job)).status,'retry_denied');
  const fresh=await q.reserve(u,'ai_analysis',id(),code);
  assert.equal(fresh.status,'reserved');
  assert.equal((await q.beginProvider(fresh.reservation_id,ip)).status,'provider_attempt_limit');
  await q.finish(fresh.reservation_id,'failed');
 });
 await t.test('shared-IP and global provider concurrency caps reject excess in-flight work',async()=>{
  const temp=await makeUser(),user=temp.user.id;
  const ar=await q.reserve(u,'ai_analysis',id(),barcode());
  const br=await q.reserve(v,'ai_analysis',id(),barcode());
  const cr=await q.reserve(user,'ai_analysis',id(),barcode());
  const a=await q.beginProvider(ar.reservation_id,ip);assert.equal(a.call_allowed,true);
  assert.equal((await q.beginProvider(br.reservation_id,ip)).status,'concurrency_limited');
  const b=await q.beginProvider(br.reservation_id,ip2);assert.equal(b.call_allowed,true);
  assert.equal((await q.beginProvider(cr.reservation_id,'d'.repeat(64))).status,'concurrency_limited');
  await q.recordProvider(a.attempt_id,'failed',0.001);await q.finish(ar.reservation_id,'failed');
  await q.recordProvider(b.attempt_id,'failed',0.001);await q.finish(br.reservation_id,'failed');
  await q.finish(cr.reservation_id,'cancelled');
 });
 await t.test('one remaining AI credit admits only one concurrent reservation',async()=>{
  const temp=await makeUser(),user=temp.user.id;
  await rest('usage_daily','POST',{user_id:user,day_utc:new Date().toISOString().slice(0,10),metric:'ai_analysis',used:2,reserved:0});
  const rs=await Promise.all(Array.from({length:10},()=>q.reserve(user,'ai_analysis',id(),barcode())));
  assert.equal(rs.filter(r=>r.status==='reserved').length,1);
  assert.equal(rs.filter(r=>r.status==='quota_exceeded').length,9);
  await q.finish(rs.find(r=>r.status==='reserved').reservation_id,'cancelled');
 });
 await t.test('three successful publications consume three credits, fourth denied; concurrent finalize counts once',async()=>{
  for(let i=1;i<=3;i++){
   const code=barcode(),key=id(),r=await rest('rpc/pickwell_admit_analysis','POST',{p_user:v,p_key:key,p_barcode:code,p_digest:'a'.repeat(64)});assert.equal(r.status,'reserved');
   const a=await q.beginProvider(r.reservation_id,ip2);assert.equal(a.call_allowed,true);
   await assert.rejects(q.recordProvider(a.attempt_id,'succeeded',-1),/operation_failed/);
   await q.recordProvider(a.attempt_id,'succeeded',0.002,20,10,150);
   const prepared=await prepare(key,v);
   const outcomes=await Promise.all(Array.from({length:5},()=>rest('rpc/pickwell_publish_analysis','POST',prepared)));
   assert.ok(outcomes.every(value=>['ready','already_exists'].includes(value.status)));
   assert.equal((await rest('products?barcode=eq.'+code.padStart(14,'0'))).length,1);
   assert.equal((await q.snapshot(v,'ai_analysis')).used,i);
  }
  assert.equal((await q.reserve(v,'ai_analysis',id(),barcode())).status,'quota_exceeded');
 });
 await t.test('publication failure rolls back credit; expiry releases only safe abandoned work',async()=>{
  const code=barcode(),r=await q.reserve(u,'ai_analysis',id(),code);
  const a=await q.beginProvider(r.reservation_id,ip);assert.equal(a.call_allowed,true);
  await q.recordProvider(a.attempt_id,'succeeded',0.001);
  await assert.rejects(q.finish(r.reservation_id,'published',id(),id()),/operation_failed/);
  assert.equal((await q.snapshot(u,'ai_analysis')).used,0);
  assert.equal((await rest('usage_reservations?id=eq.'+r.reservation_id))[0].state,'reserved');
  await q.finish(r.reservation_id,'failed');
  const abandoned=await q.reserve(u,'ai_analysis',id(),barcode());
  await rest('usage_reservations?id=eq.'+abandoned.reservation_id,'PATCH',{lease_expires_at:'2000-01-01T00:00:00Z'});
  assert.equal(await q.reconcileExpired(),1);
  assert.equal((await q.snapshot(u,'ai_analysis')).reserved,0);
 });
 await t.test('deleting an account during provider work retains the barcode claim and spend hold',async()=>{
  const temp=await makeUser(),user=temp.user.id,code=barcode();
  const r=await q.reserve(user,'ai_analysis',id(),code);
  const a=await q.beginProvider(r.reservation_id,'e'.repeat(64));assert.equal(a.call_allowed,true);
  const deleted=await fetch(url.origin+'/auth/v1/admin/users/'+user,{method:'DELETE',headers:h});assert.equal(deleted.status,200);
  const row=(await rest('ai_usage?id=eq.'+a.attempt_id))[0];
  assert.equal(row.job_id,null);assert.equal(row.user_id,null);assert.equal(row.reservation_id,null);
  assert.equal((await q.reserve(u,'ai_analysis',id(),code)).status,'processing');
  await q.recordProvider(a.attempt_id,'failed',0.001);
 });
 await t.test('global spend ceiling includes failed/retake calls',async()=>{
  // A server fixture makes the account-wide budget fully used while retaining the actual ledger.
  const ledger=await rest('ai_usage?select=held_usd,actual_cost_usd');
  const held=ledger.reduce((n,a)=>n+Math.max(Number(a.held_usd),Number(a.actual_cost_usd??0)),0);
  await patchConfig({daily_spend_usd:Number(held.toFixed(6)),call_ceiling_usd:0.01});
  const r=await q.reserve(u,'ai_analysis',id(),barcode());
  assert.equal((await q.beginProvider(r.reservation_id,ip)).status,'service_budget_exceeded');
  await q.finish(r.reservation_id,'failed');
  assert.ok(ledger.length>=8,'Failed/retake calls stay in internal spend ledger');
 });
 await t.test('account deletion retains provider budget evidence; negative costs and usage denied',async()=>{
  const before=(await rest('ai_usage?select=id')).length;
  const r=await fetch(url.origin+'/auth/v1/admin/users/'+u,{method:'DELETE',headers:h});assert.equal(r.status,200);
  assert.equal((await rest('ai_usage?select=id')).length,before);
  const bad=await fetch(url.origin+'/rest/v1/usage_daily?user_id=eq.'+v,{method:'PATCH',headers:h,body:JSON.stringify({used:-1})});assert.equal(bad.status,400);
 });
 }finally{
  await patchConfig({inference_enabled:false,approved_model:null,daily_spend_usd:1,call_ceiling_usd:0.05});
  for(const user of users)await fetch(url.origin+'/auth/v1/admin/users/'+user,{method:'DELETE',headers:h});
 }
});
