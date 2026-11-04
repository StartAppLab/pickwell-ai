# T07.1D — Integrated regression and hackathon release gate

Date: 2026-11-04, Asia/Manila. **Release decision: BLOCKED for the hosted release candidate.**

The implementation passes fresh automated/native checks. The hosted database does
**not** contain the C.1/C trust migrations or publication gate, while inference is
enabled. A new trust-protected real-product demo cannot be signed off on that
hosted deployment. No deployment/configuration change was made in this task.
T07.1A UI polish is paused by the owner. T07.2 was not begun.

## 1. Tested revision and scope

Baseline: **`667aa34c01113e4367dbc4c1fc4e88c85fec9edb`**, clean at task start.
Application code, production migrations, credentials and deployed controls are
unchanged. Two native test files were corrected/extended during verification:

- `supabase/tests/analyze_product.test.mjs`
- `supabase/tests/quota_boundary.test.mjs`

SHA-256 of their final `git diff` against that baseline:
`0f7d91e219fb0813098cb1d99f8e65b69a0a2a242380c67550dbd5d2a7203505`.
This identifies the tested source plus test-only patch; it is not a fabricated new
commit. The report/status documentation is an additional uncommitted diff.

Read applicable root/mobile instructions, setup READMEs, current PRD/DESIGN/SPEC/
DATABASE/TASKS/prompts, [T07.1 QA](PICKWELL_END_TO_END_QA.md),
[identity audit](PICKWELL_PRODUCT_IDENTITY_AUDIT.md),
[front packaging](PICKWELL_FRONT_PACKAGING.md) and
[trust implementation](PICKWELL_PRODUCT_TRUST.md). Earlier reported device/live
passes remain historical evidence and do not pass this changed flow automatically.

## 2. Fresh commands and results

| Verification | Actual result |
| --- | --- |
| `fvm flutter analyze --no-pub` in `mobile/` | PASS, no issues |
| `fvm flutter test --no-pub` | **150 passed**, 0 failed |
| `python3 -m unittest discover -s tool -p 'test_*.py'` in `mobile/` | **21 passed**, 0 failed |
| Initial root `env -u PICKWELL_NATIVE_STATUS node --test supabase/tests/*.test.mjs supabase/spikes/meta-vision/*.test.mjs` | **122 passed, 5 skipped**, 0 failed; skips subsequently executed on native |
| Root private sequential runner `node .secrets/t071-backend-suite.mjs` | Final **181 passed, 0 failed, 0 skipped across 15 files**, with a disposable DB reset before each native-mutating suite |
| Final selected native analysis rerun after adding CLI rejection assertions | **31 passed**, 0 failed/skipped; replaces that file's result in the 181-test set, not 31 additional unique tests |
| Native quota suite | **19 passed**, includes 30/31, 3/4, dynamic 20, UTC rollover, reservations, spend/concurrency and exact approved publication |
| New trust SQL fixture suite within Node set | **13 passed** on real isolated PGlite PostgreSQL; native HTTP/Auth/SQL analysis suite also exercises actual PostgreSQL 15 publication/approval boundaries |
| `node .secrets/analysis-native-run.mjs reset` then `test` | PASS: **6 SQL files, 142 pgTAP assertions**; clean migration application, existing template/security/quota/lookup/telemetry checks |
| `fvm flutter build apk --debug --no-pub --dart-define-from-file=.secrets/dev.secrets` | PASS; fresh debug APK, no hardware installation/store-signing claim |
| `python3 tool/check_environment.py --config .secrets/dev.secrets --artifact build/app/outputs/flutter-apk/app-debug.apk` | PASS, repository/public config/APK known-pattern scan |
| Private exact protected-value APK scan | PASS, **674 ZIP entries**, **354,926,021 uncompressed bytes**, 3 known private values checked, zero findings |
| Fresh hosted boundary run | **30 passed**, confirmed existing user-session authorization, public cache lookup, malformed input and direct mutation/read denials; 0 Meta requests |
| Read-only hosted inventory before/after | PASS inspection; provider ledger count **15 → 15**, testing limits unchanged, no stored label objects/candidates at inspection; **new trust gate absent** |
| `git diff --check` | PASS |

