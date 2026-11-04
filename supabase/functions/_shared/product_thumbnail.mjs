// Read-only public media projection; private Storage never has client SELECT grants.
import {validateImage} from '../../spikes/meta-vision/core.mjs';
const uuid=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const digest=/^[0-9a-f]{64}$/;
const hex=bytes=>[...new Uint8Array(bytes)].map(v=>v.toString(16).padStart(2,'0')).join('');
export function publicThumbnail(value){
 if(!value||!uuid.test(value.id??'')||!digest.test(value.digest??'')||
  !Number.isInteger(value.width)||!Number.isInteger(value.height)||value.width<1||value.width>384||value.height<1||value.height>384)return null;
 return {id:value.id,digest:value.digest,width:value.width,height:value.height};
}
export async function boundedThumbnail(response,expected){
 if(!response.ok||!response.body)throw Error('thumbnail_unavailable');
 const reader=response.body.getReader(),parts=[];let size=0;
 try{while(true){const {done,value}=await reader.read();if(done)break;size+=value.length;if(size>65536){await reader.cancel();throw Error('thumbnail_size');}parts.push(value);}}
 finally{reader.releaseLock();}
 const bytes=new Uint8Array(size);let offset=0;for(const p of parts){bytes.set(p,offset);offset+=p.length;}
 if(size!==expected.bytes||bytes[0]!==255||bytes[1]!==216||bytes.at(-2)!==255||bytes.at(-1)!==217||
  hex(await crypto.subtle.digest('SHA-256',bytes))!==expected.digest)throw Error('thumbnail_integrity');
 let binary='';for(const byte of bytes)binary+=String.fromCharCode(byte);
 const meta=validateImage('data:image/jpeg;base64,'+btoa(binary),{maxBytes:65536,maxDimension:384,maxPixels:384*384});
 if(meta.width!==expected.width||meta.height!==expected.height)throw Error('thumbnail_dimensions');
 return bytes;
}
export function createProductThumbnailHandler(env,fetcher=fetch){
 const fail=status=>new Response(null,{status,headers:{'Cache-Control':'no-store','X-Content-Type-Options':'nosniff'}});
 return async request=>{
  if(request.method!=='GET')return fail(405);
  const url=new URL(request.url),id=url.searchParams.get('id'),version=url.searchParams.get('v');
  if([...url.searchParams.keys()].sort().join(',')!=='id,v'||!uuid.test(id??'')||!digest.test(version??''))return fail(400);
  try{
   const origin=new URL(env.SUPABASE_URL);if(origin.protocol!=='https:'&&!['localhost','127.0.0.1'].includes(origin.hostname))throw Error();
   if(!env.SUPABASE_SERVICE_ROLE_KEY||origin.username||origin.password||origin.pathname!=='/')throw Error();
   const headers={apikey:env.SUPABASE_SERVICE_ROLE_KEY,Authorization:'Bearer '+env.SUPABASE_SERVICE_ROLE_KEY};
   const q=new URLSearchParams({id:'eq.'+id,digest:'eq.'+version,select:'object_path,digest,width,height,bytes',limit:'1'});
   const found=await fetcher(origin.origin+'/rest/v1/published_thumbnail_assets?'+q,{headers,redirect:'error',signal:AbortSignal.timeout(5000)});
   if(!found.ok)throw Error();const rows=await found.json();
   if(!Array.isArray(rows))throw Error();if(!rows.length)return fail(404);
   const asset=rows[0];if(!new RegExp('^v1/'+id+'/'+version+'\\.jpg$').test(asset.object_path))throw Error();
   const response=await fetcher(origin.origin+'/storage/v1/object/authenticated/product-thumbnails/'+asset.object_path,{headers,redirect:'error',signal:AbortSignal.timeout(5000)});
   const bytes=await boundedThumbnail(response,asset);
   return new Response(bytes,{headers:{'Content-Type':'image/jpeg','Content-Length':String(bytes.length),'Cache-Control':'public, max-age=300','ETag':'"'+version+'"','X-Content-Type-Options':'nosniff','Content-Security-Policy':"default-src 'none'"}});
  }catch{return fail(503);}
 };
}
