# T07.1C — Minimum Product Trust Protection

**Date:** 2026-11-04
**Status:** IMPLEMENTED / locally verified; **not deployed, no release sign-off**.
**Baseline:** `1699445` — committed T07.1C.1 front capture/identity implementation.
**Scope:** Minimum safeguards for the [identity audit](PICKWELL_PRODUCT_IDENTITY_AUDIT.md), preserving C.1 infrastructure. T07.1D, UI polish and T07.2 were not begun.

## Baseline and material changes

Before edits, the committed C.1 baseline was clean: 141 catalog Flutter tests passed;
the selected backend set passed 102 with 5 native-service suites skipped. No live
provider call or deployment occurred. Earlier [C.1 results](PICKWELL_FRONT_PACKAGING.md)
and [T07.1 QA](PICKWELL_END_TO_END_QA.md) remain historical evidence, not verification
of this new workflow. C.1's automatic identity-conflict retakes are superseded here
by operator review. Wrong/non-label or wholly unreadable images still fail safely.

A front photo improves observations but cannot prove ownership of the scanned
barcode. A coherent Product B photo set paired with Product A's valid barcode is
now **private pending review**, never automatically shared `ready` data.

## Implemented boundaries

1. The existing authenticated, bounded three-image handler makes one server-only
   Muse request and validates/stages the candidate. No new model/provider was added.
2. `analysis_publication.mjs` calls `publication_review.mjs` after pure revalidation.
   It stops before publication unless the protected SQL gate returns valid current
   bindings and an approved decision. Neither model output nor mobile form fields
   supply approval authority.
3. The additive migration `20261104000200_pickwell_product_trust.sql` adds private
   `product_trust_reviews`, exact-binding inspection/decision/cancel RPCs, a gate in
   `pickwell_publish_analysis`, and an independent check in `pickwell_finish_usage`.
   Both SQL boundaries use the existing transaction lock. The lower finalizer also
   compares the inserted analysis/findings/facts/versions/provenance with the approved
   staged candidate before sealing, publishing and consuming one credit.
4. Binding includes normalized barcode, ordered SHA-256 image input digest,
   PostgreSQL canonical JSONB candidate SHA-256 and `trust-publication-v1`.
   Review bindings are immutable. Approval cannot authorize another digest,
   candidate, barcode or policy. No account/barcode allowlist exists.
5. Existing ready data wins; fresh keys, simultaneous contributors and potential
   reformulations cannot overwrite it. Existing immutable-revision/correction
   controls remain; there is no automatic reformulation acceptance workflow.
6. RLS and revoked ordinary-role grants protect review data and RPCs. Approval is
   a server/operator credential operation. `cancel-analysis-review` is an owner-only
   confirmed-identity handler; `verify_jwt=false` in function config delegates Auth
   verification to that handler, not anonymous authorization. It also throttles
   user/network activity, bounds JSON and rejects extra authority fields.

## States, settlement and privacy

| State/outcome | Public visibility / recovery | Allowance and retention |
| --- | --- | --- |
| Extracting/provider processing | Existing processing status; no ready product | Existing reservation, timeout/reconciliation protections |
| `review_required` | Owner sees pending notice, expiry, Check request again and Cancel review; other users see processing without owner job | Candidate/review lease ≤30 minutes; one AI slot reserved, none consumed |
| Approved | Still private until owner's same-key check revalidates/publishes | Approval expires with same window; no extra model call |
| Published | Sanitized guest cache result; replay/cache never invokes Muse | One successful credit; terminal job removes candidate and client success deletes draft |
| Rejected | Safe terminal rejected response for same key; no automatic retry | Reservation released, candidate removed; provider spend retained |
| Cancelled | Owner-only cancellation; photos kept locally for deliberate new request | Reservation released, candidate removed; new persisted key |
| Expired/policy changed | Explicit new request permitted; no blind repeat inference | Candidate removed and successful-provider hold released by prune |
| Provider outcome unknown | Existing nonretryable reconciliation state | Never pretend provider finished or release blindly |

Pruning runs on existing admission/review calls and through the existing maintenance
mechanism. The 30-minute bound is logical expiry; physical removal depends on the
maintenance schedule/admission execution. Verify scheduler health at rollout.
Closed rejected/cancelled/expired review rows are pruned after 30 days. Published
bindings remain minimal non-image audit provenance. No raw images or Auth secrets
are stored in review rows or analysis RPC payloads. Provider spending remains in
the existing separate server-only ledger even when allowance is released.

