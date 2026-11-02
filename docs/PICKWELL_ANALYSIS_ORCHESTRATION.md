# T05.1 — Secure analyze-product orchestration

2026-11-03. **COMPLETE for backend orchestration and the specified mocked-provider
acceptance. Deployed with inference disabled.** This is not completion of Meta
extraction quality, interpretation, publication or the full mobile analysis flow.
Previous T04.2 work was reviewed and committed first as `1ff9910`.

## Inventory, reconciliation and minimal changes

Read root instructions, backend README, actual T01.1 adapter/schema, T02.1 catalog
constraints, T02.2 security boundary, T02.3 reservations/provider accounting,
T02.4 events and T04.2 verified-email guard. Reconciled relevant PRD v1.4,
DESIGN/SPEC v1.2, DATABASE v1.0 and TASKS requirements against implementation.
Flutter source and configuration were not changed by this task.

Existing code already provided canonical barcodes, a unique active job per barcode,
UTC Free 30/3 configuration, atomic reservations/finalization, one provider claim
per reservation, provider-attempt/concurrency/spend caps, private jobs and published
projection. Reused these rather than implementing parallel counters or schemas.

Missing pieces were the submission endpoint, binding request identity to actual
images, and a durable non-public extraction handoff. Added only those pieces.
SPEC's older illustrative five-analysis default remains superseded by approved
30/3. Billing/Premium remain disabled; no prices/limits or new services/packages.

## Request and execution contract

`POST https://bzmqgjinbjykhqqswdva.supabase.co/functions/v1/analyze-product`

Gateway `verify_jwt=true`, plus the shared trusted Auth guard and DB identity check.
Requires a persistent non-anonymous user with confirmed email. Request is multipart:

| Field | Required value |
| --- | --- |
| `barcode` | Valid EAN-8/UPC-A/EAN-13/GTIN-14, canonicalized server-side |
| `idempotency_key` | UUID, retained for transport retries |
| `nutrition_image` | Binary JPEG/PNG file |
| `ingredients_image` | Binary JPEG/PNG file, distinct bytes from nutrition |

If an Idempotency-Key header is also supplied it must match the field. Unknown or
duplicate fields, claimed user/verified/Premium fields, URL strings and malformed
barcodes are rejected. This route does not accept client-chosen Meta endpoints,
model names, user UUIDs or plan allowances.

1. Verify actual Auth user, derive trusted network HMAC bucket and throttle user/IP.
   Keep the existing conservative shared bucket until proxy ingress is certified.
2. Read at most **10 MiB + 64 KiB multipart overhead** with a **10-second** input
   deadline. Each image is at most **5 MiB**, **2400 x 2400**, and signature inspected.
   PNG chunk bounds/CRC/IDAT/IEND and JPEG marker/scan structure are checked. Declared
   MIME/extensions are ignored. This is bounded structural validation, not a heavy
   in-function image decoder or proof of readable label text.
3. SHA-256 fingerprints bind normalized barcode and both actual image byte hashes
   to `(trusted user, idempotency key)`. Identical photos or changed input under an
   existing key cannot cause a new provider invocation.
4. `pickwell_admit_analysis` uses the existing transaction advisory lock to recheck
   ready/cache state, own request/job state, shared active work, enabled inference
   and quota before creating a reservation/job. Disabled inference creates neither.
5. `pickwell_begin_provider` atomically rechecks cache/lease and claims one provider
   attempt with user/IP/global concurrency, daily attempts and conservative spend
   holds. Only an acknowledged unique claim permits network inference.
6. Reuse the actual spike adapter, factored into `invokeMetaLabels` without changing
   its operator guards or extraction schema. Fixed endpoint
   `https://api.meta.ai/v1/chat/completions`, selected model **muse-spark-1.3**,
   two inline labeled images, structured schema, 4096 output-token bound, minimal
   reasoning, non-streaming/store=false, redirect refusal and **30-second** timeout.
   RPCs have 5-second bounds; optional telemetry retains its shorter bounded path.
7. Known failures/retakes record mandatory provider metrics and release the user
   reservation without consuming a successful-analysis credit. Retakes identify
   nutrition/ingredients/both. Same-key terminal replay does not call Meta again.
8. Successful schema extraction goes to private `analysis_candidates` and returns
   `processing`, `stage=validation_pending`. It is not published, not a health
   classification, and does not consume a successful-analysis credit. Rules and
   final publication remain T05.2/T05.3.

Public cache hits return `already_exists` and the sanitized published projection,
with zero model calls. Shared cross-user work returns safe `processing`, without
another user's job ID or candidate data. An owner may receive their own job ID.
Input errors return 400; auth 401/403; quota/throttle/attempt/spend denials 429;
known provider failure 502; retake 422; private extraction staging 202. Inference
disabled/service failure returns 503; a changed image/barcode request key returns
409. No timeout/database error is represented as a catalog miss.

