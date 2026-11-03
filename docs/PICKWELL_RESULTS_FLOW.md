# T06.1 — Product results and authenticated photo submission

2026-11-03. **Implementation complete with targeted automated validation.** The
client upload and successful-photo-disposal work previously missing from T05.3 is
now connected. Real-device/full-flow acceptance is still deferred at the user's
request; the outstanding T05.2 real-label quality gate is unchanged. This does not
claim a successful new live Meta food analysis or release readiness.

## Inventory and scope

Started clean at `5386964`. Read root/mobile instructions, mobile README, shared
APP_DESIGN_GUIDELINES, current PRD v1.4, DESIGN/SPEC v1.2, DATABASE v1.0 and TASKS.
Inspected catalog layers/Cubits, capture draft, OTP gate, routes, local recents,
existing result view, theme/assets, generated DI and the deployed T05.3 contract.
Extended the existing catalog feature; no feature skeleton or template was rebuilt.

The existing capture wizard, OTP route, SDK/session, request-key generator, local
recent reference store, result route and brand/theme tokens are reused. Server v2
responses already include validated explanations/missing fields/provenance. The old
client discarded these fields and stopped at OTP preflight; those were the missing
connections. No backend migration, deployment, auth provider, package or asset was
added. The existing Supabase Flutter SDK reexports multipart support, so a new HTTP
package or parallel network stack was unnecessary.

## Submission and recovery

- Analyze is available only after two photos. The existing email gate checks the
  session; cancel returns without uploading or altering either photo. A confirmed
  gate returns to the same in-memory draft and triggers actual `analyze-product`.
- A new repository/use case and app-owned `AnalysisSubmissionCubit` follow the
  existing feature layers. SDK access is lazy and disabled integrations remain
  safe. Public project configuration plus the SDK user session are the only client
  credentials; the backend independently authorizes the contribution.
- Upload is binary multipart with canonical barcode, one UUID key and the two
  labeled image fields. Fixed filenames avoid transmitting local paths. No user
  ID, verified/Premium flag, model, endpoint or quota counter is submitted.
- Prepared files are read with bounded size, checked against MIME signatures and
  expected length, and limited to the existing 5 MiB/2400-pixel contract. Missing or
  invalid files request the relevant retake before any upload. The existing camera
  adapter remains responsible for resize/compression and pixel validation.
- Expired sessions refresh through the existing SDK. Missing/rejected sessions
  return to email verification; identity changes before/after transmission are
  checked. File operations have ten-second bounds and upload has an abort signal
  at 45 seconds plus a 46-second outer bound. No automatic paid retry is introduced.
- Same-photo retry reuses the same UUID; changing a photo changes the request key.
  Double presses are suppressed. Manual processing/uncertain-transport checks are
  capped at three total transmissions for that photo pair, then stop explicitly.
  A server reconciliation-required result disables resubmission. A disabled-inference response may be checked later with the same key/photos, without recapturing, within that bounded window. Retake preserves
  the accepted other photo. Denial/disabled/unknown/error are explicit states, never
  fabricated not-found or ready results. Broader quota UI remains T06.2.
- Published `ready` and `already_exists` responses use the same catalog parser and
  `ProductRecord` as cached lookup. The published record enters memory and the
  bounded barcode/timestamp-only recent index; an optional preference-write failure
  does not turn successful publication into a failed paid request. Navigating to
  the existing product route uses that memory record without another lookup/Meta call.

## Successful cleanup and lifecycle

The client awaits `LabelCaptureCubit.discardSubmitted()` before navigating to the
result. That clears the two draft references and deletes their owned files using
existing media cleanup. Submission keeps only its published result after successful
cleanup; temporary photo/key snapshots are cleared. The deletion operations have
five-second bounds. A cleanup failure is visible and can be retried **without
another upload**; new captures for that failed cleanup are blocked until resolved.
Existing expiry/startup orphan cleanup remains in place.

A late completed response cannot clear a newer unrelated draft: only the submitted
snapshot's unreferenced photos are disposed. Auth cancel, retake, quota denial and
uncertain outcomes retain the bounded draft for recovery. No new photo persistence,
cloud history or offline full analysis was added. Captured photos/request identity
still do not survive process death; that is not advertised as a resumable background
upload. Public product facts may remain in memory; only barcode/time references are
written to preferences.

## Accountable result view

The nested result route has a back action and real barcode-copy overflow, without
a logo title or bottom dock. It renders a truthful package-photo placeholder,
identity/barcode, labeled demo notice when applicable, separate summary/findings/
ingredient/nutrition/missing-information/provenance cards, declared allergens,
ordered and raw ingredients, attributed label explanations and local analysis date/time.
The server does not provide authorized package photos, so none were invented.

Green/yellow/red findings have distinct icons and text labels in addition to theme
colours; expandable evidence shows literal label spans and rule/source references.
No numeric score, overall certification, Add to List or inert Share button is added.
Unsupported context shows no supported findings; null nutrient values are Unknown,
not zero. Serving/per-100g/per-100mL and µg units are explicit. Small nonzero values
are not rounded into a false zero. Long labels wrap rather than truncating units.
Unknown/missing fields remain qualified and are never shown as allergen-free.

