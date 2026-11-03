# T06.2 — Remaining usage and quota states

2026-11-03 — Implemented and verified with targeted client/native backend tests
and hosted smoke checks. Full device/provider flow remains deferred.

The preceding T06.1 work was reviewed and committed as `86b21dd` before this task.
Existing quota accounting, RPCs, plan configuration and template architecture were
reused. No database migration, package, client define or new endpoint was needed.

## Behavior and boundaries

- Lookup and submission responses carry typed, validated quota snapshots. Exact
  counts render only for the SDK identity that received them. Sign-out or account
  switching hides another account's counts. Snapshots are display metadata, never
  authorization, and are not persisted in recents or full offline product payloads.
- UI uses server limits, remaining, reserved slots and UTC reset. Reset is shown
  as local date/time/time zone. A single expiry timer hides stale counts at reset;
  it does not refill an allowance or make a network request. Rebuilds do not fetch.
- Guest copy describes fair use or temporary throttling without personal daily
  limits. Temporary rate limits and global/service restrictions are distinct from
  daily quota exhaustion. No purchase/paywall action is exposed.
- Exhaustion explains reset and preserves already loaded results. Missing,
  malformed, expired or offline quota is explicitly unavailable; deep links and
  local reopening without a snapshot do not fetch solely to populate a badge.
  Reported counts can change with other activity and are labeled accordingly.
- Optional route extras carry the latest operation snapshot into capture/results;
  deep links still work without extras. Same-barcode refresh denial/error retains
  a loaded result; an actual miss clears it.
- A definitive daily quota rejection permits an explicit same-key server recheck
  after a reset/config change without spending the transmission-recovery budget.
  Server authorization, idempotency and rate controls still apply. No automatic
  retry, local allowance mutation or additional model request is introduced.
- `analyze-product` attaches a current AI snapshot through the existing server-only
  RPC after trusted authorization. One optional read has a one-second timeout and
  bounded response. Snapshot failure cannot change admission, publication, credit
  accounting or the core response. Atomic denial metadata is retained without an
  extra read. Unauthenticated/malformed/throttled requests do not read usage.
- New localized messages use the repository's English fallback convention across
  supported locales. No unrelated localization reformatting was performed.

## Observed validation

Commands used (from mobile for Flutter; repo root for backend):

```sh
fvm flutter pub get --enforce-lockfile
fvm flutter gen-l10n
fvm dart run build_runner build --delete-conflicting-outputs
fvm flutter test --no-pub test/catalog
fvm flutter analyze --no-pub
PICKWELL_NATIVE_STATUS=.secrets/native-status.json node --test --test-concurrency=1 supabase/tests/analysis_quota_response.test.mjs supabase/tests/analyze_product.test.mjs supabase/tests/get_product.test.mjs
PICKWELL_NATIVE_STATUS=.secrets/native-status.json node --test --test-concurrency=1 supabase/tests/quota_boundary.test.mjs
```

- **86 Flutter catalog tests passed; analyzer found no issues.** Tests cover 30/31,
  3/4, lowered limits with usage above the new limit, reservations, local reset,
  expiry, malformed metadata, offline fallback, guest/account privacy, no paywall,
  loaded result preservation, same-key quota recheck and compact/dark/large text.
- **39 focused backend tests plus 19 quota tests passed, zero skips.** Native
  Supabase Auth/REST/Postgres and mocked provider tests cover 30/31, three actual
  synthetic publications/fourth rejection, concurrency, UTC days, negative usage,
  retry/release, publication rollback and spend. Optional metadata failure does
  not block successful publication. A disposable native plan change to 20 was
  reflected by subsequent responses; Flutter renders the changed limit directly.
- Existing experimental Native Runtime was used without Docker and stopped after
  validation. Unrelated generated-file churn was restored; no lockfile changes.
- JavaScript syntax, diff whitespace and secret checks passed. Private test
  artifacts, sessions, startup credentials and photo fixtures remain ignored.

## Hosted evidence

