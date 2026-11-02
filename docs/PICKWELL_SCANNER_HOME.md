# T03.2 — Flutter Home, scanner and lookup UX

2026-11-02. **PARTIAL: implementation and automated/native build checks pass;
physical barcode acceptance and live hosted lookup remain unverified.**
T03.1 was reviewed and committed first as `4fe05c4`.

## Inventory and reconciliation

Read root/mobile AGENTS, mobile README, APP_DESIGN_GUIDELINES, PRD v1.4,
DESIGN/SPEC v1.2, DATABASE v1.0 and actual TASKS. Existing Home was a welcome
placeholder with simulated loading; GoRouter already had a Home/Settings shell.
Retained its GetIt/Injectable, Cubit/Freezed, shared theme, AppIcon, Manrope fonts,
DataStorage/SharedPreferences and disabled-integration behavior. No existing barcode
scanner or gallery picker was present. No approved lemon source image or real
product thumbnail asset was found; existing launcher images are template artwork.

Mason's pinned `feature-cubit` brick generated 26 catalog files into ignored scratch
storage before copying/adapting the full layer scaffold. Removed its example integer
IDs/network/cache/logging assumptions while retaining its layer/barrel structure.
The new feature adds service boundaries, typed parsing, use cases and route-owned
Cubits; existing Home/Root layers are extended, not replaced with another app.

Old instruction references to PRD 1.3/DESIGN 1.1 are superseded by the explicit
latest-version rule and user-approved lemon Home contract. Optional framework auth,
billing and onboarding capabilities remain available; this task enables no billing
or broad onboarding. Welcome/release sheets now respect the existing onboarding
switch so the default guest reaches Home directly.

## Implemented behavior

- Cream/white/forest/green default themes using approved palette values and existing
  theme infrastructure; a dark variant remains available. Header has the configured
  app name, a **labeled lemon emoji placeholder**, and only expandable search.
  Approved whole-lemon SVG/PNG is still needed; native splash/launcher art is unchanged.
- Empty or bounded device-local recent-product cards, All/Food selections and Newest
  ordering. Both categories currently contain Food only. No feed, Chat, cosmetics,
  grid toggle or Recently scanned heading. Thumbnails use truthful neutral placeholders.
- Home/Settings floating pill with Flutter blur/translucency and an Android tint/no-blur
  fallback; separate far-right icon-only barcode action with accessible tooltip.
  Scanner, product and capture routes sit outside the shell, so the dock is hidden.
- `mobile_scanner` **7.5.0** for live EAN-8/EAN-13/UPC-A/UPC-E scanning; camera starts
  on opening Scan, not Home. Permission denial/error recovery, device settings,
  torch capability gating, pause/resume/disposal and duplicate-frame suppression.
- `image_picker` **1.2.4** supplies gallery import; selected barcode photos decode
  locally. Manual numeric barcode entry is a secondary fallback. No OCR/AI provider
  is called by the scanner. Both plugins support the existing iOS SPM build.
- Canonical GTIN-14/check-digit validation, plus explicit format-aware UPC-E expansion.
  Manual eight-digit values mean EAN-8, not guessed UPC-E. Unsupported/invalid codes
  become recoverable errors before network work.
- Catalog Cubit states: idle, scanning, checking, found, miss, processing, denied,
  error. Network retries retain their operation key; a deliberate fresh processing
  check or expired receipt gets a new key. Closed routes discard late results.
- Supabase `get-product` service uses only existing public app configuration and
  SDK-managed session tokens. Guests have no sign-in gate. Backend-provided quota
  metadata is displayed when available; there are no client quota/Premium/verified
  authority flags. HTTP failures never become fake catalogue misses.
- Fresh scans always call the backend, even for a previously loaded barcode.
  Explicitly reopening an already loaded result can use memory. A fresh miss or
  processing result evicts stale ready data. Timeouts and unknown responses fail
  safely without logging headers, tokens or server payloads.
