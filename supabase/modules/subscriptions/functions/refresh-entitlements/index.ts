import { handleRefresh } from "../_shared/subscription_handlers.ts";
import {
  adminClient,
  caller,
  environment,
  reconcile,
} from "../_shared/subscription_runtime.ts";

Deno.serve((req) =>
  handleRefresh(req, {
    authenticate: caller,
    environment,
    reconcile: (id) => reconcile(adminClient(), id, 30),
  })
);
