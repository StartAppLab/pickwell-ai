import{test}from'node:test';
import assert from'node:assert/strict';
import{spawnSync}from'node:child_process';
import{createProductThumbnailHandler,publicThumbnail}from'../functions/_shared/product_thumbnail.mjs';
import{cleanupThumbnails,runThumbnailOperator}from'../scripts/attach-product-thumbnail.mjs';
const id='aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
const python=process.env.PICKWELL_THUMBNAIL_PYTHON??'.secrets/thumbnail-python/bin/python';
const generated=spawnSync(python,['-c',"import sys,io;from PIL import Image;b=io.BytesIO();Image.new('RGB',(120,80),(50,100,60)).save(b,format='JPEG');sys.stdout.buffer.write(b.getvalue())"],{maxBuffer:65536});
if(generated.status!==0)throw Error('Install pinned operator thumbnail requirements; see thumbnail documentation');
const bytes=new Uint8Array(generated.stdout),digest=[...new Uint8Array(await crypto.subtle.digest('SHA-256',bytes))].map(x=>x.toString(16).padStart(2,'0')).join('');
const asset={id,digest,width:120,height:80,bytes:bytes.length,object_path:`v1/${id}/${digest}.jpg`};
const env={SUPABASE_URL:'https://fixture.supabase.co',SUPABASE_SERVICE_ROLE_KEY:'fixture-server'};
const req=(method='GET')=>new Request(`https://public.invalid?id=${id}&v=${digest}`,{method});
test('legacy/invalid thumbnail metadata is a harmless no-image fallback',()=>{
 for(const raw of [null,{}, {...asset,id:'private-path'}, {...asset,width:500}, {...asset,digest:'https://external.invalid/a.jpg'}])assert.equal(publicThumbnail(raw),null);
 assert.deepEqual(publicThumbnail(asset),{id,digest,width:120,height:80});
});
test('unpublished/uploading media is not downloadable; lookup cannot invoke a provider',async()=>{
 const calls=[];const handler=createProductThumbnailHandler(env,async(url)=>{calls.push(url);return Response.json([]);});
 const result=await handler(req());assert.equal(result.status,404);assert.equal(result.headers.get('cache-control'),'no-store');assert.equal(calls.length,1);
 assert.ok(calls[0].includes('/published_thumbnail_assets?'));
});
test('eligible published derivative validates bytes and is returned without private headers or payloads',async()=>{
 const calls=[];const handler=createProductThumbnailHandler(env,async(url,options)=>{
  calls.push(url);assert.equal(options.redirect,'error');
  return url.includes('/rest/')?Response.json([asset]):new Response(bytes);
 });
 const response=await handler(req());assert.equal(response.status,200);assert.equal(response.headers.get('content-type'),'image/jpeg');
 assert.deepEqual(new Uint8Array(await response.arrayBuffer()),bytes);assert.equal(calls.length,2);
 assert.ok(calls.every(url=>url.startsWith(env.SUPABASE_URL)&&!url.includes('meta.ai')));
 assert.equal(response.headers.get('authorization'),null);assert.equal(response.headers.get('cache-control'),'public, max-age=300');
});
test('corrupt/hash-swapped/oversized/dimension-mismatched assets fail closed',async()=>{
 for(const [row,body]of [[asset,new Uint8Array(65537)],[{...asset,digest:'e'.repeat(64)},bytes],[{...asset,width:121},bytes],[asset,bytes.subarray(0,20)]]){
  const handler=createProductThumbnailHandler(env,async url=>url.includes('/rest/')?Response.json([row]):new Response(body));
  assert.equal((await handler(req())).status,503);
 }
});
test('thumbnail endpoint rejects methods, invalid IDs and foreign private paths',async()=>{
 let calls=0;const handler=createProductThumbnailHandler(env,async()=>{calls++;return Response.json([{...asset,object_path:'other-bucket/private'}]);});
 assert.equal((await handler(req('POST'))).status,405);
 assert.equal((await handler(new Request('https://public.invalid?id=bad&v=x'))).status,400);
 assert.equal((await handler(req())).status,503);assert.equal(calls,1);
});
test('cleanup uses Storage deletion before forgetting, never leaks unrelated keys or forgets failed deletions',async()=>{
 const calls=[];const transport={rpc:async(name)=>{calls.push(name);return name==='pickwell_thumbnail_cleanup'?[asset]:name==='pickwell_thumbnail_orphans'?[]:null;},
 call:async(path,options)=>{calls.push(path);assert.equal(options.method,'DELETE');assert.deepEqual(JSON.parse(options.body).prefixes,[asset.object_path]);return new Response('{}');}};
 assert.equal(await cleanupThumbnails(transport),1);assert.ok(calls.indexOf('pickwell_forget_thumbnail')>calls.indexOf('/storage/v1/object/product-thumbnails'));
 calls.length=0;transport.call=async()=>new Response('{}',{status:503});await assert.rejects(cleanupThumbnails(transport));assert.ok(!calls.includes('pickwell_forget_thumbnail'));
});
test('cleanup dry-run cannot mutate Storage or publication',async()=>{
 let calls=0;await runThumbnailOperator(['--cleanup'],env,async()=>{calls++;throw Error();});assert.equal(calls,0);
});
