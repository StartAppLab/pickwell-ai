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
test('empty label text still targets the missing photo; partial model retakes proceed',()=>{
 let c=labelFixture();c.ingredients.raw=null;retake(c,'ingredients');
 c=labelFixture();c.nutrition.raw=null;retake(c,'nutrition');
 c=labelFixture();c.status='needs_retake';c.retake=['nutrition'];c.nutrition.nutrients[0].value=null;
 assert.equal(validate(c).status,'validated');assert.equal(validate(c).nutrition.nutrients[0].value,null);
});

test('mismatched discernible products never pass as validated',()=>{
 const c=labelFixture();c.identity.nutrition_name='Oats';c.identity.ingredients_name='Cookies';c.identity.consistency='mismatch';retake(c,'nutrition');retake(c,'ingredients');
});
test('malformed and nonfinite fields, model-invented colour and unknown keys fail schema',()=>{
 for(const mutate of [c=>c.score=90,c=>c.nutrition.nutrients[0].value=NaN,c=>c.nutrition.nutrients[0].value=-1,
 c=>c.nutrition.basis='per_bag',c=>c.explanations[0].severity='green']){const c=labelFixture();mutate(c);assert.throws(()=>validate(c));}
});
test('model transcription is displayed; invalid units and impossible amounts become unknown',()=>{
 const c=labelFixture();c.nutrition.nutrients[0].value=19;
 assert.equal(validate(c).nutrition.nutrients[0].value,19);
 for(const mutate of [c=>change(c,'Total Fat',3,'kcal'),c=>change(c,'Total Fat',102)]){
 const c=labelFixture();mutate(c);const r=validate(c);assert.equal(r.status,'validated');
 assert.equal(r.nutrition.nutrients.find(n=>n.name==='Total Fat').value,null);
 assert.ok(!r.findings.some(f=>f.title.includes(' fat ')));
 }
});

test('contradictory totals, duplicate nutrients and mass/energy discrepancies become unknown',()=>{
 for(const mutate of [c=>change(c,'Saturated Fat',8),c=>change(c,'Total Sugars',40),
 c=>c.nutrition.nutrients.push({...c.nutrition.nutrients[1],name:'Fat'}),
 c=>change(c,'Protein',90),c=>{c.nutrition.nutrients.push({name:'Energy',value:20,unit:'kJ',source:'Energy 20 kJ'});c.nutrition.raw+=' Energy 20 kJ';}]){
 const c=labelFixture();mutate(c);const r=validate(c);assert.equal(r.status,'validated');
 assert.ok(r.nutrition.nutrients.some(n=>n.value===null));
 const normalized={...c,nutrition:r.nutrition,ingredients:r.ingredients};
 const staged=validate(normalized);
 const replay=validate({...normalized,nutrition:staged.nutrition,ingredients:staged.ingredients});
 assert.deepEqual(staged,replay);
 }
});

test('ingredient transcription differences do not require retake; unsupported allergens stay unknown',()=>{
 for(const mutate of [c=>c.ingredients.items.reverse(),c=>c.ingredients.items.push('salt'),
 c=>c.ingredients.items.push('butter'),c=>c.ingredients.items=[]]){
 const c=labelFixture();mutate(c);const r=validate(c);assert.equal(r.status,'validated');assert.ok(r.ingredients.items.length);
 }
 const c=labelFixture();c.ingredients.declared_allergens='Contains: nuts.';
 assert.equal(validate(c).ingredients.declared_allergens,null);
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
 assert.ok(body.messages[0].content.includes('must proceed'));
 assert.ok(!body.messages[0].content.includes('Use null/unknown and needs_retake for unreadable/mismatched labels.'));
 assert.ok(body.response_format.json_schema.schema.properties.retake_reasons);
 return Response.json({model:'muse-spark-1.3',usage:{prompt_tokens:100,completion_tokens:200},choices:[{finish_reason:'stop',message:{content:JSON.stringify(c)}}]});
 },analysisProfile);assert.equal(calls,1);assert.equal(validate(r.candidate).status,'validated');assert.equal(metadata.usage.input_tokens,100);
});