Node native suites ran using the existing pinned Supabase CLI **2.122.0 Native
Runtime**, without Docker, in ignored `.secrets/native-validation/`. Only migrations,
SQL tests and synthetic seeds were synchronized there; server credential files were
not copied. Every reset target was verified as native/loopback. Isolated Auth users
and provider responses were synthetic. Operator fixture files were removed after
tests. The temporary native stack is stopped after verification to free memory.

Numbers are command/suite totals and include parent tests; do not add overlapping
reruns or SQL-engine fixture tests twice. The 142 pgTAP assertions are separate from
the Node result count. No current automated test is left failed or skipped in the
final native set. Live three-photo inference, fresh OTP inbox delivery and physical
camera/permission interaction were **not executed**, rather than passed or silently
folded into those totals.

### Initial failures and minimal fixes

The first native run exposed previously skipped stale fixtures, not a reason to
weaken application checks:

1. The mutated ingredients fixture reused the front image's bytes, so duplicate
   image validation correctly returned 400 before the expected digest-conflict
   409. Changed it to different fixture bytes; same-key mutation now reaches and
   tests idempotency rejection.
2. Old finding assertions counted only four nutrient classifications, while C.1's
   fixture also declares wheat. Assertions now explicitly distinguish nutrient
   findings from the legitimate declared-allergen caution.
3. Pending review expiry now correctly reports `review_expired`; the test retained
   the pre-review `candidate_expired` oracle.
4. An old quota fixture directly assembled rows and called the lower published
   finalizer. The approval gate rejected it as designed. The fixture now stages a
   validated three-photo candidate, obtains an exact-bound controlled-demo review,
   and concurrently calls the actual protected publisher; it cannot bypass review.
5. Refresh checks now use an intentionally new fixture reference version and the
   actual current interpretation version. Otherwise the already-current no-op
   never attempted the write/conflict path the old test claimed to exercise.
6. Invalidated-record tests now pass the review gate first and verify correction
   rejection afterwards. Tampered candidate tests deliberately do **not** approve
   the changed candidate; revalidation still rejects it without charging success.

Added a real native approve/cancel/publish race, changed binding/policy denials,
stale approved-candidate rejection and quota settlement checks. The actual operator
CLI runs against disposable REST/SQL for inspection, changed-byte rejection,
no-authority dry run, approval and rejection. No production source/migration fix was
needed for these demonstrated test defects.

## 3. Capture and end-to-end matrix

| Required path | Fresh evidence / status |
| --- | --- |
| Unknown → Front → Nutrition → Ingredients | PASS automated Cubit/widget/parser/adapter checks. All three keys required, distinct bounded bytes, ordered three-image request. No new physical camera session |
| Missing photos / wrong sequence | PASS schema/input rejection and wrong-photo model fixtures. Correct field ordering is tested; no claim that code independently recognizes the semantic content of arbitrary real photos |
| Back, independent retake, auth resume, cancellation | PASS Flutter persistence/submission/OTP/navigation tests; photos preserved across cancellation/restart and owner-account guards tested |
| Camera permission denied / camera cancel | PASS automated error/cancellation fixtures; fresh actual OS dialogs unexecuted |
| Names, brands, variants, sizes conflict despite Muse `consistent` | PASS deterministic review conditions in fixture/SQL tests; not proof of barcode ownership or malicious intent |
| Unreadable / partially readable packaging | PASS malformed/wrong-photo/partial-raw/unknown fixtures and photo-specific retake checks; actual bad-photo inference not executed |
| Cached barcode avoids capture/OTP/Meta | PASS Flutter routing, native mock-provider trace and hosted guest cache; hosted provider ledger unchanged |
| Legacy record compatibility | PASS legacy/synthetic published SQL/public projection and Flutter results; remains unverified, never auto-upgraded to trusted |
| New analysis → private review | PASS native Auth/REST/SQL plus mocked Meta; zero published record before approval |
| Exact eligible approval → results → guest reuse | PASS native actual operator CLI + publisher + guest lookup, one mocked provider invocation and one successful allowance charge |
| Hosted new three-photo flow | **BLOCKED/UNEXECUTED**: C.1/C migrations and gate absent; no approved real three-photo fixture/front photo handoff for this run |
| Fresh Email OTP delivery / physical device E2E | **UNEXECUTED**. Fresh hosted existing-session refresh/verified Auth checks passed. Incorrect/expired OTP and safe resume tested in fixtures; inbox delivery is not proven here |