- Ready navigates to a minimal nested product read view: no bottom dock, Pickwell
  title, numeric score or Add to List. It renders actual returned facts/unknowns;
  demo records remain labeled fictional. Missing products navigate to the validated
  Barcode ✓ → Nutrition → Ingredients entry route.

The capture entry is the minimum working destination needed for this navigation:
users can take two local label photos and retake the pair. Images are held in RAM;
just-taken camera cache files are deleted after reading. It offers **no fake Analyze,
OTP, upload or submission action**. Full review, individual retake, draft survival,
consent/submission and process-death cleanup remain T04.1/T04.2. Native capture and
photo selection have not been exercised by a person in this run. Gallery originals
are not deleted. No server or permanent product-photo storage was added.

## Local references and persistence

`PICKWELL_RECENT_PRODUCTS_V1` stores at most 30 unique canonical barcodes and UTC
`opened_at` values. Writes serialize and deduplicate. No account IDs, names, photos,
raw AI payloads or full nutrition/analysis are persisted. Ready data is session RAM
only, bounded alongside recent references. Optional write failures retain a usable
result and surface a save warning. Corrupt entries recover safely.

After relaunch, references can appear as neutral barcode cards; opening them refreshes
through the normal backend/quota path. There is no automatic 30-request startup
refresh and no promise of full offline product results. Search filters only loaded
local records. This minimum index is necessary for T03.2 Home; T03.3 must reuse it
and verify/polish its remaining acceptance rather than regenerating it.

## Actual validation

Toolchain: Flutter **3.47.7**, Dart **3.13.5**, existing package language 3.12.
Commands ran from `mobile/` unless noted:

| Command/check | Observed result |
| --- | --- |
| `mason make feature-cubit --name catalog --output-dir ../.secrets/catalog-scaffold --on-conflict skip` | Generated the pinned 26-file scaffold; adapted it before UI wiring. |
| `fvm flutter pub add mobile_scanner:7.5.0 image_picker` | Added the two required plugins and their platform dependencies; existing packages were not broadly upgraded. |
| `fvm flutter pub get --enforce-lockfile` | Passed. |
| `fvm flutter gen-l10n` | Generated all supported locale outputs. New feature copy currently has explicit English fallback values in all locale ARBs; reviewed translations remain pending. |
| `fvm dart run build_runner build` | Regenerated DI/Home state and affected outputs; unrelated generated formatting churn was restored. |
| `fvm dart run build_runner build --define=freezed:freezed=format=true --build-filter=lib/src/features/home/presentation/blocs/home/home_cubit.freezed.dart` | Generated formatted Home state without manually editing generated code or changing unrelated generator outputs. Use this reproducible step after a default full generator run to avoid its new trailing-whitespace output. |
| `fvm flutter analyze --no-pub` | Final run: **no issues found**. |
| `fvm flutter test --no-pub test/catalog test/app_config_security_test.dart` | Final isolated run: **25 passed**. |
| `fvm flutter build ios --debug --simulator --no-pub` | Passed; simulator app installed/launched and actual Home screenshot inspected. |
| `fvm flutter build ios --debug --no-pub` | Passed with the existing signing team/bundle configuration. |
| `xcrun devicectl device install app` / `device process launch` for the connected iPad | Installation and process launch succeeded. This is not proof of camera permission, recognition or live lookup. |
| `fvm flutter build apk --debug --no-pub` | Passed. Existing in_app_review/location/posthog KGP compatibility warnings remain; no unrelated package upgrade was attempted. |
| Secret-pattern scan, relative-import check and `git diff --check` | Passed. No secret configuration/session values printed or committed. |

The focused tests cover common EAN/UPC/check digits and UPC-E expansion, all lookup
states, permission-denial recovery state/UI, duplicate suppression, stable retry
keys, stale responses after route closure, bounded concurrent reference writes,
corrupt storage, optional save failure, public DTO validation, new-scan vs local-open
quota semantics and stale-cache eviction. Widget tests cover guest empty Home,
loaded cards/search, far-right scan action, hidden nested dock, actual scanner
listener ready/miss routing, optional-auth route policy, and 320-pixel/2× text
light/dark layouts. An initial large-text filter overflow was fixed. Semantics and
stale-cache tests were corrected before the final clean run. These tests use fakes;
they do not prove platform barcode decoding or hosted function integration.

