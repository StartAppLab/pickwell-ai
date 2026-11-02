import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createHandler, META_URL, MAX_BODY, MAX_IMAGE, parseExtraction, validateImage } from './core.mjs';

// Binary header fixtures only: not readable labels or evidence of image inference.
function image(width = 20) {
  const header = Buffer.alloc(32);
  Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]).copy(header);
  header.writeUInt32BE(13, 8); header.write('IHDR', 12);
  header.writeUInt32BE(width, 16); header.writeUInt32BE(20, 20);
  return `data:image/png;base64,${header.toString('base64')}`;
}
const env = { SPIKE_ENABLED: 'true', SPIKE_OPERATOR_TOKEN: 'operator-fixture-'.repeat(4),
  SPIKE_USER_ID: 'fixture-user', SUPABASE_URL: 'https://example.supabase.co',
  SUPABASE_ANON_KEY: 'public-fixture', META_API_KEY: 'provider-fixture',
  META_API_URL: META_URL, META_MODEL: 'muse-spark-1.3' };
const user = { id: env.SPIKE_USER_ID, is_anonymous: false, email: 'tester@example.invalid',
  email_confirmed_at: '2026-11-02T00:00:00Z' };
const extraction = () => ({ status: 'extracted', retake: [],
  ingredients: { raw: 'Oats, salt', items: ['Oats', 'salt'], declared_allergens: null },
  nutrition: { raw: 'Per 100 g Sodium 20 mg', basis: 'per_100g', serving_size: null,
    nutrients: [{ name: 'Sodium', value: 20, unit: 'mg', source: 'Sodium 20 mg' }] } });
const provider = value => ({ model: env.META_MODEL, usage: { prompt_tokens: 100, completion_tokens: 20 },
  choices: [{ finish_reason: 'stop', message: { content: JSON.stringify(value) } }] });
const body = (id = crypto.randomUUID()) => ({ idempotency_key: id,
  nutrition_image: image(20), ingredients_image: image(21) });
function request(value = body(), headers = {}) {
  return new Request('https://example.invalid/spike', { method: 'POST',
    headers: { 'content-type': 'application/json', 'x-spike-token': env.SPIKE_OPERATOR_TOKEN,
      authorization: 'Bearer fixture.header.signature', ...headers }, body: JSON.stringify(value) });
}
function setup({ config = env, account = user, response = provider(extraction()), failure } = {}) {
  const calls = [];
  const handler = createHandler(config, async (url, options) => {
    calls.push({ url, options });
    if (url.endsWith('/auth/v1/user')) return Response.json(account);
    if (failure) throw failure;
    return response instanceof Response ? response.clone() : Response.json(response);
  });
  return { handler, calls };
}

test('disabled and unconfigured spikes make no outbound calls', async () => {
  for (const config of [{ ...env, SPIKE_ENABLED: 'false' }, { ...env, META_API_KEY: '' },
    { ...env, META_API_URL: 'https://example.invalid' },
    { ...env, META_MODEL: 'muse-spark-1.3-contributor' }]) {
    const { handler, calls } = setup({ config });
    assert.equal((await handler(request())).status, 503); assert.equal(calls.length, 0);
  }
});

test('operator token and bearer format are rejected before authentication or inference', async () => {
  for (const headers of [{ 'x-spike-token': 'bad' }, { authorization: '' },
    { authorization: 'Bearer sb_publishable_fixture' }]) {
    const { handler, calls } = setup();
    assert.equal((await handler(request(body(), headers))).status, 401);
    assert.equal(calls.length, 0);
  }
});

test('verified allowlist checks use server Auth response, not caller claims', async () => {
  for (const account of [{ ...user, id: 'other' }, { ...user, is_anonymous: true },
    { ...user, email_confirmed_at: null }, { ...user, email: '' }, { ...user, is_anonymous: undefined }]) {
    const { handler, calls } = setup({ account });
    assert.equal((await handler(request())).status, 403);
    assert.equal(calls.length, 1);
  }
  const handler = createHandler(env, async () => Response.json({}, { status: 401 }));
  assert.equal((await handler(request())).status, 401);
});

test('two labeled images use documented request format and usage is sanitized', async () => {
  const { handler, calls } = setup();
  const response = await handler(request());
  assert.equal(response.status, 200);
  const result = await response.json();
  assert.equal(result.status, 'extracted'); assert.equal(result.nutrition.basis, 'per_100g');
  assert.deepEqual(result.metadata.usage, { input_tokens: 100, output_tokens: 20 });
  assert.equal(result.metadata.estimated_cost_usd, null);
  const outbound = JSON.parse(calls[1].options.body);
  assert.equal(calls[1].url, META_URL); assert.equal(outbound.store, false);
  assert.equal(outbound.max_completion_tokens, 4096);
  assert.equal(outbound.reasoning_effort, 'minimal');
  assert.equal(outbound.messages[1].content.filter(part => part.type === 'image_url').length, 2);
  assert.equal(calls[1].options.headers.Authorization, `Bearer ${env.META_API_KEY}`);
  assert.equal(calls[0].options.headers.Authorization, 'Bearer fixture.header.signature');
  assert.ok(!JSON.stringify(result).includes(env.META_API_KEY));
});