The client retains its existing bounded private 24-hour recoverable drafts pending
review or cancellation, and deletes the submitted snapshot after confirmed ready.
This preserves current owner-approved recovery behavior; server image bytes remain
request-local and are cleared in `finally`. Approval does not create a permanent
photo archive or automatic image upload to the operator.

## Identity and ingredient integrity

Deterministic identity checks compare observed name, brand, variant and net quantity
across front/nutrition/ingredients even if Muse reports `consistent`. Clear
contradictions and model mismatch observations become **review conditions**;
abbreviations, partial/bilingual text and missing fields do not establish malicious
intent. Equivalent amounts and extended brand wording remain supported. Different
wording may be flagged conservatively for human resolution, not whole-photo retake.
Unknown identity stays unknown and never self-approves.

Non-image provenance retains observed identities, cross-image consistency and
review-photo targets. Separate fields document schema validation, raw ingredient
matching and trust policy. After publication, `barcode_association` says
`operator_reviewed` / `operator_evidence_review`, including opaque review reference,
basis, policy and server timestamp. `identity_verification` remains **unverified**
for independent barcode ownership. No confidence percentage, trust score or verified
badge is generated. Public projection excludes private review UUID, image/input
hash, contributor identifiers and email. Interpretation refresh preserves original
trust/identity provenance and cannot replace it using supplied refresh fields.
Legacy results remain unverified; there is no silent approval backfill.

`ingredient_evidence.mjs` cross-checks structured ingredient items with raw
transcription using normalized punctuation/accents, narrow spelling/plural tolerance
and a small explicit bilingual alias set. Unsupported items are removed and
interpretation indices remapped; explanations independently require raw support.
Absence phrases such as “no sugar” or “sugar-free” cannot confirm Sugar. Reference
citations alone cannot confirm presence. Partial readable raw text survives, even
when the confirmed structured array is empty; no fake ingredient is created to fill
it. Public legacy projections suppress unsupported ingredient assertions and their
summary instead of certifying them. This is transcription consistency, **not an
independent second OCR pass**. A hallucinated raw transcription can still agree
with a hallucinated structured item; operator evidence review remains necessary.

## Protected operator procedure

Use a protected server shell with `SUPABASE_URL` and
`SUPABASE_SERVICE_ROLE_KEY` already supplied through the existing ignored server
environment. Never put values in command arguments, Flutter, Git, logs or chat.
The CLI makes database RPCs only; it never invokes a model. No approval endpoint is
exposed to ordinary users. All examples below are instructions, **not executed live**.

```sh
node supabase/scripts/review-product.mjs --list
node supabase/scripts/review-product.mjs --inspect REVIEW_UUID --out .secrets/product-review.json
```

Inspection writes a Git-ignored private 0600 JSON file with candidate facts and
bindings, excluding contributor email/photos/tokens. Inspect it privately. Obtain
all **three exact processed files actually submitted**, through a deliberate private
handoff from the device/operator. A different crop, recompression or original camera
file will not match. The current app does not export these files automatically;
if they are unavailable, **do not approve**. Reject or allow expiry. This is a
restricted publication workflow, not unattended production moderation.

Compare the physical package/barcode and the front/label identities against those
files or a genuinely trusted product reference. Compare variant/net quantity,
contradictions, extracted facts and unsupported claims. Merely seeing consistent
text or a known barcode is insufficient. A copied/forged barcode cannot be ruled
out by this manual process alone. Reject unresolved contradictions.

Create a Git-ignored `.secrets/product-evidence.json` with a normalized 14-digit
`barcode` plus `front`, `nutrition`, `ingredients` local file paths (relative to this
manifest or absolute). Each file must also be Git-ignored and satisfy existing
image/MIME/dimension/size checks. The CLI recomputes the exact input digest, checks
current candidate/policy/expiry and defaults to dry run:

```sh
node supabase/scripts/review-product.mjs --review-file .secrets/product-review.json --decision approve --ref hackathon-review-001 --basis package_barcode_evidence --resolution no_discrepancy --evidence-manifest .secrets/product-evidence.json
```

Only after a real review, repeat with `--apply`. Allowed bases are
`package_barcode_evidence`, `trusted_product_reference`, `controlled_demo_evidence`;
never mislabel synthetic evidence as independently verified. A flagged wording
variation needs explicit `wording_variation_reviewed`; an actual unresolved conflict
must be rejected. Use an opaque reference (8–100 safe characters), not an email,
JWT, free-form private note or image URL. Reference the controlled private review
record outside public product data if more explanation is needed.

```sh
node supabase/scripts/review-product.mjs --review-file .secrets/product-review.json --decision reject --ref hackathon-reject-001 --basis package_barcode_evidence --resolution conflict_unresolved
```

