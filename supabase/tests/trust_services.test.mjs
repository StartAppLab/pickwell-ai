import {test} from 'node:test';
import assert from 'node:assert/strict';
import {deflateSync} from 'node:zlib';
import {createAnalyzeProductHandler} from '../functions/_shared/analyze_product.mjs';
import {createCancelAnalysisReviewHandler} from '../functions/_shared/cancel_analysis_review.mjs';
import {ingredientSupportedByRaw,normalizeIngredientEvidence} from '../functions/_shared/ingredient_evidence.mjs';
import {validateAnalysis} from '../functions/_shared/analysis_validation.mjs';
import {sanitizePublishedProduct} from '../functions/_shared/catalog_boundary.mjs';
import {reviewDecisionPlan} from '../scripts/review-product.mjs';
import {frontLabelFixture} from './fixtures/label_analysis.mjs';
const uid='aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',key='bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';
const env={SUPABASE_URL:'https://test.supabase.co',SUPABASE_ANON_KEY:'fixture',SUPABASE_SERVICE_ROLE_KEY:'fixture-server',PICKWELL_NETWORK_HASH_SECRET:'fixture-hash-secret-'.repeat(3),META_MODEL:'muse-spark-1.3',META_API_URL:'https://api.meta.ai/v1/chat/completions',META_API_KEY:'fixture-no-real-provider'};
const crcTable=Uint32Array.from({length:256},(_,n)=>{for(let k=0;k<8;k++)n=(n&1)?0xedb88320^(n>>>1):n>>>1;return n>>>0;});
function chunk(name,data){const all=Buffer.concat([Buffer.from(name),data]);let crc=0xffffffff;for(const b of all)crc=crcTable[(crc^b)&255]^(crc>>>8);const size=Buffer.alloc(4),end=Buffer.alloc(4);size.writeUInt32BE(data.length);end.writeUInt32BE((crc^0xffffffff)>>>0);return Buffer.concat([size,all,end]);}
function png(color){const h=Buffer.alloc(13);h.writeUInt32BE(32,0);h.writeUInt32BE(32,4);h[8]=8;h[9]=6;const pixels=Buffer.alloc(32*129,color);for(let n=0;n<32;n++)pixels[n*129]=0;return Buffer.concat([Buffer.from([137,80,78,71,13,10,26,10]),chunk('IHDR',h),chunk('IDAT',deflateSync(pixels)),chunk('IEND',Buffer.alloc(0))]);}
function submission(extra=false){const f=new FormData();f.set('barcode','036000291452');f.set('idempotency_key',key);for(const [i,p] of ['front','nutrition','ingredients'].entries())f.set(p+'_image',new Blob([png(10+i)]),p+'.png');if(extra)f.set('approved','true');return new Request('https://test.invalid',{method:'POST',body:f,headers:{Authorization:'Bearer e30.e30.fixture'}});}
test('A barcode/B evidence stays pending; replay cannot rerun Muse or publish until operator approval',async()=>{
 let approved=false,published=false,modelCalls=0,candidate;const writes=[];
 const h=createAnalyzeProductHandler(env,async(url,options={})=>{
  if(url.endsWith('/auth/v1/user'))return Response.json({id:uid,is_anonymous:false,email:'fixture@example.invalid',email_confirmed_at:'2026-11-04T00:00:00Z'});
  if(url===env.META_API_URL){modelCalls++;const c=frontLabelFixture();for(const p of ['front','nutrition','ingredients'])c.identity[p].product_name='Product B';c.identity.consistency='consistent';return Response.json({model:env.META_MODEL,choices:[{finish_reason:'stop',message:{content:JSON.stringify(c)}}]});}
  const name=url.split('/').at(-1),body=JSON.parse(options.body);writes.push({name,body});
  if(name==='pickwell_lookup_throttle')return Response.json({allowed:true});
  if(name==='pickwell_quota_snapshot')return Response.json({limit:3,used:published?1:0,reserved:published?0:1,remaining:2});
  if(name==='pickwell_admit_analysis')return Response.json(published?{status:'already_exists',product:published}:candidate?{status:'review_required'}:{status:'reserved',reservation_id:key,job_id:uid});
  if(name==='pickwell_begin_provider')return Response.json({call_allowed:true,attempt_id:key,model:env.META_MODEL});
  if(name==='pickwell_record_provider_metrics')return Response.json({status:'succeeded'});
  if(name==='pickwell_stage_analysis'){candidate={candidate:body.p_candidate,model_version:body.p_model,prompt_version:body.p_prompt};return Response.json({status:'processing'});}
  if(name==='pickwell_read_analysis_candidate')return Response.json(candidate);
  if(name==='pickwell_publication_gate')return Response.json(approved?{status:'approved',review_id:key,barcode:'00036000291452',input_digest:'a'.repeat(64),candidate_digest:'b'.repeat(64),policy_version:'trust-publication-v1'}:{status:'review_required',job_id:uid,review_expires_at:'2026-12-01T00:00:00Z'});
  if(name==='pickwell_publish_analysis'){assert.ok(approved);published={...body.p_validated,id:key,barcode:'00036000291452'};return Response.json({status:'ready',product:published});}
  throw Error('Unexpected RPC '+name);
 });
 for(let n=0;n<3;n++){const r=await h(submission());assert.equal(r.status,202);const body=await r.json();assert.equal(body.status,'review_required');assert.equal(body.product,undefined);assert.equal(body.quota.used,0);}
 assert.equal(modelCalls,1);assert.ok(!writes.some(w=>w.name==='pickwell_publish_analysis'||w.name==='pickwell_decide_product_review'));
 assert.equal((await h(submission(true))).status,400);assert.equal(modelCalls,1);
 approved=true;assert.equal((await (await h(submission())).json()).status,'ready');assert.equal(modelCalls,1);
 assert.equal((await (await h(submission())).json()).status,'already_exists');assert.equal(modelCalls,1);
 assert.ok(!JSON.stringify(writes).includes('data:image'));assert.ok(!JSON.stringify(published).includes('front_image'));
});
test('clear name/brand/variant/size conflicts are review evidence, not blanket retakes or proof of abuse',()=>{
 for(const field of ['product_name','brand','variant','net_quantity']){
  const c=frontLabelFixture();c.identity.consistency='consistent';c.identity.front[field]=field==='net_quantity'?'500 g':'Chocolate';c.identity.ingredients[field]=field==='net_quantity'?'250 g':'Vanilla';
  const r=validateAnalysis(c);assert.equal(r.status,'validated');assert.equal(r.provenance.cross_image_consistency,'review_required');assert.deepEqual(r.provenance.identity_review_photos,['front','ingredients']);
 }
 const c=frontLabelFixture();c.identity.front.product_name='Arroz';c.identity.nutrition.product_name='Rice';assert.equal(validateAnalysis(c).status,'validated');
});
test('unsupported structured ingredient/citation cannot assert presence; partial/bilingual/punctuation/OCR remain usable',()=>{
 for(const [item,raw]of [['Soy Lecithin','Soy lecithin, salt.'],['Soy Lecithin','Soy lecitin, salt.'],['Salt','Sal'],['Milk / Gatas','Milk, oats.'],['Citric acid','citric-acid; oats']])assert.equal(ingredientSupportedByRaw(item,raw),true,item);
 const c=frontLabelFixture();c.ingredients.items.push('Soy Lecithin');c.interpretation.ingredients=[{index:3,reference_id:'emulsifier',text:'unsupported'}];c.interpretation.summary_ingredients=[3];
 const normalized=normalizeIngredientEvidence(c);assert.ok(!normalized.ingredients.items.includes('Soy Lecithin'));assert.deepEqual(normalized.interpretation.ingredients,[]);
 const r=validateAnalysis(c);assert.equal(r.status,'validated');assert.ok(!r.explanations.some(e=>e.ingredient==='Soy Lecithin'));
 const empty=frontLabelFixture();empty.ingredients.raw='[unknown]';empty.ingredients.items=['invented'];assert.equal(validateAnalysis(empty).status,'validated');assert.deepEqual(validateAnalysis(empty).ingredients.items,[]);
});
test('ingredient absence claims cannot establish ingredient presence',()=>{
 for(const raw of ['Sugar-free','No sugar','No added sugar','Without sugar','Sans sugar'])assert.equal(ingredientSupportedByRaw('Sugar',raw),false);
});
test('legacy public projection suppresses unsupported ingredient summary and keeps identity unverified',()=>{
 const c=frontLabelFixture();c.ingredients.items.push('Soy Lecithin');const safe=sanitizePublishedProduct({ingredients:c.ingredients,nutrition:c.nutrition,summary:'Soy lecithin is present.',provenance:{barcode_association:{status:'independently_verified'}}});
 assert.ok(!safe.ingredients.items.includes('Soy Lecithin'));assert.ok(!safe.summary.includes('Soy lecithin is present'));assert.equal(safe.provenance.barcode_association.status,'unverified');
});
test('operator decision defaults to exact evidence and explicit policy/reference, not an account or barcode allowlist',()=>{
 const review={review_id:key,barcode:'00036000291452',input_digest:'a'.repeat(64),candidate_digest:'b'.repeat(64),policy_version:'trust-publication-v1',state:'pending',expires_at:new Date(Date.now()+60000).toISOString(),candidate:{validation:{provenance:{cross_image_consistency:'consistent'}}}};
 const opts={decision:'approve',reference:'test-review-001',basis:'package_barcode_evidence',resolution:'no_discrepancy'};
 assert.equal(reviewDecisionPlan(review,review.input_digest,opts).p_candidate_digest,review.candidate_digest);
 assert.throws(()=>reviewDecisionPlan(review,'c'.repeat(64),opts));assert.throws(()=>reviewDecisionPlan(review,review.input_digest,{...opts,basis:'model_confidence'}));
 assert.throws(()=>reviewDecisionPlan(review,review.input_digest,{...opts,reference:'private@example.invalid'}));
 review.candidate.validation.provenance.cross_image_consistency='review_required';assert.throws(()=>reviewDecisionPlan(review,review.input_digest,opts));
 assert.equal(reviewDecisionPlan(review,review.input_digest,{...opts,resolution:'wording_variation_reviewed'}).p_decision,'approve');
});
test('cancel endpoint verifies ownership from Auth and cannot receive approval authority',async()=>{
 let cancels=0;const h=createCancelAnalysisReviewHandler(env,async(url,options={})=>{
  if(url.endsWith('/auth/v1/user'))return Response.json({id:uid,is_anonymous:false,email:'fixture@example.invalid',email_confirmed_at:'2026-11-04T00:00:00Z'});
  const name=url.split('/').at(-1),body=JSON.parse(options.body);
  if(name==='pickwell_lookup_throttle')return Response.json({allowed:true});
  if(name==='pickwell_quota_snapshot')return Response.json({used:0,reserved:0});
  assert.equal(name,'pickwell_cancel_analysis_review');assert.deepEqual(body,{p_user:uid,p_key:key});cancels++;return Response.json({status:'review_cancelled',barcode:'00036000291452'});
 });
 assert.equal((await h(new Request('https://test.invalid',{method:'POST'}))).status,401);
 const call=body=>h(new Request('https://test.invalid',{method:'POST',headers:{Authorization:'Bearer e30.e30.fixture','content-type':'application/json'},body:JSON.stringify(body)}));
 assert.equal((await call({request_id:key,p_user:'someone-else',approved:true})).status,400);assert.equal(cancels,0);
 assert.equal((await (await call({request_id:key})).json()).status,'review_cancelled');assert.equal(cancels,1);
});
