# T07.1C.1 — Front Packaging Capture & Identity Extraction

**Date:** 2026-11-04 (Asia/Manila)

**Status:** Implemented and verified locally against baseline `ab2e956`. Implementation and this report are committed together. No hosted migration/deployment, live Muse call or fresh device test in this task. T07.1B findings are preserved; T07.1C operator publication controls and T07.1D release sign-off remain pending.

## Capture and recovery

Known barcode → existing guest `get-product` cache path, no front photo/OTP/model call.

Unknown barcode → Barcode ✓ already captured → **Step 1 Front packaging → Step 2 Nutrition → Step 3 Ingredients** → review/independent retake → contextual verified Email OTP → one authenticated three-image analysis → results, affected-photo retake or existing safe error/retry state.

Submission is disabled until all three photos exist. Front capture uses the same camera/permission, JPEG/PNG validation, compression and app-private file handling as the labels. Retaking front leaves both labels intact and renews the request key. Back navigation, OTP cancellation/return and restart preserve all three through the app-owned draft queue. All three participate in expiry, deletion, successful submission and stale-result cleanup; a late success cannot delete a newer front retake.

Pending manifests now write version 2 and read 1/2. Legacy two-photo drafts keep their labels but require front capture before submitting; the new front renews their key. Queue remains five drafts/24 hours, up to three 5 MiB photos per draft; no product-card photo retention or new cloud Storage. The existing next-process orphan sweep applies to front photos too.

## Input/model contract

`analyze-product` accepts exactly `barcode`, `idempotency_key`, `front_image`, `nutrition_image`, `ingredients_image`. Each image uses the existing byte-signature/structure/dimension checks: <=5 MiB, <=2400 pixels per dimension and <=2400² pixels. The bounded multipart stream now allows <=15 MiB +64 KiB; all three image byte hashes must differ. The ordered server digest includes canonical barcode plus front, nutrition and ingredient hashes. Missing/malformed/duplicate front input fails before provider admission.

The existing server-only `muse-spark-1.3` request to `https://api.meta.ai/v1/chat/completions` now includes front, nutrition, ingredients in that order and does not assume the pictures belong to one product. It remains one call with a 30-second timeout, 4096 completion-token cap and `store=false`. The response/prompt is `label_analysis_v3` / `label-analysis-v3`. Existing auth, rates, quota reservations, concurrency/spend ceilings, one-call idempotency and exactly-once successful-analysis settlement are reused. Three photos do not become three credits.

No live three-image access, runtime payload envelope, actual latency, usage or costs were measured. The extra image adds potential provider input cost; configured ceilings were not increased or bypassed. Existing historical two-image live/spike evidence remains valid only for its original scope. The protected diagnostic spike explicitly retains its legacy v2/two-image profile and truthful two-photo provenance; new analysis submissions cannot use that profile to omit front.

## Identity and uncertainty

Structured per-image `identity.front`, `identity.nutrition`, `identity.ingredients` observations contain nullable `product_name`, `brand`, `variant`, `net_quantity`. Fields must be visible, never inferred from another photo; package quantity is distinct from serving size and consumer brand from manufacturer/distributor. Missing/unreadable names may remain null; an advisory name-readability retake alone does not reject useful data. An explicit wrong-photo response remains actionable.

Identity also includes `consistency`, `food_form` and bounded `{field, photos}` conflicts. Explicit conflicts cannot be canceled by a `consistent` enum. Conservative deterministic brand/variant comparisons and simple comparable g/kg/mg or ml/l quantities flag differences for the relevant photo pair. Case, accents, basic punctuation, extended brand wording and equivalent simple quantities do not by themselves conflict. Product-name semantics, translations, company roles, complex multipacks and identity aliases cannot be exhaustively decided by these checks; no general semantic identity verification is claimed.

Detected contradictions return exact front/label retake subsets with safe diagnostic enums, and do not reach new publication or spend a successful-analysis credit. Nutrition/ingredient OCR, unknown amounts, unit support and deterministic nutrition rules remain intact. Historical v2 results remain readable and accepted v2 staged candidates retain a legacy revalidation path.

New records use front-observed name/brand. Existing Details also displays available variant/net quantity and a color-independent ownership limitation. Public provenance retains allowlisted non-image observations with `identity_verification=unverified` and `identity_policy_version=front-observations-v1`. Matching photos/names and schema validity do not independently prove barcode ownership. No confidence score or user-supplied verified flag exists.

## Required database migration and rollout

`supabase/migrations/20261104000100_pickwell_front_packaging.sql` is necessary. It adds no table or image column and makes no config/billing change. It:

