// T02.2 read boundaries. No Meta calls, quota mutation, purchases or public writes.
const reply = (body, status = 200) => Response.json(body, {
  status, headers: { 'Cache-Control': 'no-store', 'X-Content-Type-Options': 'nosniff' },
});
const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

async function jsonBody(stream, limit) {
  const reader = stream?.getReader();
  if (!reader) throw new Error('empty_body');
  const chunks = []; let size = 0;
  try {
    while (true) {
      const { done, value } = await reader.read(); if (done) break;
      size += value.length;
      if (size > limit) { await reader.cancel(); throw new Error('body_limit'); }
      chunks.push(value);
    }
    const bytes = new Uint8Array(size); let offset = 0;
    for (const chunk of chunks) { bytes.set(chunk, offset); offset += chunk.length; }
    return JSON.parse(new TextDecoder('utf-8', { fatal: true }).decode(bytes));
  } finally { reader.releaseLock(); }
}

function serverOrigin(env) {
  const url = new URL(env.SUPABASE_URL);
  const loopback = ['localhost', '127.0.0.1', '[::1]'].includes(url.hostname);
  if ((url.protocol !== 'https:' && !(loopback && url.protocol === 'http:')) ||
    url.username || url.password || url.pathname !== '/' || url.search || url.hash) throw new Error('server_config');
  if (!env.SUPABASE_ANON_KEY || !env.SUPABASE_SERVICE_ROLE_KEY) throw new Error('server_config');
  return url.origin;
}

// Admin headers never inherit the inbound JWT. Only tightly scoped server reads
// use these credentials; request identity is independently verified through Auth.
async function serverRead(env, resource, fetcher) {
  const response = await fetcher(serverOrigin(env) + '/rest/v1/' + resource, {
    headers: { apikey: env.SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${env.SUPABASE_SERVICE_ROLE_KEY}` },
    redirect: 'error', signal: AbortSignal.timeout(5000),
  });
  if (!response.ok) throw new Error('server_read_failed');
  return jsonBody(response.body, 131072);
}

export function createAnalysisStatusHandler(env, fetcher = fetch) {
  return async request => {
    if (request.method !== 'POST') return reply({ error: 'method_not_allowed' }, 405);
    let origin;
    try { origin = serverOrigin(env); } catch { return reply({ error: 'service_unavailable' }, 503); }
    const authorization = request.headers.get('authorization') ?? '';
    if (!/^Bearer [A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$/.test(authorization)) {
      return reply({ error: 'unauthorized' }, 401);
    }
    let user;
    try {
      const auth = await fetcher(origin + '/auth/v1/user', {
        headers: { apikey: env.SUPABASE_ANON_KEY, Authorization: authorization },
        redirect: 'error', signal: AbortSignal.timeout(5000),
      });
      if (!auth.ok) return reply({ error: 'unauthorized' }, 401);
      user = await jsonBody(auth.body, 32768);
    } catch { return reply({ error: 'service_unavailable' }, 503); }
    if (!uuid.test(user.id ?? '') || user.is_anonymous !== false || typeof user.email !== 'string' || !user.email ||
      !Number.isFinite(Date.parse(user.email_confirmed_at ?? ''))) {
      return reply({ error: 'email_unverified' }, 403);
    }
    let body;
    try {
      if (request.headers.get('content-type')?.split(';')[0] !== 'application/json') throw new Error();
      body = await jsonBody(request.body, 1024);
      if (!body || Object.keys(body).join(',') !== 'job_id' || !uuid.test(body.job_id ?? '')) throw new Error();
    } catch { return reply({ error: 'invalid_input' }, 400); }
    try {
      const query = new URLSearchParams({ id: `eq.${body.job_id}`, user_id: `eq.${user.id}`,
        select: 'id,barcode,state,retake_target,error_code,result_product_id,result_analysis_id,updated_at', limit: '1' });
      const rows = await serverRead(env, 'analysis_jobs?' + query, fetcher);
      if (!Array.isArray(rows)) throw new Error('invalid_server_shape');
      if (!rows.length) return reply({ error: 'not_found' }, 404);
      const row = rows[0];
      return reply({ job: pick(row, ['id', 'barcode', 'state', 'retake_target', 'error_code',
        'result_product_id', 'result_analysis_id', 'updated_at']) });
    } catch { return reply({ error: 'service_unavailable' }, 503); }
  };
}

function pick(value, keys) {
  return Object.fromEntries(keys.filter(key => Object.hasOwn(value ?? {}, key)).map(key => [key, value[key]]));
}

export function sanitizePublishedProduct(row) {
  const result = pick(row, ['id', 'barcode', 'name', 'brand', 'is_demo', 'summary',
    'schema_version', 'rules_version', 'model_version', 'analyzed_at']);
  result.nutrition = pick(row.nutrition, ['raw', 'basis', 'serving_size']);
  result.nutrition.nutrients = (row.nutrition?.nutrients ?? []).map(item =>
    pick(item, ['name', 'value', 'unit', 'source']));
  result.ingredients = pick(row.ingredients, ['raw', 'items', 'declared_allergens']);
  result.findings = (row.findings ?? []).map(finding => ({
    ...pick(finding, ['severity', 'title', 'explanation', 'sort_order']),
    source_details: {
      ...pick(finding.source_details, ['rule_id']),
      evidence: (finding.source_details?.evidence ?? []).map(evidence =>
        pick(evidence, ['source', 'field', 'label_text', 'reference', 'is_demo'])),
    },
  }));
  return result;
}

// Called only after future lookup quota/rate admission (T02.3/T03.1). Keeping this
// server helper separate prevents prematurely exposing an unmetered public route.
export async function readPublishedProduct(env, canonicalBarcode, fetcher = fetch) {
  if (!/^[0-9]{14}$/.test(canonicalBarcode)) throw new Error('invalid_barcode');
  const query = new URLSearchParams({ barcode: `eq.${canonicalBarcode}`, limit: '1',
    select: 'id,barcode,name,brand,is_demo,summary,schema_version,rules_version,model_version,analyzed_at,nutrition,ingredients,findings' });
  const rows = await serverRead(env, 'published_products?' + query, fetcher);
  if (!Array.isArray(rows)) throw new Error('invalid_server_shape');
  return rows.length ? sanitizePublishedProduct(rows[0]) : null;
}
