import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createOperationalEvents } from '../functions/_shared/operational_events.mjs';
import { createQuotaService } from '../functions/_shared/quota_boundary.mjs';
const env={SUPABASE_URL:'https://example.supabase.co',SUPABASE_ANON_KEY:'public-fixture',SUPABASE_SERVICE_ROLE_KEY:'server-fixture'};
const source='c1230000-0000-4000-8000-000000000001';
test('events discard raw context and reject unknown event names before sending',async()=>{
 const requests=[];
 const events=createOperationalEvents(env,async(url,options)=>{requests.push(JSON.parse(options.body));return new Response('true');});
 assert.equal(await events.record('analysis_failed',source,{metric:'ai_analysis',duration:123,
  email:'private@example.invalid',authorization:'Bearer PRIVATE',image:'data:image/jpeg;base64,PRIVATE',
  context:{api_key:'PRIVATE'},error:new Error('PRIVATE')}),true);
 assert.deepEqual(requests,[{p_event:'analysis_failed',p_source:source,p_metric:'ai_analysis',p_duration:123}]);
 assert.equal(await events.record('PRIVATE',source),false);
 assert.equal(await events.record('analysis_failed','PRIVATE'),false);
 assert.equal(requests.length,1);
 await events.record('analysis_failed',source,{metric:'PRIVATE',duration:'PRIVATE'});
 assert.equal(JSON.stringify(requests).includes('PRIVATE'),false);
});
test('guest lookup helper emits only definitive statuses; capture is intentionally explicit',async()=>{
 const seen=[];const events=createOperationalEvents(env,async(_url,options)=>{seen.push(JSON.parse(options.body).p_event);return new Response('true');});
 assert.equal(await events.lookup(source,'ready',30),true);
 assert.deepEqual(seen,['barcode_scanned','product_cache_hit']);
 assert.equal(await events.lookup(source,'transport_error'),false);
 assert.equal(seen.length,2);
 assert.equal(await events.record('capture_completed',source,{metric:'ai_analysis'}),true);
});
test('telemetry network, HTTP, timeout and invalid config failures return false without logging payloads',async()=>{
 for(const fetcher of [async()=>{throw new Error('PRIVATE network response');},async()=>new Response('PRIVATE',{status:503}),
  async()=>{throw new DOMException('PRIVATE','TimeoutError');}]){
  assert.equal(await createOperationalEvents(env,fetcher).record('analysis_failed',source),false);
 }
 assert.equal(await createOperationalEvents({...env,SUPABASE_URL:'http://unsafe.invalid'}).record('analysis_failed',source),false);
});
test('optional telemetry failures preserve allowed/denied quota decisions; mandatory accounting failures propagate',async()=>{
 for(const status of ['quota_exceeded','cache_hit','reserved']){
  let quotaCalls=0,eventCalls=0;
  const service=createQuotaService(env,async(url)=>{
   if(url.endsWith('/pickwell_try_event')){eventCalls++;throw new Error('PRIVATE');}
   quotaCalls++;return Response.json({status});
  });
  assert.deepEqual(await service.reserve(source,'ai_analysis',source,'96385074'),{status});
  assert.equal(quotaCalls,1);assert.equal(eventCalls,status==='reserved'?0:1);
 }
 let calls=0;
 const service=createQuotaService(env,async()=>{calls++;return new Response('PRIVATE',{status:503});});
 await assert.rejects(service.reserve(source,'ai_analysis',source,'96385074'),/quota_operation_failed/);
 await assert.rejects(service.recordProvider(source,'failed',0.01),/quota_operation_failed/);
 assert.equal(calls,2,'Mandatory failures never call best-effort event fallback or grant work');
});
test('provider estimate travels only to mandatory accounting RPC, without raw provider output',async()=>{
 let body,url;
 const service=createQuotaService(env,async(u,options)=>{url=u;body=JSON.parse(options.body);return Response.json({status:'failed'});});
 await service.recordProvider(source,'failed',null,100,20,350,0.0012);
 assert.ok(url.endsWith('/pickwell_record_provider_metrics'));
 assert.deepEqual(body,{p_attempt:source,p_state:'failed',p_cost:null,p_input:100,p_output:20,p_duration:350,p_estimate:0.0012});
});

