import {
  type AuthenticatedSubject,
  handlePremium,
  handleRefresh,
} from "../functions/_shared/subscription_handlers.ts";
import { SyncBusy } from "../functions/_shared/subscription_core.ts";
const alice = "10000000-0000-0000-0000-000000000001";
const bob = "20000000-0000-0000-0000-000000000002";
function assert(value: unknown): asserts value {
  if (!value) throw new Error("Assertion failed");
}
const request = () =>
  new Request("https://example.com", {
    method: "POST",
    body: JSON.stringify({
      user_id: bob,
      entitlement_id: "free",
      premium: true,
    }),
  });
const identity = (): AuthenticatedSubject => ({
  id: alice,
  isAnonymous: false,
  readEntitlements: () => Promise.resolve([]),
  hasEntitlement: () => Promise.resolve(false),
});
Deno.test("refresh rejects unauthenticated and anonymous identities before reconciliation", async () => {
  for (const subject of [null, { ...identity(), isAnonymous: true }]) {
    let called = false;
    const response = await handleRefresh(request(), {
      authenticate: () => Promise.resolve(subject),
      environment: () => "PRODUCTION",
      reconcile: () => {
        called = true;
        return Promise.resolve();
      },
    });
    assert(response.status === 401 && !called);
  }
});
Deno.test("refresh derives ownership from verified identity and ignores body claims", async () => {
  let reconciled = "";
  const response = await handleRefresh(request(), {
    authenticate: () => Promise.resolve(identity()),
    environment: () => "PRODUCTION",
    reconcile: (id) => {
      reconciled = id;
      return Promise.resolve();
    },
  });
  const body = await response.json();
  assert(
    response.status === 200 && reconciled === alice &&
      body.subject_id === alice,
  );
});
Deno.test("failed or concurrent verification does not return an approving snapshot", async () => {
  for (const error of [new SyncBusy(), new Error("upstream unavailable")]) {
    const response = await handleRefresh(request(), {
      authenticate: () => Promise.resolve(identity()),
      environment: () => "PRODUCTION",
      reconcile: () => Promise.reject(error),
    });
    assert(response.status === (error instanceof SyncBusy ? 429 : 503));
    assert((await response.json()).entitlements === undefined);
  }
});
Deno.test("protected example uses server entitlement and refuses client premium claims", async () => {
  let checked = "";
  const subject = identity();
  subject.hasEntitlement = (id) => {
    checked = id;
    return Promise.resolve(false);
  };
  const deps = {
    authenticate: () => Promise.resolve(subject),
    entitlementId: () => "paid",
  };
  assert(
    (await handlePremium(request(), deps)).status === 403 && checked === "paid",
  );
  subject.hasEntitlement = () => Promise.resolve(true);
  assert((await handlePremium(request(), deps)).status === 200);
  subject.isAnonymous = true;
  assert((await handlePremium(request(), deps)).status === 401);
  assert(
    (await handlePremium(request(), {
      ...deps,
      authenticate: () => Promise.resolve(null),
    })).status === 401,
  );
});