An iPad is connected and discoverable. Discovery is not a physical-device pass.
No Android phone was detected during this run. The debug APK was built/scanned but
not installed. Historical owner-reported device checks are preserved separately in
T07.1 and do not certify the new review flow.

## 4. Publication and security findings

**Locally verified:** unapproved schema-valid candidates never enter ready cache;
exact approval binds normalized barcode, ordered image digest, canonical candidate
digest and `trust-publication-v1`. Wrong policy/hash/code/candidate is rejected.
The service revalidates and checks approval, and the SQL publisher/lower finalizer
independently enforce it before sealing and consuming one successful credit.
Client fields and model consistency cannot authorize publication. Ordinary SQL
roles cannot inspect/approve/publish. Verified Email OTP identity and ownership are
rechecked server-side; a generic authenticated role is insufficient.

Concurrent real native requests share one provider claim; same-key replay and fresh
keys do not create another published product or reuse someone else's approval.
Approval/cancel/publication races settle to one safe terminal outcome. A stale
approved candidate cannot publish. Rejection/cancellation/known failure/expiry
release allowance and remove private candidates; provider costs remain recorded.
Unknown provider outcomes retain reconciliation protection. Invalidated/current
ready data cannot be silently replaced. Findings/raw support/units/basis/unknowns
and additive immutable revisions pass fresh regression checks.

**Authority limitation:** “direct database publication rejected” describes the
protected RPC/finalizer and ordinary roles, **not** a hostile PostgreSQL owner or
holder of unrestricted service-role credentials. Those trusted operators retain
raw table privileges and could deliberately bypass or disable controls. This is
an explicit privileged-credential boundary, not independent identity verification.
No Accept All or automatic AI-authorized review path was introduced.

Identity observations, review conditions, policy and operator review provenance
survive publication/retrieval/reference refresh. Independent verification remains
`unverified`. Minimal published review bindings persist; private closed unpublished
reviews expire from retention after 30 days. Candidate evidence expires within the
30-minute window; physical removal is dependent on maintenance/admission pruning.
Public projections exclude private hashes/review UUID/contributor email/images.
Legacy records retain uncertainty and unsupported structured ingredients and their
explanations cannot establish confirmed presence from a citation alone. Raw text
consistency is not independent OCR; matching hallucinated raw text remains possible.

Image privacy: server request-local bytes cleared in `finally`, no label uploads or
persistent server image storage. Client retains the approved bounded private
24-hour recoverable drafts pending action, then removes the submitted snapshot on
success/discard/expiry. Native CLI evidence fixtures are deleted after each test.
Hosted Storage had zero objects at inspection; no new live images were uploaded.

## 5. Operator readiness — actual mechanism

The manual CLI is implemented and has now been exercised against real disposable
Auth/REST/PostgreSQL, including approval and rejection. There is **no dashboard**
and no automatic device-to-operator photo transfer.

| Question | Actual behavior |
| --- | --- |
| 1. Becoming pending | Verified user submits three photos; accepted extraction stages private candidate, then gate creates `review_required` |
| 2. Operator sees candidate | Protected `review-product.mjs --list`, then `--inspect REVIEW_UUID --out IGNORED_FILE`; RPC access requires server credentials |
| 3. Available evidence | Candidate facts, raw transcription, per-photo observed identity, discrepancies and exact hashes. No server photos. Operator must obtain exact submitted processed files via private handoff and inspect real barcode/package/reference evidence |
| 4. Approval | Explicit decision/ref/basis/resolution, current barcode/input/candidate/policy binding. CLI recomputes digest of exact three files, dry run first, then `--apply` |
| 5. Rejection | Same protected inspection/binding with `--decision reject --resolution conflict_unresolved --apply`; no false image-match assertion required |
| 6. Becoming public | Approval alone stays private; owner's same-key Check request again revalidates/publishes atomically. No second Muse call |
| 7. Operator does nothing | ≤30-minute logical review expiry; pruning releases the slot and clears candidate. Hosted maintenance exists but new trust-aware pruning is undeployed |
| 8. Safe retry | Same key checks state without new inference. Expired/cancelled request can explicitly start a new persisted key under normal admission; rejected key terminal; unknown provider outcome never blindly retried |
| 9. Accidental wrong approval | Exact mismatched bytes/candidate/code fail, and inspection changes require reinspection. A human can still choose wrong evidence or wrongly judge authenticity; no independent identity guarantee |
| 10. Audit without images | Immutable non-image input/candidate/policy/review reference, basis and timestamp. Current service credential workflow has opaque operator attribution, not individually provisioned reviewer identities |

