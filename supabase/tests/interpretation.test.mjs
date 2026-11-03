import {test} from 'node:test';
import assert from 'node:assert/strict';
import {validateAnalysis,analysisSchema} from '../functions/_shared/analysis_validation.mjs';
import {INGREDIENT_REFERENCES,NUTRITION_TOPICS,emptyInterpretationPlan,INTERPRETATION_VERSION,REFERENCES,ingredientReference,refreshInterpretationRecord}
 from '../functions/_shared/interpretation.mjs';
import {labelFixture} from './fixtures/label_analysis.mjs';
const validate=c=>validateAnalysis(c,{model:'fixture:mock',now:'2026-11-03T00:00:00Z'});
export function interpretedFixture(){
 const c=labelFixture({basis:'per_serving',portion:'100 g'});
 c.ingredients={raw:'Whole Grain Oats, Soy Lecithin, Citric Acid, Monosodium Glutamate, Mystery Extract.',
  items:['Whole Grain Oats','Soy Lecithin','Citric Acid','Monosodium Glutamate','Mystery Extract'],declared_allergens:null};
 c.nutrition.nutrients.push({name:'Sodium',value:1280,unit:'mg',source:'Sodium 1280 mg'},
  {name:'Dietary Fiber',value:6,unit:'g',source:'Dietary Fiber 6 g'},
  {name:'Added Sugars',value:4,unit:'g',source:'Added Sugars 4 g'});
 c.nutrition.raw+='; Sodium 1280 mg; Dietary Fiber 6 g; Added Sugars 4 g';
 c.interpretation={...emptyInterpretationPlan(),
  ingredients:c.ingredients.items.flatMap((item,index)=>{const id=ingredientReference(item);return id?[{index,reference_id:id,text:INGREDIENT_REFERENCES[id].text}]:[];}),
  nutrition:Object.entries(NUTRITION_TOPICS).filter(([topic])=>['sodium','saturates','total_sugars','added_sugars','fibre'].includes(topic)).map(([topic,r])=>({topic,text:r.text})),summary_nutrients:['sodium','fibre'],summary_ingredients:[1]};
 return c;
}
test('model-selected references explain roles and quantities rather than repeat the label',()=>{
 const c=interpretedFixture(),r=validate(c);
 assert.equal(r.status,'validated');assert.equal(r.provenance.interpretation_version,INTERPRETATION_VERSION);
 assert.ok(r.explanations.some(e=>e.text.includes('reduce separation')));
 assert.ok(r.explanations.some(e=>e.text.includes('does not establish a health risk')));
 assert.ok(r.explanations.some(e=>e.text.includes('Added sugars are part of total sugars')));
 assert.ok(r.summary.includes('1280 mg per serving'));assert.ok(r.summary.includes('other food contributes'));
 assert.ok(r.findings.some(f=>f.severity==='red'&&f.source_details.rule_id==='fda-dv-5-20-v1:sodium'));
 assert.ok(r.findings.some(f=>f.severity==='green'&&f.source_details.rule_id==='fda-dv-5-20-v1:fibre'));
 assert.ok(!r.missing_information.some(s=>s.includes('No supported nutrition colour')));
 assert.ok(r.explanations.every(e=>e.references.every(ref=>REFERENCES[ref.id].url===ref.url)));
 assert.ok(r.missing_information.some(s=>s.includes('no matched reviewed background')));
 assert.equal(r.score,undefined);
});
test('invented prose, mismatched ingredient links and out-of-range indices cannot become explanations',()=>{
 const c=interpretedFixture();c.interpretation.ingredients=[
  {index:1,reference_id:'emulsifier',text:'Lecithin causes cancer.'},
  {index:4,reference_id:'msg',text:INGREDIENT_REFERENCES.msg.text},
  {index:999,reference_id:'msg',text:INGREDIENT_REFERENCES.msg.text}];
 const r=validate(c);assert.equal(r.status,'validated');
 assert.ok(!r.explanations.some(e=>e.photo==='ingredients'));assert.ok(!JSON.stringify(r).includes('causes cancer'));
 assert.ok(r.missing_information.some(s=>s.includes('unsupported')));
 c.interpretation.ingredients[0].url='https://invented.invalid';assert.throws(()=>validate(c));
});
test('no ingredient reference is assigned to negations, similar names or unknown additives',()=>{
 for(const item of ['no MSG','MSG-free flavour','not citric acid','xanthan gum-free','Unknown E999'])
  assert.equal(ingredientReference(item),null,item);
 assert.equal(ingredientReference('Soy lecithin (emulsifier)'),'emulsifier');
});
test('missing added sugars and incomplete nutrition remain uncertain rather than inferred',()=>{
 const c=interpretedFixture();c.nutrition.nutrients.find(n=>n.name==='Added Sugars').value=null;
 c.nutrition.serving_size=null;c.nutrition.basis='unknown';
 const r=validate(c);assert.equal(r.status,'validated');assert.deepEqual(r.findings,[]);
 assert.ok(!r.explanations.some(e=>e.topic==='added_sugars'));
 assert.ok(r.missing_information.some(s=>s.includes('cannot be inferred from total sugars')));
 c.nutrition.nutrients=[];const textOnly=validate(c);assert.equal(textOnly.status,'validated');
 assert.ok(textOnly.missing_information.some(s=>s.includes('Not enough confirmed numeric')));
});
test('US daily-value classification uses exact 5/20 percent boundaries and confirmed serving/source only',()=>{
 for(const [amount,wanted]of [[115,'green'],[115.01,null],[459.99,null],[460,'red']]){
  const c=interpretedFixture(),n=c.nutrition.nutrients.find(n=>n.name==='Sodium');
  c.nutrition.raw=c.nutrition.raw.replace(n.source,'Sodium '+amount+' mg');n.source='Sodium '+amount+' mg';n.value=amount;
  assert.equal(validate(c).findings.find(f=>f.source_details.rule_id==='fda-dv-5-20-v1:sodium')?.severity??null,wanted);
 }
 const c=interpretedFixture();c.nutrition.nutrients.find(n=>n.name==='Sodium').source='Uncorroborated value';
 const r=validate(c);assert.ok(!r.findings.some(f=>f.source_details.rule_id==='fda-dv-5-20-v1:sodium'));
 c.nutrition.basis='per_100g';assert.ok(!validate(c).findings.some(f=>f.source_details.rule_id.startsWith('fda-dv')));
});
test('interpretation survives normalized staging/publication and reference refresh preserves facts',()=>{
 const c=interpretedFixture(),r=validate(c);
 const staged={...c,nutrition:r.nutrition,ingredients:r.ingredients};assert.deepEqual(validate(staged),r);
 const product={nutrition:r.nutrition,ingredients:r.ingredients,findings:r.findings,provenance:r.provenance,missing_information:r.missing_information};
 const refresh=refreshInterpretationRecord(product);
 assert.deepEqual(refresh.nutrition,product.nutrition);assert.deepEqual(refresh.ingredients,product.ingredients);
 assert.deepEqual(refresh.findings,product.findings);assert.ok(refresh.provenance.interpretation_method.includes('no new Meta'));
 assert.ok(analysisSchema.properties.interpretation);assert.ok(refresh.summary.length>40);
});

