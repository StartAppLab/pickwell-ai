import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { createAnalysisStatusHandler, sanitizePublishedProduct, readPublishedProduct }
  from '../functions/_shared/catalog_boundary.mjs';

test('published projection strips contributor, internal and nested arbitrary fields', () => {
  const safe = sanitizePublishedProduct({ id: 'fixture', barcode: '02900000000018',
    contributor_id: 'private', user_id: 'private', prompt_version: 'private', lease_expires_at: 'private',
    nutrition: { raw: 'label', basis: 'per_100g', token: 'private', nutrients: [
      { name: 'Protein', value: 4, unit: 'g', source: '4 g', email: 'private' }] },
    ingredients: { raw: 'oats', items: ['oats'], declared_allergens: null, token: 'private' },
    findings: [{ severity: 'yellow', title: 'Demo', user_id: 'private', source_details: {
      rule_id: 'demo', token: 'private', evidence: [{ source: 'fixture', token: 'private' }] } }] });
  assert.ok(!JSON.stringify(safe).includes('private'));
  assert.equal(safe.ingredients.declared_allergens, null);
});

test('status boundary rejects forged/unverified identities before privileged reads', async () => {
  const env = { SUPABASE_URL: 'https://example.supabase.co', SUPABASE_ANON_KEY: 'public-fixture',
    SUPABASE_SERVICE_ROLE_KEY: 'server-fixture' };
  for (const user of [{ id: crypto.randomUUID(), is_anonymous: true },
    { id: crypto.randomUUID(), is_anonymous: false, email: 'fixture@example.invalid' }]) {
    let calls = 0;
    const handler = createAnalysisStatusHandler(env, async () => { calls++; return Response.json(user); });
    const request = new Request('https://example.invalid', { method: 'POST',
      headers: { authorization: 'Bearer fake.header.signature', 'content-type': 'application/json' },
      body: JSON.stringify({ job_id: crypto.randomUUID() }) });
    assert.equal((await handler(request)).status, 403);
    assert.equal(calls, 1);
  }
});

