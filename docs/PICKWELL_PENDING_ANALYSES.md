# Pending photo drafts and retryable service limits

2026-11-03 — User-requested follow-up to capture/submission and quota UX.
The user requested retaining photos through Back and accidental process close,
with a yellow Needs analysis entry on Home and resumption beyond the scanner.
This deliberately supersedes the prior route/process-only one-hour draft policy.
Earlier contextual-extraction changes and server activation remain intact.

## Implemented behavior

- One device-private pending draft, at most nutrition + ingredients and the existing
  5 MiB/image bound. It is separate from ready-product recents, account/cloud history,
  public product records and offline analysis payloads. No backend image storage.
- The existing media service still compresses, checks MIME/size/dimensions and
  decodes input. A repository copies accepted photos into a dedicated app cache
  namespace, with a bounded atomic manifest. Restoration revalidates file contents,
  canonical barcode and metadata; no arbitrary manifest path or symlink is trusted.
- Ordinary app close/restart restores the photos, barcode, original expiry,
  idempotency key and bounded transmission count. Back never deletes the draft.
  In-progress save and save failure are visible; a failed durable save blocks a new
  transmission. This cannot recover photos already lost by a previous app version.
- Draft lifetime is 24 hours from creation, not extended on reopen. Active drafts
  expire on a timer; expired/orphan files are swept on next launch/load if the app
  was closed. Cache may be purged earlier by the OS. App cache avoids treating label
  photos as backed-up documents; retention is temporary and explicitly disclosed.
- Retake replaces only the chosen image; a changed pair gets a new persisted key.
  Trying another unknown barcode preserves the pending draft and returns to it;
  finish or explicitly delete that draft before starting another product. This
  prevents the prior silent replacement of both photos.
- Home shows a yellow warning icon and text Needs analysis, Continue analysis and
  Delete saved draft. This works while recent-product hydration is loading/offline.
  Matching nested product details can also resume it. Capture offers explicit Delete.
- Accepted publication/cache success must clear saved copies and working photos
  before result navigation. Cleanup failure keeps a recoverable draft and uses the
  existing cleanup-only retry; no extra inference is needed. Explicit Delete and
  expiry clear the manifest/copies. Late results cannot delete another active draft.

## Retry and cost boundary

Cloud read-only check confirms the observed block: three provider calls recorded
against the deliberately configured three-call test cap (daily budget USD 5,
concurrency one). Inference remains enabled and billing remains disabled. These
operator controls and existing provider usage were not reset or increased.

The protected function now distinguishes a daily service-budget denial, returning
`retry_at` at next 00:00 UTC plus bounded retry seconds. Concurrency and request
throttle responses give short retry guidance. Flutter displays the daily service
message, local reset time and a manual Check again action; no automatic polling.
The service cap is distinct from the user's remaining successful-analysis credits.
For the observed UTC date, reset is **2026-11-04 08:00 Asia/Manila**.

A definitive denial before provider admission cannot have charged a model call.
Only an explicit server response for that situation permits the client to persist
and use a fresh request key, because the old denied job was settled terminally.
Replaying an old no-provider service denial remains a retryable denial. Transport
uncertainty and provider work always retain their original key and transmission
bound; restart must not create an accidental duplicate call. Authorization, quota
reservations, RLS, atomic publication and spend checks remain server-controlled.

The contextual-label prompt/schema version was not changed again in this task.
No extra model call, diagnostic transcription, new payment feature or secret in the
client was added. `path_provider` 2.1.6 was already in the lockfile transitively;
it is now an explicit direct dependency for private cache access, with no version
upgrade or new platform service.

## Validation and scope

Targeted commands:

```sh
# mobile/
fvm flutter pub get
fvm flutter gen-l10n
fvm dart run build_runner build --delete-conflicting-outputs
fvm flutter test --no-pub test/catalog
fvm flutter analyze --no-pub
# repository root; disposable native stack, no Docker
PICKWELL_NATIVE_STATUS=.secrets/native-status.json node --test --test-concurrency=1 supabase/tests/analyze_product.test.mjs supabase/tests/analysis_validation.test.mjs supabase/tests/analysis_quota_response.test.mjs supabase/spikes/meta-vision/core.test.mjs
```

