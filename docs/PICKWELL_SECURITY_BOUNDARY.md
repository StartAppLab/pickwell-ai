# T02.2 — RLS and least-privilege boundary

2026-11-02. **Security foundations and native DB/REST checks verified; public
lookup activation remains deferred to T02.3/T03.1.** No hosted database/function
or existing mobile code changed. Prior native-validation work was committed as
`ee1e371` before starting this task.

## Reconciliation and scope

Read root instruction pointers, backend README, current migrations/functions,
PRD v1.4, DESIGN/SPEC v1.2, DATABASE v1.0 and TASKS v1.1. Existing catalog/job RLS
and server-only published view are reused. Lemon UI/local recents do not affect
this backend task. The optional subscription module is still uninstalled.

The task requires negative tests for entitlement, quota and webhook writes, but
those tables did not exist. Added only their protected storage foundations, not
quota algorithms, plan prices, active entitlements, webhook processing or billing.
Atomic usage consumption and initial 30/3 plan limits remain T02.3; operational
AI usage remains T02.4; actual entitlement resolution/reconciliation remains T06.3.

## Implementation

`supabase/migrations/20261102000200_pickwell_security_boundary.sql` adds:

| Object | Security contract |
| --- | --- |
| `usage_daily` | Server-only per-user/UTC-day/metric counters; nonnegative used/reserved. No client reset or increment. |
| `usage_reservations` | Server-only, idempotency uniqueness; composite user/job FK prevents cross-account references. No reservation/finalization RPC yet. |
| `revenuecat_events` | Server-only environment-tagged event history; event identity/environment immutable; no client verification flag access. |
| `user_entitlements` | Server-only, keyed by `(user_id, environment)`. Admin test grants restricted to SANDBOX. RevenueCat rows require a verified, same-environment event reference and finite validity. |

All eight Pickwell catalog/security tables have RLS and no public/anon/authenticated
table privileges or permissive policies. All existing public base tables were also
audited for RLS. Usage/account mappings cascade on account deletion. No normal-user
Premium grant is seeded, and no billing feature is enabled.

Environment-aware entitlement keys deliberately strengthen the blueprint's original
user-only key: sandbox history cannot replace a production row or reuse a sandbox
event as production. `plan_code` is temporarily constrained text; T02.3 must attach
the real plans contract when it creates plans/limits. The new schema differs from
the generic optional subscription module; do not run its installer blindly.

Event `verified` is server-owned storage, **not** cryptographic verification or an
authoritative entitlement reducer. No webhook endpoint is exposed. T06.3 must still
authenticate provider messages, reconcile current state, handle replay/out-of-order
events and resolve trusted identity before granting privileges.

### SQL callable surface and starter compatibility

- Existing `handle_new_user()` retains its fixed empty search path and loses
  public/client RPC EXECUTE. Normal Auth signup triggers still work.
- New helpers are invoker-security with empty search paths and server-only EXECUTE.
- Revoke automatic client grants on future postgres-owned public tables/sequences.
  Remove function EXECUTE defaults both globally and within `public`; schema-specific
  platform grants survive a global-only revoke, as caught by native tests.
- Make legacy starter table/column/function grants explicit under the existing RLS
  policies. This preserves profile edits, account cleanup and sample CRUD after a
  clean reset under hardened defaults. Profile `role` UPDATE remains forbidden.
  The pure `generate_slug` and UUID helper remain callable where existing inserts
  need them; no new privileged SECURITY DEFINER RPC was created.

Initial native tests exposed both default-function grants and the starter's reliance
on implicit grants after reset. These were corrected in the unapplied-to-hosted
additive migration and retested from a clean **local** reset; no applied hosted
migration was edited or replayed.

### Controlled reads

`supabase/functions/_shared/catalog_boundary.mjs` provides:

- Owner-scoped status handler: verifies the bearer session with Supabase Auth,
  requires confirmed persistent email identity, accepts only a UUID `job_id`, and
  queries by **both** job ID and Auth-derived user ID. Unknown/other-user jobs both
  return 404. Caller user IDs, verified/Premium claims and missing/fake JWTs fail.
