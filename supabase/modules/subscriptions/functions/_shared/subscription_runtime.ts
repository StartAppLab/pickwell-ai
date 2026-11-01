import {
  createClient,
  type SupabaseClient,
} from "https://esm.sh/@supabase/supabase-js@2.117.3";
import {
  type Environment,
  grantsFromCustomer,
  SyncBusy,
} from "./subscription_core.ts";
import { type AuthenticatedSubject } from "./subscription_handlers.ts";

export function required(name: string): string {
  const value = Deno.env.get(name)?.trim();
  if (!value) throw new Error(`Missing ${name}`);
  return value;
}
export function environment(): Environment {
  const value = required("REVENUECAT_ENVIRONMENT");
  if (value !== "PRODUCTION" && value !== "SANDBOX") {
    throw new Error("Invalid environment");
  }
  return value;
}
export const adminClient = () =>
  createClient(
    required("SUPABASE_URL"),
    required("SUPABASE_SERVICE_ROLE_KEY"),
    {
      auth: { persistSession: false, autoRefreshToken: false },
    },
  );
export async function caller(
  req: Request,
): Promise<AuthenticatedSubject | null> {
  const token = req.headers.get("Authorization");
  if (!token?.startsWith("Bearer ")) return null;
  const client = createClient(
    required("SUPABASE_URL"),
    required("SUPABASE_ANON_KEY"),
    {
      global: { headers: { Authorization: token } },
      auth: { persistSession: false, autoRefreshToken: false },
    },
  );
  const { data: { user }, error } = await client.auth.getUser();
  if (error || !user || user.is_anonymous) return null;
  return {
    id: user.id,
    isAnonymous: false,
    readEntitlements: async (target: Environment) => {
      const { data, error } = await client.from("user_entitlements")
        .select(
          "entitlement_id, is_active, is_non_expiring, expires_at, verified_until, updated_at",
        )
        .eq("user_id", user.id).eq("environment", target);
      if (error || data === null) {
        throw new Error("Unable to read entitlements");
      }
      return data;
    },
    hasEntitlement: async (id: string) =>
      await rpc(client, "has_entitlement", { p_entitlement_id: id }) === true,
  };
}
async function rpc(
  client: SupabaseClient,
  name: string,
  args: Record<string, unknown>,
): Promise<unknown> {
  const { data, error } = await client.rpc(name, args);
  if (error) throw new Error("Entitlement database operation failed");
  return data;
}
export async function reconcile(
  admin: SupabaseClient,
  userId: string,
  minInterval: number,
): Promise<void> {
  const token = await rpc(admin, "claim_entitlement_sync", {
    p_user_id: userId,
    p_min_interval: minInterval,
  });
  if (typeof token !== "string") {
    throw new SyncBusy("Refresh temporarily unavailable");
  }
  try {
    const response = await fetch(
      `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(userId)}`,
      {
        headers: {
          Authorization: `Bearer ${required("REVENUECAT_SECRET_API_KEY")}`,
        },
        signal: AbortSignal.timeout(10000),
      },
    );
    if (!response.ok) throw new Error("RevenueCat unavailable");
    const target = environment();
    const grants = grantsFromCustomer(await response.json(), target);
    const applied = await rpc(admin, "apply_entitlement_snapshot", {
      p_user_id: userId,
      p_token: token,
      p_environment: target,
      p_grants: grants,
    });
    if (applied !== true) throw new SyncBusy("Synchronization lease expired");
  } finally {
    await rpc(admin, "release_entitlement_sync", {
      p_user_id: userId,
      p_token: token,
    });
  }
}
