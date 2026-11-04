# T07.1C.4 — Hosted private results and thumbnail rollout

2026-11-04. **Release decision: PASS WITH LIMITATIONS for the protected hackathon
testing environment.** The schema/functions are deployed, and inference is back
on. Genuine Muse → private screen → exact operator approval → attached front
thumbnail → guest reuse has **not** been demonstrated in this run.

## Source and deployment

Reviewed and committed the complete previously tested C.3 source/tests/docs first:
**`5178ec1f0c3bc18a0a4e94f5daabd2fbee33c15a`** — `Deliver owner-private analysis
results with exactly-once successful usage`. Thumbnail implementation was already
committed in parent `befc320`. The tree was clean before deployment. No application
code, schema design, approval policy, model or credentials were changed during
this rollout; subsequent changes are this report/status reconciliation only.

Confirmed project **`bzmqgjinbjykhqqswdva`**, matching the actual public Flutter dev
configuration. Pinned Supabase CLI **2.122.0**, API Edge bundling, no Docker.
Preflight found exactly the two requested forward migrations pending, no bucket
collision, no inflight/unknown provider work, and no staged candidates. Existing
state: four published catalog records, one expired review, 16 provider ledger rows
and zero Storage objects.

Under the existing provider/admission transaction lock, paused inference with an
audited rollout reason. Applied the following files in order, without a reset,
seed, migration repair, data removal or approval bypass:

| Applied migration | SHA-256 of deployed repository file |
| --- | --- |
| `20261104000300_pickwell_product_thumbnails.sql` | `257bf203429964cc78f171fd26d623fdaee88d542171bdaaf9c0f3ee5203d9b0` |
| `20261104000400_pickwell_private_analysis.sql` | `00509a26cdcd038b15662b4546dd7b815b19b32fdb8f67bf3784211ef532c9e1` |

Deployed compatible handlers and shared dependencies while inference remained
paused:

| Function | Hosted version / state | Authorization |
| --- | --- | --- |
| `analyze-product` | **22 / ACTIVE** | Gateway JWT + persistent verified non-anonymous Auth identity |
| `cancel-analysis-review` | **2 / ACTIVE** | Handler verified Auth identity, owner scope and throttle |
| `get-private-analysis` | **1 / ACTIVE** | Handler verified Auth identity, owner scope and throttle |
| `get-product-thumbnail` | **1 / ACTIVE** | Public read of eligible published derivative only |
| `get-product` | **9 / ACTIVE** | Public sanitized lookup, existing rate/quota controls, no model |
| `get-analysis-status` | **2 / ACTIVE** | Gateway JWT + owner-scoped handler |

Gateway JWT verification is intentionally disabled for the two handler-verified
review/private-read endpoints and guest read endpoints; none permits unauthenticated
inference. All SQL publication guards remain mandatory. Lookup/status were deployed
with the compatible shared projection. Final migration dry run is **up to date**,
with no pending migrations, seeds or roles. Restored the original inference state
only after hosted boundary checks and state-preservation assertions passed.

## Hosted results actually observed

| Check group | Result / scope |
| --- | --- |
| Existing hosted boundary harness | **30 passed**: refreshed existing verified session; guest cache and explicit miss; invalid/forged analysis denial; private jobs and direct shared/usage/entitlement writes denied |
| Existing trust Edge checks | **14 passed**: ordinary-role review/inspection/approval/publish denial; guest cancellation forbidden; authority injection rejected; mandatory front enforced; valid three-image parser test stopped at paused inference |
| New private/thumbnail HTTP and REST checks | **27 passed**: guest/forged private reads denied; verified unknown owner job `404 not_found`, no-store; invalid job/owner/approval parameters rejected; private tables/thumbnail asset view inaccessible to ordinary roles; privileged private-result/thumbnail RPCs denied; private Storage list exposes zero objects; invalid/unknown public thumbnail unavailable; legacy cached result works without thumbnail |
| Hosted SQL transaction fixture | **59 passed**, all fixture data and counters **rolled back**; detailed coverage below |
| Post-test state preservation | Original product/published/review/provider/Storage/user counts unchanged; zero fixture private results/thumbnails/candidates; all Free limits and non-inference control values unchanged |
| Maintenance | Existing active private maintenance every five minutes uses the updated prune function; confirmed private-result expiry deletion is present. Observed successful scheduled run at **2026-11-04 07:45:00 UTC** after migration. Daily telemetry retention remains active with a successful recorded run |
| Operator thumbnail cleanup | Existing protected `--cleanup --apply` workflow executed successfully, **removed 0**; no orphan/purging assets existed. Existing operator credential used transiently in memory; no key saved to logs/repo or changed |

