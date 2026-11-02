// T04.2 identity gate only. No images, jobs, quota mutation, DB writes or provider calls.
import { readBoundedJson } from './catalog_boundary.mjs';
const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
export class IdentityError extends Error {
 constructor(code, status) { super(code); this.status = status; }
}
// T05 must invoke this again for each actual submission. A previous preflight
// response or any mobile flag is never an authorization capability.
export async function requireVerifiedEmail(request, env, fetcher = fetch) {
 const authorization = request.headers.get('authorization') ?? '';
 if (!/^Bearer [A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$/.test(authorization)) throw new IdentityError('unauthorized',401);
 let origin;
 try {
  const url = new URL(env.SUPABASE_URL);
  const local = ['localhost','127.0.0.1','[::1]'].includes(url.hostname);
  if ((url.protocol !== 'https:' && !(local && url.protocol === 'http:')) || url.username || url.password ||
    url.pathname !== '/' || url.search || url.hash || !env.SUPABASE_ANON_KEY) throw Error();
  origin = url.origin;
 } catch { throw new IdentityError('service_unavailable',503); }
 let user;
 try {
  const result = await fetcher(origin+'/auth/v1/user', {
   headers:{apikey:env.SUPABASE_ANON_KEY,Authorization:authorization},
   redirect:'error',signal:AbortSignal.timeout(5000),
  });
  if (!result.ok) throw new IdentityError([400,401,403].includes(result.status)?'unauthorized':'service_unavailable',
    [400,401,403].includes(result.status)?401:503);
  user = await readBoundedJson(result.body,32768);
 } catch (error) {
  if (error instanceof IdentityError) throw error;
  throw new IdentityError('service_unavailable',503);
 }
 if (!user || !uuid.test(user.id ?? '') || user.is_anonymous !== false ||
   typeof user.email !== 'string' || !user.email.trim() || !Number.isFinite(Date.parse(user.email_confirmed_at ?? ''))) {
  throw new IdentityError('verified_email_required',403);
 }
 return user.id;
}
export function createAnalysisAuthorizationHandler(env, fetcher = fetch) {
 const reply = (body,status=200) => Response.json(body,{status,headers:{'Cache-Control':'no-store','X-Content-Type-Options':'nosniff'}});
 return async request => {
  if (request.method !== 'POST') return reply({error:'method_not_allowed'},405);
  try {
   await requireVerifiedEmail(request,env,fetcher);
   let body;
   try { body = await readBoundedJson(request.body,1024); } catch { return reply({error:'invalid_input'},400); }
   if (!body || Array.isArray(body) || Object.keys(body).length) return reply({error:'invalid_input'},400);
   return reply({status:'authorized'});
  } catch(error) {
   return reply({error:error instanceof IdentityError?error.message:'service_unavailable'},error instanceof IdentityError?error.status:503);
  }
 };
}
