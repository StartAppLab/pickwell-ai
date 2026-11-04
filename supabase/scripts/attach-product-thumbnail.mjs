// Operator-only post-publication derivative. No AI requests or approval authority.
import{readFileSync,writeFileSync,openSync,fstatSync,readSync,closeSync,mkdtempSync,rmSync}from'node:fs';
import{resolve,dirname}from'node:path';
import{pathToFileURL}from'node:url';
import{spawnSync}from'node:child_process';
import{readAnalysisInput}from'../functions/_shared/analysis_input.mjs';
import{boundedThumbnail}from'../functions/_shared/product_thumbnail.mjs';
const hash=async value=>[...new Uint8Array(await crypto.subtle.digest('SHA-256',value))].map(x=>x.toString(16).padStart(2,'0')).join('');
const objectKey=/^v1\/[0-9a-f-]{36}\/[0-9a-f]{64}\.jpg$/;
function privateFile(path){const p=resolve(path??'');if(spawnSync('git',['check-ignore','--quiet','--',p]).status!==0)throw Error('Ignored evidence path required');return p;}
function evidenceBytes(path){
 const fd=openSync(path,'r'),limit=5*1024*1024;
 try{
  const stat=fstatSync(fd);if(!stat.isFile()||stat.size<1||stat.size>limit)throw Error('Bounded evidence required');
  const buffer=Buffer.alloc(limit+1);let size=0;
  while(size<=limit){const n=readSync(fd,buffer,size,buffer.length-size,null);if(!n)break;size+=n;}
  if(!size||size>limit)throw Error('Bounded evidence required');return buffer.subarray(0,size);
 }finally{closeSync(fd);}
}
export function thumbnailTransport(env,fetcher=fetch){
 const origin=new URL(env.SUPABASE_URL);if((origin.protocol!=='https:'&&!['127.0.0.1','localhost'].includes(origin.hostname))||origin.username||origin.password||origin.pathname!=='/'||!env.SUPABASE_SERVICE_ROLE_KEY)throw Error('Server environment required');
 const headers={apikey:env.SUPABASE_SERVICE_ROLE_KEY,Authorization:'Bearer '+env.SUPABASE_SERVICE_ROLE_KEY};
 const call=(path,options={})=>fetcher(origin.origin+path,{...options,headers:{...headers,...options.headers},redirect:'error',signal:AbortSignal.timeout(10000)});
 const rpc=async(name,body)=>{const r=await call('/rest/v1/rpc/'+name,{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify(body)});if(!r.ok)throw Error('Protected media operation failed');return r.json();};
 return{call,rpc};
}
export async function cleanupThumbnails(transport){
 const rows=await transport.rpc('pickwell_thumbnail_cleanup',{});
 const orphan=await transport.rpc('pickwell_thumbnail_orphans',{});
 if(!Array.isArray(rows)||rows.length>100||!Array.isArray(orphan)||orphan.length>100)throw Error('Invalid cleanup scope');
 const paths=[...new Set([...rows.map(r=>r.object_path),...orphan])];
 if(!paths.every(p=>objectKey.test(p)))throw Error('Invalid cleanup path');
 if(paths.length){const r=await transport.call('/storage/v1/object/product-thumbnails',{method:'DELETE',headers:{'content-type':'application/json'},body:JSON.stringify({prefixes:paths})});if(!r.ok)throw Error('Storage cleanup failed');}
 // Only remove tracking after the physical Storage API operation succeeded.
 await Promise.all(rows.map(r=>transport.rpc('pickwell_forget_thumbnail',{p_id:r.id})));
 return paths.length;
}
export async function runThumbnailOperator(args,env=process.env,fetcher=fetch){
 const arg=name=>{const n=args.indexOf(name);return n<0?undefined:args[n+1];};
 if(args.includes('--help')){console.log('attach-product-thumbnail --review-file IGNORED_INSPECTION --evidence-manifest IGNORED_MANIFEST [--python PYTHON_WITH_PINNED_PILLOW] [--apply] | --cleanup --apply. Default dry run. Post-publication only; requires exact processed three-photo evidence and server-only environment.');return;}
 const transport=thumbnailTransport(env,fetcher);
 if(args.includes('--cleanup')){if(!args.includes('--apply')){console.log('Cleanup dry run; use --apply to claim expired uploads and delete via Storage API.');return;}console.log(JSON.stringify({removed:await cleanupThumbnails(transport)}));return;}
 const inspected=JSON.parse(readFileSync(privateFile(arg('--review-file')),'utf8'));
 const review=await transport.rpc('pickwell_inspect_product_review',{p_review:inspected.review_id});
 if(review?.state!=='published'||review.policy_version!=='trust-publication-v1'||
  ['review_id','barcode','input_digest','candidate_digest','policy_version'].some(k=>review[k]!==inspected[k]))throw Error('Exact published review required');
 const path=privateFile(arg('--evidence-manifest')),manifest=JSON.parse(readFileSync(path,'utf8'));
 if(manifest.barcode!==review.barcode)throw Error('Evidence barcode mismatch');
 const form=new FormData();form.set('barcode',manifest.barcode);form.set('idempotency_key',crypto.randomUUID());
 const hashes={};let verifiedFront;
 for(const photo of ['front','nutrition','ingredients']){
  const file=privateFile(resolve(dirname(path),manifest[photo]));
  const bytes=evidenceBytes(file);hashes[photo]=await hash(bytes);if(photo==='front')verifiedFront=bytes;
  form.set(photo+'_image',new Blob([bytes]),photo);
 }
 const input=await readAnalysisInput(new Request('https://operator.invalid',{method:'POST',body:form}));input.images=null;
 if(input.digest!==review.input_digest)throw Error('Exact submitted bytes required');
 const dir=mkdtempSync(resolve('.secrets/thumbnail-'));
 try{
  // Decode the bytes whose digest was verified, never re-open a mutable source path.
  const source=dir+'/verified-front',target=dir+'/front.jpg',python=arg('--python')??'python3';
  writeFileSync(source,verifiedFront,{mode:0o600,flag:'wx'});
  const result=spawnSync(python,[resolve('supabase/scripts/make-thumbnail.py'),source,target],{encoding:'utf8',timeout:15000,maxBuffer:8192,env:{PATH:process.env.PATH??'',LANG:'C.UTF-8'}});
  if(result.status!==0)throw Error('Bounded thumbnail generator unavailable or rejected input');
  const meta=JSON.parse(result.stdout),bytes=readFileSync(target);
  await boundedThumbnail(new Response(bytes),{...meta,digest:meta.sha256});
  const plan={p_review:review.review_id,p_barcode:review.barcode,p_input:review.input_digest,p_candidate:review.candidate_digest,
   p_front:hashes.front,p_nutrition:hashes.nutrition,p_ingredients:hashes.ingredients,p_digest:meta.sha256,p_width:meta.width,p_height:meta.height,p_bytes:meta.bytes};
  if(!args.includes('--apply')){console.log(JSON.stringify({status:'dry_run',evidence_matches:true,width:meta.width,height:meta.height,bytes:meta.bytes}));return;}
  await cleanupThumbnails(transport);
  const prepared=await transport.rpc('pickwell_prepare_thumbnail',plan);
  if(!objectKey.test(prepared.object_path??'')||prepared.digest!==meta.sha256)throw Error('Bad prepared association');
  if(prepared.state!=='ready'){
   const uploaded=await transport.call('/storage/v1/object/product-thumbnails/'+prepared.object_path,{method:'POST',headers:{'content-type':'image/jpeg','x-upsert':'false'},body:bytes});
   if(!uploaded.ok){
    // Concurrent/uncertain upload may already exist. Verify bytes, never overwrite.
    const existing=await transport.call('/storage/v1/object/authenticated/product-thumbnails/'+prepared.object_path);
    await boundedThumbnail(existing,{...meta,digest:meta.sha256});
   }
   await transport.rpc('pickwell_commit_thumbnail',{p_id:prepared.id});
  }
  console.log(JSON.stringify({status:'ready',width:meta.width,height:meta.height,bytes:meta.bytes}));
 }finally{rmSync(dir,{recursive:true,force:true});}
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){
 try{await runThumbnailOperator(process.argv.slice(2));}catch{console.error('Thumbnail operation failed. Check exact private evidence, published review, generator and server access. No source image changed or credentials printed. Failed/uncertain uploads stay private for bounded cleanup.');process.exitCode=1;}
}