test('legitimate repeated compound ingredients, printed mcg and added-sugar word order are supported',()=>{
 const c=labelFixture();c.ingredients.raw='Oats (salt), wheat flour (salt).';c.ingredients.items=['Oats','salt','wheat flour','salt'];c.ingredients.declared_allergens=null;
 c.nutrition.nutrients.push({name:'Vitamin D',value:0,unit:'ug',source:'Vitamin D 0 mcg'},
 {name:'Includes Added Sugars',value:2,unit:'g',source:'Includes 2 g Added Sugars'});
 c.nutrition.raw+=' Vitamin D 0 mcg; Includes 2 g Added Sugars';assert.equal(validate(c).status,'validated');
 c.nutrition.nutrients.at(-1).value=7;assert.equal(validate(c).nutrition.nutrients.at(-1).value,null);
});
test('partial ingredient markers proceed; oversized structured handoff still fails',()=>{
 const c=labelFixture();c.ingredients.raw+=' [cropped]';assert.equal(validate(c).status,'validated');
 const large=labelFixture();large.ingredients.raw='a'.repeat(12000);large.ingredients.items=['a'.repeat(12000)];large.ingredients.declared_allergens='a'.repeat(12000);
 assert.throws(()=>validate(large),/invalid_model_output/);
});

test('contextually resolved nutrient names, punctuation and abbreviated identity do not force retakes',()=>{
 const c=labelFixture();c.identity.nutrition_name='Oat Food';c.identity.ingredients_name='Oat Food - 200g';
 c.ingredients.items[0]='OATS';
 const protein=c.nutrition.nutrients.find(v=>v.name==='Protein');c.nutrition.raw=c.nutrition.raw.replace(protein.source,'Prot..n 5 g');protein.source='Prot..n 5 g';protein.value=5;
 const before=structuredClone(c),r=validate(c);assert.equal(r.status,'validated');assert.equal(r.nutrition.nutrients.find(v=>v.name==='Protein').value,5);
 assert.deepEqual(c,before);assert.equal(r.provenance.extraction_policy,'model-transcription-v4');
});
test('readable text with unknown or absent numeric fields can proceed',()=>{
 const c=labelFixture();for(const n of c.nutrition.nutrients)n.value=null;
 let r=validate(c);assert.equal(r.status,'validated');assert.deepEqual(r.findings,[]);
 c.nutrition.nutrients=[];r=validate(c);assert.equal(r.status,'validated');assert.deepEqual(r.nutrition.nutrients,[]);
 assert.ok(r.missing_information.some(s=>s.includes('Numeric nutrition')));
});

test('unmatched OCR source remains displayed but cannot produce a colour',()=>{
 const c=labelFixture();c.nutrition.nutrients.find(n=>n.name==='Total Sugars').source='Sugars unclear';
 const r=validate(c);assert.equal(r.status,'validated');assert.equal(r.nutrition.nutrients.find(n=>n.name==='Total Sugars').value,5);assert.ok(!r.findings.some(f=>f.title.includes('sugars')));
});

test('normalized unknown facts produce a stable revalidated publication handoff',()=>{
 const c=labelFixture();c.nutrition.nutrients[0].value=19;c.nutrition.raw=c.nutrition.raw.replace('Per 100 g','Facts');c.nutrition.serving_size='90 g';
 const first=validate(c);c.nutrition=first.nutrition;c.ingredients=first.ingredients;
 const staged=validate(c),replay=validate(c);assert.deepEqual(staged,replay);assert.equal(staged.nutrition.basis,'unknown');assert.equal(staged.nutrition.nutrients[0].value,19);
});

test('partial blur advice does not block readable text; wrong photo remains actionable',()=>{
 const c=labelFixture();c.status='needs_retake';c.retake=['nutrition'];
 c.retake_reasons=[{photo:'nutrition',code:'blur_or_glare',field:'fat'}];
 assert.equal(validate(c).status,'validated');
 c.retake_reasons=[{photo:'nutrition',code:'wrong_photo',field:'nutrition_panel'}];
 const r=validate(c);assert.deepEqual(r.retake,['nutrition']);
 assert.equal(r.reason_details[0].source,'model');
});

