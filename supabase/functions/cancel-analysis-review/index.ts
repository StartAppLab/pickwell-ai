import { createCancelAnalysisReviewHandler } from '../_shared/cancel_analysis_review.mjs';
const names=['SUPABASE_URL','SUPABASE_ANON_KEY','SUPABASE_SERVICE_ROLE_KEY',
 'PICKWELL_NETWORK_HASH_SECRET','PICKWELL_TRUSTED_IP_HEADER','PICKWELL_TRUSTED_PROXY_HOPS'];
Deno.serve(createCancelAnalysisReviewHandler(Object.fromEntries(names.map(name=>[name,Deno.env.get(name)]))));
