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