- Separate privileged DB headers: inbound user JWT is sent only to Auth, never
  forwarded as admin authorization. Bounded bodies/timeouts and sanitized errors
  avoid exposing backend responses or credentials.
- Published reader: uses the existing `published_products` view only; explicit
  root/nested field allowlists remove contributor/user identity, internal prompt
  metadata, arbitrary JSON fields and job details. No Meta call is possible here.

`supabase/functions/get-analysis-status/index.ts` adapts the owner-only handler;
config explicitly retains `verify_jwt=true`. No hosted deployment was performed.
The real Auth/REST tests invoke this same handler core with Web Requests; the Deno
adapter passed syntax checking but native/hosted Edge gateway execution is not claimed.

**Public `get-product` is intentionally not activated in T02.2.** T03.1 owns that
endpoint, after T02.3 supplies quota/rate admission. Its sanitized reader is tested
now, but exposing an unmetered guest endpoint would contradict the approved security
contract. No dummy success response, public service key or premature guest table
policy was introduced. This is the one exact checklist item still unverified as
a running public operation.

## Native validation actually executed

Used isolated `.secrets/native-validation/`, pinned CLI 2.122.0 and native
PostgreSQL 15.19. All URLs were programmatically restricted to loopback, with
`sslmode=disable` only for that local database. No hosted credentials or real
Meta keys were used by these tests.

| Check | Observed outcome |
| --- | --- |
| Native CLI migration up, then clean reset after fixes | Passed with the five repository migrations and configured seeds. |
| Native `test db` | **59 pgTAP assertions passed** across three files: 31 catalog, 6 existing consumer, 22 security boundary. |
| `PICKWELL_NATIVE_STATUS=.secrets/native-status.json node --test supabase/tests/security_boundary.test.mjs` | **7 tests passed, none skipped**. Two normal local Auth signups produced confirmed persistent test sessions; Auth `/user` accepted both. |
| Native REST negative checks | **64 GET/POST/PATCH/DELETE requests** across eight protected tables, for guest and signed-in roles, all denied with 401/403. Two client signup-definer RPC attempts also denied/unavailable. |
| Native privileged/ownership checks | Server-only job/counter inserts succeeded; owner status 200, other-user/random job 404, missing/fake session 401, supplied caller identity 400. Processing product not returned; published demo sanitized. |
| Isolated catalog migration regression | **9 tests passed**, 46 expected SQL rejection checks. Test runner baseline selection updated to preserve migration ordering as new migrations are added. |
| Syntax, secret scan, diff | Passed. No tokens/session JSON printed or committed. |

Local test identities use normal Supabase signup with the existing disposable local
profile's email confirmations disabled; this is **not** a claim of OTP delivery in
this run or a change to production auth. Test users and their jobs/counters were
removed through the local admin cleanup path after the assertions. Any processing
fixture remains only in the disposable test DB. Native test processes are stopped
after validation to free memory; no Docker is required.

Mock checks additionally cover anonymous/unconfirmed Auth identities and nested
projection stripping. Source JSON structure and trusted label facts still require
the later analysis validator. No production quota, spend cap, billing-state resolver,
webhook authenticity/reconciliation or public lookup rate control is certified here.

## Status and next dependency

Verified checklist items: current table RLS/write denial, owner-scoped status and
SQL-definer hardening, sandbox/production storage separation. Public `get-product`
runtime verification remains open until the later gated endpoint exists. Therefore
**T02.2 is PARTIAL against its full exact checklist**, while its scoped security
foundations are implemented and tested. Next is T02.3, then T03.1 can use the prepared
reader and close the public-lookup item. Do not start those phases automatically.

Changed: new security migration, shared read boundary, status adapter/config,
native pgTAP and Node Auth/REST tests, catalog regression runner selection, this
report and task/database/backend documentation. No Flutter packages/UI, hosted
schema/deployment, photo retention, AI charges or paid features changed.
