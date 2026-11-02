# T03.1 — Get-product backend endpoint

2026-11-02. **COMPLETE for backend implementation and local HTTP/native validation.**
Previous T02.4 changes were reviewed and committed first as `35a8c42`.
No hosted migration/deployment or real Meta inference occurred.

## Reconciliation and scope

Reviewed root instructions, backend README, current catalog/quota/event helpers,
PRD v1.4, DESIGN/SPEC v1.2, DATABASE v1.0 and TASKS v1.1. Reused the canonical
GTIN rules, published-products view, sanitizer, atomic quota functions, network
throttling, trusted Auth verification and optional event writer. Existing Flutter,
assets, routes, billing and analysis/spike infrastructure were preserved.

SPEC section 5.2's older illustrative five-analysis default conflicts with later
section 16 and PRD's approved 30/3 policy; this endpoint uses the existing 30/3
server config. No quota or Premium defaults were replaced. Its product JSON follows
the implemented structured nutrition/ingredients contract, rather than treating
SPEC's illustrative empty array as a new storage schema.

## Endpoint contract

`POST /functions/v1/get-product`

```json
{ "barcode": "2900000000018" }
```

Optional `Idempotency-Key: <UUID>` identifies one logical operation; signed-in
clients should generate it before sending and retain it for transport retries.
Without it, the backend generates a key and returns it as `request_id` on success.
A new physical lookup uses a new key. Opening a locally held result makes no call.

| Outcome | HTTP | Response |
| --- | --- | --- |
| Published current revision | 200 | `status=ready`, canonical barcode, sanitized product, request ID |
| Actual miss/invalidated product without active work | 200 | `status=not_found`, canonical barcode, request ID |
| Active job, processing product or unresolved provider work | 200 | `status=processing`, canonical barcode, `retry_after_seconds=4`; no job/owner IDs |
| Network/user request throttle | 429 | `status=rate_limited` |
| Account daily quota exhausted | 429 | `status=quota_exceeded`, effective quota/reset |
| Malformed body/GTIN/check digit | 400 | `status=error`, `error=invalid_barcode` |
| Invalid idempotency header | 400 | `error=invalid_idempotency_key` |
| Supplied invalid/expired user session | 401 | `error=unauthorized`; no guest fallback |
| Key reused for another barcode or unavailable replay | 409 | `error=idempotency_conflict` or `idempotency_expired`; use a new operation key |
| Backend/Auth/configuration failure or timeout | 503 | `error=service_unavailable`; never a fabricated miss |
| Unsupported method | 405 | `error=method_not_allowed` |

Persistent signed-in users receive only effective `plan`, `limit`, config `version`,
`used`, `reserved`, `remaining`, and `reset_at` from backend quota state. Verified
Email OTP is required for **new analysis submission**, not public reads; this route
accepts a persistent unconfirmed reader too. Guests receive `guest_best_effort=true`
and no invented per-person remaining allowance.

The HTTP handler accepts only a JSON object with `barcode`, with a 1 KiB input
limit. EAN-8, UPC-A, EAN-13 and GTIN-14 validate their check digit and normalize to
GTIN-14; whitespace is trimmed. UPC-E must first be expanded by a format-aware
scanner in the later Flutter task; eight-digit text means EAN-8 here.

## Trust, data and atomic charging

`get-product/index.ts` is a small Deno adapter around `_shared/get_product.mjs`.
Config explicitly sets `verify_jwt=false` for this guest-capable read route. The
handler independently verifies supplied user JWTs with Supabase Auth. Auth failures
and service outages stay distinct; malformed sessions do not become guest reads.