- Extends existing retake constraints and diagnostic/settlement RPCs to front and exact front/label subsets.
- Supports v2/v3 publication, checks v3 nonconflicting/unverified identity metadata, and retains observations in existing JSON provenance (bounded allowance 4 → 8 KiB).
- Uses front name/brand only when creating a new product; existing published records retain cache/overwrite protections.
- Preserves identity during immutable interpretation refresh and refuses to inherit new verification authority from the refresh payload.
- Restates service-only execution; RLS/client write grants and atomic publication/credit controls remain.

The complete migration chain applied cleanly and replayed through the isolated migration runner with sentinel data preserved. PostgreSQL-engine tests exercised actual publication, identity persistence, front-only retake, credit release, replay and guest cache retrieval. The isolated engine is PGlite PostgreSQL 17.5; fresh Supabase PostgreSQL 15/native and hosted checks remain unverified.

Before using the new client against the cloud: apply the forward migration, deploy the updated analysis/read handlers with their shared modules, then distribute/rebuild the updated Flutter client. Old two-file unknown-product submissions safely fail the new input contract; ordinary guest lookup and old results stay compatible. The current cloud was not modified. Hosted request-size/provider/spend checks and physical front capture belong to authorized follow-up validation; do not infer deployment readiness from mocks.

## Commands and observed results

| Command/check | Observed result |
| --- | --- |
| `fvm flutter gen-l10n` from `mobile/` | PASS. All six new keys supplied for all 12 locales; six pre-existing untranslated keys per non-English locale remain unchanged. No new untranslated keys introduced. |
| `fvm dart format` on touched catalog source/tests | PASS. |
| `fvm flutter test --no-pub test/catalog` | **141 passed, 0 failed** in the final run. Includes full capture, missing front, front retake, back/OTP/restart, real disk legacy recovery, native SDK multipart boundary, delayed cleanup, result identity and existing lookup/results/usage UI regressions. |
| `fvm flutter analyze --no-pub` | PASS; no issues. |
| Root Node test run: `front_packaging`, `analysis_validation`, `interpretation`, `analysis_authorization`, `analysis_quota_response`, `retake_details`, `quota_boundary`, `operational_events`, `security_boundary`, `get_product`, `analyze_product`, spike `core`, `catalog_schema` | **102 passed, 0 failed, 5 skipped**. Five native-service cases deliberately not run without a native stack; no claim of fresh hosted/native parallel execution. |
| Root: `node --test supabase/tests/front_packaging.test.mjs supabase/tests/analysis_validation.test.mjs` after the final accent-handling refinement | **44 passed, 0 failed, 0 skipped**. These overlap the backend total. |
| Root: `node --test supabase/tests/catalog_schema.test.mjs` | **10 passed**, including clean migration/replay/data preservation and new actual SQL publication/identity/one-credit/replay/front-retake tests; 46 expected SQL rejection checks across the suite. Included in backend total. |
| Root: `python3 mobile/tool/check_environment.py` | PASS; known-secret patterns in tracked/nonignored content, not full Git history or a rebuilt artifact scan. |
| `git diff --check`, document link/source-contract checks | PASS after final review. |

During implementation, old two-photo test setups, a required front constructor argument and the result test's ambiguous scrollable selector failed; they were corrected. No failures remain in the final targeted runs. No live provider call, new token/cost measurement, device installation, full-project release regression or deployment is claimed.

## Remaining T07.1C / T07.1D work

A contributor can still scan A and photograph B's front plus both B labels. Model-observed consistency and a front photo alone cannot prevent this. The current publication policy remains as explicitly requested; this task does **not** implement the operator approval gate or make unrestricted public contributions safe. T07.1C must enforce evidence-bound shared publication, address remaining audited unsupported-ingredient attribution/provenance/correction concerns, and review legacy trust status without retroactively certifying records. T07.1D must test affected live/device/security/race and deployment behavior before release. T06.3 remains deferred and billing disabled. No Comparison, Passport, assistant, unrelated UI polish or T07.2 work was started.

## Exact modified files

Includes generated localization outputs and this report; source and generated files are listed explicitly. Baseline is `ab2e956`; see this file’s Git history for the implementation commit.

