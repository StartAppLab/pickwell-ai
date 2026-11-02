import { createOperationalEvents } from './operational_events.mjs';

// Server-only T02.3 adapter. Public routes are wired in T03.1/T05.1.
// Never derive authorization, plan, user UUID or proxy trust from request JSON.
const ipLiteral = value => {
  if (typeof value !== 'string' || value.length > 64 || /[%\s\[\]]/.test(value)) return false;
  if (/^\d{1,3}(\.\d{1,3}){3}$/.test(value)) return value.split('.').every(n => Number(n) <= 255);
  // URL's IPv6 parser validates expansion/embedded IPv4 without a new package.
  if (!value.includes(':')) return false;
  try { return new URL(`http://[${value}]/`).hostname.startsWith('['); } catch { return false; }
};

export async function networkBucket(request, { secret, trustedHeader, trustedProxyHops } = {}) {
  if (typeof secret !== 'string' || secret.length < 32) throw new Error('network_hash_secret_required');
  // Header trust is an operator setting only. Leave unset unless ingress strips
  // caller values and appends an authenticated chain. The default shares a bucket.
  let address = 'unknown-network';
  if (trustedHeader) {
    if (!['x-forwarded-for', 'cf-connecting-ip', 'x-real-ip'].includes(trustedHeader) ||
      !Number.isInteger(trustedProxyHops) || trustedProxyHops < 1 || trustedProxyHops > 8) throw new Error('proxy_config');
    const raw = request.headers.get(trustedHeader) ?? '';
    if (raw.length <= 512) {
      const chain = raw.split(',').map(value => value.trim());
      if (chain.length >= trustedProxyHops && (trustedHeader === 'x-forwarded-for' || chain.length === 1)) {
        const selected = chain[chain.length - trustedProxyHops];
        if (ipLiteral(selected)) address = selected.toLowerCase();
      }
    }
  }
  const key = await crypto.subtle.importKey('raw', new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']);
  return [...new Uint8Array(await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(address)))]
    .map(byte => byte.toString(16).padStart(2, '0')).join('');
}

export function createQuotaService(env, fetcher = fetch) {
  const origin = new URL(env.SUPABASE_URL);
  const local = ['localhost', '127.0.0.1', '[::1]'].includes(origin.hostname);
  if ((origin.protocol !== 'https:' && !(local && origin.protocol === 'http:')) ||
    origin.username || origin.password || origin.pathname !== '/' || origin.search || origin.hash ||
    !env.SUPABASE_SERVICE_ROLE_KEY || !env.SUPABASE_ANON_KEY) throw new Error('server_config');
  const telemetry = createOperationalEvents(env, fetcher);
  async function rpc(name, body) {
    const response = await fetcher(origin.origin + '/rest/v1/rpc/' + name, {
      method: 'POST', headers: { apikey: env.SUPABASE_SERVICE_ROLE_KEY,
        Authorization: `Bearer ${env.SUPABASE_SERVICE_ROLE_KEY}`, 'content-type': 'application/json' },
      body: JSON.stringify(body), redirect: 'error', signal: AbortSignal.timeout(5000),
    });
    if (!response.ok) throw new Error('quota_operation_failed');
    // All RPC responses are bounded scalars/small objects, never provider payloads.
    const raw = await response.text();
    if (raw.length > 8192) throw new Error('quota_response_size');
    return JSON.parse(raw);
  }
  return {
    // Fetch trusted identity from Auth; never decode an unverified JWT locally.
    async identity(request, { verified = false } = {}) {
      const authorization = request.headers.get('authorization') ?? '';
      if (!/^Bearer [A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$/.test(authorization)) throw new Error('unauthorized');
      const response = await fetcher(origin.origin + '/auth/v1/user', {
        headers: { apikey: env.SUPABASE_ANON_KEY, Authorization: authorization },
        redirect: 'error', signal: AbortSignal.timeout(5000),
      });
      if (!response.ok) throw new Error([401,403].includes(response.status) ? 'unauthorized' : 'identity_unavailable');
      const user = await response.json();
      if (!/^[0-9a-f-]{36}$/i.test(user.id ?? '') || user.is_anonymous !== false ||
        (verified && (typeof user.email !== 'string' || !user.email || !Number.isFinite(Date.parse(user.email_confirmed_at ?? ''))))) {
        throw new Error('verified_identity_required');
      }
      return user.id;
    },
    throttle: (bucket, user = null) => rpc('pickwell_lookup_throttle', { p_ip_bucket: bucket, p_user: user }),
    snapshot: (user, metric) => rpc('pickwell_quota_snapshot', { p_user: user, p_metric: metric }),
    async reserve(user, metric, key, barcode, job = null) {
      const result = await rpc('pickwell_reserve_usage', {
        p_user: user, p_metric: metric, p_key: key, p_barcode: barcode, p_job: job });
      // These branches create no reservation row, so no DB state trigger can emit.
      // Event failure never changes a successful/denied quota decision.
      if (result.status === 'quota_exceeded') await telemetry.record('quota_exceeded', key, { metric });
      if (result.status === 'cache_hit') await telemetry.record('product_cache_hit', key, { metric });
      return result;
    },
    beginProvider: (reservation, bucket) => rpc('pickwell_begin_provider', { p_reservation: reservation, p_ip_bucket: bucket }),
    recordProvider: (attempt, state, cost = null, input = null, output = null, duration = null, estimate = null) =>
      rpc('pickwell_record_provider_metrics', { p_attempt: attempt, p_state: state, p_cost: cost,
        p_input: input, p_output: output, p_duration: duration, p_estimate: estimate }),
    finish: (reservation, outcome, product = null, analysis = null) => rpc('pickwell_finish_usage', {
      p_reservation: reservation, p_outcome: outcome, p_product: product, p_analysis: analysis }),
    reconcileExpired: () => rpc('pickwell_reconcile_expired', {}),
  };
}
