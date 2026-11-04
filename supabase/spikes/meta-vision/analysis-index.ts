// Operator-only T05.2 entry. Deploy only in the existing isolated spike workspace;
// never install it as an unauthenticated production analysis endpoint.
import { createHandler } from './core.mjs';
import { legacyAnalysisProfile as analysisProfile, validateAnalysis } from '../../functions/_shared/analysis_validation.mjs';
const names = ['SPIKE_ENABLED', 'SPIKE_OPERATOR_TOKEN', 'SPIKE_USER_ID',
  'SUPABASE_URL', 'SUPABASE_ANON_KEY', 'META_API_KEY', 'META_API_URL', 'META_MODEL'];
const env = Object.fromEntries(names.map(name => [name, Deno.env.get(name) ?? '']));
Deno.serve(createHandler(env, fetch, {
  ...analysisProfile, parse: value => validateAnalysis(value, { model: env.META_MODEL }),
}));
