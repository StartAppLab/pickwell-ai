import {test} from 'node:test';
import assert from 'node:assert/strict';
import {validateAnalysis,RULES_VERSION,analysisProfile} from '../functions/_shared/analysis_validation.mjs';
import {invokeMetaLabels,META_URL} from '../spikes/meta-vision/core.mjs';
import {labelFixture} from './fixtures/label_analysis.mjs';
const validate=c=>validateAnalysis(c,{model:'fixture:mock',now:'2026-11-03T00:00:00Z'});
const retake=(c,photo)=>{const r=validate(c);assert.equal(r.status,'needs_retake');assert.ok(r.retake.includes(photo));assert.equal(r.findings,undefined);};
const change=(c,name,value,unit='g')=>{const v=c.nutrition.nutrients.find(v=>v.name===name),old=v.source;
 v.value=value;v.unit=unit;v.source=`${name} ${value} ${unit}`;c.nutrition.raw=c.nutrition.raw.replace(old,v.source);};
test('two synthetic foods retain ordered facts, allergens, model prose and versioned evidence',()=>{
 for(const c of [labelFixture(),labelFixture({fat:18,sugars:23,salt:1.6})]){
 const r=validate(c);assert.equal(r.status,'validated');assert.equal(r.explanations.length,2);assert.equal(r.findings.length,4);
 assert.equal(r.provenance.rules_version,RULES_VERSION);assert.equal(r.provenance.model_version,'fixture:mock');
 assert.equal(r.ingredients.declared_allergens,'Contains: wheat.');assert.equal(r.score,undefined);
 for(const f of r.findings)assert.ok(c.nutrition.raw.includes(f.source_details.evidence[0].source));
 }
});
test('exact low/high boundaries and large-portion high override',()=>{
 for(const [fat,wanted]of [[3,'green'],[3.001,'yellow'],[17.5,'yellow'],[17.501,'red']]){
 assert.equal(validate(labelFixture({fat})).findings[0].severity,wanted);}
 const c=labelFixture({fat:15,portion:'200 g'});assert.equal(validate(c).findings[0].severity,'red');
 assert.equal(validate(c).findings[0].source_details.portion.triggered,true);
});
test('no extrapolation of per-serving, liquids or missing portion context into low findings',()=>{
 for(const kind of ['per_serving','liquid','unknown_portion']){
 const c=labelFixture({portion:'100 g'});if(kind==='per_serving'){c.nutrition.basis='per_serving';c.nutrition.raw=c.nutrition.raw.replace('Per 100 g','Per serving');}
 if(kind==='liquid')c.identity.food_form='liquid';if(kind==='unknown_portion')c.nutrition.serving_size=null;
 assert.equal(validate(c).status,'validated');assert.deepEqual(validate(c).findings,[]);}
});
test('unknown optional facts remain null and unclassified; no allergen absence inferred',()=>{
 const c=labelFixture();c.nutrition.nutrients.find(v=>v.name==='Salt').value=null;c.ingredients.declared_allergens=null;
 const r=validate(c);assert.equal(r.status,'validated');assert.equal(r.nutrition.nutrients.at(-1).value,null);
 assert.ok(!r.findings.some(f=>f.title.includes('salt')));assert.ok(r.missing_information.some(s=>s.includes('allergen-free')));
});
test('unreadable photo, essential unknown and explicit provider retakes target exact photo',()=>{
 let c=labelFixture();c.ingredients.items=[];retake(c,'ingredients');c=labelFixture();c.nutrition.raw=null;retake(c,'nutrition');
 c=labelFixture();c.nutrition.nutrients[0].value=null;retake(c,'nutrition');
 c=labelFixture();c.status='needs_retake';c.retake=['ingredients'];assert.deepEqual(validate(c).retake,['ingredients']);
});
test('mismatched discernible products never pass as validated',()=>{
 const c=labelFixture();c.identity.nutrition_name='Oats';c.identity.ingredients_name='Cookies';retake(c,'nutrition');retake(c,'ingredients');
});
test('malformed and nonfinite fields, model-invented colour and unknown keys fail schema',()=>{
 for(const mutate of [c=>c.score=90,c=>c.nutrition.nutrients[0].value=NaN,c=>c.nutrition.nutrients[0].value=-1,
 c=>c.nutrition.basis='per_bag',c=>c.explanations[0].severity='green']){const c=labelFixture();mutate(c);assert.throws(()=>validate(c));}
});
test('numeric source mismatch, inequalities, wrong unit and missing basis fail safely',()=>{
 for(const mutate of [c=>c.nutrition.nutrients[0].value=19,c=>c.nutrition.nutrients[0].source='Energy <180 kcal',
 c=>change(c,'Total Fat',3,'kcal'),c=>c.nutrition.raw=c.nutrition.raw.replace('Per 100 g','Facts'),
 c=>c.nutrition.serving_size='90 g',c=>change(c,'Total Fat',102)]){const c=labelFixture();mutate(c);retake(c,'nutrition');}
});
test('contradictory totals, duplicate nutrients and mass/energy discrepancies fail safely',()=>{
 for(const mutate of [c=>change(c,'Saturated Fat',8),c=>change(c,'Total Sugars',40),
 c=>c.nutrition.nutrients.push({...c.nutrition.nutrients[1],name:'Fat'}),
 c=>change(c,'Protein',90),c=>{c.nutrition.nutrients.push({name:'Energy',value:20,unit:'kJ',source:'Energy 20 kJ'});c.nutrition.raw+=' Energy 20 kJ';}]){
 const c=labelFixture();mutate(c);retake(c,'nutrition');}
});
test('ingredient ordering, duplicates, fabricated allergen text and absent spans fail',()=>{
 for(const mutate of [c=>c.ingredients.items.reverse(),c=>c.ingredients.items.push('salt'),
 c=>c.ingredients.declared_allergens='Contains: nuts.',c=>c.ingredients.items.push('butter')]){
 const c=labelFixture();mutate(c);retake(c,'ingredients');}
});
test('unsupported model claims or invented numbers are omitted, never determine colour',()=>{
 const c=labelFixture();c.explanations=[{photo:'ingredients',source:'Oats',text:'Oats prevent disease and are healthy.'},
 {photo:'nutrition',source:'Total Fat 3 g',text:'Zero calories.'}];
 const r=validate(c);assert.equal(r.explanations.length,0);assert.equal(r.findings.length,4);
});
test('v2 adapter uses the approved endpoint and one bounded two-image request',async()=>{
 let calls=0;const c=labelFixture(),metadata={};
 const r=await invokeMetaLabels({META_API_KEY:'mock-only',META_MODEL:'muse-spark-1.3'},
 {nutrition_image:'private nutrition',ingredients_image:'private ingredients'},metadata,async(url,options)=>{
 calls++;assert.equal(url,META_URL);const body=JSON.parse(options.body);assert.equal(body.response_format.json_schema.name,'label_analysis_v2');
 assert.equal(body.messages[1].content.filter(v=>v.type==='image_url').length,2);assert.equal(body.max_completion_tokens,4096);
 return Response.json({model:'muse-spark-1.3',usage:{prompt_tokens:100,completion_tokens:200},choices:[{finish_reason:'stop',message:{content:JSON.stringify(c)}}]});
 },analysisProfile);assert.equal(calls,1);assert.equal(validate(r.candidate).status,'validated');assert.equal(metadata.usage.input_tokens,100);
});

test('legitimate repeated compound ingredients, printed mcg and added-sugar word order are supported',()=>{
 const c=labelFixture();c.ingredients.raw='Oats (salt), wheat flour (salt).';c.ingredients.items=['Oats','salt','wheat flour','salt'];c.ingredients.declared_allergens=null;
 c.nutrition.nutrients.push({name:'Vitamin D',value:0,unit:'ug',source:'Vitamin D 0 mcg'},
 {name:'Includes Added Sugars',value:2,unit:'g',source:'Includes 2 g Added Sugars'});
 c.nutrition.raw+=' Vitamin D 0 mcg; Includes 2 g Added Sugars';assert.equal(validate(c).status,'validated');
 c.nutrition.nutrients.at(-1).value=7;retake(c,'nutrition');
});
test('cropped markers and oversized structured handoff cannot pass a publication candidate',()=>{
 const c=labelFixture();c.ingredients.raw+=' [cropped]';retake(c,'ingredients');
 const large=labelFixture();large.ingredients.raw='a'.repeat(12000);large.ingredients.items=['a'.repeat(12000)];large.ingredients.declared_allergens='a'.repeat(12000);
 assert.throws(()=>validate(large),/invalid_model_output/);
});