test('bad MIME/signature/dimensions, external URLs, same image and claimed privileges never invoke Meta', async () => {
  for (const value of [{ ...body(), nutrition_image: 'https://example.invalid/image.jpg' },
    { ...body(), nutrition_image: image().replace('image/png', 'image/jpeg') },
    { ...body(), nutrition_image: image(5000) },
    { ...body(), nutrition_image: image(), ingredients_image: image() },
    { ...body(), verified: true }, { ...body(), plan: 'premium' }]) {
    const { handler, calls } = setup();
    assert.equal((await handler(request(value))).status, 400); assert.equal(calls.length, 1);
  }
  assert.throws(() => validateImage(`data:image/png;base64,${'A'.repeat(MAX_IMAGE * 2)}`));
});

test('streamed body cap is enforced without relying on Content-Length', async () => {
  const { handler, calls } = setup();
  assert.equal((await handler(request({ junk: 'x'.repeat(MAX_BODY) }))).status, 413);
  assert.equal(calls.length, 1);
});

test('unreadable and unknown basis request retake without returning partial facts', async () => {
  const value = extraction(); value.status = 'needs_retake'; value.retake = ['ingredients'];
  value.ingredients = { raw: null, items: [], declared_allergens: null };
  const { handler } = setup({ response: provider(value) });
  const result = await (await handler(request())).json();
  assert.equal(result.status, 'needs_retake'); assert.deepEqual(result.retake, ['ingredients']);
  assert.equal(result.ingredients, undefined);
  assert.equal(result.diagnostic_extraction.status, 'needs_retake');
  assert.equal(result.diagnostic_extraction.ingredients.raw, null);
  const unknown = extraction(); unknown.nutrition.basis = 'unknown';
  assert.deepEqual(parseExtraction(unknown), { status: 'needs_retake', retake: ['nutrition'] });
});

test('malformed, negative, extra-field and unsupported-unit extractions fail closed', async () => {
  const values = [];
  let value = extraction(); value.nutrition.nutrients[0].value = -1; values.push(value);
  value = extraction(); value.nutrition.nutrients[0].unit = 'ounces'; values.push(value);
  value = extraction(); value.premium = true; values.push(value);
  value = extraction(); delete value.ingredients; values.push(value);
  for (const response of [...values.map(provider), { ...provider(extraction()), choices: [] },
    { ...provider(extraction()), choices: [{ finish_reason: 'length', message: { content: '{}' } }] }]) {
    const { handler } = setup({ response });
    assert.equal((await handler(request())).status, 502);
  }
});

test('idempotency and three-attempt process cap do not retry paid calls', async () => {
  const { handler, calls } = setup(); const value = body();
  assert.equal((await handler(request(value))).status, 200);
  assert.equal((await handler(request(value))).status, 409);
  assert.equal((await handler(request())).status, 200);
  assert.equal((await handler(request())).status, 200);
  assert.equal((await handler(request())).status, 429);
  assert.equal(calls.filter(call => call.url === META_URL).length, 3);
});

test('concurrent requests admit at most one inference in the same process', async () => {
  let release, notify;
  const started = new Promise(resolve => { notify = resolve; });
  const pending = new Promise(resolve => { release = resolve; });
  let modelCalls = 0;
  const handler = createHandler(env, async url => {
    if (url.endsWith('/auth/v1/user')) return Response.json(user);
    modelCalls++; notify(); await pending;
    return Response.json(provider(extraction()));
  });
  const first = handler(request());
  await started;
  try {
    assert.equal((await handler(request())).status, 429);
    assert.equal(modelCalls, 1);
  } finally { release(); }
  assert.equal((await first).status, 200);
});

test('provider rate limits/timeouts fail once, preserve available usage, and never echo raw errors', async () => {
  for (const options of [{ response: Response.json({ secret: env.META_API_KEY }, { status: 429 }) },
    { failure: new DOMException(env.META_API_KEY, 'TimeoutError') },
    { response: { ...provider(extraction()), choices: [{ finish_reason: 'stop', message: { content: 'not JSON' } }] } }]) {
    const { handler, calls } = setup(options);
    const response = await handler(request());
    assert.equal(response.status, 502);
    const result = await response.json();
    assert.ok(result.metadata.duration_ms >= 0);
    assert.ok(!JSON.stringify(result).includes(env.META_API_KEY));
    assert.equal(calls.filter(call => call.url === META_URL).length, 1);
  }
});