Rejection is also dry run unless `--apply`; it requires the exact current candidate
binding but no false evidence-match assertion. On approval, ask the owner to use
**Check request again** before expiry. It publishes transactionally with no second
Muse call. Inspection changes require a fresh inspection/review. Exact repeated
SQL decisions are idempotent; different decisions or evidence do not reuse approval.

## Validation observed

Uses the existing pinned `@electric-sql/pglite@0.3.14` test installation under ignored `.secrets/sql-test/`; setup command is documented in [catalog foundation](PICKWELL_CATALOG_FOUNDATION.md). No new application package was introduced.

All automated provider responses were mocked/non-sensitive fixtures. No live Meta
call, cloud query/mutation, deployment, email, quota change or production-data edit.

| Command / check | Observed outcome |
| --- | --- |
| `env -u PICKWELL_NATIVE_STATUS node --test supabase/tests/*.test.mjs` | **111 passed, 0 failed, 5 skipped**; includes real isolated PostgreSQL checks |
| New `product_trust.test.mjs` within that run | 12 subtests + parent = **13 passed** on PGlite PostgreSQL 17.5 with all versioned migrations; not Supabase target PostgreSQL 15/native multi-connection validation |
| New `trust_services.test.mjs` within that run | **7 passed**: real handler/mock provider/DB boundary, review, ingredient and cancel/operator checks |
| `fvm flutter test --no-pub test/catalog` | **146 passed**, including four review state/recovery tests and one review notice widget test; subsequent SDK suite **3 passed** adds one unique cancellation boundary test (147 unique catalog tests across the runs) |
| `fvm flutter analyze --no-pub lib/src/features/catalog test/catalog` | No issues found |
| `python3 tool/check_environment.py` from `mobile/` | Known-secret scan passed on tracked/nonignored files; not history or arbitrary secret formats |
| `node --check supabase/scripts/review-product.mjs`, changed native test syntax | Passed |
| `git diff --check` | Passed |

The five skipped suites require a running disposable Native Runtime. Their absence
is explicit, not a passing hosted/auth/race result. The native analysis suite's
positive-publication fixtures now make explicit operator decisions rather than
bypassing this gate; those native paths were **not executed** here. Initial SDK cancellation fixture left backend disabled; corrected its fixture configuration and the 3-test SDK run passed. One initial new
widget test used an outdated expected button label; corrected to localized current
“Check request again” and the final catalog run passed. The SQL cancellation test
caught an illegal terminal-job metadata update; that update was removed without
weakening terminal immutability, and all isolated SQL tests passed.

### Required scenario mapping

| Requested scenario | Permanent evidence / result |
| --- | --- |
| 1 A barcode/B photos | `trust_services` one model call, private review on replay; `product_trust` no ready record without approval |
| 2 Cross-image mismatch | `front_packaging`, `trust_services`, SQL review resolution tests |
| 3 Name contradiction despite consistent | Same suites: review required, no blanket retake |
| 4 Missing/uncertain identity | SQL pending/rejected with zero used credit |
| 5 Valid three-photo flow | Parser/hash/handler fixtures, Flutter catalog tests, exact approved SQL publication |
| 6 Unauthorized publication | Actual isolated anon/authenticated role denials, ACL checks, lower-finalizer bypass rejection; guest handler rejection |
| 7 Changed input digest | Exact decision rejects different hash; multipart mutation rejected by existing input binding |
| 8 Different candidate/revision | Decision and finalizer mismatch checks, immutable binding test |
| 9 Concurrent approved/unapproved | Promise-based isolated SQL interleavings, one outcome; PGlite serializes calls, so genuine multi-connection race verification remains unverified |
| 10 Replay/fresh key | One model on same key, exact decision replay, fresh other-user key shares existing work; no approval reuse |
| 11 Existing ready conflict | SQL existing ready wins and public cache preserved |
| 12 Formulation change | Same immutable-record safeguard; no unverified automatic replacement |
| 13 Unsupported ingredient | Normalization/remapping/explanation and legacy projection tests; absence phrase check |
| 14 Guest reuse | Handler cached retry zero extra model call; isolated sanitized public projection and existing get-product tests |
| 15 Quota/cleanup | SQL rejection/cancel/expiry release + candidate removal, provider ledger retention; Flutter pending retention/ready cleanup |
| 16 Legacy compatibility | Isolated synthetic legacy row remains readable/unverified; reference refresh preserves identity/trust, existing Flutter result tests |

## Required rollout and residual risks

