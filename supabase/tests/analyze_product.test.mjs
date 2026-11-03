import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {createServer} from 'node:http';
import {deflateSync} from 'node:zlib';
import {createAnalyzeProductHandler} from '../functions/_shared/analyze_product.mjs';
import {labelFixture} from './fixtures/label_analysis.mjs';
import {createGetProductHandler} from '../functions/_shared/get_product.mjs';
import {META_URL} from '../spikes/meta-vision/core.mjs';
import {INGREDIENT_REFERENCES,NUTRITION_TOPICS,emptyInterpretationPlan,refreshInterpretationRecord} from '../functions/_shared/interpretation.mjs';
const crc=bytes=>{let n=0xffffffff;for(const v of bytes){n^=v;for(let k=0;k<8;k++)n=n&1?0xedb88320^(n>>>1):n>>>1;}return (n^0xffffffff)>>>0;};
function png(color=0,width=1){
 const chunk=(name,data)=>{const t=Buffer.from(name),a=Buffer.alloc(4),b=Buffer.alloc(4);a.writeUInt32BE(data.length);b.writeUInt32BE(crc(Buffer.concat([t,data])));return Buffer.concat([a,t,data,b]);};
 const header=Buffer.alloc(13);header.writeUInt32BE(width,0);header.writeUInt32BE(1,4);header[8]=8;header[9]=6;
 const pixels=Buffer.alloc(1+width*4,color);pixels[0]=0;
 return Buffer.concat([Buffer.from([137,80,78,71,13,10,26,10]),chunk('IHDR',header),chunk('IDAT',deflateSync(pixels)),chunk('IEND',Buffer.alloc(0))]);
}
function form(barcode,key=crypto.randomUUID(),overrides={}){
 const f=new FormData();f.set('barcode',barcode);f.set('idempotency_key',key);
 f.set('nutrition_image',new Blob([png(10)],{type:'image/jpeg'}),'misleading.jpg');
 f.set('ingredients_image',new Blob([png(20)],{type:'image/png'}),'ingredients.png');
 for(const [k,v]of Object.entries(overrides))f.set(k,v);return f;
}
const candidate=labelFixture;
const modelResult=value=>Response.json({model:'muse-spark-1.3',usage:{prompt_tokens:123,completion_tokens:42},
 choices:[{finish_reason:'stop',message:{content:JSON.stringify(value)}}]});

test('analyze-product rejects guests before reading images or calling services',async()=>{
 let calls=0;const h=createAnalyzeProductHandler({},async()=>{calls++;throw Error();});
 const r=await h(new Request('https://example.invalid',{method:'POST',body:'PRIVATE image input'}));
 assert.equal(r.status,401);assert.equal(calls,0);assert.deepEqual(await r.json(),{status:'error',error:'unauthorized'});
});