- [docs/PICKWELL_AGENT_PROMPTS.md](../docs/PICKWELL_AGENT_PROMPTS.md)
- [docs/PICKWELL_DATABASE.md](../docs/PICKWELL_DATABASE.md)
- [docs/PICKWELL_DESIGN.md](../docs/PICKWELL_DESIGN.md)
- [docs/PICKWELL_FRONT_PACKAGING.md](../docs/PICKWELL_FRONT_PACKAGING.md)
- [docs/PICKWELL_PRD.md](../docs/PICKWELL_PRD.md)
- [docs/PICKWELL_SPEC.md](../docs/PICKWELL_SPEC.md)
- [docs/PICKWELL_TASKS.md](../docs/PICKWELL_TASKS.md)
- [mobile/AGENTS.md](../mobile/AGENTS.md)
- [mobile/lib/src/features/catalog/data/data_sources/services/analysis_api_service.dart](../mobile/lib/src/features/catalog/data/data_sources/services/analysis_api_service.dart)
- [mobile/lib/src/features/catalog/data/models/analysis_model.dart](../mobile/lib/src/features/catalog/data/models/analysis_model.dart)
- [mobile/lib/src/features/catalog/data/repositories/pending_capture_repository.dart](../mobile/lib/src/features/catalog/data/repositories/pending_capture_repository.dart)
- [mobile/lib/src/features/catalog/domain/entities/analysis_entity.dart](../mobile/lib/src/features/catalog/domain/entities/analysis_entity.dart)
- [mobile/lib/src/features/catalog/domain/entities/label_photo.dart](../mobile/lib/src/features/catalog/domain/entities/label_photo.dart)
- [mobile/lib/src/features/catalog/domain/entities/pending_capture.dart](../mobile/lib/src/features/catalog/domain/entities/pending_capture.dart)
- [mobile/lib/src/features/catalog/presentation/blocs/catalog/analysis_submission_cubit.dart](../mobile/lib/src/features/catalog/presentation/blocs/catalog/analysis_submission_cubit.dart)
- [mobile/lib/src/features/catalog/presentation/blocs/catalog/label_capture_cubit.dart](../mobile/lib/src/features/catalog/presentation/blocs/catalog/label_capture_cubit.dart)
- [mobile/lib/src/features/catalog/presentation/views/capture_entry_view.dart](../mobile/lib/src/features/catalog/presentation/views/capture_entry_view.dart)
- [mobile/lib/src/features/catalog/presentation/widgets/analysis_submission_notice.dart](../mobile/lib/src/features/catalog/presentation/widgets/analysis_submission_notice.dart)
- [mobile/lib/src/features/catalog/presentation/widgets/label_photo_card.dart](../mobile/lib/src/features/catalog/presentation/widgets/label_photo_card.dart)
- [mobile/lib/src/features/catalog/presentation/widgets/product_result_content.dart](../mobile/lib/src/features/catalog/presentation/widgets/product_result_content.dart)
- [mobile/lib/src/localization/l10n/app_ar.arb](../mobile/lib/src/localization/l10n/app_ar.arb)
- [mobile/lib/src/localization/l10n/app_de.arb](../mobile/lib/src/localization/l10n/app_de.arb)
- [mobile/lib/src/localization/l10n/app_en.arb](../mobile/lib/src/localization/l10n/app_en.arb)
- [mobile/lib/src/localization/l10n/app_es.arb](../mobile/lib/src/localization/l10n/app_es.arb)
- [mobile/lib/src/localization/l10n/app_fr.arb](../mobile/lib/src/localization/l10n/app_fr.arb)
- [mobile/lib/src/localization/l10n/app_hi.arb](../mobile/lib/src/localization/l10n/app_hi.arb)
- [mobile/lib/src/localization/l10n/app_it.arb](../mobile/lib/src/localization/l10n/app_it.arb)
- [mobile/lib/src/localization/l10n/app_ja.arb](../mobile/lib/src/localization/l10n/app_ja.arb)
- [mobile/lib/src/localization/l10n/app_ko.arb](../mobile/lib/src/localization/l10n/app_ko.arb)
- [mobile/lib/src/localization/l10n/app_localizations.dart](../mobile/lib/src/localization/l10n/app_localizations.dart)
- [mobile/lib/src/localization/l10n/app_localizations_ar.dart](../mobile/lib/src/localization/l10n/app_localizations_ar.dart)
- [mobile/lib/src/localization/l10n/app_localizations_de.dart](../mobile/lib/src/localization/l10n/app_localizations_de.dart)
- [mobile/lib/src/localization/l10n/app_localizations_en.dart](../mobile/lib/src/localization/l10n/app_localizations_en.dart)
- [mobile/lib/src/localization/l10n/app_localizations_es.dart](../mobile/lib/src/localization/l10n/app_localizations_es.dart)
- [mobile/lib/src/localization/l10n/app_localizations_fr.dart](../mobile/lib/src/localization/l10n/app_localizations_fr.dart)
- [mobile/lib/src/localization/l10n/app_localizations_hi.dart](../mobile/lib/src/localization/l10n/app_localizations_hi.dart)
- [mobile/lib/src/localization/l10n/app_localizations_it.dart](../mobile/lib/src/localization/l10n/app_localizations_it.dart)
- [mobile/lib/src/localization/l10n/app_localizations_ja.dart](../mobile/lib/src/localization/l10n/app_localizations_ja.dart)
- [mobile/lib/src/localization/l10n/app_localizations_ko.dart](../mobile/lib/src/localization/l10n/app_localizations_ko.dart)
- [mobile/lib/src/localization/l10n/app_localizations_pt.dart](../mobile/lib/src/localization/l10n/app_localizations_pt.dart)
- [mobile/lib/src/localization/l10n/app_localizations_ru.dart](../mobile/lib/src/localization/l10n/app_localizations_ru.dart)
- [mobile/lib/src/localization/l10n/app_localizations_zh.dart](../mobile/lib/src/localization/l10n/app_localizations_zh.dart)
- [mobile/lib/src/localization/l10n/app_pt.arb](../mobile/lib/src/localization/l10n/app_pt.arb)
- [mobile/lib/src/localization/l10n/app_ru.arb](../mobile/lib/src/localization/l10n/app_ru.arb)
- [mobile/lib/src/localization/l10n/app_zh.arb](../mobile/lib/src/localization/l10n/app_zh.arb)
- [mobile/test/catalog/analysis_sdk_test.dart](../mobile/test/catalog/analysis_sdk_test.dart)
- [mobile/test/catalog/analysis_submission_test.dart](../mobile/test/catalog/analysis_submission_test.dart)
- [mobile/test/catalog/email_otp_test.dart](../mobile/test/catalog/email_otp_test.dart)
- [mobile/test/catalog/front_packaging_test.dart](../mobile/test/catalog/front_packaging_test.dart)
- [mobile/test/catalog/label_capture_test.dart](../mobile/test/catalog/label_capture_test.dart)
- [mobile/test/catalog/pending_capture_test.dart](../mobile/test/catalog/pending_capture_test.dart)
- [mobile/test/catalog/product_results_test.dart](../mobile/test/catalog/product_results_test.dart)
- [mobile/test/catalog/quota_status_test.dart](../mobile/test/catalog/quota_status_test.dart)
- [mobile/test/catalog/ui_polish_test.dart](../mobile/test/catalog/ui_polish_test.dart)
- [supabase/functions/_shared/analysis_input.mjs](../supabase/functions/_shared/analysis_input.mjs)
- [supabase/functions/_shared/analysis_publication.mjs](../supabase/functions/_shared/analysis_publication.mjs)
- [supabase/functions/_shared/analysis_validation.mjs](../supabase/functions/_shared/analysis_validation.mjs)
- [supabase/functions/_shared/analyze_product.mjs](../supabase/functions/_shared/analyze_product.mjs)
- [supabase/functions/_shared/catalog_boundary.mjs](../supabase/functions/_shared/catalog_boundary.mjs)
- [supabase/functions/_shared/product_identity.mjs](../supabase/functions/_shared/product_identity.mjs)
- [supabase/functions/_shared/retake_details.mjs](../supabase/functions/_shared/retake_details.mjs)
- [supabase/migrations/20261104000100_pickwell_front_packaging.sql](../supabase/migrations/20261104000100_pickwell_front_packaging.sql)
- [supabase/spikes/meta-vision/analysis-index.ts](../supabase/spikes/meta-vision/analysis-index.ts)
- [supabase/spikes/meta-vision/core.mjs](../supabase/spikes/meta-vision/core.mjs)
- [supabase/tests/analysis_validation.test.mjs](../supabase/tests/analysis_validation.test.mjs)
- [supabase/tests/analyze_product.test.mjs](../supabase/tests/analyze_product.test.mjs)
- [supabase/tests/catalog_schema.test.mjs](../supabase/tests/catalog_schema.test.mjs)
- [supabase/tests/fixtures/label_analysis.mjs](../supabase/tests/fixtures/label_analysis.mjs)
- [supabase/tests/front_packaging.test.mjs](../supabase/tests/front_packaging.test.mjs)

## 2026-11-04 — Later hosted rollout (T07.1D.1)

[Hosted rollout evidence](PICKWELL_HOSTED_TRUST_ROLLOUT.md) supersedes the
missing-deployment caveat in this historical report. Both migrations and compatible
functions are deployed and hosted security checks pass; inference is restored under
unchanged testing limits, billing false. Real three-photo/Muse/device/operator
approval validation was explicitly deferred by the owner. Testing-deployment
decision: PASS WITH LIMITATIONS; no full real-product flow or T07.2 sign-off claimed.