Observed final outcomes: **94 catalog tests passed; 59 native/backend tests passed
with zero skips; static analyzer found no issues.** After a test-only storage-root
constructor cleanup, the 16 affected storage/capture tests were rerun and passed.
The analyzer and whitespace checks were clean. Credential scan of changed/new
files found zero known private values or credential-pattern leaks.

The focused tests cover disk/Cubit recreation with identical key/expiry/attempts,
independent capture preservation, explicit deletion, successful-submission cleanup,
cleanup/save failure recovery, expired/path-traversal/orphan cleanup, warning-card
resume from outside the scanner, server retry timing and safe request-key renewal.
Existing scanner/OTP/results/recents/quota tests remain in the scoped catalog suite.
Native Auth/REST/Postgres tests exercise publication, replay and authorization with
mocked Meta; no real provider calls were made by this follow-up.

The response-only backend update was deployed to existing project
`bzmqgjinbjykhqqswdva` via CLI 2.122.0 `functions deploy analyze-product --use-api`.
No additional migration or project configuration change was required in this
follow-up (the prior unknown-nutrition migration was already applied).
Native services were stopped afterward. No real-device forced-close test, new
live Meta extraction or full end-to-end acceptance is claimed. **Rebuild/relaunch
the app** for the new persistence, messages and Home entry. Existing credentials
are sufficient; no artwork is needed. New strings follow existing English locale
fallbacks. Prior T05.2 quality and T07.1 live acceptance remain open.

## Modified files in this follow-up and preceding uncommitted work

- `docs/PICKWELL_ANALYSIS_VALIDATION.md`
- `docs/PICKWELL_PENDING_ANALYSES.md`
- `docs/PICKWELL_QUOTA_UI.md`
- `docs/PICKWELL_TASKS.md`
- `mobile/lib/src/config/injection_container.config.dart`
- `mobile/lib/src/config/router/app_router.dart`
- `mobile/lib/src/features/catalog/data/data_sources/services/scanner_media_service.dart`
- `mobile/lib/src/features/catalog/data/models/analysis_model.dart`
- `mobile/lib/src/features/catalog/data/models/catalog_model.dart`
- `mobile/lib/src/features/catalog/data/repositories/_repositories.dart`
- `mobile/lib/src/features/catalog/data/repositories/pending_capture_repository.dart`
- `mobile/lib/src/features/catalog/domain/entities/_entities.dart`
- `mobile/lib/src/features/catalog/domain/entities/analysis_entity.dart`
- `mobile/lib/src/features/catalog/domain/entities/label_photo.dart`
- `mobile/lib/src/features/catalog/domain/entities/pending_capture.dart`
- `mobile/lib/src/features/catalog/domain/repositories/_repositories.dart`
- `mobile/lib/src/features/catalog/domain/repositories/pending_capture_repository.dart`
- `mobile/lib/src/features/catalog/presentation/blocs/catalog/analysis_submission_cubit.dart`
- `mobile/lib/src/features/catalog/presentation/blocs/catalog/label_capture_cubit.dart`
- `mobile/lib/src/features/catalog/presentation/views/capture_entry_view.dart`
- `mobile/lib/src/features/catalog/presentation/views/product_detail_view.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/analysis_submission_notice.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/pending_capture_card.dart`
- `mobile/lib/src/features/home/presentation/views/home_view.dart`
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
- `mobile/pubspec.lock`
- `mobile/pubspec.yaml`
- `mobile/test/catalog/analysis_submission_test.dart`
- `mobile/test/catalog/catalog_repository_test.dart`
- `mobile/test/catalog/label_capture_test.dart`
- `mobile/test/catalog/pending_capture_test.dart`
- `mobile/test/catalog/product_results_test.dart`
- `supabase/functions/_shared/analysis_validation.mjs`
- `supabase/functions/_shared/analyze_product.mjs`
- `supabase/migrations/20261103000300_pickwell_unknown_nutrition.sql`
- `supabase/tests/analysis_validation.test.mjs`
- `supabase/tests/analyze_product.test.mjs`
- `mobile/README.md`
- `supabase/README.md`

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