## Unknown outcomes and retries

There is **no automatic paid retry**. Provider timeout/transport uncertainty records
`unknown` and keeps the existing provider spend, concurrency and barcode claim.
User successful-use count remains zero; the reserved allowance stays held until
trusted reconciliation establishes the outcome. The API explicitly reports
`provider_reconciliation_required`, `provider_outcome_unknown`, `retryable=false`.
An initial uncertain result returns 503; repeat status is safe processing and never
another model call. Expired in-flight claims also expose reconciliation state.

A lost provider-claim acknowledgement never permits an unacknowledged call. Retrying
the same key cannot create a second claim; changing keys cannot bypass shared barcode
holds or the daily per-barcode attempt cap. This intentionally favors bounded cost
over blind retries. There is no client-accessible reconciliation action.

Mandatory ledger/SQL acknowledgement failures remain fail closed. Optional events
cannot convert a quota denial into an allowance or deny an admitted operation.
No elevated SQL headers inherit the incoming user JWT.

## Versioned private persistence and privacy

Migration `20261103000100_pickwell_analysis_orchestration.sql` adds:

- `analysis_requests`: canonical barcode/image digest/key and private ownership/
  reservation/job links, with 30-day expired closed-request pruning.
- `analysis_candidates`: bounded structured extraction, model/prompt version and
  24-hour expiry for T05.2/T05.3. No original image, URL payload or token is inserted.
- Narrow server-only admission, reply, staging, settlement and pruning RPCs, all
  invoker functions with empty search_path. Existing verified-identity definer guard
  is reused; clients have no EXECUTE, table read/write grants or policies.

`pickwell_prune_analysis()` expires private candidates and releases unspent known
completed reservations. Admission runs it opportunistically; ops must schedule it
alongside existing telemetry maintenance before hosted inference is enabled. The
existing project has no Cron extension/schedule, so fixed-time automatic retention
is not claimed. Unresolved provider accounting is not silently discarded. Original
photos exist only in request memory and are released; none are stored in Supabase.

## Targeted native and isolated validation

**54 native tests passed**, zero skipped, on the guarded disposable loopback Native
Runtime Auth/REST/PostgreSQL stack with mocked Meta only. Includes:

- **32 parallel submissions from two authenticated users:** one job/claim/provider
  call, shared outcome, no cross-owner job ID leak.
- Twelve same-key parallel submissions: one provider call, one reservation; changed
  image digest rejected. New keys cannot evade three-attempt barcode cap.
- Three Free reserved slots, fourth denied; release/retake/failure preserve successful
  allowance. Existing quota tests also verify three synthetic publications/4th denial,
  idempotent finalization, UTC reset, mutable limits and rollback behavior.
- Bounded image/multipart validation, misleading MIME, binary corruption, duplicate
  images, oversize/dimensions and forged verification fields do not reach Meta.
- Trusted identity, blocked anonymous/unverified paths, actual native Auth, denied
  anonymous/authenticated table writes/reads and correctly parameterized private RPC.
- Model timeout, known failure, malformed output and precise retake; unknown holds
  and lost SQL acknowledgement cause no repeated provider request.
- Expired candidate cleanup releases an unspent reservation. A **clearly synthetic,
  trusted test writer** exercised the existing atomic publication finalizer, then
  parallel users reused exactly one published record without more provider calls.
  This is a DB/handler fixture, not implementation or evidence of real T05.2/T05.3.

**25 isolated tests passed**, zero skipped: 11 existing spike tests after adapter
factoring; 5 verified-email boundary tests; 9 catalog/migration replay tests with
46 expected SQL rejection checks using the real PGlite PostgreSQL engine. Existing
catalog/sample data and unique barcode constraints survive applying/replaying the
migration runner. No Docker, new package, blanket Flutter/web regression or new
physical-device test was used. Native stack was stopped and its loopback API verified
unreachable afterward to release machine resources.

Commands (private connection/session values are never shown):

```sh
SUPABASE_EXPERIMENTAL_STACK=1 npx --yes supabase@2.122.0 start --runtime native --preparation on-demand --stack t021 --exclude functions,realtime,studio,analytics,pooler,mail --workdir .secrets/native-validation
node .secrets/analysis-native-run.mjs reset
PICKWELL_NATIVE_STATUS=.secrets/native-status.json node --test --test-concurrency=1 supabase/tests/analyze_product.test.mjs supabase/tests/quota_boundary.test.mjs supabase/tests/security_boundary.test.mjs supabase/tests/get_product.test.mjs
node --test supabase/spikes/meta-vision/core.test.mjs supabase/tests/analysis_authorization.test.mjs supabase/tests/catalog_schema.test.mjs
SUPABASE_EXPERIMENTAL_STACK=1 npx --yes supabase@2.122.0 stop --stack t021 --workdir .secrets/native-validation
```