test('protein and printed Vitamin D IU get general function context without dose conversions or new colours',()=>{
 const c=interpretedFixture();c.nutrition.nutrients.push({name:'Vitamin D',value:71,unit:'IU',source:'Vitamin D 71 IU'});c.nutrition.raw+='; Vitamin D 71 IU';
 c.interpretation.nutrition=[{topic:'protein',text:NUTRITION_TOPICS.protein.text},{topic:'vitamin_d',text:NUTRITION_TOPICS.vitamin_d.text}];
 const r=validate(c);assert.ok(r.explanations.some(e=>e.text.includes('71 IU')&&e.text.includes('absorb calcium')));
 assert.ok(r.explanations.some(e=>e.text.includes('cell repair')));assert.deepEqual(r.findings,[]);
});

test('declared allergen caution is anchored to actual label text, without inferring absent allergens',()=>{
 const c=interpretedFixture();c.ingredients.declared_allergens='Contains: soy.';c.ingredients.raw+=' Contains: soy.';
 const r=validate(c),finding=r.findings.find(f=>f.source_details.rule_id==='declared-allergen-v1');
 assert.equal(finding.severity,'yellow');assert.equal(finding.source_details.evidence[0].source,'Contains: soy.');
 assert.ok(r.summary.startsWith('Declared allergens: Contains: soy.'));
 c.ingredients.declared_allergens='Contains: nuts.';
 assert.ok(!validate(c).findings.some(f=>f.source_details.rule_id==='declared-allergen-v1'));
});