### Exact safe manual workflow

Use the existing **server-only** environment; never paste/export credentials into
Flutter, Git, command arguments or public reports. These commands are instructions
for an authorized target; no hosted approval was executed here:

```sh
node supabase/scripts/review-product.mjs --list
node supabase/scripts/review-product.mjs --inspect REVIEW_UUID --out .secrets/review.json
node supabase/scripts/review-product.mjs --review-file .secrets/review.json --decision approve --ref hackathon-review-001 --basis package_barcode_evidence --resolution no_discrepancy --evidence-manifest .secrets/evidence.json
```

The third command is a **dry run**. Only after inspecting package/barcode and exact
processed front/nutrition/ingredients files, repeat it with `--apply`. The ignored
manifest contains normalized 14-digit `barcode` and `front`, `nutrition`,
`ingredients` file paths; filenames are relative to that manifest. Recompression or
an original camera file different from the submitted processed bytes will fail.
Inspect output is private 0600. Delete private evidence copies when review ends.
`wording_variation_reviewed` is for a resolved wording discrepancy, not permission
to approve real contradictory products. Missing evidence means reject or expire.

```sh
node supabase/scripts/review-product.mjs --review-file .secrets/review.json --decision reject --ref hackathon-reject-001 --basis package_barcode_evidence --resolution conflict_unresolved --apply
```

The detailed operational contract remains [Product Trust](PICKWELL_PRODUCT_TRUST.md).
It is not currently possible to approve an ordinary phone capture using only the
stored candidate: **exact processed photos must first be handed over privately**.
That requirement is separate from the cloud deployment blocker.

### Smallest future console (not implemented)

A protected operator session, pending queue with expiry, candidate/identity/conflict
viewer, explicit exact-evidence matching and approve/reject controls using the same
backend binding, plus non-image audit history. If photos are transported for review,
that needs justified short-lived private handling and deletion, never permanent
retention. No service key in a browser, Accept All, model authority or arbitrary
identity-policy bypass. A console is optional; a tested manual workflow suffices
for a controlled demo when evidence is available.

## 6. Actual hosted model/configuration and remaining blockers

Fresh read-only inventory confirms:

- Model: **`muse-spark-1.3`**. Repository adapter endpoint:
  **`https://api.meta.ai/v1/chat/completions`**; server-side POST, three ordered image
  parts, strict JSON schema `label_analysis_v3` (prompt `label-analysis-v3`), 4,096 max completion tokens,
  minimal reasoning, `store=false`, `stream=false`, 30-second provider timeout.
  Mock adapter tests assert the contract; live model access/accuracy was not retested.
- Inference is currently **enabled**. Billing **false**; no RevenueCat activation.
- Free testing allowances **1,000 barcode / 100 successful analyses/day**. Standard
  production **30/3** passed isolated boundary tests; changing limit to 20 and UTC
  reset also passed. No deployed allowance was silently restored or increased.
- Global provider calls/day **500**, per-user **100**, IP **500**; daily spend ceiling
  **$100**, per-call reserved ceiling **$1.34**, global concurrency **5**. These are
  existing testing controls, not actual measured call prices or a credit balance.
- Hosted migrations stop at **`20261103000900`**. Missing:
  `20261104000100_pickwell_front_packaging.sql` and
  `20261104000200_pickwell_product_trust.sql`. Neither review table nor gate exists.
  Consequently the hosted deployment cannot enforce the new review contract.
- Existing maintenance active every five minutes and telemetry retention daily
  `17 0 * * *`; no temporary scheduler probe was installed in this task.
