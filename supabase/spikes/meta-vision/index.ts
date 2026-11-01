// Deliberately outside supabase/functions/. No deployment/config installation.
import { createHandler } from './core.mjs';

const names = ['SPIKE_ENABLED', 'SPIKE_OPERATOR_TOKEN', 'SPIKE_USER_ID',
  'SUPABASE_URL', 'SUPABASE_ANON_KEY', 'META_API_KEY', 'META_API_URL', 'META_MODEL'];
const env = Object.fromEntries(names.map(name => [name, Deno.env.get(name) ?? '']));
Deno.serve(createHandler(env));
