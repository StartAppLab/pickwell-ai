import { createAnalysisAuthorizationHandler } from '../_shared/analysis_authorization.mjs';
Deno.serve(createAnalysisAuthorizationHandler({
 SUPABASE_URL:Deno.env.get('SUPABASE_URL'),
 SUPABASE_ANON_KEY:Deno.env.get('SUPABASE_ANON_KEY'),
}));