New copy is localized through all existing ARBs and generated outputs, following
the current English-fallback convention; linguistic translation review remains
unverified. The capture privacy disclosure now describes the real upload instead
of falsely saying photos never leave the device. DI/localization outputs were
regenerated, and unrelated generator churn in mapper/Home/paywall was removed.

## Actual validation

Commands from `mobile/`:

```sh
fvm flutter pub get --enforce-lockfile
fvm flutter gen-l10n
fvm dart run build_runner build
fvm flutter test --no-pub test/catalog
fvm flutter analyze --no-pub
```

Final observed results: **74 focused tests passed; static analyzer: no issues.**
Dependency resolution succeeded with the existing lockfile and no package changes.
Tests include the existing catalog/capture/OTP regressions and new:

- SDK-to-loopback HTTP binary multipart, valid session versus guest/disabled mode,
  expired-session rejection before upload, exact image field names/UUID reuse,
  file-size failure, no client privilege fields or original path transmitted.
- Cancel/verify resume, duplicate suppression, transport/processing retry identity,
  capped checks, precise single-photo retake and changed-photo key, denied/blocked
  draft preservation, malformed finding evidence rejected before rendering.
- Accepted-response cleanup of **real temporary files**, visible failed deletion
  and cleanup-only retry without another network request, late-result protection
  for a newer draft, and optional recents-write failure.
- Cached/new response evidence equivalence, accepted submission -> shared result
  route, green/yellow/red/unknown/missing values, long ingredients, no score/dock,
  large text on a compact screen and explicit non-percentage error/status views.

Light/dark result widgets were rendered with the actual bundled Manrope/Material
fonts and visually inspected. Preview data is explicitly synthetic and stays only
in test fixtures. PNG renders are in ignored `.secrets/`, not product artwork.
Git diff whitespace and known-secret/credential-pattern checks pass. No images,
OTPs, session tokens or private provider/service keys are included in source or logs.

No live email/Meta inference, cloud deployment, new hardware scan/capture, native
build or blanket project regression was run. Loopback SDK/fake-backend/widget tests
prove the client contract and lifecycle, not real Supabase gateway/Meta/device
acceptance. Existing normal inference/billing settings were not enabled or changed;
a live app will truthfully show unavailable while the backend inference gate is off.

## Acceptance and next dependency

All four T06.1 implementation checkboxes are verified by parser/Cubit/widget checks.
T05.3's client-disposal checkbox is now resolved by the awaited hook, real file
cleanup and route tests. The earlier missing client implementation is no longer a
blocker. Full device OTP -> upload -> real Meta -> publish -> second guest acceptance
remains deferred, as do the T05.2 two readable products/genuinely unreadable fixture
and richer ingredient explanation requirements. Do not relabel those as passed.

No new credentials are required. No authorized package imagery was supplied; the
visible placeholder is intentional. Next is T06.2 usage/quota UI if requested;
keep the prior quality/operational gates before enabling live inference or release.
Prepared for the requested T06.1 commit before beginning T06.2.

## Exact repository files changed

- `docs/PICKWELL_PUBLICATION.md`
- `docs/PICKWELL_RESULTS_FLOW.md`
- `docs/PICKWELL_TASKS.md`
- `mobile/README.md`
- `mobile/lib/src/config/injection_container.config.dart`
- `mobile/lib/src/config/router/app_router.dart`
- `mobile/lib/src/features/catalog/data/data_sources/services/_services.dart`
- `mobile/lib/src/features/catalog/data/data_sources/services/analysis_api_service.dart`
- `mobile/lib/src/features/catalog/data/models/_models.dart`
- `mobile/lib/src/features/catalog/data/models/analysis_model.dart`
- `mobile/lib/src/features/catalog/data/models/catalog_model.dart`
- `mobile/lib/src/features/catalog/data/repositories/_repositories.dart`
- `mobile/lib/src/features/catalog/data/repositories/analysis_repository.dart`
- `mobile/lib/src/features/catalog/domain/entities/_entities.dart`
- `mobile/lib/src/features/catalog/domain/entities/analysis_entity.dart`
- `mobile/lib/src/features/catalog/domain/entities/catalog_entity.dart`
- `mobile/lib/src/features/catalog/domain/repositories/_repositories.dart`
- `mobile/lib/src/features/catalog/domain/repositories/analysis_repository.dart`
- `mobile/lib/src/features/catalog/domain/use_cases/_use_cases.dart`
- `mobile/lib/src/features/catalog/domain/use_cases/analyze_product_use_case.dart`
- `mobile/lib/src/features/catalog/presentation/blocs/_blocs.dart`
- `mobile/lib/src/features/catalog/presentation/blocs/catalog/analysis_submission_cubit.dart`
- `mobile/lib/src/features/catalog/presentation/blocs/catalog/label_capture_cubit.dart`
- `mobile/lib/src/features/catalog/presentation/views/capture_entry_view.dart`
- `mobile/lib/src/features/catalog/presentation/views/product_detail_view.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/_widgets.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/analysis_submission_notice.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/nutrition_fact_row.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/product_finding_card.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/product_result_content.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/product_section.dart`
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
- `mobile/test/catalog/email_otp_test.dart`
- `mobile/test/catalog/label_capture_test.dart`
- `mobile/test/catalog/product_results_test.dart`
