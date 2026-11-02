import { createQuotaService, networkBucket } from './quota_boundary.mjs';
import { sanitizePublishedProduct } from './catalog_boundary.mjs';
import { createOperationalEvents } from './operational_events.mjs';
const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const respond = (body, status = 200) => Response.json(body, { status,
 headers: { 'Cache-Control': 'no-store', 'X-Content-Type-Options': 'nosniff' } });
const error = (code, status) => respond({ status: 'error', error: code }, status);

export function normalizeBarcode(value) {
 if (typeof value !== 'string') throw new Error('invalid_barcode');
 const code = value.trim();
 if (!/^(\d{8}|\d{12}|\d{13}|\d{14})$/.test(code)) throw new Error('invalid_barcode');
 let sum = 0;
 for (let n = 1; n < code.length; n++) sum += Number(code[code.length - 1 - n]) * (n % 2 ? 3 : 1);
 if ((10 - sum % 10) % 10 !== Number(code.at(-1))) throw new Error('invalid_barcode');
 return code.padStart(14, '0');
}
async function input(request) {
 if (request.headers.get('content-type')?.split(';')[0] !== 'application/json') throw new Error();
 const reader = request.body?.getReader(); if (!reader) throw new Error();
 const chunks = []; let size = 0;
 try {
  while (true) {
   const {done, value} = await reader.read(); if (done) break;
   size += value.length; if (size > 1024) { await reader.cancel(); throw new Error(); }
   chunks.push(value);
  }
 } finally { reader.releaseLock(); }
 const bytes = new Uint8Array(size); let offset = 0;
 for (const chunk of chunks) { bytes.set(chunk, offset); offset += chunk.length; }
 const body = JSON.parse(new TextDecoder('utf-8', {fatal:true}).decode(bytes));
 if (!body || Array.isArray(body) || Object.keys(body).join(',') !== 'barcode') throw new Error();
 return normalizeBarcode(body.barcode);
}

export function createGetProductHandler(env, fetcher = fetch) {
 return async request => {
  if (request.method !== 'POST') return error('method_not_allowed', 405);
  let code;
  try { code = await input(request); } catch { return error('invalid_barcode', 400); }
  const key = request.headers.get('idempotency-key') ?? crypto.randomUUID();
  if (!uuid.test(key)) return error('invalid_idempotency_key', 400);
  let q, user = null, bucket, publicBearers;
  try {
   q = createQuotaService(env, fetcher);
   const named = JSON.parse(env.SUPABASE_PUBLISHABLE_KEYS || '{}');
   if (!named || typeof named !== 'object' || Array.isArray(named)) throw new Error();
   publicBearers = [env.SUPABASE_ANON_KEY, env.SUPABASE_PUBLISHABLE_KEY, ...Object.values(named)]
    .filter(value => typeof value === 'string' && value.length).map(value => `Bearer ${value}`);
   bucket = await networkBucket(request, { secret: env.PICKWELL_NETWORK_HASH_SECRET,
    trustedHeader: env.PICKWELL_TRUSTED_IP_HEADER || undefined,
    trustedProxyHops: env.PICKWELL_TRUSTED_PROXY_HOPS ? Number(env.PICKWELL_TRUSTED_PROXY_HOPS) : undefined });
  } catch { return error('service_unavailable', 503); }
  // A supplied invalid/expired credential must never downgrade into guest access.
  if (request.headers.has('authorization') && !publicBearers.includes(request.headers.get('authorization'))) {
   try { user = await q.identity(request); }
   catch (e) { return error(['unauthorized','verified_identity_required'].includes(e.message) ? 'unauthorized' : 'service_unavailable',
    ['unauthorized','verified_identity_required'].includes(e.message) ? 401 : 503); }
  }
  try {
   const throttle = await q.throttle(bucket, user);
   if (throttle.allowed !== true) return respond({status:'rate_limited',error:'rate_limited'}, 429);
   const origin = new URL(env.SUPABASE_URL).origin;
   const response = await fetcher(origin + '/rest/v1/rpc/pickwell_get_product', {
    method:'POST', headers:{apikey:env.SUPABASE_SERVICE_ROLE_KEY,
     Authorization:`Bearer ${env.SUPABASE_SERVICE_ROLE_KEY}`, 'content-type':'application/json'},
    body:JSON.stringify({p_user:user,p_key:key,p_barcode:code}), redirect:'error', signal:AbortSignal.timeout(5000),
   });
   if (!response.ok) return error(response.status === 400 ? 'idempotency_conflict' : 'service_unavailable', response.status === 400 ? 409 : 503);
   const raw = await response.text(); if (raw.length > 131072) throw new Error();
   const result = JSON.parse(raw);
   if (result.status === 'retry_expired') return error('idempotency_expired', 409);
   const quota = result.quota ?? (result.status === 'quota_exceeded' ? result : null);
   const safeQuota = user && quota ? Object.fromEntries(['plan','limit','version','used','reserved','remaining','reset_at']
    .filter(name => Object.hasOwn(quota,name)).map(name => [name,quota[name]])) : null;
   if (result.status === 'quota_exceeded') {
    await createOperationalEvents(env, fetcher).record('quota_exceeded',key,{metric:'barcode_lookup'});
    return respond({status:'quota_exceeded',error:'quota_exceeded',quota:safeQuota},429);
   }
   if (!['ready','not_found','processing'].includes(result.status) || result.barcode !== code) throw new Error();
   const body = {status:result.status,barcode:code,request_id:key,
    ...(safeQuota ? {quota:safeQuota} : {guest_best_effort:true})};
   if (result.status === 'ready') {
    if (!result.product || result.product.barcode !== code) throw new Error();
    body.product = sanitizePublishedProduct(result.product);
   }
   if (result.status === 'processing') body.retry_after_seconds = 4;
   // Construct/validate response before optional logging; no model adapter is imported.
   const output = respond(body);
   if (!user) await createOperationalEvents(env,fetcher).lookup(key,result.status);
   return output;
  } catch { return error('service_unavailable',503); }
 };
}
