import { handlePremium } from "../_shared/subscription_handlers.ts";
import { caller, required } from "../_shared/subscription_runtime.ts";

// Example authorization endpoint; actual paid product operations remain app-owned.
Deno.serve((req) =>
  handlePremium(req, {
    authenticate: caller,
    entitlementId: () => required("PREMIUM_ENTITLEMENT_ID"),
  })
);
