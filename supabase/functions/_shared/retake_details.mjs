// Closed diagnostics only: no raw label text, photos, provider prose or credentials.
export const RETAKE_FIELDS=['nutrition_panel','ingredients_list','product_identity','serving_basis','serving_size','allergens',
 'energy','fat','saturates','carbohydrate','sugars','added_sugars','protein','salt','sodium','fibre','other'];
export const MODEL_RETAKE_CODES=['unreadable_text','blur_or_glare','cropped_label','wrong_photo','product_mismatch','no_readable_values','other'];
export const VALIDATION_RETAKE_CODES=['missing_ingredients','incomplete_ingredients','ingredient_order_or_source','allergen_source',
 'missing_nutrition','numeric_source','duplicate_nutrient','unit_mismatch','numeric_range','no_readable_values','contradictory_totals',
 'contradictory_mass','contradictory_energy','unspecified_retake','product_mismatch'];
export const RETAKE_CODES=[...new Set([...MODEL_RETAKE_CODES,...VALIDATION_RETAKE_CODES,'model_requested','reason_unavailable'])];
export function sanitizeRetakeDetails(value,photos){
 const targets=new Set(photos),result=[],seen=new Set();
 for(const d of Array.isArray(value)?value.slice(0,10):[]){
  if(!d||!targets.has(d.photo)||!['model','validation','legacy'].includes(d.source)||!RETAKE_CODES.includes(d.code)||!RETAKE_FIELDS.includes(d.field))continue;
  const clean={photo:d.photo,source:d.source,code:d.code,field:d.field},key=JSON.stringify(clean);
  if(!seen.has(key)){seen.add(key);result.push(clean);}
 }
 for(const photo of targets){
  if(!result.some(d=>d.photo===photo))result.push({photo,source:'legacy',code:'reason_unavailable',field:'other'});
 }
 return result.slice(0,12);
}

// Preserve legacy two-label targets while supporting exact three-photo subsets.
const retakeGroups={front:['front'],nutrition:['nutrition'],ingredients:['ingredients'],both:['nutrition','ingredients'],
 front_nutrition:['front','nutrition'],front_ingredients:['front','ingredients'],all:['front','nutrition','ingredients']};
export const retakePhotos=target=>retakeGroups[target]?[...retakeGroups[target]]:[];
export function retakeTarget(photos){
 const key=[...new Set(photos)].sort().join(',');
 return Object.keys(retakeGroups).find(target=>[...retakeGroups[target]].sort().join(',')===key)??null;
}