Updated only `analyze-product` using Supabase CLI 2.122.0 with explicit project
`bzmqgjinbjykhqqswdva` and API deployment. No CLI upgrade or SQL deployment.

Eight hosted checks passed:

| Request | Observed result |
| --- | --- |
| Guest analysis | 401; no personal quota |
| Public key as user bearer | 401; no personal quota |
| Forged bearer | 401; no personal quota |
| Verified malformed analysis | 400 |
| Valid-shaped request while inference disabled | 503; AI limit 3, used 0, reserved 0, remaining 3 |
| Cached analysis response | 200 already_exists; same AI snapshot |
| Guest cached lookup | 200 ready; guest best effort, no personal allowance |
| Verified cached lookup | 200 ready; barcode limit 30, used 1, remaining 29 |

Both authenticated snapshots report reset `2026-11-04T00:00:00+00:00`
(08:00 Asia/Manila). The verified cached lookup consumed one genuine definitive
lookup; it was not administratively refunded. Cloud plan values remained 30/3,
version 1. Cloud limit changes were not required for this test.

Before/after verification: ten migrations, one demo product/analysis, zero normal
provider calls/jobs/candidates, no exposed table without RLS, no unsafe catalog
writes/publication RPC grants. **Billing and inference remain false.** No Meta
call, new publication or paid inference occurred. Tiny synthetic images exercised
transport only and establish no image-model accuracy.

## Acceptance and remaining work

All four T06.2 implementation checkboxes are verified. Server agreement is proven
by hosted responses; mutable limits and boundary/reset handling by native tests
and client tests. No additional credentials or assets are needed for this task.

Full captured-photo → OTP → real Meta → publication → new guest/device acceptance
is still deferred, as requested. Existing T05.2 image-quality/retake constraints
remain; this task does not resolve or relabel them. Live inference must be
intentionally enabled and validated later. No new hardware test is claimed.
T06.3 is the next listed task and was not started.

## Modified files

- `docs/PICKWELL_QUOTA_UI.md`
- `docs/PICKWELL_TASKS.md`
- `mobile/README.md`
- `mobile/lib/src/config/router/app_router.dart`
- `mobile/lib/src/features/catalog/data/data_sources/services/analysis_api_service.dart`
- `mobile/lib/src/features/catalog/data/data_sources/services/catalog_api_service.dart`
- `mobile/lib/src/features/catalog/data/models/analysis_model.dart`
- `mobile/lib/src/features/catalog/data/models/catalog_model.dart`
- `mobile/lib/src/features/catalog/data/models/quota_model.dart`
- `mobile/lib/src/features/catalog/domain/entities/_entities.dart`
- `mobile/lib/src/features/catalog/domain/entities/analysis_entity.dart`
- `mobile/lib/src/features/catalog/domain/entities/catalog_entity.dart`
- `mobile/lib/src/features/catalog/domain/entities/quota_snapshot.dart`
- `mobile/lib/src/features/catalog/presentation/blocs/catalog/analysis_submission_cubit.dart`
- `mobile/lib/src/features/catalog/presentation/blocs/catalog/catalog_cubit.dart`
- `mobile/lib/src/features/catalog/presentation/blocs/catalog/catalog_state.dart`
- `mobile/lib/src/features/catalog/presentation/views/capture_entry_view.dart`
- `mobile/lib/src/features/catalog/presentation/views/catalog_view.dart`
- `mobile/lib/src/features/catalog/presentation/views/product_detail_view.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/_widgets.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/analysis_submission_notice.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/lookup_notice.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/product_result_content.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/quota_status.dart`
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
- `mobile/test/catalog/catalog_repository_test.dart`
- `mobile/test/catalog/quota_status_test.dart`
- `supabase/README.md`
- `supabase/functions/_shared/analysis_quota_response.mjs`
- `supabase/functions/_shared/analyze_product.mjs`
- `supabase/tests/analysis_quota_response.test.mjs`
- `supabase/tests/analyze_product.test.mjs`
