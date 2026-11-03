import {test} from 'node:test';
import assert from 'node:assert/strict';
import {attachAnalysisQuota} from '../functions/_shared/analysis_quota_response.mjs';
const env={SUPABASE_URL:'https://fixture.supabase.co',SUPABASE_SERVICE_ROLE_KEY:'fixture-server-role'};
const owner='10000000-0000-4000-8000-000000000001';
const quota=(used=0,limit=3)=>({plan:'free',limit,version:1,used,reserved:0,remaining:Math.max(0,limit-used),reset_at:'2026-11-04T00:00:00Z'});
test('analysis usage metadata uses trusted identity, private headers, current limits and bounded read',async()=>{
 for(const [used,limit]of [[2,3],[3,3],[25,20]]){
  let calls=0;const r=await attachAnalysisQuota(Response.json({status:'ready',product:{barcode:'fixture'}}),owner,env,async(url,options)=>{
   calls++;assert.equal(url,'https://fixture.supabase.co/rest/v1/rpc/pickwell_quota_snapshot');
   assert.deepEqual(JSON.parse(options.body),{p_user:owner,p_metric:'ai_analysis'});assert.ok(options.signal);assert.equal(options.redirect,'error');
   assert.equal(options.headers.Authorization,'Bearer fixture-server-role');return Response.json({...quota(used,limit),user_id:'PRIVATE',email:'PRIVATE'});
  });
  const body=await r.json();assert.equal(r.status,200);assert.equal(body.quota.limit,limit);assert.equal(body.quota.remaining,Math.max(0,limit-used));
  assert.ok(!JSON.stringify(body).includes('PRIVATE'));assert.equal(calls,1);
 }
});
test('atomic quota denial is preserved without a second snapshot or any local increment',async()=>{
 let calls=0;const result=await attachAnalysisQuota(Response.json({status:'quota_exceeded',quota:quota(3)},{status:429}),owner,env,async()=>{calls++;throw Error();});
 assert.equal(calls,0);assert.equal(result.status,429);assert.deepEqual((await result.json()).quota,quota(3));
});
test('missing/failed optional usage never changes ready, retake, processing or denial outcomes',async()=>{
 for(const [status,http]of [['ready',200],['needs_retake',422],['processing',202],['error',503]]){
  const response=await attachAnalysisQuota(Response.json({status},{status:http}),owner,env,async()=>{throw Error('PRIVATE failure');});
  const body=await response.json();assert.equal(body.status,status);assert.equal(response.status,http);assert.equal(body.quota_unavailable,true);assert.equal(body.quota,undefined);
 }
});
test('guests, authentication failures and throttled callers cannot trigger a quota display read',async()=>{
 let calls=0;for(const [user,status,http]of [[null,'error',401],[owner,'error',403],[owner,'rate_limited',429]]){
  const input=Response.json({status},{status:http}),output=await attachAnalysisQuota(input,user,env,async()=>{calls++;throw Error();});
  assert.equal(input,output);
 }assert.equal(calls,0);
});