test('native Auth/REST verifies DB grants, owner-scoped reads and server-only writes',
  { skip: !process.env.PICKWELL_NATIVE_STATUS }, async t => {
  const state = JSON.parse(await readFile(process.env.PICKWELL_NATIVE_STATUS, 'utf8'));
  const config = state.env;
  const origin = new URL(config.API_URL);
  assert.ok(state.runtime === 'native' && ['127.0.0.1', 'localhost'].includes(origin.hostname),
    'Only the isolated local native stack may be targeted');
  const publicKey = config.PUBLISHABLE_KEY ?? config.ANON_KEY;
  const serverKey = config.SERVICE_ROLE_KEY;
  const serverHeaders = { apikey: serverKey, Authorization: `Bearer ${serverKey}`, 'content-type': 'application/json' };
  const users = [], job = crypto.randomUUID();
  async function call(path, { token, method = 'GET', body, server = false, prefer } = {}) {
    const headers = server ? { ...serverHeaders } : { apikey: publicKey, 'content-type': 'application/json' };
    if (token) headers.Authorization = `Bearer ${token}`;
    if (prefer) headers.Prefer = prefer;
    return fetch(origin.origin + path, { method, headers, redirect: 'error',
      signal: AbortSignal.timeout(60000), ...(body ? { body: JSON.stringify(body) } : {}) });
  }
  try {
    // Standard local Auth signup; no admin verification override or hosted email.
    // Existing disposable test profile has email confirmations disabled.
    for (let i = 0; i < 2; i++) {
      const r = await call('/auth/v1/signup', { method: 'POST', body: {
        email: `boundary-${crypto.randomUUID()}@example.invalid`, password: 'Local-' + crypto.randomUUID() } });
      assert.equal(r.status, 200, 'Local Auth signup succeeds');
      const session = await r.json();
      assert.ok(session.access_token && session.user?.email_confirmed_at && session.user?.is_anonymous === false);
      users.push({ id: session.user.id, token: session.access_token });
      const verified = await call('/auth/v1/user', { token: session.access_token });
      assert.equal(verified.status, 200);
    }
    await t.test('client REST roles cannot mutate any protected security/catalog table', async () => {
      for (const token of [undefined, users[0].token]) {
        for (const table of ['products', 'product_analyses', 'analysis_findings', 'analysis_jobs',
          'usage_daily', 'usage_reservations', 'user_entitlements', 'revenuecat_events']) {
          const field = { products: 'name', product_analyses: 'summary', analysis_findings: 'title',
            analysis_jobs: 'state', usage_daily: 'used', usage_reservations: 'state',
            user_entitlements: 'plan_code', revenuecat_events: 'verified' }[table];
          const value = field === 'used' ? 0 : field === 'verified' ? true : 'forged';
          const key = ['usage_daily', 'user_entitlements'].includes(table) ? 'user_id'
            : table === 'revenuecat_events' ? 'event_id' : 'id';
          for (const method of ['GET', 'POST', 'PATCH', 'DELETE']) {
            const filter = ['PATCH', 'DELETE'].includes(method) ? `?${key}=eq.${crypto.randomUUID()}` : '';
            const r = await call('/rest/v1/' + table + filter, { token, method,
              ...(method === 'POST' || method === 'PATCH' ? { body: { [field]: value } } : {}) });
            assert.ok([401, 403].includes(r.status), `${table} ${method} denied to client role (HTTP ${r.status})`);
          }
        }
        const rpc = await call('/rest/v1/rpc/handle_new_user', { token, method: 'POST', body: {} });
        assert.ok([401, 403, 404].includes(rpc.status), 'Signup definer is not a client RPC');
      }
    });
    await t.test('server-only insertion and usage reads succeed', async () => {
      const insert = await call('/rest/v1/analysis_jobs', { server: true, method: 'POST', body: {
        id: job, barcode: '96385074', user_id: users[0].id, idempotency_key: crypto.randomUUID() } });
      assert.equal(insert.status, 201);
      const usage = await call('/rest/v1/usage_daily', { server: true, method: 'POST', body: {
        user_id: users[0].id, day_utc: '2026-11-02', metric: 'ai_analysis', used: 1 } });
      assert.equal(usage.status, 201);
    });
    const env = { SUPABASE_URL: origin.origin, SUPABASE_ANON_KEY: publicKey,
      SUPABASE_SERVICE_ROLE_KEY: serverKey };
    await t.test('status function core accepts owner, hides other users and ignores client identity claims', async () => {
      const handler = createAnalysisStatusHandler(env);
      const request = (token, body) => new Request(origin.origin + '/functions/v1/get-analysis-status', {
        method: 'POST', headers: { 'content-type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
        body: JSON.stringify(body) });
      assert.equal((await handler(request(undefined, { job_id: job }))).status, 401);
      assert.equal((await handler(request('invalid.invalid.invalid', { job_id: job }))).status, 401);
      assert.equal((await handler(request(users[0].token, { job_id: job, user_id: users[1].id }))).status, 400);
      const own = await handler(request(users[0].token, { job_id: job }));
      assert.equal(own.status, 200);
      assert.equal((await own.json()).job.user_id, undefined);
      assert.equal((await handler(request(users[1].token, { job_id: job }))).status, 404);
      assert.equal((await handler(request(users[1].token, { job_id: crypto.randomUUID() }))).status, 404);
    });
    await t.test('published-only reader strips private fields and misses processing rows', async () => {
      const processing = await call('/rest/v1/products?on_conflict=barcode', { server: true,
        method: 'POST', prefer: 'resolution=ignore-duplicates', body: {
          barcode: '96385074', name: 'TEST PROCESSING ONLY', is_demo: true } });
      assert.equal(processing.status, 201);
      const demo = await readPublishedProduct(env, '02900000000018');
      assert.equal(demo.is_demo, true);
      assert.equal(demo.contributor_id, undefined);
      assert.equal(demo.prompt_version, undefined);
      assert.equal(await readPublishedProduct(env, '00000096385074'), null);
    });
  } finally {
    for (const user of users) await call('/auth/v1/admin/users/' + user.id, { server: true, method: 'DELETE' });
  }
});
