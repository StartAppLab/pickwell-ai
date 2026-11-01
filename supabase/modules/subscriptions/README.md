# Optional server subscription enforcement

Install this module only for an app with Supabase authentication and server-backed
premium operations. The default template does not apply these tables or deploy
these functions. Flutter's Phase 1 guards remain usable without this module.

## Install in the generated app

From the repository root:

```sh
python3 supabase/tool/install_subscriptions.py
supabase start
supabase db reset
supabase test db
```

Installation copies a timestamped migration, the three functions, shared helpers,
and the pgTAP suite into the active Supabase directories. It adds `verify_jwt =
false` for these functions because each handler verifies its own authorization:
RevenueCat supplies its webhook authorization header; user endpoints call
Supabase Auth `getUser()` using the caller's bearer token. Installation is
idempotent and refuses to overwrite changed app-owned code. Review and commit
the installed files before deployment. Module source updates do not automatically
upgrade an already-installed schema; add a new migration when upgrading.

## Configure and deploy

Copy `.env.example` to an ignored server secrets file, fill in real values, and
load it through Supabase secrets management. Never put these values in Flutter
Dart defines, logs, Git, or a template archive containing populated credentials.

- `REVENUECAT_SECRET_API_KEY`: a secret API v1 key for this app's RevenueCat project.
- `REVENUECAT_WEBHOOK_AUTHORIZATION`: a long random authorization header value,
  for example `Bearer <random-secret>`, also configured in RevenueCat.
- `REVENUECAT_APP_IDS`: comma-separated RevenueCat app IDs, not bundle identifiers.
- `REVENUECAT_ENVIRONMENT`: explicitly `PRODUCTION` or `SANDBOX`.
- `PREMIUM_ENTITLEMENT_ID`: the app-owned entitlement checked by `premium-status`.

Supabase supplies `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and
`SUPABASE_SERVICE_ROLE_KEY` to deployed functions. The service-role key never
reaches the mobile app.

```sh
supabase secrets set --env-file supabase/.env.subscriptions
supabase functions deploy revenuecat-webhook
supabase functions deploy refresh-entitlements
supabase functions deploy premium-status
```

These commands target the project's linked backend; deploy only when that backend
has been deliberately selected. For local checks use `supabase functions serve
--env-file supabase/.env.subscriptions` instead.

In RevenueCat, register the deployed `revenuecat-webhook` HTTPS endpoint, match
its authorization header, select the expected app(s), and select the matching
purchase environment. Use separate Supabase projects and webhook integrations
for production and sandbox. The SQL authorization helper **always requires
production grants**, even if sandbox rows exist. Do not weaken it for testing;
test production policy using local SQL fixtures and sandbox synchronization in
a separate backend.

## Identity and guest purchases

The authenticated Supabase UUID is the RevenueCat app user ID. The Flutter
starter already passes its current authenticated ID to RevenueCat on sign-in.
`refresh-entitlements` derives the UUID from the verified Supabase session. It
ignores user IDs, customer IDs, entitlement IDs, and premium flags in request bodies.
Anonymous Supabase sessions are excluded from this first backend module.

Guests can still buy through RevenueCat in the mobile app. They must sign in
before using protected backend operations, then let the SDK perform login/restore
and request server reconciliation. Trusted webhook aliases are used only to
discover candidate UUIDs; each existing signed-in account is independently reconciled through RevenueCat's server API.
No entitlement in the webhook body or guest alias alone grants access. Configure RevenueCat restore/transfer behavior deliberately and verify
guest-to-account conversion and account switching in store sandbox. This module
does not introduce an account-merging API or accept client-provided ownership
claims. Transfers reconcile both identified accounts using RevenueCat's current
customer state; deleted/nonexistent/anonymous accounts and guest IDs are skipped.

## Protect the actual product

`user_entitlements` is server-managed. RLS permits only reads for the owner.
Client roles cannot write grants, inspect sync leases, or mark webhook events
processed. Account deletion cascades entitlement rows and leases automatically;
store subscriptions are not canceled by account deletion.

Add `public.has_entitlement('your-entitlement')` to a policy for a protected table:

```sql
create policy "Premium owners can read exports" on public.exports
  for select to authenticated
  using (user_id = (select auth.uid()) and (select public.has_entitlement('export')));