- Provider rows **15 → 15**, no candidates or Storage objects at inspection. No
  production product records, credentials, limits or inference flags changed.

**Live Muse run: NOT PERFORMED.** Existing local real fixtures have nutrition and
ingredients pairs but no front-package image. The hosted gate is absent and no
secure processed-photo handoff is in place. Do not submit an exploratory real product
through that old hosted publisher merely to obtain a demo; no latency, token usage,
accuracy or live inference cost is claimed. Fixture token/cost values are synthetic.

Minimal unblock sequence (not executed): deploy the two reviewed forward migrations
and compatible analysis/lookup/cancellation handlers together, rebuild/install the
client, verify the gate/maintenance/Auth in the hosted profile, prepare a genuine
three-photo product with exact-byte operator handoff, perform explicit review and
same-key publication, then verify another guest's cache hit and no repeat provider
ledger entry. Re-run affected hosted/device checks before release sign-off. Do not
reset existing data or disable protections to make the demo proceed.

## 7. Demo readiness

| Scenario | Supported now | Setup / limitations |
| --- | --- | --- |
| A. Unknown barcode + three-photo capture | Local client behavior/build demonstrable; automated pass | Fresh physical run/install required; current cloud is not the changed full-flow backend |
| B. Muse Spark real extraction / structured output | Historical real Muse evidence exists; current contract/mock/native pipeline passes | No genuine three-photo inference in this run. New recording requires correct deployment, real front photo and authorized bounded live call; never present fixtures as live |
| C. Contradictory evidence held for review | Native deterministic fixture demonstration works | Hosted trust rollout required for actual hosted recording; label discrepancies are review, not independent identity proof |
| D. Human operator approves eligible candidate | Actual CLI demonstrated against disposable PostgreSQL with generated fixtures | Real product needs private exact-byte handoff and manual barcode/package review; hosted rollout required |
| E. Guest rescan uses approved result with no extra model | Native pass; current hosted older cache also passes | Hosted newly operator-reviewed result requires D first. Old cached product does not prove the new approval flow |
| F. Architecture and validation evidence | Demonstrable now from code, fresh tests, native SQL/CLI and actual report | Clearly label mock provider/controlled-demo fixtures and local versus hosted |

Safest rehearsal: disposable Native Runtime/staging with synthetic non-food fixture
barcodes and mocked provider, explicitly labeled as such. For a genuine product demo,
use a separate authorized staging project, real matching package/barcode/three
photos and proper operator review, without editing live catalog identities. A full
real inference demonstration remains a release evidence gap. No dashboard is needed.

## 8. Release disposition and files

**BLOCKED** for the current hosted release candidate. Local regression is green,
but hosted trust enforcement, a real three-photo review/publication handoff and fresh
changed-flow device validation remain unverified. Remaining poisoning paths include
undeployed cloud gate (current P0), human review error/forged packaging, compromised
privileged DB/service credentials, hallucinated raw transcription and unaudited
legacy associations. Operator review is not independent GTIN verification.

T07.1A can technically resume on the tested local baseline; no automated UI blocker
was observed, but it remains paused per owner direction and must not obscure the
backend release blocker. **T07.2 cannot begin immediately**: resolve the deployment
and demonstrable real workflow gaps and obtain a release disposition first. No UI
polish, admin dashboard, new AI mode, Passport, Comparison or T07.2 work started.

Changed files: the two test files above; this report; current status links in PRD,
DESIGN, SPEC, DATABASE, TASKS and AGENT_PROMPTS; dated cross-link in the T07.1C report.
No application source, production migration, deployment or credential changes.
Working-tree changes remain reviewable and uncommitted; `667aa34` is preserved.

## 2026-11-04 — Later hosted rollout (T07.1D.1)

[Hosted rollout evidence](PICKWELL_HOSTED_TRUST_ROLLOUT.md) supersedes the
missing-deployment caveat in this historical report. Both migrations and compatible
functions are deployed and hosted security checks pass; inference is restored under
unchanged testing limits, billing false. Real three-photo/Muse/device/operator
approval validation was explicitly deferred by the owner. Testing-deployment
decision: PASS WITH LIMITATIONS; no full real-product flow or T07.2 sign-off claimed.
