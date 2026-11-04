import {test} from 'node:test';
import assert from 'node:assert/strict';
import {deflateSync} from 'node:zlib';
import {readAnalysisInput,BODY_BYTES,IMAGE_BYTES} from '../functions/_shared/analysis_input.mjs';
import {validateAnalysis,analysisProfile,legacyAnalysisProfile,PROMPT_VERSION,LEGACY_PROMPT_VERSION} from '../functions/_shared/analysis_validation.mjs';
import {publishAnalysis} from '../functions/_shared/analysis_publication.mjs';
import {sanitizePublishedProduct} from '../functions/_shared/catalog_boundary.mjs';
import {retakePhotos,retakeTarget,sanitizeRetakeDetails} from '../functions/_shared/retake_details.mjs';
import {invokeMetaLabels} from '../spikes/meta-vision/core.mjs';
import {frontLabelFixture,labelFixture} from './fixtures/label_analysis.mjs';
const validate=c=>validateAnalysis(c,{model:'muse-spark-1.3',now:'2026-11-04T00:00:00Z',requireFront:true});
const crcTable=Uint32Array.from({length:256},(_,n)=>{for(let k=0;k<8;k++)n=(n&1)?0xedb88320^(n>>>1):n>>>1;return n>>>0;});
function chunk(name,data){const payload=Buffer.concat([Buffer.from(name),data]);let crc=0xffffffff;for(const b of payload)crc=crcTable[(crc^b)&255]^(crc>>>8);const n=Buffer.alloc(4),end=Buffer.alloc(4);n.writeUInt32BE(data.length);end.writeUInt32BE((crc^0xffffffff)>>>0);return Buffer.concat([n,payload,end]);}
function png(color){const h=Buffer.alloc(13);h.writeUInt32BE(32,0);h.writeUInt32BE(32,4);h[8]=8;h[9]=6;const pixels=Buffer.alloc(32*129,color);for(let n=0;n<32;n++)pixels[n*129]=0;return Buffer.concat([Buffer.from([137,80,78,71,13,10,26,10]),chunk('IHDR',h),chunk('IDAT',deflateSync(pixels)),chunk('IEND',Buffer.alloc(0))]);}
function request({front=10,missing=false,duplicate=false,bad=false}={}){const f=new FormData();f.set('barcode','036000291452');f.set('idempotency_key','11111111-1111-4111-8111-111111111111');if(!missing)f.set('front_image',new Blob([bad?Buffer.from('not an image'):png(duplicate?20:front)]),'f.png');f.set('nutrition_image',new Blob([png(20)]),'n.png');f.set('ingredients_image',new Blob([png(30)]),'i.png');return new Request('https://test.invalid',{method:'POST',body:f});}
test('three-image input is mandatory, distinct and included in ordered digest',async()=>{
 const a=await readAnalysisInput(request()),same=await readAnalysisInput(request()),changed=await readAnalysisInput(request({front:11}));
 assert.equal(a.digest,same.digest);assert.notEqual(a.digest,changed.digest);assert.equal(a.barcode,'00036000291452');assert.equal(Object.keys(a.images).length,3);assert.equal(BODY_BYTES,3*IMAGE_BYTES+65536);
 for(const options of [{missing:true},{duplicate:true},{bad:true}])await assert.rejects(readAnalysisInput(request(options)));
});
test('front observation fields are preserved, unknowns accepted and ownership explicitly unverified',()=>{
 const c=frontLabelFixture();Object.assign(c.identity.front,{brand:'Fixture brand',variant:'Original',net_quantity:'500 g'});
 const v=validate(c);assert.equal(v.status,'validated');assert.equal(v.provenance.identity.front.net_quantity,'500 g');assert.equal(v.provenance.identity_verification,'unverified');assert.equal(v.provenance.prompt_version,PROMPT_VERSION);
 for(const name of [null,'']){c.identity.front.product_name=name;assert.equal(validate(c).status,'validated');}
 c.status='needs_retake';c.retake=['front'];c.retake_reasons=[{photo:'front',code:'unreadable_text',field:'product_identity'}];assert.equal(validate(c).status,'validated','Unknown name is not by itself a failed photo');
});
test('wrong front photo is actionable without discarding usable labels',()=>{
 const c=frontLabelFixture();c.retake_reasons=[{photo:'front',code:'wrong_photo',field:'product_identity'}];
 const r=validate(c);assert.equal(r.status,'needs_retake');assert.deepEqual(r.retake,['front']);assert.equal(r.reason_details[0].field,'product_identity');
});
test('explicit name conflict cannot be overridden by a consistent model enum',()=>{
 const c=frontLabelFixture();c.identity.front.product_name='Oats';c.identity.nutrition.product_name='Cookies';
 c.identity.consistency='consistent';c.identity.conflicts=[{field:'product_name',photos:['front','nutrition']}];
 assert.equal(validate(c).status,'validated');assert.deepEqual(validate(c).provenance.identity_review_photos,['front','nutrition']);
});
test('brand, flavor and same-brand net-quantity contradictions flag only relevant photos',()=>{
 for(const field of ['brand','variant','net_quantity']){
  const c=frontLabelFixture();c.identity.consistency='consistent';c.identity.front.brand=c.identity.ingredients.brand='Same brand';
  c.identity.front[field]=field==='net_quantity'?'500 g':'Chocolate';c.identity.ingredients[field]=field==='net_quantity'?'250 g':'Vanilla';
  const r=validate(c);assert.equal(r.status,'validated');assert.deepEqual(r.provenance.identity_review_photos,['front','ingredients']);
 }
});
test('equivalent net amounts and extended brand wording are not false conflicts',()=>{
 const c=frontLabelFixture();Object.assign(c.identity.front,{brand:'Fixture',net_quantity:'0.5 kg'});Object.assign(c.identity.nutrition,{brand:'Fixture Foods',net_quantity:'500 g'});
 assert.equal(validate(c).status,'validated');c.identity.front.brand='Néstle';c.identity.nutrition.brand='Nestle';assert.equal(validate(c).status,'validated');c.identity.nutrition.net_quantity=null;assert.equal(validate(c).status,'validated');
});
test('malformed observations and one-photo conflict actions fail closed',()=>{
 const c=frontLabelFixture();c.identity.conflicts=[{field:'brand',photos:['front']}];assert.throws(()=>validate(c),/invalid_model_output/);
 assert.throws(()=>validate(labelFixture()),/invalid_model_output/);
 const b=frontLabelFixture();b.identity.front.verified=true;assert.throws(()=>analysisProfile.parse(b));
});
test('front subsets survive retake group conversion and diagnostics redaction',()=>{
 for(const targets of [['front'],['front','nutrition'],['front','ingredients'],['front','nutrition','ingredients'],['nutrition','ingredients']])assert.deepEqual(retakePhotos(retakeTarget(targets)),targets);
 assert.deepEqual(sanitizeRetakeDetails([{photo:'front',source:'validation',code:'product_mismatch',field:'product_identity',token:'private'}],['front']),[{photo:'front',source:'validation',code:'product_mismatch',field:'product_identity'}]);
});
test('one bounded Muse call includes front then both labels, no assumed same-product claim',async()=>{
 let calls=0;const c=frontLabelFixture();
 await invokeMetaLabels({META_MODEL:'muse-spark-1.3',META_API_KEY:'fixture'}, {front_image:'front-bytes',nutrition_image:'nutrition-bytes',ingredients_image:'ingredient-bytes'},{},async(url,options)=>{
  calls++;const body=JSON.parse(options.body);assert.deepEqual(body.messages[1].content.filter(v=>v.type==='image_url').map(v=>v.image_url.url),['front-bytes','nutrition-bytes','ingredient-bytes']);assert.equal(body.store,false);assert.ok(body.messages[1].content[0].text.includes('may belong to different products'));assert.equal(body.max_completion_tokens,4096);return Response.json({model:'muse-spark-1.3',choices:[{finish_reason:'stop',message:{content:JSON.stringify(c)}}]});
 },analysisProfile);assert.equal(calls,1);
});
test('publication revalidation accepts new observations and legacy results remain compatible',async()=>{
 for(const [candidate,version]of [[frontLabelFixture(),PROMPT_VERSION],[labelFixture(),LEGACY_PROMPT_VERSION]]){
  const validation=validateAnalysis(candidate,{model:'muse-spark-1.3',now:'2026-11-04T00:00:00Z'});let publishes=0;
  const result=await publishAnalysis(async(name,args)=>{
   if(name==='pickwell_read_analysis_candidate')return {candidate:{...candidate,validation},prompt_version:version,model_version:'muse-spark-1.3'};
   if(name==='pickwell_deliver_private_analysis')return {status:'private_ready'};
   if(name==='pickwell_publication_gate')return {status:'approved',review_id:'11111111-1111-4111-8111-111111111111',barcode:'00036000291452',input_digest:'a'.repeat(64),candidate_digest:'b'.repeat(64),policy_version:'trust-publication-v1'};
   assert.equal(name,'pickwell_publish_analysis');publishes++;assert.deepEqual(args.p_validated,validation);return {status:'ready'};
  },{},()=>{throw Error('unexpected settlement');});assert.equal(result.status,'ready');assert.equal(publishes,1);
 }
});
test('sanitized public identity contains observations, never contributor or verification authority',()=>{
 const c=frontLabelFixture(),v=validate(c);v.provenance.identity.front.token='private';v.provenance.identity_verification='verified';
 const p=sanitizePublishedProduct({nutrition:v.nutrition,ingredients:v.ingredients,provenance:v.provenance,contributor_email:'private@example.invalid'});
 assert.equal(p.provenance.identity.front.token,undefined);assert.equal(p.provenance.identity_verification,'unverified');assert.equal(p.contributor_email,undefined);
 assert.equal(sanitizePublishedProduct({nutrition:{},ingredients:{},provenance:{}}).provenance.identity,undefined);
});

