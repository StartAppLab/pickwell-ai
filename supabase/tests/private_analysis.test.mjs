import{test}from'node:test';
import assert from'node:assert/strict';
import{readFile,readdir}from'node:fs/promises';
import{resolve}from'node:path';import{pathToFileURL}from'node:url';
import{frontLabelFixture}from'./fixtures/label_analysis.mjs';
import{validateAnalysis,PROMPT_VERSION}from'../functions/_shared/analysis_validation.mjs';
const root=resolve('.secrets/sql-test/node_modules/@electric-sql/pglite/dist');
const{PGlite}=await import(pathToFileURL(root+'/index.js'));const{uuid_ossp}=await import(pathToFileURL(root+'/contrib/uuid_ossp.js'));
const id=()=>crypto.randomUUID();let sequence=810000;
function code(){const b='298'+String(++sequence).padStart(9,'0');let n=0;for(let i=0;i<12;i++)n+=Number(b[11-i])*(i%2?1:3);return '0'+b+((10-n%10)%10);}
test('private successful analysis and shared publication are separate atomic operations',async t=>{
 const db=new PGlite({extensions:{uuid_ossp}}),scalar=async sql=>(await db.query(sql)).rows[0].value;
 const rpc=async(name,args,types)=>(await db.query(`select public.${name}(${args.map((_,i)=>'$'+(i+1)+'::'+types[i]).join(',')}) as value`,args)).rows[0].value;
 const user=async()=>{const uid=id();await db.query("insert into auth.users(id,email) values($1,$2)",[uid,uid+'@example.invalid']);return uid;};
 async function stage({uid=null,barcode=code(),key=id(),name='Private fixture',existing=false}={}){
  uid??=await user();const admission=await rpc('pickwell_admit_analysis',[uid,key,barcode,'a'.repeat(64)],['uuid','uuid','text','text']);
  if(admission.status!=='reserved')return{uid,key,barcode,...admission};
  const provider=await rpc('pickwell_begin_provider',[admission.reservation_id,'b'.repeat(64)],['uuid','text']);assert.equal(provider.call_allowed,true);
  await rpc('pickwell_record_provider',[provider.attempt_id,'succeeded',0,1,1,1],['uuid','text','numeric','bigint','bigint','integer']);
  const candidate=frontLabelFixture();for(const photo of ['front','nutrition','ingredients'])candidate.identity[photo].product_name=name;
  const validated=validateAnalysis(candidate,{model:'muse-spark-1.3',requireFront:true});assert.equal(validated.status,'validated');
  const payload={...candidate,nutrition:validated.nutrition,ingredients:validated.ingredients,validation:validated};
  await rpc('pickwell_stage_analysis',[uid,key,payload,'muse-spark-1.3',PROMPT_VERSION],['uuid','uuid','jsonb','text','text']);
  return{uid,key,barcode,validated,...admission};
 }
 const deliver=s=>rpc('pickwell_deliver_private_analysis',[s.uid,s.key,s.validated],['uuid','uuid','jsonb']);
 const read=s=>rpc('pickwell_private_analysis',[s.uid,s.job_id],['uuid','uuid']);
 const quota=s=>rpc('pickwell_quota_snapshot',[s.uid,'ai_analysis'],['uuid','text']);
 const publish=s=>rpc('pickwell_publish_analysis',[s.uid,s.key,s.validated],['uuid','uuid','jsonb']);
 async function decide(s,decision='approve'){
  await rpc('pickwell_publication_gate',[s.uid,s.key],['uuid','uuid']);
  const v=(await db.query('select * from public.product_trust_reviews where job_id=$1',[s.job_id])).rows[0];
  return rpc('pickwell_decide_product_review',[v.id,v.barcode,v.input_digest,v.candidate_digest,v.policy_version,decision,'private-test-review','controlled_demo_evidence',decision==='approve'?'no_discrepancy':'conflict_unresolved'],['uuid','text','text','text','text','text','text','text','text']);
 }
 try{
  await db.exec(`create role anon;create role authenticated;create role service_role bypassrls;create schema auth;
   create table auth.users(id uuid primary key,email text,raw_user_meta_data jsonb,is_anonymous boolean default false not null,email_confirmed_at timestamptz default now());
   create function auth.uid() returns uuid language sql stable as $$select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid$$;
   create schema storage;create table storage.buckets(id text primary key,name text,public boolean,file_size_limit bigint,allowed_mime_types text[]);
   create table storage.objects(id uuid primary key default gen_random_uuid(),bucket_id text,name text,metadata jsonb,created_at timestamptz default now());
   create function storage.foldername(text) returns text[] language sql immutable as $$select(string_to_array($1,'/'))[1:array_length(string_to_array($1,'/'),1)-1]$$;
   create schema extensions;create extension if not exists "uuid-ossp" with schema extensions;set search_path=public;`);
  for(const f of(await readdir('supabase/migrations')).filter(f=>f.endsWith('.sql')).sort())await db.exec((await readFile('supabase/migrations/'+f,'utf8')).replace('create extension if not exists "pgcrypto";','-- no pgcrypto in fixture'));
  await db.exec("update public.quota_controls set inference_enabled=true,approved_model='muse-spark-1.3',daily_spend_usd=10,change_reason='isolated private result fixture'");
  await t.test('delivering validated private result charges once and never publishes',async()=>{
   const s=await stage(),r=await deliver(s);assert.equal(r.status,'private_ready');assert.equal(r.product.name,'Private fixture');
   assert.equal((await quota(s)).used,1);assert.equal((await quota(s)).reserved,0);
   assert.equal(await scalar('select count(*)::int as value from public.published_products'),0);
   const again=await Promise.all(Array.from({length:8},()=>deliver(s)));assert.ok(again.every(x=>x.status==='private_ready'));assert.equal((await quota(s)).used,1);
  });
  await t.test('private result is owner-only and not a public cache record',async()=>{
   const s=await stage();await deliver(s);
   const other=await user();assert.equal((await rpc('pickwell_private_analysis',[other,s.job_id],['uuid','uuid'])).status,'not_found');
   await assert.rejects(rpc('pickwell_private_analysis',[null,s.job_id],['uuid','uuid']));
   for(const role of ['anon','authenticated']){await db.exec('set role '+role);try{await assert.rejects(db.query('select * from public.private_analysis_results'));await assert.rejects(read(s));}finally{await db.exec('reset role');}}
   assert.equal((await rpc('pickwell_get_product',[null,id(),s.barcode],['uuid','uuid','text'])).status,'not_found');
  });
  await t.test('publication still requires exact approval and cannot charge a delivered result twice',async()=>{
   const s=await stage();await deliver(s);assert.notEqual((await publish(s)).status,'ready');
   await decide(s);const r=await publish(s);assert.equal(r.status,'ready');assert.equal((await quota(s)).used,1);
   await publish(s);assert.equal((await quota(s)).used,1);assert.equal((await read(s)).status,'private_ready');
  });
  await t.test('rejection and cancellation preserve private result and cannot refund success',async()=>{
   for(const action of ['reject','cancel']){const s=await stage();await deliver(s);
    if(action==='reject')await decide(s,'reject');else await rpc('pickwell_cancel_analysis_review',[s.uid,s.key],['uuid','uuid']);
    assert.equal((await read(s)).status,'private_ready');assert.equal((await quota(s)).used,1);assert.equal((await quota(s)).reserved,0);
   }
  });
  await t.test('review expiry clears publication candidate but preserves 24h private result and credit',async()=>{
   const s=await stage();await deliver(s);await db.query("update public.analysis_candidates set expires_at=clock_timestamp()-interval '1 second' where job_id=$1",[s.job_id]);
   await rpc('pickwell_prune_analysis',[],[]);assert.equal((await read(s)).status,'private_ready');assert.equal((await quota(s)).used,1);
   assert.equal((await db.query('select count(*)::int as n from public.analysis_candidates where job_id=$1',[s.job_id])).rows[0].n,0);
  });
  await t.test('both owners can finish different private contributions; near-simultaneous approvals produce one canonical record',async()=>{
   const a=await stage({name:'Product A'}),buid=await user(),key=id();
   assert.equal((await rpc('pickwell_admit_analysis',[buid,key,a.barcode,'a'.repeat(64)],['uuid','uuid','text','text'])).status,'processing');
   await deliver(a);const b=await stage({uid:buid,barcode:a.barcode,key,name:'Product B'});assert.equal(b.status,'reserved');await deliver(b);
   assert.equal((await read(a)).product.name,'Product A');assert.equal((await read(b)).product.name,'Product B');
   await Promise.all([decide(a),decide(b)]);const outcomes=await Promise.all([publish(a),publish(b)]);
   assert.equal(outcomes.filter(x=>x.status==='ready').length,1);assert.equal((await quota(a)).used,1);assert.equal((await quota(b)).used,1);
   assert.equal((await db.query('select count(*)::int as n from public.products where barcode=$1',[a.barcode])).rows[0].n,1);
   assert.equal((await read(b)).product.name,'Product B');assert.ok((await read(b)).canonical_product);
  });
  await t.test('cancelling successful private analyses cannot exceed three Free successes',async()=>{
   const uid=await user();for(let n=0;n<3;n++){const s=await stage({uid});await deliver(s);await rpc('pickwell_cancel_analysis_review',[uid,s.key],['uuid','uuid']);}
   const denied=await stage({uid});assert.equal(denied.status,'quota_exceeded');
  });
  await t.test('invalid handoff cannot consume successful private allowance',async()=>{
   const s=await stage();const invalid={...s.validated,summary:'Changed candidate'};await assert.rejects(rpc('pickwell_deliver_private_analysis',[s.uid,s.key,invalid],['uuid','uuid','jsonb']));
   assert.equal((await quota(s)).used,0);await rpc('pickwell_settle_analysis',[s.uid,s.key,'failed','invalid_model_output',null],['uuid','uuid','text','text','text']);assert.equal((await quota(s)).reserved,0);
  });
 }finally{await db.close();}
});