test('real native HTTP/Auth/SQL orchestration with mocked Meta and parallel submissions',
 {skip:!process.env.PICKWELL_NATIVE_STATUS},async t=>{
 const status=JSON.parse(await readFile(process.env.PICKWELL_NATIVE_STATUS,'utf8'));
 const origin=new URL(status.env.API_URL);assert.equal(status.runtime,'native');assert.equal(origin.hostname,'127.0.0.1');
 const env={SUPABASE_URL:origin.origin,SUPABASE_ANON_KEY:status.env.ANON_KEY??status.env.PUBLISHABLE_KEY,
  SUPABASE_SERVICE_ROLE_KEY:status.env.SERVICE_ROLE_KEY,PICKWELL_NETWORK_HASH_SECRET:'test-only-network-bucket-'.repeat(3),
  META_API_URL:META_URL,META_API_KEY:'fixture-no-real-provider',META_MODEL:'muse-spark-1.3'};
 const serverHeaders={apikey:env.SUPABASE_SERVICE_ROLE_KEY,Authorization:`Bearer ${env.SUPABASE_SERVICE_ROLE_KEY}`,'content-type':'application/json'};
 async function rest(path,method='GET',body){
  const r=await fetch(origin.origin+'/rest/v1/'+path,{method,headers:{...serverHeaders,Prefer:'return=representation'},body:body===undefined?undefined:JSON.stringify(body)});
  const raw=await r.text();assert.ok(r.ok,`Native REST ${method} ${path.split('?')[0]} HTTP ${r.status}`);return raw?JSON.parse(raw):null;
 }
 const rpc=(name,body)=>rest('rpc/'+name,'POST',body);
 const config=body=>rest('quota_controls?id=eq.true','PATCH',{...body,change_reason:'Disposable native orchestration fixture only'});
 const made=[];let seq=Math.floor(Math.random()*100000000);const code=()=>{const b='298'+String(++seq).padStart(9,'0');let sum=0;for(let i=0;i<12;i++)sum+=Number(b[11-i])*(i%2===0?3:1);return b+((10-sum%10)%10);};
 async function user(){const r=await fetch(origin.origin+'/auth/v1/signup',{method:'POST',headers:{apikey:env.SUPABASE_ANON_KEY,'content-type':'application/json'},
  body:JSON.stringify({email:`orchestrate-${crypto.randomUUID()}@example.invalid`,password:crypto.randomUUID()+'Aa1!'})});
  assert.equal(r.status,200);const u=await r.json();assert.ok(u.access_token);made.push(u.user.id);return u;}
 let providerCalls=0,behavior='success',badAuth=false,claimLoss=false,claimLost=false;
 let deferPublication=true,publicationAckLoss=false,snapshotDown=false;
 const fetcher=async(url,options)=>{
  if(url===META_URL){
   providerCalls++;assert.equal(options.redirect,'error');assert.ok(options.signal);
   assert.equal(options.headers.Authorization,'Bearer fixture-no-real-provider');
   const p=JSON.parse(options.body);assert.equal(p.messages[1].content.filter(v=>v.type==='image_url').length,2);
   assert.equal(p.max_completion_tokens,4096);assert.equal(p.store,false);
   if(behavior==='timeout')throw new DOMException('PRIVATE upstream','TimeoutError');
   if(behavior==='fail')return new Response('PRIVATE upstream',{status:429});
   if(behavior==='malformed')return modelResult({...candidate(),extra:'PRIVATE'});
   if(behavior==='unclassified')return modelResult(labelFixture({basis:'per_serving',portion:'100 g'}));
   if(behavior==='interpreted'){
    const c=labelFixture({basis:'per_serving',portion:'100 g'});
    c.ingredients={raw:'Soy Lecithin, Sugar.',items:['Soy Lecithin','Sugar'],declared_allergens:null};
    c.nutrition.nutrients.push({name:'Sodium',value:1280,unit:'mg',source:'Sodium 1280 mg'},{name:'Dietary Fiber',value:6,unit:'g',source:'Dietary Fiber 6 g'});
    c.nutrition.raw+='; Sodium 1280 mg; Dietary Fiber 6 g';
    c.interpretation={...emptyInterpretationPlan(),ingredients:[{index:0,reference_id:'emulsifier',text:INGREDIENT_REFERENCES.emulsifier.text}],
     nutrition:[{topic:'sodium',text:NUTRITION_TOPICS.sodium.text},{topic:'fibre',text:NUTRITION_TOPICS.fibre.text}],summary_nutrients:['sodium','fibre']};
    return modelResult(c);
   }
   if(behavior==='contradiction'){const c=candidate(),n=c.nutrition.nutrients[0];c.nutrition.raw=c.nutrition.raw.replace(n.source,'Energy 9000 kcal');n.value=9000;n.source='Energy 9000 kcal';return modelResult(c);}
   if(behavior==='normalized'){const c=candidate();c.nutrition.nutrients[0].value=19;c.nutrition.raw=c.nutrition.raw.replace('Per 100 g','Nutrition facts');return modelResult(c);}
   if(behavior==='formatted'){
    const c=candidate();c.nutrition.raw=c.nutrition.raw.replace(/\bg\b/g,'G').replace(/\bkcal\b/g,'KCAL');
    for(const n of c.nutrition.nutrients)n.source=n.source.replace(/(\d)\s+([a-z]+)/g,'$1$2');
    return modelResult(c);
   }
   if(behavior==='text-only'){const c=candidate();c.status='needs_retake';c.retake=['nutrition'];c.retake_reasons=[{photo:'nutrition',code:'blur_or_glare',field:'fat'}];c.nutrition.nutrients=[];return modelResult(c);}
   if(behavior==='extended-units'){
    const c=candidate();for(const [name,value,unit]of [['Vitamin D',71,'IU'],['Folate',120,'ug DFE'],['Total Fat',8,'%DV']]){
     const source=name+' '+value+' '+unit;c.nutrition.raw+='; '+source;c.nutrition.nutrients.push({name,value,unit,source});
    }return modelResult(c);
   }
   if(behavior==='source-mismatch'){const c=candidate();for(const n of c.nutrition.nutrients)n.source='unmatched transcription';return modelResult(c);}
   if(behavior==='ingredient-order'){const c=candidate();c.ingredients.items.reverse();return modelResult(c);}
   if(behavior==='retake'){const c=candidate();c.status='needs_retake';c.retake=['nutrition'];c.retake_reasons=[{photo:'nutrition',code:'blur_or_glare',field:'fat'}];c.nutrition.basis='unknown';c.nutrition.raw=null;return modelResult(c);}
   return modelResult(candidate());
  }
  assert.equal(new URL(url).origin,origin.origin,'Only native Supabase and mocked Meta are allowed');
  assert.ok(!url.includes('/storage/v1/'),'Analysis must not persist photos in Storage');
  if(url.includes('/rest/v1/'))assert.ok(!String(options?.body??'').includes('data:image'),'No photo payload may enter SQL');
  if(snapshotDown&&url.endsWith('/pickwell_quota_snapshot'))return Response.json({error:'Optional snapshot unavailable'},{status:503});
  if(deferPublication&&url.endsWith('/pickwell_publish_analysis'))return Response.json({error:'Simulated transient publication outage'},{status:503});
  if(badAuth&&url.endsWith('/auth/v1/user'))return Response.json({id:made[0],is_anonymous:true,email:'fixture@example.invalid',email_confirmed_at:new Date().toISOString(),user_metadata:{verified:true}});
  const result=await fetch(url,options);
  if(publicationAckLoss&&url.endsWith('/pickwell_publish_analysis')){publicationAckLoss=false;await result.text();throw Error('Simulated lost publication acknowledgement');}
  if(claimLoss&&!claimLost&&url.endsWith('/pickwell_begin_provider')){claimLost=true;await result.text();throw Error('Simulated lost SQL acknowledgement');}
  return result;
 };
 const handler=createAnalyzeProductHandler(env,fetcher);
 const server=createServer(async(req,res)=>{
  try {const response=await handler(new Request('http://127.0.0.1'+req.url,{method:req.method,headers:req.headers,body:req,duplex:'half'}));
   res.writeHead(response.status,Object.fromEntries(response.headers));res.end(await response.text());}
  catch {res.writeHead(500);res.end();}
 });
 await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));const endpoint=`http://127.0.0.1:${server.address().port}/analyze-product`;
 const submit=async(u,barcode,key=crypto.randomUUID(),overrides={})=>{
  const r=await fetch(endpoint,{method:'POST',headers:{Authorization:`Bearer ${u.access_token}`},body:form(barcode,key,overrides)});
  const j=await r.json();assert.ok(!/PRIVATE|data:image|Bearer |refresh_token/.test(JSON.stringify(j)));return {http:r.status,body:j};
 };
 const cleanup=async(u,key)=>rpc('pickwell_settle_analysis',{p_user:u.user.id,p_key:key,p_outcome:'failed',p_error:'service_unavailable',p_retake:null});
 let alice,bob;
 try{
  alice=await user();bob=await user();
  await config({inference_enabled:true,approved_model:env.META_MODEL,ip_per_minute:1000,user_per_minute:200,
   global_calls_daily:100,user_calls_daily:100,ip_calls_daily:500,daily_spend_usd:10,call_ceiling_usd:0.05});
  await t.test('cached published demo bypasses Meta and private facts remain sanitized',async()=>{
   const before=providerCalls,r=await submit(alice,'2900000000018');assert.equal(r.http,200);assert.equal(r.body.status,'already_exists');
   assert.equal(r.body.product.is_demo,true);assert.equal(r.body.product.nutrition.nutrients.length,8);assert.equal(providerCalls,before);
   assert.equal(r.body.product.contributor_id,undefined);
  });
  await t.test('blocked/anonymous Auth identity cannot read body or reserve/invoke model',async()=>{
   const before=providerCalls;badAuth=true;const r=await submit(alice,code());badAuth=false;
   assert.equal(r.http,403);assert.equal(providerCalls,before);
  });
  await t.test('inference-disabled flag fails closed without creating jobs',async()=>{
   await config({inference_enabled:false});const before=(await rest('analysis_jobs?select=id')).length;
   const r=await submit(alice,code());assert.equal(r.http,503);assert.equal(r.body.error,'inference_disabled');assert.equal(r.body.quota.limit,3);assert.equal(r.body.quota.remaining,3);
   assert.equal((await rest('analysis_jobs?select=id')).length,before);await config({inference_enabled:true});
  });
  await t.test('malformed, duplicate, corrupt, excessive-dimension and claimed-privilege files never invoke model',async()=>{
   const before=providerCalls,corrupt=png(10);corrupt[corrupt.length-1]^=1;
   for(const overrides of [
    {nutrition_image:new Blob([corrupt],{type:'image/png'})},
    {nutrition_image:'https://attacker.invalid/image.png'},
    {nutrition_image:new Blob(['invalid'],{type:'image/jpeg'})},
    {nutrition_image:new Blob([png(20)],{type:'image/png'})},
    {nutrition_image:new Blob([png(10,2401)],{type:'image/png'})},
    {nutrition_image:new Blob([Buffer.alloc(5*1024*1024+1)],{type:'image/png'})},
    {verified:'true'},
   ]){const r=await submit(alice,code(),crypto.randomUUID(),overrides);assert.equal(r.http,400);}
   assert.equal(providerCalls,before);
  });
  await t.test('32 cross-user submits share one claim and hide the other owner job',async()=>{
   const barcode=code(),before=providerCalls,keys=Array.from({length:32},()=>crypto.randomUUID());
   const out=await Promise.all(keys.map((k,i)=>submit(i%2?bob:alice,barcode,k)));
   assert.equal(providerCalls-before,1);assert.equal(out.filter(r=>r.http===202).length,1);
   assert.ok(out.every(r=>[200,202].includes(r.http)&&r.body.status==='processing'));
   const winner=out.findIndex(r=>r.http===202);const owner=winner%2?bob:alice;
   for(let i=0;i<out.length;i++)if(i%2!==winner%2)assert.equal(out[i].body.job_id,undefined);
   const jobs=await rest(`analysis_jobs?barcode=eq.${barcode.padStart(14,'0')}`);assert.equal(jobs.length,1);
   assert.equal((await rest(`products?barcode=eq.${barcode.padStart(14,'0')}`)).length,0,'No premature publication');
   const stored=await rest('analysis_candidates?job_id=eq.'+jobs[0].id);assert.equal(stored.length,1);
   assert.equal(stored[0].candidate.validation.status,'validated');assert.equal(stored[0].prompt_version,'label-analysis-v2');
   assert.equal(stored[0].candidate.validation.provenance.rules_version,'uk-fop-2016-conservative-v1');
   await cleanup(owner,keys[winner]);
   const shared=await submit(winner%2?alice:bob,barcode,keys[winner%2?0:1]);assert.equal(shared.body.status,'analysis_failed');
  });
  await t.test('same-key parallel retry performs one provider call; mutated image binding is rejected',async()=>{
   const key=crypto.randomUUID(),barcode=code(),before=providerCalls;
   const out=await Promise.all(Array.from({length:12},()=>submit(alice,barcode,key)));
   assert.equal(providerCalls-before,1);assert.ok(out.every(r=>[200,202].includes(r.http)));
   const r=await submit(alice,barcode,key,{ingredients_image:new Blob([png(30)],{type:'image/png'})});
   assert.equal(r.http,409);assert.equal(providerCalls-before,1);
   const snapshot=await rpc('pickwell_quota_snapshot',{p_user:alice.user.id,p_metric:'ai_analysis'});
   assert.equal(snapshot.used,0);assert.equal(snapshot.reserved,1);await cleanup(alice,key);
  });
  await t.test('three reservations fill Free allowance; fourth denied without provider; release permits next',async()=>{
   const keys=[];for(let n=0;n<3;n++){const key=crypto.randomUUID();keys.push(key);assert.equal((await submit(alice,code(),key)).http,202);}
   const before=providerCalls,r=await submit(alice,code());assert.equal(r.http,429);assert.equal(r.body.status,'quota_exceeded');assert.equal(providerCalls,before);
   for(const key of keys)await cleanup(alice,key);
  });
  await t.test('known provider failure and retake release slots; retake targets are precise and replay-safe',async()=>{
   for(const mode of ['fail','malformed','retake']){
    behavior=mode;const key=crypto.randomUUID(),barcode=code(),before=providerCalls,r=await submit(alice,barcode,key);
    assert.equal(r.http,mode==='retake'?422:502);assert.equal(r.body.status,mode==='retake'?'needs_retake':'analysis_failed');
    if(mode==='retake'){
     assert.deepEqual(r.body.retake,['nutrition']);
     assert.ok(r.body.retake_details.some(d=>d.source==='model'&&d.code==='blur_or_glare'&&d.field==='fat'));
     assert.deepEqual((await submit(alice,barcode,key)).body.retake_details,r.body.retake_details);
     const job=(await rest('analysis_jobs?id=eq.'+r.body.job_id))[0];
     assert.deepEqual(job.retake_details,r.body.retake_details);
     assert.equal(r.body.allow_diagnostic_reanalysis,false);
     await rest('analysis_jobs?id=eq.'+r.body.job_id,'PATCH',{retake_details:[]});
     const legacy=(await submit(alice,barcode,key)).body;
     assert.equal(legacy.allow_diagnostic_reanalysis,true);
     assert.equal(legacy.retake_details[0].code,'reason_unavailable');
     assert.equal(providerCalls-before,1);
     await rest('analysis_jobs?id=eq.'+r.body.job_id,'PATCH',{retake_details:job.retake_details});
     await assert.rejects(rpc('pickwell_analysis_reply',{p_user:bob.user.id,p_key:key}));
     await assert.rejects(rpc('pickwell_record_analysis_retake',{p_user:alice.user.id,p_key:key,p_retake:'nutrition',
       p_details:[{photo:'nutrition',source:'model',code:'bad arbitrary code',field:'fat'}]}));
     const denied=await fetch(origin.origin+'/rest/v1/rpc/pickwell_record_analysis_retake',{method:'POST',
       headers:{apikey:env.SUPABASE_ANON_KEY,Authorization:'Bearer '+alice.access_token,'content-type':'application/json'},
       body:JSON.stringify({p_user:alice.user.id,p_key:key,p_retake:'nutrition',p_details:[]})});
     assert.ok([401,403,404].includes(denied.status));
    }
    assert.equal((await submit(alice,barcode,key)).body.status,r.body.status);assert.equal(providerCalls-before,1);
    const quota=await rpc('pickwell_quota_snapshot',{p_user:alice.user.id,p_metric:'ai_analysis'});assert.equal(quota.used,0);assert.equal(quota.reserved,0);
   }
   behavior='success';
  });
  await t.test('new request keys cannot evade the per-barcode daily provider-attempt cap',async()=>{
   behavior='fail';const barcode=code(),before=providerCalls;
   for(let n=0;n<3;n++)assert.equal((await submit(alice,barcode)).http,502);
   const denied=await submit(alice,barcode);assert.equal(denied.http,429);assert.equal(denied.body.error,'provider_attempt_limit');
   assert.equal(providerCalls-before,3);behavior='success';
  });
  await t.test('expired private candidates are removed and release the unspent successful-analysis slot',async()=>{
   const key=crypto.randomUUID(),barcode=code(),before=providerCalls;
   const staged=await submit(alice,barcode,key);assert.equal(staged.http,202);
   await rest('analysis_candidates?job_id=eq.'+staged.body.job_id,'PATCH',{expires_at:new Date(Date.now()-1000).toISOString()});
   assert.equal(await rpc('pickwell_prune_analysis',{}),1);
   const retry=await submit(alice,barcode,key);assert.equal(retry.body.status,'analysis_failed');assert.equal(retry.body.error,'candidate_expired');
   assert.equal(providerCalls-before,1);assert.equal((await rest('analysis_candidates?job_id=eq.'+staged.body.job_id)).length,0);
   const quota=await rpc('pickwell_quota_snapshot',{p_user:alice.user.id,p_metric:'ai_analysis'});assert.equal(quota.used,0);assert.equal(quota.reserved,0);
  });
  await t.test('spend rejection never invokes provider and releases a queued user reservation',async()=>{
   await config({global_calls_daily:1});const before=providerCalls,r=await submit(alice,code());
   assert.equal(r.http,429);assert.equal(r.body.error,'service_budget_exceeded');assert.equal(providerCalls,before);await config({global_calls_daily:100});
  });
  await t.test('timeout is unknown, keeps cost/barcode holds and cannot be retried into another paid call',async()=>{
   behavior='timeout';const barcode=code(),key=crypto.randomUUID(),before=providerCalls,r=await submit(alice,barcode,key);
   assert.equal(r.http,503);assert.equal(r.body.error,'provider_outcome_unknown');
   const repeat=await submit(alice,barcode,key);assert.equal(repeat.body.status,'processing');assert.equal(repeat.body.stage,'provider_reconciliation_required');assert.equal(repeat.body.retryable,false);
   const other=await submit(bob,barcode);assert.equal(other.body.status,'processing');assert.equal(other.body.job_id,undefined);assert.equal(providerCalls-before,1);
   const request=(await rest(`analysis_requests?user_id=eq.${alice.user.id}&idempotency_key=eq.${key}`))[0];
   const ledger=(await rest(`ai_usage?reservation_id=eq.${request.reservation_id}`))[0];assert.equal(ledger.state,'unknown');
   // Only the disposable mocked provider is known finished here. Production needs
   // explicit operator reconciliation and must never blindly clear this hold.
   await rpc('pickwell_record_provider_metrics',{p_attempt:ledger.id,p_state:'failed',p_cost:0,p_input:null,p_output:null,p_duration:0,p_estimate:null});
   await cleanup(alice,key);behavior='success';
  });
  await t.test('lost claim acknowledgement fails closed; a retry never sends an unacknowledged call',async()=>{
   claimLoss=true;const key=crypto.randomUUID(),barcode=code(),before=providerCalls;
   assert.equal((await submit(alice,barcode,key)).http,503);
   assert.equal((await submit(alice,barcode,key)).body.status,'processing');assert.equal(providerCalls,before);claimLoss=false;
   const request=(await rest(`analysis_requests?user_id=eq.${alice.user.id}&idempotency_key=eq.${key}`))[0];
   const ledger=(await rest(`ai_usage?reservation_id=eq.${request.reservation_id}`))[0];
   await rpc('pickwell_record_provider_metrics',{p_attempt:ledger.id,p_state:'failed',p_cost:0,p_input:null,p_output:null,p_duration:0,p_estimate:null});await cleanup(alice,key);
  });
  await t.test('one synthetic trusted publication is reused by parallel users with zero repeated provider calls',async()=>{
   const key=crypto.randomUUID(),barcode=code();const staged=await submit(alice,barcode,key);assert.equal(staged.http,202);
   const pending=(await rest('analysis_candidates?job_id=eq.'+staged.body.job_id))[0];
   const request=(await rest(`analysis_requests?user_id=eq.${alice.user.id}&idempotency_key=eq.${key}`))[0];
   // Trusted fixture writer exercises the existing atomic finalizer, not an
   // implementation or claim of real T05.2 interpretation/T05.3 publication.
   const product=(await rest('products','POST',{barcode,name:'SYNTHETIC ORCHESTRATION TEST',is_demo:true}))[0];
   const analysis=(await rest('product_analyses','POST',{product_id:product.id,contributor_id:alice.user.id,
    nutrition:pending.candidate.nutrition,ingredients:pending.candidate.ingredients,summary:'SYNTHETIC MOCK PROVIDER FIXTURE ONLY',
    model_version:'fixture:mock-provider',prompt_version:'fixture',rules_version:'fixture',validated_at:new Date().toISOString()}))[0];
   await rest('analysis_findings','POST',{analysis_id:analysis.id,severity:'yellow',title:'Synthetic fixture',
    explanation:'Test data, not food advice',source_details:{rule_id:'fixture',evidence:[{is_demo:true}]}});
   await rpc('pickwell_finish_usage',{p_reservation:request.reservation_id,p_outcome:'published',p_product:product.id,p_analysis:analysis.id});
   const before=providerCalls;
   const reused=await Promise.all(Array.from({length:12},(_,i)=>submit(i%2?alice:bob,barcode)));
   assert.ok(reused.every(v=>v.http===200&&v.body.status==='already_exists'&&v.body.product.is_demo===true));
   assert.equal(providerCalls,before);assert.equal((await rest('products?barcode=eq.'+barcode.padStart(14,'0'))).length,1);
   assert.equal((await submit(alice,barcode,key)).body.status,'already_exists');assert.equal(providerCalls,before);
  });
  await rest('plan_limits?plan_code=eq.free&metric=eq.ai_analysis','PATCH',{daily_limit:100,change_reason:'Disposable publication integration only'});
  await t.test('actual publication revalidates, seals facts and charges once; another guest reads without Meta',async()=>{
   deferPublication=false;const key=crypto.randomUUID(),barcode=code(),before=providerCalls;
   const quotaBefore=await rpc('pickwell_quota_snapshot',{p_user:alice.user.id,p_metric:'ai_analysis'});
   snapshotDown=true;const output=await submit(alice,barcode,key);snapshotDown=false;assert.equal(output.http,200);assert.equal(output.body.status,'ready');assert.equal(output.body.quota_unavailable,true);
   const product=output.body.product;assert.equal(product.schema_version,2);assert.equal(product.findings.length,4);
   assert.equal(product.explanations.length,2);assert.equal(product.provenance.prompt_version,'label-analysis-v2');
   assert.ok(product.findings.every(f=>f.source_details.reference&&f.source_details.evidence[0].basis==='per_100g'));
   assert.equal(providerCalls-before,1);
   assert.equal((await rest('analysis_candidates')).length,0);
   const revisions=await rest('product_analyses?product_id=eq.'+product.id);assert.equal(revisions.length,1);assert.ok(revisions[0].sealed_at);
   const quotaAfter=await rpc('pickwell_quota_snapshot',{p_user:alice.user.id,p_metric:'ai_analysis'});
   assert.equal(quotaAfter.used,quotaBefore.used+1);assert.equal(quotaAfter.reserved,0);
   await rest('plan_limits?plan_code=eq.free&metric=eq.ai_analysis','PATCH',{daily_limit:20,change_reason:'Disposable mutable response test'});
   const observed=await submit(alice,barcode,key);assert.equal(observed.body.quota.limit,20);assert.equal(observed.body.quota.used,quotaAfter.used);assert.equal(observed.body.quota.remaining,20-quotaAfter.used);
   await rest('plan_limits?plan_code=eq.free&metric=eq.ai_analysis','PATCH',{daily_limit:100,change_reason:'Restore disposable publication fixture'});
   const lookup=createGetProductHandler(env,fetcher),request=()=>new Request('http://127.0.0.1/get-product',{
    method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({barcode})});
   for(let n=0;n<2;n++){const response=await lookup(request());assert.equal(response.status,200);const body=await response.json();
    assert.equal(body.status,'ready');assert.equal(body.product.id,product.id);assert.equal(body.product.explanations.length,2);
    assert.ok(!/contributor_id|user_id|email|data:image|input_digest|refresh_token/.test(JSON.stringify(body.product)));}
   const retries=await Promise.all(Array.from({length:12},()=>submit(alice,barcode,key)));
   assert.ok(retries.every(r=>r.body.status==='already_exists'));assert.equal(providerCalls-before,1);
   assert.equal((await rest('product_analyses?product_id=eq.'+product.id)).length,1);
   assert.equal((await rpc('pickwell_quota_snapshot',{p_user:alice.user.id,p_metric:'ai_analysis'})).used,quotaAfter.used);
  });
  await t.test('OCR source/order inconsistencies publish once; impossible amounts stay unknown',async()=>{
   for(const [mode,target] of [['contradiction','nutrition'],['ingredient-order','ingredients'],['source-mismatch','nutrition'],['text-only','nutrition']]){
    behavior=mode;const key=crypto.randomUUID(),barcode=code(),before=providerCalls;
    const initial=await rpc('pickwell_quota_snapshot',{p_user:alice.user.id,p_metric:'ai_analysis'});
    const r=await submit(alice,barcode,key);assert.equal(r.http,200,mode+': '+JSON.stringify(r.body));assert.equal(r.body.status,'ready',JSON.stringify(r.body));
    if(mode==='contradiction')assert.equal(r.body.product.nutrition.nutrients[0].value,null);
    if(mode==='text-only')assert.deepEqual(r.body.product.nutrition.nutrients,[]);
    if(mode==='source-mismatch'){assert.ok(r.body.product.nutrition.nutrients.every(n=>n.value!==null));assert.deepEqual(r.body.product.findings,[]);}
    assert.equal((await submit(alice,barcode,key)).body.status,'already_exists');assert.equal(providerCalls-before,1);
    const quota=await rpc('pickwell_quota_snapshot',{p_user:alice.user.id,p_metric:'ai_analysis'});
    assert.equal(quota.used,initial.used+1);assert.equal(quota.reserved,0);
   }behavior='success';
  });
  await t.test('a valid per-serving label publishes without inventing any colour finding',async()=>{
   behavior='unclassified';const result=await submit(alice,code());behavior='success';
   assert.equal(result.body.status,'ready');assert.deepEqual(result.body.product.findings,[]);
   assert.equal(result.body.product.nutrition.basis,'per_serving');
   assert.ok(result.body.product.missing_information.some(v=>v.includes('No supported nutrition colour')));
  });
  await t.test('uncertain facts publish as unknown and survive secure candidate revalidation',async()=>{
   behavior='normalized';const barcode=code(),key=crypto.randomUUID();
   const r=await submit(alice,barcode,key);behavior='success';
   assert.equal(r.body.status,'ready',JSON.stringify(r.body));assert.equal(r.body.product.nutrition.basis,'unknown');
   assert.equal(r.body.product.nutrition.nutrients[0].value,19);assert.deepEqual(r.body.product.findings,[]);
   assert.ok(['ready','already_exists'].includes((await submit(alice,barcode,key)).body.status));
  });
  await t.test('format-equivalent numeric sources publish and replay without another model call',async()=>{
   behavior='formatted';const key=crypto.randomUUID(),barcode=code(),before=providerCalls;
   const result=await submit(alice,barcode,key);behavior='success';
   assert.equal(result.body.status,'ready');
   assert.ok(result.body.product.nutrition.nutrients.every(n=>n.value!==null));
   assert.equal(result.body.product.findings.length,4);
   assert.ok(['ready','already_exists'].includes((await submit(alice,barcode,key)).body.status));
   assert.equal(providerCalls-before,1);
  });
  await t.test('IU and qualified units publish and remain readable to a guest without another model call',async()=>{
   behavior='extended-units';const barcode=code(),key=crypto.randomUUID(),before=providerCalls;
   const r=await submit(alice,barcode,key);behavior='success';assert.equal(r.body.status,'ready',JSON.stringify(r.body));
   const vitamin=r.body.product.nutrition.nutrients.find(n=>n.name==='Vitamin D');
   assert.deepEqual(vitamin,{name:'Vitamin D',value:71,unit:'IU',source:'Vitamin D 71 IU'});
   const lookup=createGetProductHandler(env,fetcher);
   const response=await lookup(new Request('http://127.0.0.1/get-product',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({barcode})}));
   const body=await response.json();assert.equal(body.status,'ready');
   assert.deepEqual(body.product.nutrition.nutrients.find(n=>n.name==='Vitamin D'),vitamin);
   assert.equal(providerCalls-before,1);
   assert.equal(body.product.findings.filter(f=>f.title.includes(' fat ')).length,1);
  });
  await t.test('grounded interpretation publishes, caches references and requires no model on guest lookup',async()=>{
   behavior='interpreted';const barcode=code(),before=providerCalls;
   const r=await submit(alice,barcode);behavior='success';assert.equal(r.body.status,'ready',JSON.stringify(r.body));
   assert.ok(r.body.product.summary.includes('other food contributes'));assert.ok(r.body.product.provenance.interpretation_version);
   assert.ok(r.body.product.explanations.some(e=>e.references?.[0]?.id==='fda-ingredients'&&e.text.includes('reduce separation')));
   const lookup=createGetProductHandler(env,fetcher);
   const response=await lookup(new Request('http://127.0.0.1/get-product',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({barcode})}));
   const cached=await response.json();assert.equal(cached.status,'ready');assert.deepEqual(cached.product.explanations,r.body.product.explanations);
   assert.equal(providerCalls-before,1);
  });
  await t.test('operator refresh is immutable, atomic, idempotent and denied to clients without spending credits',async()=>{
   behavior='success';const r=await submit(alice,code());assert.equal(r.body.status,'ready');
   const product=(await rest('published_products?id=eq.'+r.body.product.id))[0];
   const payload=refreshInterpretationRecord(product),args={p_product:product.id,p_expected_analysis:product.analysis_id,p_expected_version:null,p_payload:payload};
   const quota=await rpc('pickwell_quota_snapshot',{p_user:alice.user.id,p_metric:'ai_analysis'}),before=providerCalls;
   const forged=structuredClone(args);forged.p_payload.nutrition.raw='Forged label';await assert.rejects(rpc('pickwell_refresh_interpretation',forged));
   await assert.rejects(rpc('pickwell_refresh_interpretation',{...args,p_expected_analysis:crypto.randomUUID()}));
   for(const token of [null,alice.access_token]){
    const response=await fetch(origin.origin+'/rest/v1/rpc/pickwell_refresh_interpretation',{method:'POST',headers:{apikey:env.SUPABASE_ANON_KEY,...(token?{Authorization:'Bearer '+token}:{}),'content-type':'application/json'},body:JSON.stringify(args)});
    assert.ok([401,403,404].includes(response.status));
   }
   const [first,second]=await Promise.all([rpc('pickwell_refresh_interpretation',args),rpc('pickwell_refresh_interpretation',args)]);
   assert.deepEqual(new Set([first.status,second.status]),new Set(['refreshed','already_current']));
   const current=(await rest('published_products?id=eq.'+product.id))[0];assert.notEqual(current.analysis_id,product.analysis_id);
   assert.deepEqual(current.nutrition,product.nutrition);assert.deepEqual(current.ingredients,product.ingredients);assert.deepEqual(current.findings,product.findings);
   assert.equal((await rest('product_analyses?product_id=eq.'+product.id)).length,2);
   assert.equal((await rpc('pickwell_quota_snapshot',{p_user:alice.user.id,p_metric:'ai_analysis'})).used,quota.used);assert.equal(providerCalls,before);
   assert.ok(current.provenance.interpretation_method.includes('no new Meta'));
  });
  await t.test('parallel publication is atomic and a lost acknowledgement never double charges',async()=>{
   deferPublication=true;const key=crypto.randomUUID(),barcode=code(),before=providerCalls;
   const staged=await submit(alice,barcode,key);assert.equal(staged.http,202);
   deferPublication=false;publicationAckLoss=true;
   const results=await Promise.all(Array.from({length:12},()=>submit(alice,barcode,key)));
   assert.ok(results.every(r=>r.http===200&&['ready','already_exists'].includes(r.body.status)));
   assert.equal(providerCalls-before,1);
   const request=(await rest(`analysis_requests?user_id=eq.${alice.user.id}&idempotency_key=eq.${key}`))[0];
   const reservation=(await rest('usage_reservations?id=eq.'+request.reservation_id))[0];
   assert.equal(reservation.state,'consumed');assert.equal(reservation.outcome,'published');
   assert.equal((await rest('products?barcode=eq.'+barcode.padStart(14,'0'))).length,1);
   assert.equal((await rest('analysis_candidates?job_id=eq.'+request.job_id)).length,0);
  });
  await t.test('failed finding insert rolls back product/revision/credit and retry can safely recover',async()=>{
   deferPublication=true;const key=crypto.randomUUID(),barcode=code();const staged=await submit(alice,barcode,key);
   assert.equal(staged.http,202);const row=(await rest('analysis_candidates?job_id=eq.'+staged.body.job_id))[0];
   const broken=structuredClone(row.candidate);broken.validation.findings[0].severity='purple';
   await rest('analysis_candidates?job_id=eq.'+row.job_id,'PATCH',{candidate:broken});
   await assert.rejects(rpc('pickwell_publish_analysis',{p_user:alice.user.id,p_key:key,p_validated:broken.validation}));
   assert.equal((await rest('products?barcode=eq.'+barcode.padStart(14,'0'))).length,0);
   assert.equal((await rest('usage_reservations?job_id=eq.'+row.job_id))[0].state,'reserved');
   assert.equal((await rest('analysis_jobs?id=eq.'+row.job_id))[0].state,'processing');
   await rest('analysis_candidates?job_id=eq.'+row.job_id,'PATCH',{candidate:row.candidate});
   deferPublication=false;assert.ok(['ready','already_exists'].includes((await submit(alice,barcode,key)).body.status));
  });
  await t.test('invalidated catalog records require operator review and cannot be overwritten by contributors',async()=>{
   const barcode=code(),key=crypto.randomUUID();
   const existing=(await rest('products','POST',{barcode,status:'invalidated',invalidated_at:new Date().toISOString(),invalidation_reason:'Synthetic operator review fixture'}))[0];
   const before=providerCalls,result=await submit(alice,barcode,key);assert.equal(result.body.status,'analysis_failed');
   assert.equal(result.body.error,'correction_review_required');
   assert.equal((await rest('products?id=eq.'+existing.id))[0].status,'invalidated');
   assert.equal((await rest('product_analyses?product_id=eq.'+existing.id)).length,0);
   const request=(await rest(`analysis_requests?user_id=eq.${alice.user.id}&idempotency_key=eq.${key}`))[0];
   assert.equal((await rest('usage_reservations?id=eq.'+request.reservation_id))[0].state,'released');
   assert.equal((await rest('analysis_candidates?job_id=eq.'+request.job_id)).length,0);
   assert.equal((await submit(alice,barcode,key)).body.status,'analysis_failed');assert.equal(providerCalls-before,1);
  });
  await t.test('changed staged facts are revalidated and rejected without spending successful-use credit',async()=>{
   deferPublication=true;const key=crypto.randomUUID(),barcode=code();const staged=await submit(alice,barcode,key);
   const row=(await rest('analysis_candidates?job_id=eq.'+staged.body.job_id))[0];
   row.candidate.nutrition.nutrients[0].value=9999;
   await rest('analysis_candidates?job_id=eq.'+row.job_id,'PATCH',{candidate:row.candidate});
   deferPublication=false;const result=await submit(alice,barcode,key);assert.equal(result.body.status,'analysis_failed');
   assert.equal(result.body.error,'invalid_model_output');
   assert.equal((await rest('analysis_candidates?job_id=eq.'+row.job_id)).length,0);
   assert.equal((await rest('products?barcode=eq.'+barcode.padStart(14,'0'))).length,0);
   assert.equal((await rest('usage_reservations?job_id=eq.'+row.job_id))[0].state,'released');
   const ledger=(await rest('ai_usage?job_id=eq.'+row.job_id))[0];assert.equal(ledger.state,'succeeded');assert.equal(ledger.input_tokens,123);
  });
  await t.test('client table/RPC grants remain denied while server staging works',async()=>{
   for(const token of [null,alice.access_token]){
    for(const resource of ['analysis_requests?select=*','analysis_candidates?select=*']){
     const r=await fetch(origin.origin+'/rest/v1/'+resource,{headers:{apikey:env.SUPABASE_ANON_KEY,...(token?{Authorization:`Bearer ${token}`}:{})}});assert.ok([401,403].includes(r.status));
    }
    const exampleJob=(await rest('analysis_jobs?user_id=eq.'+alice.user.id+'&limit=1'))[0];
    for(const [table,body] of [
     ['analysis_requests',{user_id:alice.user.id,idempotency_key:crypto.randomUUID(),barcode:'00000096385074',input_digest:'a'.repeat(64)}],
     ['analysis_candidates',{job_id:exampleJob.id,candidate:candidate(),model_version:env.META_MODEL,prompt_version:'forged'}],
    ]){
     const denied=await fetch(origin.origin+'/rest/v1/'+table,{method:'POST',headers:{apikey:env.SUPABASE_ANON_KEY,'content-type':'application/json',...(token?{Authorization:`Bearer ${token}`}:{})},body:JSON.stringify(body)});
     assert.ok([401,403].includes(denied.status));
    }
    for(const [name,body]of [['pickwell_read_analysis_candidate',{p_user:alice.user.id,p_key:crypto.randomUUID()}],
     ['pickwell_publish_analysis',{p_user:alice.user.id,p_key:crypto.randomUUID(),p_validated:{}}]]){
     const denied=await fetch(origin.origin+'/rest/v1/rpc/'+name,{method:'POST',headers:{apikey:env.SUPABASE_ANON_KEY,'content-type':'application/json',...(token?{Authorization:`Bearer ${token}`}:{})},body:JSON.stringify(body)});assert.ok([401,403].includes(denied.status));}
    const r=await fetch(origin.origin+'/rest/v1/rpc/pickwell_admit_analysis',{method:'POST',headers:{apikey:env.SUPABASE_ANON_KEY,'content-type':'application/json',...(token?{Authorization:`Bearer ${token}`}:{})},body:JSON.stringify({p_user:alice.user.id,p_key:crypto.randomUUID(),p_barcode:'96385074',p_digest:'a'.repeat(64)})});assert.ok([401,403].includes(r.status));
   }
  });
 }finally{
  await config({inference_enabled:false});
  for(const id of made)await fetch(origin.origin+'/auth/v1/admin/users/'+id,{method:'DELETE',headers:serverHeaders});
  await new Promise(resolve=>server.close(resolve));
 }
});

