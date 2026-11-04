// A transcription cross-check, not independent OCR or proof of product identity.
const norm=value=>String(value??'').normalize('NFKD').replace(/\p{M}/gu,'').toLowerCase().replace(/[^\p{L}\p{N}]+/gu,' ').trim();
const aliases={'sal':'salt','sel':'salt','asin':'salt','azucar':'sugar','sucre':'sugar','asukal':'sugar','leche':'milk','lait':'milk','gatas':'milk','tubig':'water','agua':'water','eau':'water','harina de trigo':'wheat flour'};
const canonical=value=>aliases[norm(value)]??norm(value);
const near=(a,b)=>{
 if(a===b||a.length>=4&&(a+'s'===b||b+'s'===a))return true;
 if(Math.min(a.length,b.length)<6||Math.abs(a.length-b.length)>1)return false;
 let x=0,y=0,edits=0;while(x<a.length&&y<b.length){if(a[x]===b[y]){x++;y++;continue;}if(++edits>1)return false;if(a.length>=b.length)x++;if(b.length>=a.length)y++;}
 return edits+(x<a.length||y<b.length?1:0)<=1;
};
export function ingredientSupportedByRaw(item,raw){
 if(typeof item!=='string'||!item.trim()||!String(raw??'').trim())return false;
 const source=norm(raw),value=norm(item);
 // An absence claim is not ingredient-presence evidence. Conservatively omit
 // ambiguous mixed statements rather than turning a citation into confirmation.
 if(['no ','no added ','without ','free from ','sin ','sans ','walang '].some(prefix=>(' '+source+' ').includes(' '+prefix+value+' '))||(' '+source+' ').includes(' '+value+' free '))return false;
 if(value&&(' '+source+' ').includes(' '+value+' '))return true;
 // Explicit bilingual alternatives are usable when one printed alternative matches.
 const alternatives=item.split(/\s*\/\s*/).map(canonical).filter(Boolean);
 const chunks=String(raw).split(/[,;()\n]/).map(canonical);
 if(alternatives.some(a=>chunks.includes(a)))return true;
 const words=value.split(' '),rawWords=source.split(' ');
 if(words.length>8)return false;
 for(let n=0;n+words.length<=rawWords.length;n++)if(words.every((word,i)=>near(word,rawWords[n+i])))return true;
 return false;
}
export function normalizeIngredientEvidence(candidate){
 const value=structuredClone(candidate),items=value.ingredients.items,keep=new Map(),confirmed=[];
 items.forEach((item,index)=>{if(ingredientSupportedByRaw(item,value.ingredients.raw)){keep.set(index,confirmed.length);confirmed.push(item);}});
 value.ingredients.items=confirmed;
 if(value.interpretation){
  value.interpretation.ingredients=value.interpretation.ingredients.filter(row=>keep.has(row.index)).map(row=>({...row,index:keep.get(row.index)}));
  value.interpretation.summary_ingredients=value.interpretation.summary_ingredients.filter(index=>keep.has(index)).map(index=>keep.get(index));
 }
 return value;
}
