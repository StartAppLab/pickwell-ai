import {
  affectedUsers,
  grantsFromCustomer,
  parseEvent,
} from "../functions/_shared/subscription_core.ts";
import {
  handleWebhook,
  type WebhookDependencies,
} from "../functions/revenuecat-webhook/handler.ts";

function assert(value: unknown): asserts value {
  if (!value) throw new Error("Assertion failed");
}
const alice = "10000000-0000-0000-0000-000000000001";
const bob = "20000000-0000-0000-0000-000000000002";
const future = "2099-01-01T00:00:00Z";
function customer(expiry: string | null, sandbox = false, lifetime = false) {
  return {
    subscriber: {
      entitlements: {
        premium: { product_identifier: "product", expires_date: expiry },
      },
      subscriptions: lifetime ? {} : { product: { is_sandbox: sandbox } },
      non_subscriptions: lifetime ? { product: [{ is_sandbox: sandbox }] } : {},
    },
  };
}
Deno.test("active, expired, sandbox and lifetime grants have distinct authorization", () => {
  assert(grantsFromCustomer(customer(future), "PRODUCTION")[0].is_active);
  assert(
    !grantsFromCustomer(customer("2000-01-01T00:00:00Z"), "PRODUCTION")[0]
      .is_active,
  );
  assert(grantsFromCustomer(customer(future, true), "PRODUCTION").length === 0);
  assert(
    grantsFromCustomer(customer(null, false, true), "PRODUCTION")[0]
      .is_non_expiring,
  );
  assert(!grantsFromCustomer(customer(null), "PRODUCTION")[0].is_active);
  assert(
    grantsFromCustomer({
      subscriber: {
        entitlements: {},
        subscriptions: {},
        non_subscriptions: {},
      },
    }, "PRODUCTION").length === 0,
  );
});
Deno.test("cancellation keeps paid time; grace uses its explicitly supplied deadline", () => {
  const body = customer(future);
  Object.assign(body.subscriber.subscriptions.product!, {
    unsubscribe_detected_at: "2026-01-01T00:00:00Z",
  });
  assert(grantsFromCustomer(body, "PRODUCTION")[0].is_active);
  const grace = customer("2000-01-01T00:00:00Z");
  Object.assign(grace.subscriber.entitlements.premium, {
    grace_period_expires_date: future,
  });
  assert(grantsFromCustomer(grace, "PRODUCTION")[0].is_active);
});
Deno.test("malformed customer state cannot become a free or lifetime grant", () => {
  for (const body of [customer("invalid"), {}, { subscriber: {} }]) {
    let failed = false;
    try {
      grantsFromCustomer(body, "PRODUCTION");
    } catch (_) {
      failed = true;
    }
    assert(failed);
  }
});
Deno.test("transfers reconcile both accounts; guest aliases cannot authorize a user", () => {
  const event = parseEvent(
    {
      event: {
        id: "1",
        type: "TRANSFER",
        app_id: "app",
        transferred_from: [alice, "guest"],
        transferred_to: [bob, alice],
      },
    },
    new Set(["app"]),
    "PRODUCTION",
  );
  assert(affectedUsers(event).join(",") === `${alice},${bob}`);
  assert(
    affectedUsers({
      id: "2",
      type: "RENEWAL",
      app_id: "app",
      app_user_id: "guest",
    }).length === 0,
  );
});
function harness() {
  const synced: string[] = [];
  const completed = new Set<string>();
  const deps: WebhookDependencies = {
    authorization: "Bearer test-secret",
    appIds: new Set(["app"]),
    environment: "PRODUCTION",
    processed: (id) => Promise.resolve(completed.has(id)),
    userExists: () => Promise.resolve(true),
    reconcile: (id) => {
      synced.push(id);
      return Promise.resolve();
    },
    complete: (id) => {
      completed.add(id);
      return Promise.resolve();
    },
  };
  const request = (
    event: Record<string, unknown>,
    auth = "Bearer test-secret",
  ) =>
    new Request("https://example.com", {
      method: "POST",
      headers: { Authorization: auth },
      body: JSON.stringify({ event }),
    });
  const event = {
    id: "1",
    type: "RENEWAL",
    app_id: "app",
    environment: "PRODUCTION",
    app_user_id: alice,
  };
  return { synced, completed, deps, request, event };
}
Deno.test("webhook rejects invalid authorization, app and environment", async () => {
  const h = harness();
  assert(
    (await handleWebhook(h.request(h.event, "wrong"), h.deps)).status === 401,
  );
  assert(
    (await handleWebhook(h.request({ ...h.event, app_id: "other" }), h.deps))
      .status === 400,
  );
  assert(
    (await handleWebhook(
      h.request({ ...h.event, environment: "SANDBOX" }),
      h.deps,
    )).status === 400,
  );
  assert(h.synced.length === 0);
});
Deno.test("duplicates acknowledge only durable completion; failed processing can retry", async () => {
  const h = harness();
  const sync = h.deps.reconcile;
  h.deps.reconcile = () => Promise.reject(new Error("offline"));
  assert((await handleWebhook(h.request(h.event), h.deps)).status === 503);
  assert(h.completed.size === 0);
  h.deps.reconcile = sync;
  assert((await handleWebhook(h.request(h.event), h.deps)).status === 200);
  assert((await handleWebhook(h.request(h.event), h.deps)).status === 200);
  assert(h.synced.length === 1);
});
Deno.test("event ordering does not determine grants: each event reconciles current state", async () => {
  const h = harness();
  for (
    const event of [{ ...h.event, id: "new", type: "EXPIRATION" }, {
      ...h.event,
      id: "old",
      type: "INITIAL_PURCHASE",
    }]
  ) {
    assert((await handleWebhook(h.request(event), h.deps)).status === 200);
  }
  assert(h.synced.length === 2);
});