Codegen warns that SDK language 3.13 is newer than its pinned analyzer language 3.12;
generation completed and Flutter static analysis/builds passed. Kept the documented
compatible generator group instead of upgrading dependencies during this task.

## Unmet acceptance and exact next actions

1. **Real-device scan deferred by the user.** A physical iPad is connected and the
   development build installed/launched, but no barcode was presented/decoded here.
   Native camera permission denial/grant, torch support, gallery decoding, EAN/UPC
   recognition and label-photo capture remain unverified. No Android device was tested.
2. **Configured hosted `get-product` GET returned HTTP 404.** This was a read-only
   availability probe, not a barcode lookup or model request. The mobile live ready/
   miss acceptance cannot pass until the intended hosted schema/function is reviewed
   and deployed with its private network-HMAC/ingress configuration. No hosted
   migration, function deployment or secret changes were made by this task.
3. **Brand source art missing.** Replace the labeled emoji placeholder with the
   approved whole-lemon mark when supplied; retain truthful thumbnail placeholders
   unless authorized media exists. Native icon/splash replacement remains pending assets.
4. **New feature translations are English fallbacks**, not verified localized copy.
   Full capture/review/submission and polished results/usage/Settings remain later tasks.

Default app builds intentionally preserve disabled backend/auth integrations. To
exercise the real lookup after deployment, run with the existing ignored public
configuration (`--dart-define-from-file=.secrets/dev.secrets`): backend enabled,
optional auth, billing disabled and onboarding disabled. No new mobile secret is
needed. Never add Meta/service-role/server-HMAC credentials to Dart defines.

Verified T03.2 implementation checks: Home, dock/navigation, Cubit states, tested
ready/miss route transitions and optional manual entry. Scanner/permission/native
format checkboxes remain open pending the deferred hardware test. Overall status
is **PARTIAL**, not a claimed functioning end-to-end MVP. No AI charges, backend
writes, purchases or public unauthenticated inference endpoints were introduced.

Next dependency: deploy/verify the already implemented T03.1 read backend and perform
the deferred physical test. Next planned development task is T03.3 (reuse the index);
do not automatically start it or later analysis/auth phases.