test('numeric source mismatch never erases all OCR values or requests a retake',()=>{
 const c=labelFixture();for(const n of c.nutrition.nutrients)n.source='unmatched text';
 const r=validate(c);assert.equal(r.status,'validated');
 assert.deepEqual(r.nutrition.nutrients.map(n=>n.value),c.nutrition.nutrients.map(n=>n.value));
 assert.deepEqual(r.findings,[]);
});

test('missing legacy reason is explicit; malformed provider reason cannot become free-form UI text',()=>{
 const c=labelFixture();c.status='needs_retake';c.retake=['ingredients'];delete c.retake_reasons;
 assert.equal(validate(c).status,'validated');
 c.retake_reasons=[{photo:'ingredients',code:'raw PRIVATE provider message',field:'other'}];assert.throws(()=>validate(c));
});

test('case, compact spacing and unit words do not erase correctly extracted values',()=>{
 for(const kind of ['uppercase','compact-source','compact-raw','unit-words']){
  const c=labelFixture();
  const format=text=>kind==='uppercase'?text.replace(/\bg\b/g,'G').replace(/\bkcal\b/g,'KCAL'):
   kind==='unit-words'?text.replace(/\bg\b/g,'grams'):
   text.replace(/(\d)\s+([a-z]+)/g,'$1$2');
  if(kind!=='compact-source')c.nutrition.raw=format(c.nutrition.raw);
  if(kind!=='compact-raw')for(const n of c.nutrition.nutrients)n.source=format(n.source);
  assert.notEqual(kind==='compact-source'?c.nutrition.nutrients[0].source:c.nutrition.raw,kind==='compact-source'?labelFixture().nutrition.nutrients[0].source:labelFixture().nutrition.raw,'Regression input must actually change');
  const r=validate(c);assert.equal(r.status,'validated',kind);
  assert.ok(r.nutrition.nutrients.every(n=>n.value!==null),kind);
  assert.equal(r.findings.length,4,kind);
 }
});
test('equivalent unit spellings, leading decimals and Calories with percent daily value are supported',()=>{
 const c=labelFixture();
 const energy=c.nutrition.nutrients[0];c.nutrition.raw=c.nutrition.raw.replace(energy.source,'Calories 180 8%');energy.source='Calories 180 8%';
 const salt=c.nutrition.nutrients.at(-1);c.nutrition.raw=c.nutrition.raw.replace(salt.source,'Salt .3g');salt.source='Salt .3 g';
 c.nutrition.nutrients.push({name:'Vitamin D',value:2,unit:'ug',source:'Vitamin D 2 MCG'});
 c.nutrition.raw+=' Vitamin D 2 micrograms';
 const r=validate(c);assert.equal(r.status,'validated');assert.ok(r.nutrition.nutrients.every(n=>n.value!==null));
});
test('model-selected values display across columns; ambiguous evidence receives no colour',()=>{
 for(const [second,known]of [[3,true],[8,false]]){
  const c=labelFixture(),n=c.nutrition.nutrients[1],row='Total Fat 3g / '+second+'g';
  c.nutrition.raw=c.nutrition.raw.replace(n.source,row);n.source=row;
  const r=validate(c);assert.equal(r.status,'validated');assert.equal(r.nutrition.nutrients[1].value,3);assert.equal(r.findings.some(f=>f.title.includes(' fat ')),known);
 }
});
test('text mismatch does not erase model amounts; unsupported evidence cannot set a colour',()=>{
 for(const [row,amount]of [['Total Fat 30g',3],['Total Fat 3%',3],['Total Fat <3g',3],
  ['Total Fat -3g',3],['Total Fat 1,000g',1],['Total Fat 1,000g',1000]]){
  const c=labelFixture(),n=c.nutrition.nutrients[1];c.nutrition.raw=c.nutrition.raw.replace(n.source,row);n.source=row;n.value=amount;
  const r=validate(c);assert.equal(r.nutrition.nutrients[1].value,amount>102?null:amount,row);assert.ok(!r.findings.some(f=>f.title.includes(' fat ')),row);
 }
});