test('authenticated handler keeps all image bytes request-local and cached retry makes no second model call',async()=>{
 const {createAnalyzeProductHandler}=await import('../functions/_shared/analyze_product.mjs');
 let provider=0,candidate=null,published=null;
 const written=[];const user='aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
 const handler=createAnalyzeProductHandler({SUPABASE_URL:'https://test.supabase.co',SUPABASE_ANON_KEY:'fixture',SUPABASE_SERVICE_ROLE_KEY:'fixture-private',PICKWELL_NETWORK_HASH_SECRET:'fixture-network-secret-'.repeat(3),META_API_KEY:'fixture-model-key',META_API_URL:'https://api.meta.ai/v1/chat/completions',META_MODEL:'muse-spark-1.3'},async(url,options={})=>{
  if(url.endsWith('/auth/v1/user'))return Response.json({id:user,email:'fixture@example.invalid',email_confirmed_at:'2026-11-04T00:00:00Z',is_anonymous:false});
  if(url==='https://api.meta.ai/v1/chat/completions'){
   provider++;const body=JSON.parse(options.body);assert.equal(body.messages[1].content.filter(x=>x.type==='image_url').length,3);
   return Response.json({model:'muse-spark-1.3',choices:[{finish_reason:'stop',message:{content:JSON.stringify(frontLabelFixture())}}]});
  }
  const name=url.split('/').at(-1),body=JSON.parse(options.body);written.push({name,body});
  if(name==='pickwell_lookup_throttle')return Response.json({allowed:true});
  if(name==='pickwell_quota_snapshot')return Response.json({plan:'free',limit:3,used:published?1:0,reserved:0,remaining:published?2:3});
  if(name==='pickwell_admit_analysis')return Response.json(published?{status:'already_exists',product:published}:{status:'reserved',reservation_id:'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',job_id:'cccccccc-cccc-4ccc-8ccc-cccccccccccc'});
  if(name==='pickwell_begin_provider')return Response.json({call_allowed:true,attempt_id:'dddddddd-dddd-4ddd-8ddd-dddddddddddd',model:'muse-spark-1.3'});
  if(name==='pickwell_record_provider_metrics')return Response.json({status:'succeeded'});
  if(name==='pickwell_stage_analysis'){candidate={candidate:body.p_candidate,model_version:body.p_model,prompt_version:body.p_prompt};return Response.json({status:'processing'});}
  if(name==='pickwell_read_analysis_candidate')return Response.json(candidate);
  if(name==='pickwell_deliver_private_analysis')return Response.json({status:'private_ready'});
  if(name==='pickwell_publication_gate')return Response.json({status:'approved',review_id:'11111111-1111-4111-8111-111111111111',barcode:'00036000291452',input_digest:'a'.repeat(64),candidate_digest:'b'.repeat(64),policy_version:'trust-publication-v1'});
  if(name==='pickwell_publish_analysis'){
   const v=body.p_validated;published={id:'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',barcode:'00036000291452',nutrition:v.nutrition,ingredients:v.ingredients,provenance:v.provenance,findings:v.findings,missing_information:v.missing_information};candidate=null;return Response.json({status:'ready',product:published});
  }
  throw Error('Unexpected RPC '+name);
 });
 const authenticated=()=>{const r=request();return new Request(r,{headers:{...Object.fromEntries(r.headers),authorization:'Bearer e30.e30.fixture'}});};
 const first=await handler(authenticated());assert.equal(first.status,200);assert.equal((await first.json()).status,'ready');
 const second=await handler(authenticated());assert.equal((await second.json()).status,'already_exists');assert.equal(provider,1);
 assert.ok(written.some(x=>x.name==='pickwell_stage_analysis'));assert.ok(!JSON.stringify(written).includes('data:image'));assert.ok(!JSON.stringify(published).includes('front_image'));
});

test('historical protected two-image spike retains v2 identity and truthful two-photo provenance',async()=>{
 const c=labelFixture();let body;
 const r=await invokeMetaLabels({META_MODEL:'muse-spark-1.3',META_API_KEY:'fixture'},{nutrition_image:'n',ingredients_image:'i'},{},async(url,options)=>{
  body=JSON.parse(options.body);return Response.json({model:'muse-spark-1.3',choices:[{finish_reason:'stop',message:{content:JSON.stringify(c)}}]});
 },legacyAnalysisProfile);
 assert.equal(body.messages[1].content.filter(x=>x.type==='image_url').length,2);assert.equal(body.response_format.json_schema.name,'label_analysis_v2');
 assert.equal(validateAnalysis(r.candidate).provenance.prompt_version,LEGACY_PROMPT_VERSION);assert.ok(validateAnalysis(r.candidate).provenance.extraction_source.startsWith('two '));
});