Plugin references: [mobile_scanner](https://pub.dev/packages/mobile_scanner) and
[image_picker](https://pub.dev/packages/image_picker). No generated images or assumed
attached mockups were used.

<details>
<summary>Exact changed-file inventory</summary>

```text
docs/PICKWELL_SCANNER_HOME.md
docs/PICKWELL_TASKS.md
mobile/README.md
mobile/android/app/src/main/AndroidManifest.xml
mobile/ios/Runner/Info.plist
mobile/lib/src/config/injection_container.config.dart
mobile/lib/src/config/router/app_router.dart
mobile/lib/src/config/theme/app_color_scheme.dart
mobile/lib/src/core/storage/data_storage.dart
mobile/lib/src/features/_features.dart
mobile/lib/src/features/catalog/catalog.dart
mobile/lib/src/features/catalog/data/_data.dart
mobile/lib/src/features/catalog/data/data_sources/_data_sources.dart
mobile/lib/src/features/catalog/data/data_sources/catalog_local_source.dart
mobile/lib/src/features/catalog/data/data_sources/catalog_remote_source.dart
mobile/lib/src/features/catalog/data/data_sources/services/_services.dart
mobile/lib/src/features/catalog/data/data_sources/services/catalog_api_service.dart
mobile/lib/src/features/catalog/data/data_sources/services/scanner_media_service.dart
mobile/lib/src/features/catalog/data/models/_models.dart
mobile/lib/src/features/catalog/data/models/catalog_model.dart
mobile/lib/src/features/catalog/data/repositories/_repositories.dart
mobile/lib/src/features/catalog/data/repositories/catalog_repository.dart
mobile/lib/src/features/catalog/domain/_domain.dart
mobile/lib/src/features/catalog/domain/entities/_entities.dart
mobile/lib/src/features/catalog/domain/entities/catalog_entity.dart
mobile/lib/src/features/catalog/domain/repositories/_repositories.dart
mobile/lib/src/features/catalog/domain/repositories/catalog_repository.dart
mobile/lib/src/features/catalog/domain/use_cases/_use_cases.dart
mobile/lib/src/features/catalog/domain/use_cases/get_catalog_use_case.dart
mobile/lib/src/features/catalog/presentation/_presentation.dart
mobile/lib/src/features/catalog/presentation/blocs/_blocs.dart
mobile/lib/src/features/catalog/presentation/blocs/catalog/catalog_cubit.dart
mobile/lib/src/features/catalog/presentation/blocs/catalog/catalog_state.dart
mobile/lib/src/features/catalog/presentation/blocs/catalog/label_capture_cubit.dart
mobile/lib/src/features/catalog/presentation/views/_views.dart
mobile/lib/src/features/catalog/presentation/views/capture_entry_view.dart
mobile/lib/src/features/catalog/presentation/views/catalog_view.dart
mobile/lib/src/features/catalog/presentation/views/product_detail_view.dart
mobile/lib/src/features/catalog/presentation/widgets/_widgets.dart
mobile/lib/src/features/catalog/presentation/widgets/catalog_widget.dart
mobile/lib/src/features/catalog/presentation/widgets/lookup_notice.dart
mobile/lib/src/features/home/presentation/blocs/home/home_cubit.dart
mobile/lib/src/features/home/presentation/blocs/home/home_cubit.freezed.dart
mobile/lib/src/features/home/presentation/blocs/home/home_state.dart
mobile/lib/src/features/home/presentation/views/home_view.dart
mobile/lib/src/features/root/presentation/views/root_view.dart
mobile/lib/src/features/root/presentation/widgets/nav_item.dart
mobile/lib/src/localization/l10n/app_ar.arb
mobile/lib/src/localization/l10n/app_de.arb
mobile/lib/src/localization/l10n/app_en.arb
mobile/lib/src/localization/l10n/app_es.arb
mobile/lib/src/localization/l10n/app_fr.arb
mobile/lib/src/localization/l10n/app_hi.arb
mobile/lib/src/localization/l10n/app_it.arb
mobile/lib/src/localization/l10n/app_ja.arb
mobile/lib/src/localization/l10n/app_ko.arb
mobile/lib/src/localization/l10n/app_localizations.dart
mobile/lib/src/localization/l10n/app_localizations_ar.dart
mobile/lib/src/localization/l10n/app_localizations_de.dart
mobile/lib/src/localization/l10n/app_localizations_en.dart
mobile/lib/src/localization/l10n/app_localizations_es.dart
mobile/lib/src/localization/l10n/app_localizations_fr.dart
mobile/lib/src/localization/l10n/app_localizations_hi.dart
mobile/lib/src/localization/l10n/app_localizations_it.dart
mobile/lib/src/localization/l10n/app_localizations_ja.dart
mobile/lib/src/localization/l10n/app_localizations_ko.dart
mobile/lib/src/localization/l10n/app_localizations_pt.dart
mobile/lib/src/localization/l10n/app_localizations_ru.dart
mobile/lib/src/localization/l10n/app_localizations_zh.dart
mobile/lib/src/localization/l10n/app_pt.arb
mobile/lib/src/localization/l10n/app_ru.arb
mobile/lib/src/localization/l10n/app_zh.arb
mobile/pubspec.lock
mobile/pubspec.yaml
mobile/test/catalog/catalog_cubit_test.dart
mobile/test/catalog/catalog_repository_test.dart
mobile/test/catalog/home_widget_test.dart
```

</details>