**Total hosted assertions: 71 HTTP/REST + 59 SQL = 130 passing.** No remaining
failed boundary assertion. These are not 130 real-product analyses.

### SQL fixture coverage and limits

The fixture used the existing confirmed owner identity and a transaction-only
synthetic second Auth identity, **not a second delivered OTP or real session**.
It exercised the actual hosted functions and constraints, including:

- Immutable owner-private projection, bounded 24-hour expiry, no public ready leak,
  and cross-owner `not_found` at the SQL/RPC boundary.
- Same-key private delivery charges exactly one successful-analysis credit;
  cancellation/rejection/review expiry keep that credit and the valid private
  result. Failed/unreadable inference refund behavior remains covered by the
  committed native regression; no failing provider was invoked here.
- A second contributor waits for the active barcode claim, then resumes the same
  bound request key to obtain a different private contribution. Conflicting
  contributions remain separate.
- Both contributions can receive exact-bound test approvals inside the rollback
  transaction. First publication creates one canonical revision; the other cannot
  overwrite/merge it and can access the canonical transition. No publication
  double charge. Guest cache reuse sees the canonical record inside that transaction.
- Modified approval bindings, direct finalizer publication without approval and
  pre-publication thumbnail preparation are rejected.
- Derivative remains nonpublic while uploading; commit refuses absent Storage
  metadata; exact approved/published association exposes the derivative projection
  only after commit. These tests use **transaction-only Storage metadata**, not
  uploaded JPEG bytes or a genuinely reviewed package photograph.
- Expired upload cleanup quarantines metadata, refuses forgetting before Storage
  deletion, and the hosted Storage protection rejects direct SQL deletion.
- Immutable private payload cannot be changed; expiry removes it. An expired
  owner's result can return only an already approved public canonical record.

Provider metrics, test approvals and the temporary ready record were synthetic
and rolled back. No fake public product, verified account, provider usage, image
or review decision was committed. The second identity is a SQL test condition,
not a claim that an actual second verified session signed in. Hosted contention
and first-winner behavior were exercised transactionally; **parallel network
submission/approval races were not freshly executed against the cloud**. The
committed C.3 native suite supplies the 34 real local Auth/HTTP/PostgreSQL race and
integration cases. No live model response, token count, latency or cost is invented.

Two initial test-harness assumptions were corrected without changing safeguards:
Supabase correctly forbids deleting Storage metadata directly, and private bucket
listing can safely return HTTP 200 with an empty RLS-filtered list. Final tests
expect those protections rather than relaxing them.

## Actual publication and image state

**Owner-private results: 0 persisted. Approved thumbnails: 0. Storage objects: 0.**
The one pre-existing review is expired. Legacy published products remain readable
with honest placeholders. Thumbnail capability is deployed; **no real front image
has been attached or publicly served** in this run. Public derivative bytes,
positive owner-private HTTP retrieval and a real operator contribution still need
the genuine product test below; SQL fixtures are not a substitute for it.

The operator workflow remains post-publication and exact-evidence-bound. Keep all
three exact processed submission files in a private handoff, inspect barcode,
package identity and candidate, issue the explicit bound decision, let the owner
check that same request, then run `attach-product-thumbnail.mjs` with the existing
review/evidence manifest. No new photograph or AI-authorized publication.

**Thumbnail cleanup scheduling limitation:** private-result pruning is scheduled
and active, but there is **no automatic cloud Storage-API thumbnail cleanup
scheduler** in the existing implementation. The protected operator command works
and must be run after operator upload batches and when retrying incomplete uploads.
Its 30-minute upload-age/orphan rules do not themselves schedule execution. A
future automated protected runner is still pending; no dashboard, new public
maintenance endpoint, credential store or service was introduced during rollout.

## Model, quota, spend and privacy preservation

- Inference **enabled again**, model **`muse-spark-1.3`**, endpoint
  `https://api.meta.ai/v1/chat/completions`, existing three-photo contract unchanged.
- Hackathon allowances remain **1000 barcode / 100 successful private analyses per
  UTC day**. Standard baseline **30/3** remains in versioned configuration, not
  activated. Successful private delivery consumes once; shared publication adds
  zero. Cancellation cannot obtain free successful calls.
- Global spend **$100/day**, per-call ceiling **$1.34**, global calls **500/day**,
  per-user calls **100/day**, IP calls **500/day**, concurrency **5** unchanged.
