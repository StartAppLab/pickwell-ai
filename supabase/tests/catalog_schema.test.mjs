// Targeted PostgreSQL-engine tests; not a substitute for Docker-backed Supabase.
// Uses the same pinned PGlite version as the existing subscription SQL tests.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile, readdir } from 'node:fs/promises';
import { resolve } from 'node:path';
import { pathToFileURL } from 'node:url';

const moduleRoot = resolve('.secrets/sql-test/node_modules/@electric-sql/pglite/dist');
const { PGlite } = await import(pathToFileURL(moduleRoot + '/index.js').href);
const { uuid_ossp } = await import(pathToFileURL(moduleRoot + '/contrib/uuid_ossp.js').href);
const alice = '10000000-0000-4000-8000-000000000001';
const bob = '20000000-0000-4000-8000-000000000001';
const demo = 'd0000000-0000-4000-8000-000000000001';
const demoAnalysis = 'd0000000-0000-4000-8000-000000000002';
const id = () => crypto.randomUUID();

test('T02.1 additive migrations and catalog/job invariants', async t => {
  const db = new PGlite({ extensions: { uuid_ossp } });
  let assertions = 0;
  const scalar = async sql => (await db.query(sql)).rows[0].value;
  async function rejects(sql, code) {
    await assert.rejects(db.exec(sql), error => error.code === code);
    assertions++;
  }
  try {
    // Minimal platform fixtures, not real accounts or an alternate Auth service.
    await db.exec(`create role anon; create role authenticated; create role service_role bypassrls;
      create schema auth; create table auth.users(id uuid primary key, email text, raw_user_meta_data jsonb, is_anonymous boolean not null default false, email_confirmed_at timestamptz default now());
      create function auth.uid() returns uuid language sql stable as
        $$select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid$$;
      create schema storage;
      create table storage.buckets(id text primary key, name text, public boolean, file_size_limit bigint, allowed_mime_types text[]);
      create table storage.objects(id uuid primary key default gen_random_uuid(), bucket_id text, name text);
      create function storage.foldername(text) returns text[] language sql immutable as
        $$select (string_to_array($1,'/'))[1:array_length(string_to_array($1,'/'),1)-1]$$;
      create schema supabase_migrations;
      create table supabase_migrations.schema_migrations(version text primary key);`);

    const files = (await readdir('supabase/migrations')).filter(f => f.endsWith('.sql')).sort();
    const apply = async files => {
      let count = 0;
      for (const file of files) {
        const version = file.split('_')[0];
        await db.transaction(async tx => {
          if ((await tx.query('select 1 from supabase_migrations.schema_migrations where version=$1', [version])).rows.length) return;
          // PGlite lacks pgcrypto; no migration crypto operation is replaced.
          // gen_random_uuid is built into PostgreSQL; uuid-ossp is loaded above.
          const sql = (await readFile('supabase/migrations/' + file, 'utf8'))
            .replace('create extension if not exists "pgcrypto";', '-- pgcrypto unavailable in isolated PGlite');
          await tx.exec(sql);
          await tx.query('insert into supabase_migrations.schema_migrations values ($1)', [version]);
          count++;
        });
      }
      return count;
    };

    await t.test('existing migrations and sample content survive additive migration and runner replay', async () => {
      assert.equal(await apply(files.filter(f => f.split('_')[0] < '20261102000100')), 3);
      await db.exec(await readFile('supabase/seed.sql', 'utf8'));
      await db.exec(`insert into auth.users(id,email,raw_user_meta_data) values
        ('${alice}','alice@example.invalid','{}'),('${bob}','bob@example.invalid','{}');
        insert into public.posts(user_id,title,content) values ('${alice}','Preserve this post','legacy sentinel');`);
      const before = await scalar('select count(*)::int as value from public.posts');
      assert.equal(await apply(files), files.length - 3);
      assert.equal(await apply(files), 0);
      assert.equal(await scalar('select count(*)::int as value from public.posts'), before);
      assert.equal(await scalar("select content as value from public.posts where title='Preserve this post'"), 'legacy sentinel');
      assert.equal(await scalar('select count(*)::int as value from public.categories'), 8);
    });

    const seed = await readFile('supabase/seed/04_pickwell_demo.sql', 'utf8');
    await t.test('demo is explicitly synthetic, complete, ready, and seed replay preserves it', async () => {
      await db.exec(seed); await db.exec(seed);
      assert.equal(await scalar(`select count(*)::int as value from public.products where id='${demo}' and status='ready' and is_demo`), 1);
      assert.equal(await scalar(`select model_version as value from public.product_analyses where id='${demoAnalysis}'`), 'fixture:no-provider-call');
      assert.equal(await scalar(`select jsonb_array_length(nutrition->'nutrients') as value from public.product_analyses where id='${demoAnalysis}'`), 8);
      assert.equal(await scalar('select count(*)::int as value from public.analysis_findings'), 1);
      assert.equal(await scalar('select count(*)::int as value from public.published_products'), 1);
    });

    await t.test('canonical aliases, check digits and barcode uniqueness are constrained', async () => {
      assert.equal(await scalar("select public.pickwell_normalize_barcode('036000291452') as value"), '00036000291452');
      assert.equal(await scalar("select public.pickwell_normalize_barcode('0036000291452') as value"), '00036000291452');
      await db.exec("insert into public.products(barcode) values ('036000291452')");
      await rejects("insert into public.products(barcode) values ('0036000291452')", '23505');
      await rejects("insert into public.products(barcode) values ('036000291453')", '22023');
      await rejects("insert into public.products(barcode) values ('not-a-barcode')", '22023');
      assert.equal(await scalar("select public.pickwell_normalize_barcode('96385074') as value"), '00000096385074');
    });

    const other = id();
    await db.exec(`insert into public.products(id,barcode) values ('${other}','4006381333931')`);
    await t.test('ready publication, revision ownership, evidence and structured fields fail closed', async () => {
      await rejects(`update public.products set status='ready' where id='${other}'`, '23514');
      await rejects(`update public.products set current_analysis_id='${demoAnalysis}' where id='${other}'`, '23503');
      await rejects(`insert into public.product_analyses(product_id,nutrition,ingredients,summary,model_version,prompt_version,rules_version,validated_at)
        values ('${other}','{}','{}','x','m','p','r',now())`, '23514');
      await rejects(`insert into public.product_analyses(product_id,nutrition,ingredients,summary,model_version,prompt_version,rules_version,validated_at)
        select '${other}',nutrition,ingredients,summary,'',prompt_version,rules_version,validated_at from public.product_analyses where id='${demoAnalysis}'`, '23514');
      await rejects(`update public.product_analyses set summary='forged' where id='${demoAnalysis}'`, '23514');
      await rejects(`update public.analysis_findings set explanation='forged'`, '23514');
      await rejects(`insert into public.analysis_findings(analysis_id,severity,title,explanation,source_details,sort_order)
        values ('${demoAnalysis}','green','unsupported','unsupported','{}',1)`, '23514');
      await rejects(`update public.products set status='invalidated' where id='${demo}'`, '23514');
      await db.exec(`update public.products set status='invalidated', invalidated_at=now(), invalidation_reason='fixture correction test' where id='${demo}'`);
      await db.exec(seed);
      assert.equal(await scalar(`select status as value from public.products where id='${demo}'`), 'invalidated');
      assert.equal(await scalar('select count(*)::int as value from public.published_products'), 0);
    });

    const job = id(), key = id();
    await t.test('job identity, idempotency, active claim, retry and terminal states are enforced', async () => {
      await db.exec(`insert into public.analysis_jobs(id,barcode,user_id,idempotency_key) values ('${job}','4006381333931','${alice}','${key}')`);
      await rejects(`insert into public.analysis_jobs(barcode,user_id,idempotency_key,state,error_code)
        values ('96385074','${bob}','${id()}','failed','provider_timeout')`, '23514');
      await rejects(`insert into public.analysis_jobs(barcode,user_id,idempotency_key) values ('4006381333931','${bob}','${id()}')`, '23505');
      await rejects(`update public.analysis_jobs set state='ready' where id='${job}'`, '23514');
      await rejects(`update public.analysis_jobs set state='processing',lease_expires_at=now()+interval '1 minute' where id='${job}'`, '23514');
      await db.exec(`update public.analysis_jobs set state='processing',attempts=1,lease_expires_at=now()+interval '1 minute' where id='${job}'`);
      await rejects(`update public.analysis_jobs set state='needs_retake' where id='${job}'`, '23514');
      await db.exec(`update public.analysis_jobs set state='needs_retake',retake_target='ingredients' where id='${job}'`);
      await rejects(`insert into public.analysis_jobs(barcode,user_id,idempotency_key) values ('036000291452','${alice}','${key}')`, '23505');
      await db.exec(`update public.analysis_jobs set state='queued' where id='${job}';
        update public.analysis_jobs set state='processing',attempts=2,lease_expires_at=now()+interval '1 minute' where id='${job}'`);
      await rejects(`update public.analysis_jobs set state='ready',result_product_id='${demo}',result_analysis_id='${demoAnalysis}' where id='${job}'`, '23503');
      await db.exec(`update public.analysis_jobs set state='failed',error_code='provider_timeout' where id='${job}';
        update public.analysis_jobs set state='cancelled' where id='${job}'`);
      await rejects(`update public.analysis_jobs set state='queued' where id='${job}'`, '23514');
      await rejects(`update public.analysis_jobs set user_id='${bob}' where id='${job}'`, '23514');
    });

    await t.test('public/authenticated clients cannot read or forge catalog/jobs, service role can read', async () => {
      for (const role of ['anon', 'authenticated']) {
        await db.exec(`set role ${role}`);
        try {
          for (const table of ['products', 'product_analyses', 'analysis_findings', 'analysis_jobs']) {
            await rejects(`select * from public.${table}`, '42501');
            await rejects(`delete from public.${table}`, '42501');
          }
          await rejects('select * from public.published_products', '42501');
          await rejects("insert into public.products(barcode) values ('96385074')", '42501');
          await rejects(`update public.products set name='forged' where id='${demo}'`, '42501');
        } finally { await db.exec('reset role'); }
      }
      await db.exec('set role service_role');
      try {
        assert.equal(await scalar('select count(*)::int as value from public.products'), 3);
        const serviceProduct = id(), serviceAnalysis = id();
        await db.exec(`insert into public.products(id,barcode) values ('${serviceProduct}','96385074');
          insert into public.product_analyses(id,product_id,nutrition,ingredients,summary,model_version,prompt_version,rules_version,validated_at)
          select '${serviceAnalysis}','${serviceProduct}',nutrition,ingredients,summary,model_version,prompt_version,rules_version,validated_at
          from public.product_analyses where id='${demoAnalysis}';
          insert into public.analysis_findings(analysis_id,severity,title,explanation,source_details)
          select '${serviceAnalysis}',severity,title,explanation,source_details from public.analysis_findings where analysis_id='${demoAnalysis}';
          update public.products set status='ready',current_analysis_id='${serviceAnalysis}',published_at=now() where id='${serviceProduct}'`);
        assert.equal(await scalar(`select count(*)::int as value from public.published_products where id='${serviceProduct}'`), 1);
      }
      finally { await db.exec('reset role'); }
      assert.equal(await scalar("select count(*)::int as value from pg_class where relnamespace='public'::regnamespace and relname in ('products','product_analyses','analysis_findings','analysis_jobs') and relrowsecurity"), 4);
    });

    await t.test('admin correction publishes a new revision and old evidence stays sealed', async () => {
      const correction = id();
      await db.exec(`insert into public.product_analyses(id,product_id,nutrition,ingredients,summary,model_version,prompt_version,rules_version,validated_at)
        select '${correction}',product_id,nutrition,ingredients,'SYNTHETIC DEMO — corrected revision',model_version,prompt_version,'demo-notice-v2',now()
        from public.product_analyses where id='${demoAnalysis}'`);
      await rejects(`insert into public.analysis_findings(analysis_id,severity,title,explanation,source_details)
        values ('${correction}','yellow','Demo','Demo','{"rule_id":"demo","evidence":[]}')`, '23514');
      await rejects(`update public.products set status='ready',current_analysis_id='${correction}' where id='${demo}'`, '23514');
      await db.exec(`insert into public.analysis_findings(analysis_id,severity,title,explanation,source_details)
        select '${correction}',severity,title,explanation,source_details from public.analysis_findings where analysis_id='${demoAnalysis}';
        update public.products set status='ready',current_analysis_id='${correction}',published_at=now() where id='${demo}'`);
      assert.equal(await scalar(`select summary as value from public.published_products where id='${demo}'`), 'SYNTHETIC DEMO — corrected revision');
      assert.equal(await scalar(`select sealed_at is not null as value from public.product_analyses where id='${demoAnalysis}'`), true);
      await rejects(`insert into public.analysis_findings(analysis_id,severity,title,explanation,source_details,sort_order)
        select '${demoAnalysis}',severity,title,explanation,source_details,1 from public.analysis_findings where analysis_id='${correction}'`, '23514');
      await rejects(`update public.product_analyses set sealed_at=null where id='${demoAnalysis}'`, '23514');
    });

    await t.test('account removal detaches contributor but preserves published facts and clears jobs', async () => {
      const revision = id();
      await db.exec(`insert into public.product_analyses(id,product_id,contributor_id,nutrition,ingredients,summary,model_version,prompt_version,rules_version,validated_at)
        select '${revision}','${other}','${alice}',nutrition,ingredients,summary,model_version,prompt_version,rules_version,validated_at from public.product_analyses where id='${demoAnalysis}';
        delete from auth.users where id='${alice}'`);
      assert.equal(await scalar(`select contributor_id as value from public.product_analyses where id='${revision}'`), null);
      assert.equal(await scalar(`select count(*)::int as value from public.analysis_jobs where user_id='${alice}'`), 0);
      assert.equal(await scalar('select count(*)::int as value from public.product_analyses'), 4);
    });
    t.diagnostic(`${assertions} expected SQL rejection checks executed on a real PostgreSQL engine`);
    t.diagnostic(`Isolated engine PostgreSQL ${await scalar("select current_setting('server_version') as value")}; Supabase target is PostgreSQL 15`);
  } finally { await db.close(); }
});