Known injected public/legacy keys used as bearer defaults are explicitly recognized
as guest credentials, never user identity. Named injected publishable-key maps and
the local single-key fallback are supported. Send publishable keys in `apikey` and
session JWTs in `Authorization` as described by
[Supabase API-key guidance](https://supabase.com/docs/guides/getting-started/api-keys)
and [Edge environment documentation](https://supabase.com/docs/guides/functions/secrets).
No key prefix or unverified JWT claims grant account identity or a plan.

The handler requires a protected `PICKWELL_NETWORK_HASH_SECRET` and invokes the
existing network/user attempt throttle **before** catalogue access. Proxy headers
are ignored unless operator-configured and trusted; without verified attribution,
a conservative shared unknown-network bucket applies. Missing/invalid configuration
fails closed. No direct table grants or privileged SQL EXECUTE are given to clients.

The additive `20261102000500_pickwell_product_lookup.sql` introduces one private
atomic lookup RPC and short-lived `lookup_receipts`:

1. Validate barcode and serialize admission under the existing transaction lock.
2. Signed-in users reserve existing Free lookup capacity; guests do not create
   anonymous Auth users or pretend to have attributable account quota.
3. Read the existing **ready-only** published view, or determine safe processing/miss.
   Return no unpublished nutrition/findings, contributor identity or private jobs.
4. In the same transaction, create a replay receipt and settle one definitive
   signed-in lookup. Query failures roll back the reservation and charge together.
5. The handler applies the existing explicit root/nested product allowlists and
   validates the response state. Optional guest/denial analytics cannot change the
   underlying read or quota decision. Meta adapters are never imported or invoked.

Receipts contain only reservation/status/product/revision references, not duplicated
label JSON or photos. Replay is limited to five minutes and the same published
revision. A correction/invalidation or expired receipt returns a conflict rather
than freely refreshing through an old key. Miss/processing retries preserve their
original status; use a new lookup key for a deliberate fresh check, or owner-scoped
analysis status when available. Expired references are physically deleted on the
next lookup, and account deletion cascades them. No periodic receipt cleanup claim
is made when traffic is absent.

**Transport ambiguity:** a failure known to happen before the RPC transaction adds
no usage. If the DB commits but its response is lost, the backend cannot safely
infer rollback or refund; retry the **same** key for the original charged result.
Do not promise zero usage for every possible client/network disconnect after commit.
Idempotency prevents duplicate charges; it cannot prove delivery to a disconnected
client. A client that omits its key cannot reliably retry an unreceived generated key.

## Actual validation

Used isolated native Supabase (CLI 2.122.0, PostgreSQL 15.19), loopback-only connection
guards and no Docker. All eight migrations and configured seeds applied cleanly.
SQL tests ran first after reset; mutating Node suites ran afterward.

| Command/check | Observed outcome |
| --- | --- |
| Native `db reset --yes --db-url [guarded local URL] --workdir .secrets/native-validation` | All migrations/seeds applied; no hosted target. |
| Native `test db --db-url [guarded local URL] --workdir .secrets/native-validation` | **142 pgTAP assertions passed**, including 14 lookup assertions and all 128 prior assertions. |
| `PICKWELL_NATIVE_STATUS=.secrets/native-status.json node --test supabase/tests/get_product.test.mjs` | **11 passed, zero skipped**. Handler exposed through a real loopback HTTP listener, calling real native Supabase Auth/REST. |
| `PICKWELL_NATIVE_STATUS=.secrets/native-status.json node --test supabase/tests/quota_boundary.test.mjs` | **19 passed**; existing quota/provider controls preserved. |
| Native `node --test supabase/tests/security_boundary.test.mjs supabase/tests/operational_events.test.mjs` with the same status environment | **15 passed**, preserving ownership, RLS, event redaction/failures and accounting. |
| `node --test supabase/tests/catalog_schema.test.mjs` | **9 passed**, 46 expected SQL rejections; additive migration/replay preserves original data. |
| Node syntax checks, source secret-pattern scan, `git diff --check` | Passed. |

Endpoint checks covered the complete synthetic demo (eight nutrients and findings),
miss, processing, malformed/checksum/oversized/forged input, bad session, Auth outage,
DB failure/timeout, rate limiting, published projection redaction, mutable limits and
UTC reset metadata. Eight concurrent same-key HTTP lookups returned one charged
result. Disposable test configuration raised per-minute ceilings to isolate the daily
quota case; the HTTP 30/31 check seeded used=29 before the final two requests.
The separate quota suite exercised all 30 consumptions, and defaults were restored. The 30th lookup succeeded, the 31st returned quota_exceeded. A known failure
before SQL execution returned 503 and left usage unchanged. SQL tests verified
unconfirmed reads, alias retries, key/barcode mismatch, expired receipts, private
receipt/RPC denial and zero provider admissions.

The fetch trace allowed only the isolated Supabase origin, with no provider-start or
provider-result RPC. The native `ai_usage` count was unchanged across endpoint tests:
**zero Meta admissions/calls** for these reads. All fixtures are explicitly synthetic;
no live nutrition claims, provider token measurement or cost measurement was invented.
Test identities were removed and native services stopped afterward.

The HTTP test listener is a Node bridge around the exact Web Request handler used
by Deno. The Deno entrypoint passed syntax checking. **Deno Edge gateway execution
and hosted deployment were not performed or certified.** The native start excluded
Functions; no Docker fallback, remote write or extra runtime package was introduced.

## Completion, files and next dependency

All three T03.1 backend checkboxes and the local HTTP acceptance cases are verified.
The deferred T02.2 sanitized public-read boundary is now exercised by this handler;
its hosted gateway remains an unverified deployment check.

Changed: this report, TASKS, DATABASE, backend README, function config; new shared
`get_product.mjs`, Deno `get-product/index.ts`, lookup migration and two lookup tests;
existing `quota_boundary.mjs` changes only Auth service-error classification. No
mobile source, images, billing flags or provider configuration changed.

Before deployment, apply reviewed migrations to the intended project, configure a
random server-only network HMAC secret, verify ingress attribution (or retain the
shared conservative fallback), and test the actual Edge gateway. T02.4 automatic
retention still needs enabled/verified Supabase Cron; no live scheduler claim is made.
No new credentials/assets/device access were needed for local validation.

Next: **T03.2 — Flutter scanner/home and lookup UX**. Do not start automatically.


## Hosted deployment and live validation — 2026-11-02

**DEPLOYED AND VALIDATED** on the existing Pickwell project
`bzmqgjinbjykhqqswdva`. Function `get-product` is ACTIVE, version 1. Earlier local-only
statements above describe the original task-time results and are retained as history.

Endpoint: `https://bzmqgjinbjykhqqswdva.supabase.co/functions/v1/get-product`.
Deployed the existing implementation without handler, mobile, database-schema or
architecture changes. Used the authenticated CLI API bundler without Docker:

```sh
npx --yes supabase@2.122.0 secrets set --project-ref bzmqgjinbjykhqqswdva --env-file .secrets/lookup-server.env
npx --yes supabase@2.122.0 functions deploy get-product --project-ref bzmqgjinbjykhqqswdva --use-api
npx --yes supabase@2.122.0 db query --linked --project-ref bzmqgjinbjykhqqswdva --file supabase/seed/04_pickwell_demo.sql
node --test supabase/tests/get_product.test.mjs
```

Generated a cryptographically random 256-bit HMAC secret in a mode-0600 ignored
file and uploaded only that setting. Supabase injects privileged database credentials;
none were added to Flutter. Proxy-trust settings remain unset: the conservative
shared unknown-network bucket is intentional until trusted ingress attribution is
verified. Caller-provided IP headers cannot choose their own throttle bucket.
Gateway JWT verification is disabled only for this guest-capable read function, as
already configured; supplied user sessions are independently verified with Auth.
No inference endpoint was deployed or enabled.

Applied only the existing clearly labeled synthetic demo seed, not the generic
sample/social seeds. Barcode `2900000000018` now resolves to the fictional oat
fixture, with `is_demo=true`, explicit demo text, 8 nutrients, two ingredients and
one finding. This is test data, not an actual analyzed food product.

### Observed live results

Requests used the existing public mobile development configuration. The existing
normal Auth session was refreshed securely in its ignored session file; no new user,
OTP request or administrative verification bypass was required.

| Live case | Observed result | Duration |
| --- | --- | --- |
| Guest demo barcode | HTTP 200, `ready`, complete sanitized demo, no account quota | 3821 ms first invocation |
| Guest missing EAN-8 `96385074` | HTTP 200, `not_found` | 374 ms |
| Invalid check digit | HTTP 400, `invalid_barcode` | 178 ms |
| Forged client Premium field | HTTP 400, body rejected | 200 ms |
| Invalid supplied session | HTTP 401, `unauthorized`, no guest fallback | 531 ms |
| GET instead of POST | HTTP 405 | 121 ms |
| Existing public key as default bearer | HTTP 200, guest `not_found` | 500 ms |
| Signed-in missing barcode | HTTP 200, Free limit 30, used 1, remaining 29 | 366 ms |
| Same signed-in idempotency key/body | HTTP 200, identical quota; no second charge | 278 ms |
| Same key, different barcode | HTTP 409, `idempotency_conflict` | 376 ms |
| Guest requests with varying forged X-Forwarded-For | HTTP 429, `rate_limited` on ninth burst attempt | Not separately measured |

The authenticated response reset is `2026-11-03T00:00:00+00:00`. The single charged
lookup is a real test-user allowance use; counters were not reset or altered for
testing. Guest burst requests intentionally consume the shared throttle window;
subsequent clients may receive 429 until that window resets.

Private fixture assertions checked demo nutrient/ingredient completeness, sanitized
fields, no guest quota claims and exact quota equality on replay. Ten live contract
cases passed, plus the separate live throttle assertion. The targeted local handler
suite passed **7 tests**, with **1 native-stack integration test skipped** because
the native stack was not started. Those local tests also cover simulated database
failure/timeout returning 503 and safe processing states. No live database outage,
quota exhaustion or processing job was forced on the hosted project.

Post-test cloud assertions: one demo product and analysis, **zero provider ledger
rows**, one unchanged existing Auth user, no unsafe client grants/RPC permissions,
and billing, Premium and normal inference all disabled. The deployed module graph
imports no Meta/provider adapter. No Meta API calls or provider cost were incurred;
ordinary Edge/database requests use Supabase resources.

Deployment logs, public-response evidence, query files, sessions and HMAC material
remain ignored under `.secrets/`; no credential values appear in this report.

Remaining: verify physical camera/permission/EAN-UPC/gallery behavior and live mobile
ready/miss navigation for T03.2. Trusted per-IP attribution is not certified; the
shared fallback is conservative and can limit unrelated guests together. Supabase
Cron/automatic retention remains unconfigured and must be verified before broader
hosted use. This deployment does not complete T01.1 extraction feasibility or later
capture/submission tasks.

Deployment method: [Supabase Edge deployment](https://supabase.com/docs/guides/functions/deploy)
and [protected Edge environment settings](https://supabase.com/docs/guides/functions/secrets).
