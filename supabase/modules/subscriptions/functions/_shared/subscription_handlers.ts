import { type Environment, SyncBusy, uuid } from "./subscription_core.ts";

export const headers = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
export const json = (body: unknown, status = 200) =>
  Response.json(body, { status, headers });
export interface AuthenticatedSubject {
  id: string;
  isAnonymous: boolean;
  readEntitlements(environment: Environment): Promise<unknown[]>;
  hasEntitlement(id: string): Promise<boolean>;
}
export type Authenticate = (
  req: Request,
) => Promise<AuthenticatedSubject | null>;
export async function handleRefresh(req: Request, deps: {
  authenticate: Authenticate;
  reconcile(id: string): Promise<void>;
  environment(): Environment;
}): Promise<Response> {
  if (req.method === "OPTIONS") return new Response("ok", { headers });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);
  try {
    const subject = await deps.authenticate(req);
    if (!subject || subject.isAnonymous || !uuid(subject.id)) {
      return json({ error: "Unauthorized" }, 401);
    }
    // Request bodies never establish identity or entitlement ownership.
    await deps.reconcile(subject.id);
    const grants = await subject.readEntitlements(deps.environment());
    return json({
      subject_id: subject.id,
      source: "server",
      entitlements: grants,
    });
  } catch (error) {
    if (error instanceof SyncBusy) {
      const response = json({
        error: "Refresh pending. Retry after 30 seconds.",
      }, 429);
      response.headers.set("Retry-After", "30");
      return response;
    }
    return json({ error: "Unable to verify access. Please retry." }, 503);
  }
}
export async function handlePremium(req: Request, deps: {
  authenticate: Authenticate;
  entitlementId(): string;
}): Promise<Response> {
  if (req.method === "OPTIONS") return new Response("ok", { headers });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);
  try {
    const subject = await deps.authenticate(req);
    if (!subject || subject.isAnonymous || !uuid(subject.id)) {
      return json({ error: "Unauthorized" }, 401);
    }
    if (!await subject.hasEntitlement(deps.entitlementId())) {
      return json({ error: "Premium access required" }, 403);
    }
    // Add app-owned paid work AFTER this authorization check.
    return json({ authorized: true, subject_id: subject.id });
  } catch (_) {
    return json({ error: "Unable to verify access" }, 503);
  }
}