```

Enable RLS and review all other policies too: permissive policies combine with
OR, so an unrestricted policy can bypass a premium policy. For Edge Functions,
verify the caller, check the helper with the caller-scoped client, then perform
the operation. Do not check it with a service-role client lacking the caller JWT.

`premium-status` is an executable authorization example returning only the
verified subject. Replace or extend it with app-specific paid work **after** its
check. Merely installing the module does not protect existing APIs or tables.
Client `allowWhen`, `BILLING_MODE`, and feature mappings cannot override this SQL
helper. Keep premium business rules server-owned.

## Synchronization and failure rules

The webhook authenticates every delivery and checks its app/environment where
those fields exist. RevenueCat's project-level promotional, alias, and transfer
events can lack a store app ID; their authorization header must be unique to this
project's webhook integration. The server API secret must belong to the same
RevenueCat project: API v1 does not expose a project ID for independent comparison.
App-scoped events with missing/unexpected app IDs are rejected. It
fetches current RevenueCat customer state instead of applying event names.
Cancellation therefore retains paid-through access; expiration/revocation removes
it. Refunded subscription metadata also denies access. Known grace deadlines and non-expiring purchases are handled explicitly.
Sandbox transactions cannot generate production grants. Multiple entitlement
IDs are supported; RevenueCat determines the currently effective product for
each entitlement. Malformed upstream data fails rather than granting access.

Synchronization acquires a database lease before fetching RevenueCat. Applying
a snapshot verifies that lease and replaces the subject's grants atomically.
Expired leases cannot overwrite newer results. A failed delivery returns 503
and is not marked processed; successful duplicates return 200. Transfer retries
can safely reconcile accounts already updated by an earlier partial attempt.

`refresh-entitlements` reconciles only the authenticated caller and returns their
server snapshot. Call it after purchase/restore and on app resume when needed.
Long-running sessions must refresh before the verification deadline; avoid
refreshing on every operation when the server snapshot remains fresh.
Requests are throttled to one attempt per account per 30 seconds; concurrent
or throttled requests return 429 and must be retried. Webhooks bypass that
cooldown but still require an exclusive lease. Current handler work is completed
before acknowledgment; no unfinished background task is treated as success.

Rows have both store expiration and a one-hour verification freshness limit.
Lifetime access also requires fresh server verification. Premium operations deny
expired, revoked, unknown-expiration, sandbox, and stale grants. During an outage,
previous server approval can remain usable within that bounded validity; it is
never extended by a client claim. Apps needing shorter revocation latency should
shorten the limit in their migration and refresh/reconcile appropriately.

The mobile Supabase entitlement adapter is a later integration step; the new
Phase 1 interface supports it. Backend enforcement already works independently
of the mobile presentation state. No client can authorize paid work by changing
its local provider or billing flag.

## Validate without real purchases

```sh
npx --yes deno test supabase/modules/subscriptions/tests/subscription_core_test.ts supabase/modules/subscriptions/tests/subscription_handlers_test.ts
npx --yes deno test --allow-read --allow-env --allow-sys supabase/modules/subscriptions/tests/subscription_sql_test.ts
python3 -m unittest discover -s supabase/tool -p 'test_*.py'
npx --yes deno check supabase/modules/subscriptions/functions/revenuecat-webhook/index.ts supabase/modules/subscriptions/functions/refresh-entitlements/index.ts supabase/modules/subscriptions/functions/premium-status/index.ts
```

The isolated PostgreSQL checks use PGlite with minimal Auth fixtures. They do not
replace `supabase test db` on the installed module's local Docker stack or
store-sandbox tests for real RevenueCat identity/transfer behavior. No automated
test above contacts a paid RevenueCat project or modifies a remote backend.
