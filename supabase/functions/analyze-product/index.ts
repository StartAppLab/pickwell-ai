import { createAnalyzeProductHandler } from '../_shared/analyze_product.mjs';
const names=['SUPABASE_URL','SUPABASE_ANON_KEY','SUPABASE_SERVICE_ROLE_KEY',
 'PICKWELL_NETWORK_HASH_SECRET','PICKWELL_TRUSTED_IP_HEADER','PICKWELL_TRUSTED_PROXY_HOPS',
 'META_API_URL','META_API_KEY','META_MODEL'];
Deno.serve(createAnalyzeProductHandler(Object.fromEntries(names.map(name=>[name,Deno.env.get(name)]))));