## 2026-11-03 — Multiple pending products (current app behavior)

The user requested saving additional Needs analysis items rather than having a
single unfinished product block the next scan. The app now keeps **up to five**
independent device-private drafts, one per canonical barcode. The single-draft
restriction in earlier sections is superseded by this follow-up.

- Scanning a different missing barcode switches the active capture without
  deleting saved photos. Scanning the same pending barcode (including its
  normalized UPC/EAN representation) reopens that item with the same photos,
  expiry, attempt count and request key; it does not create a duplicate or call AI.
  Ready published barcodes continue to use the existing results path.
- Home renders a Needs analysis card for every saved item, newest-created first,
  with individual Continue/Delete actions. Barcode search filters pending items
  too. Matching nested details show only their own pending card.
- At five pending items, starting another unknown product shows a clear capacity
  message on Home. Nothing is silently evicted; complete or explicitly delete one
  to free a slot. Existing items can still be reopened or retaken at capacity.
- Each item retains its original 24-hour expiry and separate timer. Expiring,
  deleting or successfully submitting one does not clear the others. A late
  accepted response removes only its submitted photo version, preserving a
  switched active product or newer retake. Unknown provider outcomes retain their
  own original request key; switching items does not reset transmission counts.
- The existing cache namespace now contains a barcode-specific directory and
  bounded atomic manifest for each item. On first load, the old single manifest
  and its referenced photos migrate into that layout without changing request
  identity/expiry. Saving/deleting one barcode never sweeps another item's files.
  Transient I/O failure preserves existing data and offers restore retry; invalid,
  expired and orphan data are cleaned only within owned cache namespaces.
- Retention remains temporary private cache, not cloud/account history or full
  offline results. Five drafts permit at most ten bounded label files (up to
  50 MiB saved photos, plus validated working copies). OS cache cleanup may remove
  files sooner. No new package, Drift table, backend deployment, quota change,
  image generation or live Meta call was needed for this app-only change.

Observed verification: **100 focused catalog tests passed; analyzer clean.**
Additional checks cover five-item preservation, capacity refusal without eviction,
canonical-barcode deduplication, independent key/attempt restoration, legacy disk
migration, per-item deletion/expiry, late-publication isolation, transient restore
failure recovery, and selecting/deleting individual cards outside the scanner.
The storage/capture subset was rerun after final lifecycle guards; no real-device
restart or real-model success is inferred. Existing OTP tests now assert the same
barcode/photo objects across auth, rather than the state-container object's
identity (the state also carries the pending list).

Primary changed files are the pending-capture entity/repository, file-backed
repository, LabelCaptureCubit, pending cards, capture/Home views, capture route,
localized messages and their generated outputs, plus targeted pending/capture/
submission/OTP tests. Prior uncommitted extraction, activation and retry changes
were preserved. No task's unverified live acceptance checkbox was advanced.
**Rebuild/relaunch the app without uninstalling** to use multi-draft storage and
migrate an existing draft. Hardware forced-close and live full-flow checks remain
part of T07.1.

## Retake diagnosis and historical saved photos

The app now displays model-versus-validation retake reasons per photo/field.
Old results without recorded details can explicitly reanalyze their saved photos,
with a new persisted key and clear provider-attempt notice; no camera retake or
automatic inference is required. See [retake evidence](PICKWELL_RETAKE_DIAGNOSTICS.md).
The hackathon per-barcode cap is now ten within unchanged global 20/day and USD 30
budget; earlier five-attempt descriptions are historical. Rebuild/restart without
uninstalling; live image/device acceptance is still pending.