Initial native startup used an unsupported --listen flag and a status invocation
produced no JSON. Corrected to the documented native command and captured status
privately from its startup receipt. No DB/provider success is inferred from those
failed setup commands. Syntax, diff and modified-source secret checks pass.

## Actual cloud deployment and checks

Read-only preflight matched the existing Pickwell project, eight applied migrations,
unused new-table names, inference/billing off and zero provider calls. Dry run listed
only the one new migration. Applied it additively, with no reset, seeds, role/Vault
upload or applied-history rewrite. Deployed only the protected analyze-product
function; API bundling successfully included the reused adapter outside functions/.

```sh
npx --yes supabase@2.122.0 db push --linked --project-ref bzmqgjinbjykhqqswdva --dry-run --skip-vault
npx --yes supabase@2.122.0 db push --linked --project-ref bzmqgjinbjykhqqswdva --skip-vault --yes
npx --yes supabase@2.122.0 functions deploy analyze-product --project-ref bzmqgjinbjykhqqswdva --use-api
```

Actual hosted results using public configuration and the existing verified test
session (small synthetic PNGs test the transport/guard, not real label extraction):

| Hosted test | Observed result | End-to-end request time |
| --- | --- | --- |
| Guest | HTTP 401 unauthorized | 1732 ms |
| Public key as bearer | HTTP 401 unauthorized | 1066 ms |
| Forged token | HTTP 401 gateway denial | 113 ms |
| Verified malformed/claimed flags | HTTP 400 invalid_input | 1938 ms |
| Verified valid missing-product multipart | HTTP 503 inference_disabled | 327 ms |
| Published demo multipart submission | HTTP 200 already_exists, complete sanitized demo | 519 ms |

Final cloud assertions passed: new migration present; inference and billing remain
false; provider ledger, jobs and candidates **all zero**; one existing Auth user and
one demo product preserved; all public tables RLS-enabled; no client grants on new
tables/RPCs. One cache-hit request fingerprint receipt was created, without images,
provider work or AI-credit consumption. Final migration dry run is up to date.
No real Meta inference was performed by this task, so there are no new real token,
latency or billed-cost measurements. Provider counts/tokens in native tests are
explicitly mock data, not invoices or new live-model evidence.

## Security note and remaining operational limits

No credentials/images were committed and no cloud key was displayed. One startup
log tail inadvertently included **disposable loopback-only native test credentials**.
That was acknowledged; later logs stayed private/redacted and the native stack was
stopped and checked unreachable. Those local values are not cloud credentials.
No claim is made that local test keys were rotated; future native stacks remain
local development resources. Session/config/test inputs stay in ignored `.secrets/`.

Before enabling normal hosted inference: finish T05.2 deterministic validation and
T05.3 atomic publication/cleanup, configure retention scheduling, verify approved
worst-case cost bounds and the maximum hosted image/CPU envelope, and retain safe
proxy attribution or its conservative shared fallback. The default conservative
spend holds are enforced in tests; they are not a newly measured real provider
billing guarantee. Original T01.1 real-label extraction limitations remain open.

Flutter upload/submission/result wiring was not added to this backend-only task;
the current app's Analyze action still performs the auth checkpoint. No new user UI,
OTP provider, billing, paywall, product discovery or unrelated refactor. Existing
physical-camera reports do not establish new provider/deployment/device QA here.

All four T05.1 implementation/targeted acceptance checkboxes are verified. The T04.2
backend-guard checkbox is now verified on the actual protected submission handler.
Full real-product capture → interpretation → publication → cached reuse is still
unverified and must not be called MVP-ready. No additional credentials are required
for the completed mocked-provider scope; no new visual assets were needed.

**Next: T05.2 — Extract, interpret and validate.** T05.3 publication/cleanup and
mobile upload integration follow; do not start them automatically.

Official provider references checked for the existing selected model/endpoint:
[Meta image understanding](https://dev.meta.ai/docs/image-understanding) and
[Meta chat completions](https://dev.meta.ai/docs/protocols/chat-completions).

## Exact repository files changed

- `docs/PICKWELL_ANALYSIS_ORCHESTRATION.md`
- `docs/PICKWELL_TASKS.md`
- `supabase/README.md`
- `supabase/config.toml`
- `supabase/functions/_shared/analysis_input.mjs`
- `supabase/functions/_shared/analyze_product.mjs`
- `supabase/functions/analyze-product/index.ts`
- `supabase/migrations/20261103000100_pickwell_analysis_orchestration.sql`
- `supabase/spikes/meta-vision/core.mjs`
- `supabase/tests/analyze_product.test.mjs`