test('native Auth/REST restricts operational data and deduplicates sanitized server events',
 {skip:!process.env.PICKWELL_NATIVE_STATUS},async t=>{
 const {readFile}=await import('node:fs/promises');
 const s=JSON.parse(await readFile(process.env.PICKWELL_NATIVE_STATUS,'utf8'));
 const url=new URL(s.env.API_URL);
 assert.ok(s.runtime==='native'&&url.hostname==='127.0.0.1','Only disposable local native stack may be tested');
 const local={SUPABASE_URL:url.origin,SUPABASE_ANON_KEY:s.env.PUBLISHABLE_KEY??s.env.ANON_KEY,SUPABASE_SERVICE_ROLE_KEY:s.env.SERVICE_ROLE_KEY};
 const server={apikey:local.SUPABASE_SERVICE_ROLE_KEY,Authorization:`Bearer ${local.SUPABASE_SERVICE_ROLE_KEY}`,'content-type':'application/json'};
 const signup=await fetch(url.origin+'/auth/v1/signup',{method:'POST',headers:{apikey:local.SUPABASE_ANON_KEY,'content-type':'application/json'},
  body:JSON.stringify({email:`events-${crypto.randomUUID()}@example.invalid`,password:crypto.randomUUID()+'Aa1!'})});
 assert.equal(signup.status,200);const session=await signup.json();assert.ok(session.access_token&&session.user.id);
 try{
  await t.test('guest and verified user cannot inspect, forge or prune operational data',async()=>{
   for(const token of [null,session.access_token]){
    const headers={apikey:local.SUPABASE_ANON_KEY,'content-type':'application/json',...(token?{Authorization:`Bearer ${token}`}:{})};
    for(const resource of ['operational_events','provider_usage_daily','daily_operational_counts','daily_provider_costs']){
     const r=await fetch(url.origin+'/rest/v1/'+resource,{headers});assert.ok([401,403].includes(r.status));
    }
    const insert=await fetch(url.origin+'/rest/v1/operational_events',{method:'POST',headers,
     body:JSON.stringify({event_type:'analysis_completed',source_id:source})});assert.ok([401,403].includes(insert.status));
    for(const rpc of ['pickwell_try_event','pickwell_prune_telemetry','pickwell_record_provider_metrics']){
     const r=await fetch(url.origin+'/rest/v1/rpc/'+rpc,{method:'POST',headers,body:'{}'});assert.ok([401,403,404].includes(r.status));
    }
   }
  });
  await t.test('server events contain no supplied sensitive context and concurrent retries count once',async()=>{
   const telemetry=createOperationalEvents(local),key=crypto.randomUUID();
   const results=await Promise.all(Array.from({length:10},()=>telemetry.record('product_cache_hit',key,
    {metric:'barcode_lookup',duration:40,context:{image:'PRIVATE',api_key:'PRIVATE'},email:'PRIVATE'})));
   assert.ok(results.every(Boolean));
   const r=await fetch(url.origin+'/rest/v1/operational_events?source_id=eq.'+key,{headers:server});assert.equal(r.status,200);
   const rows=await r.json();assert.equal(rows.length,1);assert.equal(JSON.stringify(rows).includes('PRIVATE'),false);
   assert.deepEqual(Object.keys(rows[0]).sort(),['created_at','duration_ms','event_type','id','metric','source_id']);
   for(const resource of ['daily_operational_counts','daily_provider_costs']){
    const report=await fetch(url.origin+'/rest/v1/'+resource,{headers:server});assert.equal(report.status,200);
    const data=await report.json();assert.ok(Array.isArray(data));
    assert.equal(JSON.stringify(data).includes('PRIVATE'),false);
   }
  });
 }finally{await fetch(url.origin+'/auth/v1/admin/users/'+session.user.id,{method:'DELETE',headers:server});}
});