Deno.test("refund metadata cannot preserve a paid grant with a future expiration", () => {
  const body = customer(future);
  Object.assign(body.subscriber.subscriptions.product!, {
    refunded_at: "2026-01-01T00:00:00Z",
  });
  assert(grantsFromCustomer(body, "PRODUCTION").length === 0);
});
Deno.test("multiple products share one canonical RevenueCat entitlement without duplicate grants", () => {
  const body = customer(null, false, true);
  Object.assign(body.subscriber.subscriptions, {
    expiredMonthly: { is_sandbox: false, expires_date: "2000-01-01T00:00:00Z" },
    otherMonthly: { is_sandbox: false, expires_date: future },
  });
  // RevenueCat's entitlement record selects the effective product; do not guess
  // mappings from unrelated historical subscriptions or product names.
  const grants = grantsFromCustomer(body, "PRODUCTION");
  assert(
    grants.length === 1 && grants[0].product_id === "product" &&
      grants[0].is_non_expiring,
  );
});
Deno.test("guest-to-account alias discovery reconciles UUIDs independently of event claims", async () => {
  const h = harness();
  const response = await handleWebhook(
    h.request({
      ...h.event,
      app_user_id: "$RCAnonymousID:guest",
      aliases: [alice, "guest"],
      entitlement_ids: ["pretend-paid"],
      original_app_user_id: "guest",
    }),
    h.deps,
  );
  assert(response.status === 200 && h.synced.join(",") === alice);
});
Deno.test("promotional project events are supported but arbitrary missing app IDs are rejected", () => {
  const promo = parseEvent(
    {
      event: {
        id: "promo",
        type: "EXPIRATION",
        store: "PROMOTIONAL",
        app_user_id: alice,
      },
    },
    new Set(["app"]),
    "PRODUCTION",
  );
  assert(affectedUsers(promo)[0] === alice);
  let failed = false;
  try {
    parseEvent(
      { event: { id: "bad", type: "RENEWAL", app_user_id: alice } },
      new Set(["app"]),
      "PRODUCTION",
    );
  } catch (_) {
    failed = true;
  }
  assert(failed);
});
Deno.test("concurrent delivery cannot acknowledge an unfinished reconciliation", async () => {
  const h = harness();
  let busy = false;
  let finish!: () => void;
  h.deps.reconcile = () => {
    if (busy) return Promise.reject(new Error("lease busy"));
    busy = true;
    return new Promise<void>((resolve) => {
      finish = resolve;
    });
  };
  const first = handleWebhook(h.request(h.event), h.deps);
  while (!finish) await new Promise((resolve) => setTimeout(resolve, 0));
  assert((await handleWebhook(h.request(h.event), h.deps)).status === 503);
  assert(h.completed.size === 0);
  finish();
  assert((await first).status === 200);
  assert((await handleWebhook(h.request(h.event), h.deps)).status === 200);
});
Deno.test("oversized chunked webhook bodies are bounded and never processed", async () => {
  const h = harness();
  const response = await handleWebhook(
    new Request("https://example.com", {
      method: "POST",
      headers: { Authorization: "Bearer test-secret" },
      body: new ReadableStream({
        start(controller) {
          controller.enqueue(new Uint8Array(65537));
          controller.close();
        },
      }),
    }),
    h.deps,
  );
  assert(response.status === 413 && h.synced.length === 0);
});
