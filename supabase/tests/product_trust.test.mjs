import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFile,readdir} from 'node:fs/promises';
import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {frontLabelFixture} from './fixtures/label_analysis.mjs';
import {normalizeIngredientEvidence} from '../functions/_shared/ingredient_evidence.mjs';
import {validateAnalysis,PROMPT_VERSION} from '../functions/_shared/analysis_validation.mjs';
import {sanitizePublishedProduct} from '../functions/_shared/catalog_boundary.mjs';
const root=resolve('.secrets/sql-test/node_modules/@electric-sql/pglite/dist');
const {PGlite}=await import(pathToFileURL(root+'/index.js'));
const {uuid_ossp}=await import(pathToFileURL(root+'/contrib/uuid_ossp.js'));
const id=()=>crypto.randomUUID();let sequence=700000;
function barcode(){const raw='298'+String(++sequence).padStart(9,'0');let sum=0;for(let n=0;n<raw.length;n++)sum+=Number(raw[raw.length-1-n])*(n%2===0?3:1);return '0'+raw+((10-sum%10)%10);}

test('bound product trust gate on isolated PostgreSQL',async t=>{
 const db=new PGlite({extensions:{uuid_ossp}});
 const scalar=async sql=>(await db.query(sql)).rows[0].value;
 const rpc=async(name,args,types)=>(await db.query(`select public.${name}(${args.map((_,n)=>'$'+(n+1)+'::'+types[n]).join(',')}) as value`,args)).rows[0].value;
 const denied=promise=>assert.rejects(promise,e=>['23514','42501','P0002'].includes(e.code));
 async function user(){const uid=id();await db.query('insert into auth.users(id,email,raw_user_meta_data) values($1,$2,$3)',[uid,uid+'@example.invalid',{}]);return uid;}
 async function stage({uid=null,code=barcode(),candidate=frontLabelFixture(),digest='a'.repeat(64)}={}){
  uid??=await user();const key=id();
  const admission=await rpc('pickwell_admit_analysis',[uid,key,code,digest],['uuid','uuid','text','text']);assert.equal(admission.status,'reserved');
  const provider=await rpc('pickwell_begin_provider',[admission.reservation_id,'b'.repeat(64)],['uuid','text']);assert.equal(provider.call_allowed,true);
  await rpc('pickwell_record_provider',[provider.attempt_id,'succeeded',0,100,100,1],['uuid','text','numeric','bigint','bigint','integer']);
  candidate=normalizeIngredientEvidence(candidate);const validation=validateAnalysis(candidate,{model:'muse-spark-1.3',requireFront:true});assert.equal(validation.status,'validated');
  candidate={...candidate,nutrition:validation.nutrition,ingredients:validation.ingredients,validation};
  await rpc('pickwell_stage_analysis',[uid,key,candidate,'muse-spark-1.3',PROMPT_VERSION],['uuid','uuid','jsonb','text','text']);
  return {uid,key,code,digest,candidate,validation,...admission};
 }
 const gate=s=>rpc('pickwell_publication_gate',[s.uid,s.key],['uuid','uuid']);
 const publish=s=>rpc('pickwell_publish_analysis',[s.uid,s.key,s.validation],['uuid','uuid','jsonb']);
 async function inspection(s){await gate(s);return (await rpc('pickwell_inspect_product_review',[null],['uuid'])).find(r=>r.barcode===s.code);}
 async function inspect(s){const row=await inspection(s);return rpc('pickwell_inspect_product_review',[row.review_id],['uuid']);}
 const decide=(v,{code=v.barcode,input=v.input_digest,candidate=v.candidate_digest,decision='approve',resolution='no_discrepancy'}={})=>rpc('pickwell_decide_product_review',
  [v.review_id,code,input,candidate,v.policy_version,decision,'test-review-001','controlled_demo_evidence',resolution],['uuid','text','text','text','text','text','text','text','text']);
 const usage=s=>rpc('pickwell_quota_snapshot',[s.uid,'ai_analysis'],['uuid','text']);
 try{
  await db.exec(`create role anon;create role authenticated;create role service_role bypassrls;
   create schema auth;create table auth.users(id uuid primary key,email text,raw_user_meta_data jsonb,is_anonymous boolean not null default false,email_confirmed_at timestamptz default now());
   create function auth.uid() returns uuid language sql stable as $$select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid$$;
   create schema storage;create table storage.buckets(id text primary key,name text,public boolean,file_size_limit bigint,allowed_mime_types text[]);
   create table storage.objects(id uuid primary key default gen_random_uuid(),bucket_id text,name text,metadata jsonb,created_at timestamptz default now());
   create function storage.foldername(text) returns text[] language sql immutable as $$select (string_to_array($1,'/'))[1:array_length(string_to_array($1,'/'),1)-1]$$;
   create schema extensions;create extension if not exists "uuid-ossp" with schema extensions;set search_path=public;`);
  for(const file of (await readdir('supabase/migrations')).filter(f=>f.endsWith('.sql')).sort())await db.exec((await readFile('supabase/migrations/'+file,'utf8')).replace('create extension if not exists "pgcrypto";','-- unavailable in PGlite'));
  await db.exec("update public.quota_controls set inference_enabled=true,approved_model='muse-spark-1.3',daily_spend_usd=10,global_calls_daily=100,change_reason='disposable trust fixture only'");

  await t.test('A barcode with coherent B images/facts cannot auto-publish despite readable valid extraction',async()=>{
   const c=frontLabelFixture();for(const p of ['front','nutrition','ingredients'])c.identity[p].product_name='Product B';c.identity.consistency='consistent';
   const s=await stage({candidate:c}),r=await publish(s);assert.equal(r.status,'review_required');assert.equal((await usage(s)).used,0);assert.equal((await usage(s)).reserved,1);
   assert.equal(await scalar(`select count(*)::int as value from public.published_products where barcode='${s.code}'`),0);
   const details=await inspect(s);assert.equal(details.candidate.identity.front.product_name,'Product B');assert.equal(details.input_digest,s.digest);
   await rpc('pickwell_cancel_analysis_review',[s.uid,s.key],['uuid','uuid']);
  });
  await t.test('ordinary clients cannot inspect/approve or forge a publication via table or RPC',async()=>{
   for(const role of ['anon','authenticated']){
    assert.equal(await scalar(`select has_table_privilege('${role}','public.product_trust_reviews','SELECT') as value`),false);
    await db.exec('set role '+role);
    try {
     await denied(db.query('select * from public.product_trust_reviews'));
     await denied(rpc('pickwell_publication_gate',[id(),id()],['uuid','uuid']));
    } finally { await db.exec('reset role'); }

    for(const signature of ['pickwell_publication_gate(uuid,uuid)','pickwell_decide_product_review(uuid,text,text,text,text,text,text,text,text)','pickwell_publish_analysis(uuid,uuid,jsonb)','pickwell_finish_usage(uuid,text,uuid,uuid)'])assert.equal(await scalar(`select has_function_privilege('${role}','public.${signature}','EXECUTE') as value`),false);
   }
   const s=await stage();await denied(rpc('pickwell_finish_usage',[s.reservation_id,'published',id(),id()],['uuid','text','uuid','uuid']));
   await rpc('pickwell_cancel_analysis_review',[s.uid,s.key],['uuid','uuid']); // No gate yet: does not cancel provider work blindly.
   await gate(s);await rpc('pickwell_cancel_analysis_review',[s.uid,s.key],['uuid','uuid']);
  });
  await t.test('approvals reject changed barcode, image digest, candidate and unperformed policy',async()=>{
   const s=await stage(),v=await inspect(s);
   for(const change of [{code:barcode()},{input:'c'.repeat(64)},{candidate:'d'.repeat(64)}])await denied(decide(v,change));
   await denied(db.query("update public.product_trust_reviews set candidate_digest=$1 where id=$2",['e'.repeat(64),v.review_id]));
   const changed={...s.candidate,identity:{...s.candidate.identity,front:{...s.candidate.identity.front,product_name:'Another product'}}};
   await db.query('update public.analysis_candidates set candidate=$1 where job_id=$2',[changed,s.job_id]);await denied(decide(v));await denied(gate(s));
   await db.query('update public.analysis_candidates set candidate=$1 where job_id=$2',[s.candidate,s.job_id]);
   await rpc('pickwell_cancel_analysis_review',[s.uid,s.key],['uuid','uuid']);
  });
  await t.test('explicit name/brand/size discrepancies require review even when Muse says consistent; bilingual wording can be resolved',async()=>{
   const c=frontLabelFixture();c.identity.front.product_name='Arroz';c.identity.nutrition.product_name='Rice';c.identity.consistency='consistent';
   const s=await stage({candidate:c});assert.equal(s.validation.provenance.cross_image_consistency,'review_required');
   const v=await inspect(s);await denied(decide(v));await decide(v,{resolution:'wording_variation_reviewed'});const result=await publish(s);assert.equal(result.status,'ready');
   assert.equal(result.product.provenance.barcode_association.status,'operator_reviewed');assert.equal(result.product.provenance.identity_verification,'unverified');
  });
  await t.test('missing/uncertain identity is not an automatic rejection or an automatic approval',async()=>{
   const c=frontLabelFixture();c.identity.front.product_name=null;
   const s=await stage({candidate:c});assert.equal((await publish(s)).status,'review_required');
   const v=await inspect(s);await decide(v,{decision:'reject',resolution:'conflict_unresolved'});
   const u=await usage(s);assert.equal(u.used,0);assert.equal(u.reserved,0);
   assert.equal((await rpc('pickwell_analysis_reply',[s.uid,s.key],['uuid','uuid'])).error,'review_rejected');
   assert.equal(await scalar(`select count(*)::int as value from public.analysis_candidates where job_id='${s.job_id}'`),0);
  });
  let accepted;
  await t.test('correct approval publishes one immutable revision, finalizes exactly one credit and cleans candidate',async()=>{
   const s=await stage(),v=await inspect(s);await decide(v);assert.equal((await gate(s)).status,'approved');
   const result=await publish(s);accepted={...s,product:result.product};assert.equal(result.status,'ready');
   assert.equal(result.product.provenance.barcode_association.review_ref,'test-review-001');
   const u=await usage(s);assert.equal(u.used,1);assert.equal(u.reserved,0);
   assert.equal(await scalar(`select count(*)::int as value from public.analysis_candidates where job_id='${s.job_id}'`),0);
   assert.equal((await publish(s)).status,'already_exists');assert.equal((await usage(s)).used,1);
   const second=await rpc('pickwell_admit_analysis',[s.uid,id(),s.code,'f'.repeat(64)],['uuid','uuid','text','text']);assert.equal(second.status,'already_exists');
  });
  await t.test('fresh key and second owner cannot borrow approval or bypass an active reviewed candidate',async()=>{
   const s=await stage(),v=await inspect(s);await decide(v);
   const bob=await user();const jobs=await Promise.all([rpc('pickwell_admit_analysis',[s.uid,id(),s.code,s.digest],['uuid','uuid','text','text']),rpc('pickwell_admit_analysis',[bob,id(),s.code,s.digest],['uuid','uuid','text','text'])]);
   for(const j of jobs){assert.equal(j.status,'processing');assert.equal(j.job_id,undefined);}
   const values=await Promise.all([publish(s),rpc('pickwell_admit_analysis',[bob,id(),s.code,'c'.repeat(64)],['uuid','uuid','text','text'])]);
   assert.equal(values[0].status,'ready');assert.ok(['processing','already_exists'].includes(values[1].status));
   assert.equal(await scalar(`select count(*)::int as value from public.products where barcode='${s.code}'`),1);
   assert.equal((await usage(s)).used,1);
  });
  await t.test('existing ready conflict and possible reformulation cannot overwrite trusted records',async()=>{
   const before=accepted.product;
   const second=await rpc('pickwell_admit_analysis',[await user(),id(),accepted.code,'f'.repeat(64)],['uuid','uuid','text','text']);
   assert.equal(second.status,'already_exists');assert.equal(second.product.analysis_id,before.analysis_id);
   assert.deepEqual(second.product.ingredients,before.ingredients);assert.equal(second.product.provenance.barcode_association.review_ref,'test-review-001');
  });
  await t.test('owner cancellation is scoped, releases reservation and keeps provider ledger',async()=>{
   const s=await stage();await gate(s);await denied(rpc('pickwell_cancel_analysis_review',[await user(),s.key],['uuid','uuid']));
   const cancelled=await rpc('pickwell_cancel_analysis_review',[s.uid,s.key],['uuid','uuid']);assert.equal(cancelled.status,'review_cancelled');
   assert.equal((await usage(s)).used,0);assert.equal((await usage(s)).reserved,0);
   assert.equal(await scalar(`select count(*)::int as value from public.analysis_candidates where job_id='${s.job_id}'`),0);
   assert.equal(await scalar(`select count(*)::int as value from public.ai_usage where job_id='${s.job_id}' and state='succeeded'`),1);
   assert.equal((await rpc('pickwell_cancel_analysis_review',[s.uid,s.key],['uuid','uuid'])).status,'review_cancelled');
  });
  await t.test('expiry releases holds and prevents an approval replay after its window',async()=>{
   const s=await stage();await db.query("update public.analysis_candidates set expires_at=clock_timestamp()+interval '1 second' where job_id=$1",[s.job_id]);
   const v=await inspect(s);await new Promise(r=>setTimeout(r,1100));await rpc('pickwell_prune_analysis',[],[]);
   assert.equal((await usage(s)).used,0);assert.equal((await usage(s)).reserved,0);await denied(decide(v));
   assert.equal((await rpc('pickwell_analysis_reply',[s.uid,s.key],['uuid','uuid'])).error,'review_expired');
  });
  await t.test('guest reuse returns reviewed data without a provider operation and legacy demo remains unverified',async()=>{
   const result=await rpc('pickwell_get_product',[null,id(),accepted.code],['uuid','uuid','text']);assert.equal(result.status,'ready');assert.equal(result.product.analysis_id,accepted.product.analysis_id);
   const safe=sanitizePublishedProduct(result.product);assert.equal(safe.provenance.barcode_association.status,'operator_reviewed');assert.equal(safe.provenance.barcode_association.review_id,undefined);
   await db.exec(await readFile('supabase/seed/04_pickwell_demo.sql','utf8'));const legacy=await rpc('pickwell_get_product',[null,id(),'02900000000018'],['uuid','uuid','text']);assert.equal(legacy.status,'ready');assert.equal(sanitizePublishedProduct(legacy.product).provenance.barcode_association.status,'unverified');
  });
  await t.test('interpretation refresh preserves the original review, not caller-supplied authority',async()=>{
   const p=accepted.product,provenance={...p.provenance,interpretation_version:'evidence-composition-v99',barcode_association:{status:'independently_verified',review_ref:'forged-ref'},identity:{front:{product_name:'Forged'}}};
   const r=await rpc('pickwell_refresh_interpretation',[p.id,p.analysis_id,p.provenance.interpretation_version,{nutrition:p.nutrition,ingredients:p.ingredients,findings:p.findings??[],summary:'Reviewed context revision',explanations:[],missing_information:[],provenance}],['uuid','uuid','text','jsonb']);assert.equal(r.status,'refreshed');
   const current=await rpc('pickwell_get_product',[null,id(),accepted.code],['uuid','uuid','text']);
   assert.deepEqual(current.product.provenance.barcode_association,p.provenance.barcode_association);assert.deepEqual(current.product.provenance.identity,p.provenance.identity);
  });

  // Thumbnail fixtures use the exact same ordered evidence-hash contract as analysis.
  async function mediaFixture({published=true}={}) {
   const code=barcode(),front='1'.repeat(64),nutrition='2'.repeat(64),ingredients='3'.repeat(64);
   const bytes=await crypto.subtle.digest('SHA-256',new TextEncoder().encode(`${code}|${front}|${nutrition}|${ingredients}`));
   const digest=[...new Uint8Array(bytes)].map(x=>x.toString(16).padStart(2,'0')).join('');
   const s=await stage({code,digest}),v=await inspect(s);
   if(published){await decide(v);await publish(s);}
   const args=[v.review_id,code,digest,v.candidate_digest,front,nutrition,ingredients,'4'.repeat(64),300,200,4096];
   const prepare=()=>rpc('pickwell_prepare_thumbnail',args,['uuid','text','text','text','text','text','text','text','integer','integer','integer']);
   return {s,v,args,prepare};
  }
  await t.test('thumbnail upload is impossible for pending, rejected or cancelled reviews',async()=>{
   for(const terminal of ['pending','reject','cancel','expire']){
    const fixture=await mediaFixture({published:false});
    if(terminal==='reject')await decide(fixture.v,{decision:'reject',resolution:'conflict_unresolved'});
    if(terminal==='cancel')await rpc('pickwell_cancel_analysis_review',[fixture.s.uid,fixture.s.key],['uuid','uuid']);
    if(terminal==='expire'){
     await db.query("update public.analysis_candidates set expires_at=clock_timestamp()-interval '1 second' where job_id=$1",[fixture.s.job_id]);
     await rpc('pickwell_prune_analysis',[],[]);
    }
    await denied(fixture.prepare());
    if(terminal==='pending')await rpc('pickwell_cancel_analysis_review',[fixture.s.uid,fixture.s.key],['uuid','uuid']);
   }
   assert.equal(await scalar("select count(*)::int as value from public.product_thumbnails"),0);
   assert.equal(await scalar("select public as value from storage.buckets where id='product-thumbnails'"),false);
  });
  await t.test('thumbnail source, review/candidate and format/size bindings fail closed',async()=>{
   const fixture=await mediaFixture();
   for(const [index,value]of [[1,barcode()],[2,'e'.repeat(64)],[3,'f'.repeat(64)],[4,'9'.repeat(64)],[7,'not-a-hash'],[8,385],[10,65537]]){
    const args=[...fixture.args];args[index]=value;
    await assert.rejects(rpc('pickwell_prepare_thumbnail',args,['uuid','text','text','text','text','text','text','text','integer','integer','integer']));
   }
  });
  await t.test('only completed upload appears in published projection; association and image cannot be replaced',async()=>{
   const fixture=await mediaFixture(),asset=await fixture.prepare();
   assert.equal(await scalar("select thumbnail as value from public.published_products where barcode='"+fixture.s.code+"'"),null);
   await denied(rpc('pickwell_commit_thumbnail',[asset.id],['uuid']));
   await db.query("insert into storage.objects(bucket_id,name,metadata) values('product-thumbnails',$1,$2)",[asset.object_path,{mimetype:'image/jpeg',size:4096}]);
   const outcomes=await Promise.all(Array.from({length:8},()=>rpc('pickwell_commit_thumbnail',[asset.id],['uuid'])));
   assert.ok(outcomes.every(o=>o.status==='ready'));
   assert.equal(await scalar("select count(*)::int as value from public.published_thumbnail_assets where id='"+asset.id+"'"),1);
   const projection=await scalar("select thumbnail as value from public.published_products where barcode='"+fixture.s.code+"'");
   assert.deepEqual(sanitizePublishedProduct({... (await publish(fixture.s)).product}).thumbnail,projection);
   const current=(await publish(fixture.s)).product;
   await rpc('pickwell_refresh_interpretation',[current.id,current.analysis_id,current.provenance.interpretation_version,
    {nutrition:current.nutrition,ingredients:current.ingredients,findings:current.findings??[],summary:'Thumbnail-preserving fixture refresh',explanations:[],missing_information:[],
     provenance:{...current.provenance,interpretation_version:'evidence-composition-v98'}}],['uuid','uuid','text','jsonb']);
   const refreshed=await rpc('pickwell_get_product',[null,id(),fixture.s.code],['uuid','uuid','text']);assert.deepEqual(refreshed.product.thumbnail,projection);
   const again=await fixture.prepare();assert.equal(again.id,asset.id);
   fixture.args[7]='5'.repeat(64);await denied(fixture.prepare());
   await denied(db.query("update public.product_thumbnails set digest=$1 where id=$2",['6'.repeat(64),asset.id]));
   assert.equal((await usage(fixture.s)).used,1,'Optional thumbnail never charges another credit');
  });
  await t.test('expired upload is private, cleanup claims it, and Storage deletion must precede forgetting',async()=>{
   const fixture=await mediaFixture(),asset=await fixture.prepare();
   // Time travel only in a disposable test fixture, not a production mutation path.
   await db.exec('alter table public.product_thumbnails disable trigger pickwell_thumbnail_immutable');
   await db.query("update public.product_thumbnails set created_at=clock_timestamp()-interval '31 minutes' where id=$1",[asset.id]);
   await db.exec('alter table public.product_thumbnails enable trigger pickwell_thumbnail_immutable');
   await db.query("insert into storage.objects(bucket_id,name,metadata) values('product-thumbnails',$1,$2)",[asset.object_path,{mimetype:'image/jpeg',size:4096}]);
   await denied(rpc('pickwell_commit_thumbnail',[asset.id],['uuid']));
   const cleanup=await rpc('pickwell_thumbnail_cleanup',[],[]);assert.ok(cleanup.some(row=>row.id===asset.id));
   await denied(rpc('pickwell_forget_thumbnail',[asset.id],['uuid']));
   // Stub Storage API deletion in PGlite only; native verification uses Storage HTTP.
   await db.query("delete from storage.objects where bucket_id='product-thumbnails' and name=$1",[asset.object_path]);
   await rpc('pickwell_forget_thumbnail',[asset.id],['uuid']);
   assert.equal(await scalar("select count(*)::int as value from public.product_thumbnails where id='"+asset.id+"'"),0);
  });
  await t.test('private thumbnail rows and mutation functions have no ordinary-role grants; Storage deny is restrictive',async()=>{
   for(const role of ['anon','authenticated']){
    await db.exec('set role '+role);
    try{await denied(db.query('select * from public.product_thumbnails'));await denied(rpc('pickwell_commit_thumbnail',[id()],['uuid']));}
    finally{await db.exec('reset role');}
   }
   assert.equal(await scalar("select permissive='RESTRICTIVE' as value from pg_policies where policyname='Pickwell thumbnails server only'"),true);
  });
 }finally{await db.close();}
});
