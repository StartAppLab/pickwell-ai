// Model observations only. Neither matching names nor a front photo verifies a GTIN.
const object=properties=>({type:'object',properties,required:Object.keys(properties),additionalProperties:false});
const nullable={type:['string','null'],maxLength:400};
export const IDENTITY_PHOTOS=['front','nutrition','ingredients'];
export const IDENTITY_FIELDS=['product_name','brand','variant','net_quantity'];
export const identityObservationSchema=object(Object.fromEntries(IDENTITY_FIELDS.map(key=>[key,nullable])));
export const productIdentitySchema=object({
 ...Object.fromEntries(IDENTITY_PHOTOS.map(photo=>[photo,identityObservationSchema])),
 consistency:{type:'string',enum:['consistent','unknown','mismatch']},
 food_form:{type:'string',enum:['solid','liquid','unknown']},
 conflicts:{type:'array',maxItems:6,items:object({field:{type:'string',enum:IDENTITY_FIELDS},
  photos:{type:'array',maxItems:3,items:{type:'string',enum:IDENTITY_PHOTOS}}})},
});
const norm=value=>typeof value==='string'?value.normalize('NFKD').replace(/\p{M}/gu,'').toLowerCase().replace(/[^\p{L}\p{N}]+/gu,' ').trim():'';
const quantity=value=>{
 const match=typeof value==='string'&&value.normalize('NFKC').toLowerCase().trim().match(/^(\d+(?:[.,]\d+)?)\s*(kg|g|mg|ml|l)$/);
 if(!match)return null;
 const factor={kg:1000,g:1,mg:0.001,ml:1,l:1000}[match[2]];
 return {value:Number(match[1].replace(',','.'))*factor,basis:['ml','l'].includes(match[2])?'volume':'mass'};
};
export function identityConflictPhotos(identity){
 const targets=new Set();
 for(const conflict of identity.conflicts){
  const photos=[...new Set(conflict.photos)];
  if(photos.length<2){const error=new Error('invalid_model_output');error.code='invalid_model_output';throw error;}
  photos.forEach(photo=>targets.add(photo));
 }
 for(let a=0;a<IDENTITY_PHOTOS.length;a++)for(let b=a+1;b<IDENTITY_PHOTOS.length;b++){
  const left=IDENTITY_PHOTOS[a],right=IDENTITY_PHOTOS[b];
  for(const field of ['brand','variant','net_quantity']){
   const x=identity[left][field],y=identity[right][field];if(!norm(x)||!norm(y))continue;
   let conflict=false;
   if(field==='net_quantity'){
    const q=quantity(x),r=quantity(y);
    conflict=!!(q&&r&&q.basis===r.basis&&Math.abs(q.value-r.value)>Math.max(q.value,r.value)*0.000001);
   }else{
    const n=norm(x),m=norm(y);
    // Accommodate abbreviated/extended branding. Differences flag review, never
    // prove which observation is correct. Missing fields stay unknown.
    conflict=n!==m&&!(' '+n+' ').includes(' '+m+' ')&&!(' '+m+' ').includes(' '+n+' ');
   }
   if(conflict){targets.add(left);targets.add(right);}
  }
 }
 if(identity.consistency==='mismatch'&&!targets.size)IDENTITY_PHOTOS.forEach(photo=>targets.add(photo));
 return [...targets];
}
export function sanitizeIdentityObservations(value){
 if(!value||!value.front)return null;
 const observations={};
 for(const photo of IDENTITY_PHOTOS){
  observations[photo]=Object.fromEntries(IDENTITY_FIELDS.map(field=>{
   const text=value[photo]?.[field];return [field,typeof text==='string'&&text.trim()?text.trim().slice(0,400):null];
  }));
 }
 return {...observations,consistency:['consistent','unknown','mismatch'].includes(value.consistency)?value.consistency:'unknown'};
}
