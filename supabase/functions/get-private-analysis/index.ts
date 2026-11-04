import { createPrivateAnalysisHandler } from '../_shared/private_analysis.mjs';
const env = Object.fromEntries(['SUPABASE_URL', 'SUPABASE_ANON_KEY', 'SUPABASE_SERVICE_ROLE_KEY', 'PICKWELL_NETWORK_HASH_SECRET', 'PICKWELL_TRUSTED_IP_HEADER', 'PICKWELL_TRUSTED_PROXY_HOPS']
  .map(name => [name, Deno.env.get(name) ?? '']));
Deno.serve(createPrivateAnalysisHandler(env));
