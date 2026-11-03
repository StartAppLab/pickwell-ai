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

## 2026-11-03 — Authorized device-test activation

After the T06.2 commit, the user explicitly requested enabling real analysis.
Meta model discovery returned HTTP 200 and confirmed `muse-spark-1.3`; the three
server-only Meta configuration values were refreshed from the protected existing
local environment. No key was displayed or copied into Flutter.

Cloud `quota_controls` version 2 now has inference enabled, approved model
`muse-spark-1.3`, billing disabled, one concurrent provider call, three provider
attempts per UTC day, USD 5 daily admission budget and USD 1.34 held per call.
Free user quotas remain 30 lookups / 3 successful analyses. The three-call global
test cap also counts failed/retake calls; it is separate from successful-user
credits. At most three new calls are admitted by these daily test controls.

The old USD 0.05 reserve was not a proven maximum. The new conservative reserve
uses the documented full 1,048,576-token context at USD 1.25/M input plus the
adapter's bounded 4,096 output tokens at USD 4.25/M (USD 1.328128, rounded up).
This deliberately over-reserves small label requests. See official
[model context](https://dev.meta.ai/docs/models) and
[Standard pricing](https://dev.meta.ai/docs/pricing-rate-limits), checked today.
No image formula or historical average is used as a guaranteed cost ceiling.

Activation was read back from the hosted database. Guest and public-key-as-user
analysis calls still returned 401. No new inference was deliberately invoked by
this activation check; successful real extraction/publication remains for the
device end-to-end test, and prior quality constraints remain open. Historical
OFF-state results above describe their original test time.

No app rebuild is required for the server switch. Retry Analyze from the existing
capture flow; if its bounded request window expired, reopen the capture flow.
A clearer-photo retake may still be required by the model/validator. To stop the
test, an operator can set `public.quota_controls.inference_enabled=false` on its
single `id=true` row, increment version and record a change reason. Billing must
remain false. Do not change client counters or disable trusted-email enforcement.

## 2026-11-03 — Hackathon test-cap increase (current configuration)

The user explicitly requested increasing the temporary service testing limits.
A guarded transaction updated only the existing server control row, version 2 → 3:

| Control | Before | Current |
| --- | --- | --- |
| Global provider attempts / UTC day | 3 | 20 |
| Conservative daily admission budget | USD 5 | USD 30 |
| Provider attempts per user / UTC day | 9 | 20 |
| Provider attempts per network / UTC day | 20 | 40 |
| Provider attempts per barcode / UTC day | 3 | 5 |

The USD 1.34 per-call hold is unchanged, so 20 admissions fit within the new daily
budget (20 × 1.34 = USD 26.80). Holds are conservative admission accounting, not a
claim that each small label request costs USD 1.34. Global/user/network concurrency
remain one; model, auth, image limits, per-minute throttles and request idempotency
are unchanged. Free remains 30 barcode lookups and 3 successful analyses/day;
billing remains disabled and protected inference enabled.

Hosted read-back verified every changed value, incremented audit version/change
reason, unchanged Free limits and no deletion/reset of existing provider usage.
Three prior calls were still recorded at verification, leaving 17 global attempts
at that moment; per-barcode and other admission controls still apply. No inference
was invoked for this settings change. No deployment, app rebuild, migration or
secret change was required. Existing saved-draft retry can pick up the new limits.
Earlier three-attempt reports above are historical and superseded by this change.
Daily counters reset at 00:00 UTC (08:00 Manila); these configured caps remain in
effect until an operator changes them. Restore conservative controls after the
hackathon; do not erase the spend ledger or enable billing as part of that reset.