test('daily service admission denial reports UTC reset and explicit safe restart without provider invocation',async()=>{
 for(const denial of ['service_budget_exceeded','provider_attempt_limit']){
 const user='10000000-0000-4000-8000-000000000001',now=new Date();let provider=0,denied=false;
 const env={SUPABASE_URL:'https://fixture.supabase.co',SUPABASE_ANON_KEY:'fixture-public',SUPABASE_SERVICE_ROLE_KEY:'fixture-server',
  PICKWELL_NETWORK_HASH_SECRET:'fixture-network-secret-'.repeat(3),META_API_URL:META_URL,META_API_KEY:'fixture-provider',META_MODEL:'muse-spark-1.3'};
 const h=createAnalyzeProductHandler(env,async(url,options)=>{
  if(url===META_URL){provider++;throw Error('Forbidden model call');}
  if(url.endsWith('/auth/v1/user'))return Response.json({id:user,is_anonymous:false,email:'test@example.invalid',email_confirmed_at:'2026-01-01T00:00:00Z'});
  if(url.endsWith('/pickwell_lookup_throttle'))return Response.json({allowed:true});
  if(url.endsWith('/pickwell_admit_analysis'))return Response.json(denied?{status:'analysis_failed',error:denial}:{status:'reserved',reservation_id:crypto.randomUUID()});
  if(url.endsWith('/pickwell_begin_provider'))return Response.json({call_allowed:false,status:denial});
  if(url.endsWith('/pickwell_settle_analysis')){denied=true;return Response.json({status:'analysis_failed'});}
  if(url.endsWith('/pickwell_quota_snapshot'))return Response.json({plan:'free',limit:3,used:0,reserved:0,remaining:3,version:1,reset_at:'2026-11-04T00:00:00Z'});
  return Response.json({});
 });
 const r=await h(new Request('https://fixture.invalid',{method:'POST',headers:{Authorization:'Bearer fixture.header.signature'},body:form('96385074')})),body=await r.json();
 assert.equal(r.status,429);assert.equal(body.error,denial);assert.equal(body.retry_with_new_request,true);
 if(denial==='service_budget_exceeded'){
 const reset=new Date(body.retry_at);assert.equal(reset.getUTCHours(),0);assert.ok(reset>now);assert.ok(body.retry_after_seconds>0&&body.retry_after_seconds<=86400);
 }assert.equal(provider,0);
 const again=await h(new Request('https://fixture.invalid',{method:'POST',headers:{Authorization:'Bearer fixture.header.signature'},body:form('96385074')}));
 const replay=await again.json();assert.equal(again.status,429);assert.equal(replay.retry_with_new_request,true);assert.equal(replay.error,denial);assert.equal(provider,0);
 }
});
