import { createAnalysisStatusHandler } from '../_shared/catalog_boundary.mjs';

const env = Object.fromEntries(['SUPABASE_URL', 'SUPABASE_ANON_KEY', 'SUPABASE_SERVICE_ROLE_KEY']
  .map(name => [name, Deno.env.get(name) ?? '']));
Deno.serve(createAnalysisStatusHandler(env));