Do not claim these changes protect the current hosted deployment yet. Apply the
forward migration **after C.1's `20261104000100`**, then deploy updated shared
`analyze-product` and `get-product` dependencies plus the new
`cancel-analysis-review` function, and rebuild the client/localizations. Deploying
only SQL safely blocks auto-publication but an old client cannot explain pending
review. Confirm owner-only status, maintenance scheduling, private inspection,
exact-photo handoff and protected operator credential access in the target profile.
No new secret type or model setting is required; use existing protected server
credentials. Do not expose operator credentials in app or distribute service keys
for review access. Keep billing false, RevenueCat deferred and owner-approved
1000/100 testing allowances unchanged.

Remaining risks and unverified limits:

- **Raw privileged DB/service access remains trusted.** A compromised administrator
  can directly edit tables, call operator RPCs, disable triggers or lie about review.
  Ordinary client/model authority is blocked; this is not protection against the DB
  owner. No dedicated operator-role provisioning or full moderation platform added.
- Humans can approve wrong/forged packaging or misread OCR. No trusted global GTIN
  catalog, independent verification, authenticity guarantee, confidence score,
  barcode-reuse adjudication or dispute workflow was invented. T08.3 owns broader
  design. Unresolved evidence must remain unpublished.
- The app does not hand the operator exact processed photos. A secure manual handoff
  is necessary for real approvals. Without it, the restricted default blocks new
  shared publication; existing guest cache reads still work.
- Existing published records were not re-audited or invalidated. Legacy projections
  disclose uncertainty and filter unsupported ingredient assertions, but this does
  not retrospectively prove identity or raw-text accuracy.
- The intentionally narrow ingredient matcher can omit legitimate translations or
  synonyms, and conservative absence checks can omit mixed statements. Raw text is
  retained; no blanket retake or assertion of absence is generated.
- Review holds reserve an allowance until expiry/cancellation. Verify real scheduler,
  hosted session recovery and PostgreSQL 15 behavior. Real multi-connection races,
  approval/cancel/publish races under hosted load and fresh device UI remain
  unverified here. No live provider/image accuracy claim is made.
- SQL publisher/finalizer and review lifecycle are security-sensitive changes.
  Their exact matching intentionally fails closed on validator/policy drift; drain
  pending old candidates or let them expire rather than reusing old approval.

**Release disposition:** Critical uncontrolled publication is locally mitigated by
restricted evidence-bound review. Hosted/device rollout and release acceptance
remain unverified; **T07.1D remains NOT STARTED**. No T08 work, UI polish or T07.2
started. Implementation was verified against baseline `1699445`; subsequent commit history records the commit of this change set.

## Exact changed-file manifest

Working-tree files for this task (including generated localization output); no secret files or photos included.