test('explicit parenthesized row units work before or after a value without guessing',()=>{
 for(const before of [true,false]){
  const c=labelFixture();
  for(const n of c.nutrition.nutrients){
   const row=before?n.name+' ('+n.unit.toUpperCase()+'): '+n.value:n.name+' '+n.value+' ('+n.unit+')';
   c.nutrition.raw=c.nutrition.raw.replace(n.source,row);
  }
  const r=validate(c);assert.equal(r.status,'validated');assert.ok(r.nutrition.nutrients.every(n=>n.value!==null));
 }
});

test('colour evidence preserves decimal meaning at classification boundaries',()=>{
 for(const value of [3.00000000001,17.50000000001]){
  const c=labelFixture(),n=c.nutrition.nutrients[1];n.value=value;
  assert.ok(!validate(c).findings.some(f=>f.title.includes(' fat ')));
 }
 const c=labelFixture(),n=c.nutrition.nutrients[1];
 c.nutrition.raw=c.nutrition.raw.replace(n.source,'Total Fat 1,000g');n.source='Total Fat 1.000g';n.value=1;
 assert.ok(!validate(c).findings.some(f=>f.title.includes(' fat ')),'Conflicting transcription cannot produce a colour');
});

test('decimal formatting and ambiguous thousands affect claims rather than whole-photo acceptance',()=>{
 for(const printed of ['3.00','3,00']){
  const c=labelFixture(),n=c.nutrition.nutrients[1];
  c.nutrition.raw=c.nutrition.raw.replace(n.source,'Total Fat '+printed+' g');
  const r=validate(c);assert.equal(r.nutrition.nutrients[1].value,3);
 }
 for(const amount of [0,1000]){
  const c=labelFixture(),n=c.nutrition.nutrients[1];n.value=amount;n.source='Total Fat 1 000g';
  c.nutrition.raw=c.nutrition.raw.replace('Total Fat 3 g',n.source);
  assert.ok(!validate(c).findings.some(f=>f.title.includes(' fat ')));
 }
});

test('named nutrient rows survive omitted amounts in a separate raw transcription',()=>{
 const c=labelFixture();
 c.nutrition.raw='Nutrition Facts Per 100 g Serving size 100 g Energy Total Fat Saturated Fat Total Sugars Salt Protein';
 const r=validate(c);assert.equal(r.status,'validated');
 assert.deepEqual(r.nutrition.nutrients.map(n=>n.value),c.nutrition.nutrients.map(n=>n.value));
 const staged={...c,nutrition:r.nutrition,ingredients:r.ingredients};
 assert.deepEqual(validate(staged),r,'Publication revalidation preserves the result');
 // Display the extraction, but unrelated/conflicting sources cannot set colours.
 const other=labelFixture();other.nutrition.raw='Nutrition Facts Per 100 g Serving size 100 g';
 other.nutrition.nutrients[1].source='Protein 3 g';
 assert.equal(validate(other).nutrition.nutrients[1].value,3);assert.ok(!validate(other).findings.some(f=>f.title.includes(' fat ')));
 const conflict=labelFixture();conflict.nutrition.raw=conflict.nutrition.raw.replace('Total Fat 3 g','Total Fat 8 g');
 assert.equal(validate(conflict).nutrition.nutrients[1].value,3);assert.ok(!validate(conflict).findings.some(f=>f.title.includes(' fat ')));
});

test('bilingual Calories/Calorías row retains its selected energy amount',()=>{
 const c=labelFixture(),n=c.nutrition.nutrients[0];
 c.nutrition.raw=c.nutrition.raw.replace(n.source,'Calories/Calorías 180 260');
 n.source='Calories/Calorías 180';
 assert.equal(validate(c).nutrition.nutrients[0].value,180);
 n.value=260;assert.equal(validate(c).nutrition.nutrients[0].value,260);
});
