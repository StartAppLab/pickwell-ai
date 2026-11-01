import { handleWebhook } from "./handler.ts";
import {
  adminClient,
  environment,
  reconcile,
  required,
} from "../_shared/subscription_runtime.ts";

Deno.serve(async (req) => {
  try {
    const admin = adminClient();
    return await handleWebhook(req, {
      authorization: required("REVENUECAT_WEBHOOK_AUTHORIZATION"),
      appIds: new Set(
        required("REVENUECAT_APP_IDS").split(",").map((id) => id.trim()).filter(
          Boolean,
        ),
      ),
      environment: environment(),
      processed: async (id) => {
        const { data, error } = await admin.from("revenuecat_webhook_events")
          .select("event_id").eq("event_id", id).maybeSingle();
        if (error) throw error;
        return data !== null;
      },
      userExists: async (id) => {
        const { data: { user }, error } = await admin.auth.admin.getUserById(
          id,
        );
        if (error && error.status !== 404) throw error;
        return user !== null && !user.is_anonymous;
      },
      reconcile: (id) => reconcile(admin, id, 0),
      complete: async (id) => {
        const { error } = await admin.from("revenuecat_webhook_events").upsert({
          event_id: id,
        }, { onConflict: "event_id" });
        if (error) throw error;
      },
    });
  } catch (_) {
    return Response.json({ error: "Subscription service unavailable" }, {
      status: 503,
    });
  }
});
