import { normalizeBarcode } from './get_product.mjs';
import { validateImage } from '../../spikes/meta-vision/core.mjs';
export const IMAGE_BYTES = 5*1024*1024;
export const BODY_BYTES = 3*IMAGE_BYTES+65536;
export class AnalysisInputError extends Error {}
const bad = () => { throw new AnalysisInputError('invalid_input'); };
async function boundedBody(request) {
 if (!request.body) bad();
 const reader=request.body.getReader();const chunks=[];let size=0,timer;
 const timeout=new Promise((_,reject)=>{timer=setTimeout(()=>{void reader.cancel().catch(()=>{});reject(new AnalysisInputError('input_timeout'));},10000);});
 try {
  await Promise.race([(async()=>{while(true){const r=await reader.read();if(r.done)break;size+=r.value.length;if(size>BODY_BYTES){void reader.cancel().catch(()=>{});bad();}chunks.push(r.value);}})(),timeout]);
  const bytes=new Uint8Array(size);let offset=0;for(const chunk of chunks){bytes.set(chunk,offset);offset+=chunk.length;}return bytes;
 } finally { clearTimeout(timer);reader.releaseLock(); }
}
const crcTable = Uint32Array.from({length:256},(_,n)=>{for(let k=0;k<8;k++)n=(n&1)?0xedb88320^(n>>>1):n>>>1;return n>>>0;});
function pngStructure(bytes) {
 const view=new DataView(bytes.buffer,bytes.byteOffset,bytes.byteLength);let offset=8,idat=false,ended=false;
 while(offset+12<=bytes.length){
  const length=view.getUint32(offset);if(offset+12+length>bytes.length)bad();
  const name=String.fromCharCode(...bytes.subarray(offset+4,offset+8));
  let crc=0xffffffff;for(let i=offset+4;i<offset+8+length;i++)crc=crcTable[(crc^bytes[i])&255]^(crc>>>8);
  if(((crc^0xffffffff)>>>0)!==view.getUint32(offset+8+length))bad();
  if(name==='IDAT'){if(!length)bad();idat=true;}
  if(name==='IEND'){if(length!==0||offset+12!==bytes.length)bad();ended=true;break;}
  offset+=12+length;
 }
 if(!idat||!ended)bad();
}
function jpegStructure(bytes) {
 let offset=2,scan=false;
 while(offset+4<=bytes.length){
  if(bytes[offset]!==255)bad();const marker=bytes[offset+1];
  if(marker===0xda){const n=(bytes[offset+2]<<8)|bytes[offset+3];if(n<6||offset+2+n>=bytes.length-2)bad();scan=true;break;}
  const length=(bytes[offset+2]<<8)|bytes[offset+3];if(length<2||offset+2+length>bytes.length)bad();offset+=2+length;
 }
 if(!scan)bad();
}
function dataUrl(bytes,mime){const chunks=[];for(let n=0;n<bytes.length;n+=32768)chunks.push(String.fromCharCode(...bytes.subarray(n,n+32768)));return `data:${mime};base64,${btoa(chunks.join(''))}`;}
const hash=async bytes=>[...new Uint8Array(await crypto.subtle.digest('SHA-256',bytes))].map(v=>v.toString(16).padStart(2,'0')).join('');
async function image(file){
 if(!(file instanceof Blob)||typeof file.name!=='string'||file.size<=0||file.size>IMAGE_BYTES)bad();
 const bytes=new Uint8Array(await file.arrayBuffer());
 const mime=bytes[0]===137?'image/png':bytes[0]===255?'image/jpeg':null;if(!mime)bad();
 const url=dataUrl(bytes,mime);let metadata;
 try{metadata=validateImage(url,{maxBytes:IMAGE_BYTES,maxDimension:2400,maxPixels:2400*2400});}catch{bad();}
 if(mime==='image/png')pngStructure(bytes);else jpegStructure(bytes);
 return {url,metadata,digest:await hash(bytes)};
}
export async function readAnalysisInput(request){
 const type=request.headers.get('content-type')??'';
 if(!type.toLowerCase().startsWith('multipart/form-data;'))bad();
 const bytes=await boundedBody(request);let form;
 try{form=await new Response(bytes,{headers:{'content-type':type}}).formData();}catch{bad();}
 if([...form.keys()].sort().join(',')!=='barcode,front_image,idempotency_key,ingredients_image,nutrition_image')bad();
 let barcode;try{barcode=normalizeBarcode(form.get('barcode'));}catch{bad();}
 const key=form.get('idempotency_key');if(typeof key!=='string'||!/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(key))bad();
 if(request.headers.has('idempotency-key')&&request.headers.get('idempotency-key')!==key)bad();
 const front=await image(form.get('front_image')),nutrition=await image(form.get('nutrition_image')),ingredients=await image(form.get('ingredients_image'));
 if(new Set([front.digest,nutrition.digest,ingredients.digest]).size!==3)bad();
 return {barcode,key,digest:await hash(new TextEncoder().encode(`${barcode}|${front.digest}|${nutrition.digest}|${ingredients.digest}`)),
  images:{front_image:front.url,nutrition_image:nutrition.url,ingredients_image:ingredients.url}};
}