- `docs/PICKWELL_AGENT_PROMPTS.md`
- `docs/PICKWELL_DATABASE.md`
- `docs/PICKWELL_DESIGN.md`
- `docs/PICKWELL_PRD.md`
- `docs/PICKWELL_PRODUCT_TRUST.md`
- `docs/PICKWELL_SPEC.md`
- `docs/PICKWELL_TASKS.md`
- `mobile/AGENTS.md`
- `mobile/lib/src/features/catalog/data/data_sources/services/analysis_api_service.dart`
- `mobile/lib/src/features/catalog/data/models/analysis_model.dart`
- `mobile/lib/src/features/catalog/data/repositories/analysis_repository.dart`
- `mobile/lib/src/features/catalog/domain/entities/analysis_entity.dart`
- `mobile/lib/src/features/catalog/domain/repositories/analysis_repository.dart`
- `mobile/lib/src/features/catalog/domain/use_cases/analyze_product_use_case.dart`
- `mobile/lib/src/features/catalog/presentation/blocs/catalog/analysis_submission_cubit.dart`
- `mobile/lib/src/features/catalog/presentation/views/capture_entry_view.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/analysis_submission_notice.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/product_result_content.dart`
- `mobile/lib/src/localization/l10n/app_ar.arb`
- `mobile/lib/src/localization/l10n/app_de.arb`
- `mobile/lib/src/localization/l10n/app_en.arb`
- `mobile/lib/src/localization/l10n/app_es.arb`
- `mobile/lib/src/localization/l10n/app_fr.arb`
- `mobile/lib/src/localization/l10n/app_hi.arb`
- `mobile/lib/src/localization/l10n/app_it.arb`
- `mobile/lib/src/localization/l10n/app_ja.arb`
- `mobile/lib/src/localization/l10n/app_ko.arb`
- `mobile/lib/src/localization/l10n/app_localizations.dart`
- `mobile/lib/src/localization/l10n/app_localizations_ar.dart`
- `mobile/lib/src/localization/l10n/app_localizations_de.dart`
- `mobile/lib/src/localization/l10n/app_localizations_en.dart`
- `mobile/lib/src/localization/l10n/app_localizations_es.dart`
- `mobile/lib/src/localization/l10n/app_localizations_fr.dart`
- `mobile/lib/src/localization/l10n/app_localizations_hi.dart`
- `mobile/lib/src/localization/l10n/app_localizations_it.dart`
- `mobile/lib/src/localization/l10n/app_localizations_ja.dart`
- `mobile/lib/src/localization/l10n/app_localizations_ko.dart`
- `mobile/lib/src/localization/l10n/app_localizations_pt.dart`
- `mobile/lib/src/localization/l10n/app_localizations_ru.dart`
- `mobile/lib/src/localization/l10n/app_localizations_zh.dart`
- `mobile/lib/src/localization/l10n/app_pt.arb`
- `mobile/lib/src/localization/l10n/app_ru.arb`
- `mobile/lib/src/localization/l10n/app_zh.arb`
- `mobile/test/catalog/analysis_fixtures.dart`
- `mobile/test/catalog/analysis_sdk_test.dart`
- `mobile/test/catalog/analysis_submission_test.dart`
- `mobile/test/catalog/product_results_test.dart`
- `supabase/README.md`
- `supabase/config.toml`
- `supabase/functions/_shared/analysis_publication.mjs`
- `supabase/functions/_shared/analysis_validation.mjs`
- `supabase/functions/_shared/analyze_product.mjs`
- `supabase/functions/_shared/cancel_analysis_review.mjs`
- `supabase/functions/_shared/catalog_boundary.mjs`
- `supabase/functions/_shared/ingredient_evidence.mjs`
- `supabase/functions/_shared/interpretation.mjs`
- `supabase/functions/_shared/product_identity.mjs`
- `supabase/functions/_shared/publication_review.mjs`
- `supabase/functions/cancel-analysis-review/index.ts`
- `supabase/migrations/20261104000200_pickwell_product_trust.sql`
- `supabase/scripts/review-product.mjs`
- `supabase/tests/analysis_validation.test.mjs`
- `supabase/tests/analyze_product.test.mjs`
- `supabase/tests/catalog_schema.test.mjs`
- `supabase/tests/front_packaging.test.mjs`
- `supabase/tests/product_trust.test.mjs`
- `supabase/tests/trust_services.test.mjs`

## 2026-11-04 — Later T07.1D verification

The [fresh release-gate report](PICKWELL_RELEASE_GATE.md) supersedes this report's
unverified native/CLI test caveats: disposable PostgreSQL 15 Auth/REST, concurrent
publication/decision checks and actual operator CLI approval/rejection now pass.
Hosted rollout is still absent and the release decision is BLOCKED; no new live
three-photo inference or physical-device review handoff was performed. Historical
results above remain unchanged.

## 2026-11-04 — Later hosted rollout (T07.1D.1)

[Hosted rollout evidence](PICKWELL_HOSTED_TRUST_ROLLOUT.md) supersedes the
missing-deployment caveat in this historical report. Both migrations and compatible
functions are deployed and hosted security checks pass; inference is restored under
unchanged testing limits, billing false. Real three-photo/Muse/device/operator
approval validation was explicitly deferred by the owner. Testing-deployment
decision: PASS WITH LIMITATIONS; no full real-product flow or T07.2 sign-off claimed.

## 2026-11-04 — Approved thumbnail derivative exception (T07.1A.1, local only)

[Product Thumbnails](PICKWELL_PRODUCT_THUMBNAILS.md) permits an optional optimized
front derivative **after published operator review**, tied to exact original
three-image hashes and candidate/review. This intentionally retained public package
media is distinct from temporary evidence photos; raw/nutrition/ingredient photos
remain nonpublic. No new publication authority or pending-review upload is added.
Keep private operator evidence through derivative attachment, then delete copies.
This feature is not deployed by its implementation task.

## T07.1C.3 local follow-up (not deployed)

[Immediate private results](PICKWELL_PRIVATE_RESULTS.md) now separate successful
owner analysis from shared publication. A private-ready result consumes one
credit; cancellation/rejection/review expiry does not refund it, and publication
never double charges. Private payload survives review closure up to 24h, with
owner-bound local draft references/preview. This supersedes earlier hidden-result
and refund wording for the new local path only. Shared thumbnail eligibility,
exact processed evidence, review bindings and immutable canonical data remain
unchanged. No extra public image source, automatic approval or hosted rollout.