- Billing **false**. No RevenueCat/paywall/provider configuration changes or key
  rotation. Only the audited inference pause/restoration control version/reason
  changed; all other controls and plan data were compared against preflight.
- **Live Meta calls in this task: 0.** Existing provider rows remained **16 → 16**.
  No actual inference cost/token/latency or fresh inbox delivery measurement.
- Original images remain request-local or in the existing bounded owner-local
  draft. Server-only private results are non-image payloads with 24-hour expiry.
  No contributor email/tokens/image payloads were exposed in cache output.

## Flutter build and device preparation

Built the matching dev application from **`5178ec1`** using only the existing public
configuration:

```sh
cd mobile
fvm flutter build apk --debug --dart-define-from-file=.secrets/dev.secrets
```

**Build passed.** APK: `mobile/build/app/outputs/flutter-apk/app-debug.apk`,
287,512,706 bytes (debug build). SHA-256:
`be108282f85518f3844b329e081b85171c16c45b5779260bbf12365676b81186`.
The artifact contains the intended public project URL; a scan found zero exact
matches for available server secret values and zero privileged service-role JWTs.
The repo/config known-secret pattern check also passed. These scanners do not
prove the absence of every possible secret encoding or historical leak.

The connected **M2007J3SG Android phone** accepted `adb install -r` successfully
without uninstalling/resetting data. Android accepted the launch intent, but later
UI inspection found the phone locked, Pickwell absent from the visible hierarchy
and no running Pickwell process at that inspection. Therefore **actual launch,
private-result navigation/content and local front preview are NOT device-passed**.
The initial UI-inspection failure was transient; it was not proof of disconnection.
No lock-screen bypass was attempted. An iPad was also detected; no iPad install,
new iOS build or device validation was performed in this task.

**Fresh focused Flutter checks: 20 passed; analyzer: no issues.** These cover preliminary identity/nutrition/findings,
owner/account switching, bounded draft recovery, shared-cache exclusion, thumbnail
fallback and consistent product identity. An initial selection used two nonexistent
short test filenames; the corrected actual test paths passed. No app fix was needed.
Existing C.3 evidence is **213 backend / 142 SQL / 167 Flutter / six Python tests**;
these are prior local results, not freshly rerun full hosted/device acceptance.
Fresh pre-deployment targeted backend review ran **42 passing** tests and the
thumbnail Python suite **six passing**. The fresh APK build passed.

## Commands, receipts and completion

Used pinned CLI `db push --linked --project-ref ... --dry-run --skip-vault`, then
forward `db push --skip-vault --yes`, followed by API deployments of the six named
functions. Preflight/pause/fixture/maintenance/preservation/restore checks used
explicit project-bound `db query --file ... --output json`. No hosted reset.

Protected receipts and reusable private harnesses are under ignored
`.secrets/t071c4-*`. Existing harnesses: `.secrets/t071-hosted-boundary.mjs` and
`.secrets/t071d1-edge-checks.mjs` (the latter is pause-only). Do not run its valid
image input test after restoration expecting `inference_disabled`.

**Remaining genuine acceptance:** unlock/open the matching app; capture a
legitimate matching barcode + front/nutrition/ingredients; verify OTP/session,
actual Muse response and immediate private UI/local front preview; inspect the
exact processed handoff for a genuine bound operator approval; check same request
without another Muse call; attach the approved derivative; verify guest canonical
reuse and public thumbnail bytes. The local fixture folder still contains only
older nutrition/ingredient pairs and a mislabeled unreadable sample, **no matching
front-package evidence**. No substitute or synthetic approval was used.

The hosted implementation is usable for protected testing. A real current-flow
demo and automatic thumbnail orphan cleanup are **not fully signed off**.
No Flutter polish, dashboard, extra photo, automatic approval, comparison,
RevenueCat or submission task was started.

### Documentation changed after verification

`PICKWELL_HOSTED_PRIVATE_RESULTS_ROLLOUT.md` (new); status/authority reconciliation in
`PICKWELL_TASKS.md`, `PICKWELL_PRD.md`, `PICKWELL_DESIGN.md`, `PICKWELL_SPEC.md`,
`PICKWELL_DATABASE.md`, `PICKWELL_AGENT_PROMPTS.md`; historical-report pointers in
`PICKWELL_PRIVATE_RESULTS.md`, `PICKWELL_PRODUCT_THUMBNAILS.md`,
`PICKWELL_HOSTED_TRUST_ROLLOUT.md`; deployment pointers in `mobile/AGENTS.md` and
`supabase/README.md`. No source implementation changes after deployment.
