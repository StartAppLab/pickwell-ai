// Optional telemetry only. Mandatory quota/provider accounting is never caught here.
const events = new Set(['barcode_scanned', 'product_cache_hit', 'product_not_found', 'capture_completed',
  'analysis_started', 'analysis_completed', 'analysis_failed', 'analysis_retake_required', 'quota_exceeded']);
const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export function createOperationalEvents(env, fetcher = fetch) {
  return {
    async record(event, source, { metric, duration } = {}) {
      // Explicit fields only: caller context/raw errors/images/headers are discarded.
      if (!events.has(event) || !uuid.test(source ?? '')) return false;
      try {
        const origin = new URL(env.SUPABASE_URL);
        const local = ['127.0.0.1', 'localhost', '[::1]'].includes(origin.hostname);
        if ((origin.protocol !== 'https:' && !(local && origin.protocol === 'http:')) ||
          origin.username || origin.password || origin.pathname !== '/' || origin.search || origin.hash ||
          !env.SUPABASE_SERVICE_ROLE_KEY) return false;
        const response = await fetcher(origin.origin + '/rest/v1/rpc/pickwell_try_event', {
          method: 'POST', headers: { apikey: env.SUPABASE_SERVICE_ROLE_KEY,
            Authorization: `Bearer ${env.SUPABASE_SERVICE_ROLE_KEY}`, 'content-type': 'application/json' },
          body: JSON.stringify({ p_event: event, p_source: source,
            p_metric: ['barcode_lookup', 'ai_analysis'].includes(metric) ? metric : null,
            p_duration: Number.isInteger(duration) && duration >= 0 && duration <= 3600000 ? duration : null }),
          redirect: 'error', signal: AbortSignal.timeout(500),
        });
        if (!response.ok) return false;
        return (await response.text()) === 'true';
      } catch { return false; } // Never log raw provider/Auth/network errors.
    },
    // Guest-capable T03.1 calls this after a definitive server lookup. No public
    // analytics endpoint or untrusted client event ingestion is introduced here.
    async lookup(source, status, duration) {
      if (!['ready', 'not_found', 'processing'].includes(status)) return false;
      const scanned = await this.record('barcode_scanned', source, { metric: 'barcode_lookup', duration });
      const outcome = status === 'ready' ? 'product_cache_hit' : status === 'not_found' ? 'product_not_found' : null;
      return outcome ? (await this.record(outcome, source, { metric: 'barcode_lookup', duration })) && scanned : scanned;
    },
  };
}
