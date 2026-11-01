# Mobile template development rules

These instructions apply to `mobile/`. Paths below are relative to this directory
unless stated otherwise. Read [README.md](README.md) for setup and supported app
recipes, and [fastlane/README.md](fastlane/README.md) before working on store setup.
Inspect the implementation first: scaffolds and examples do not establish that a
service is implemented.

## Preserve a working starter

- Keep this a reusable consumer-app template. Organizations, workspaces,
  memberships, and team billing require a separately requested design.
- The default configuration keeps auth, backend, billing, onboarding, analytics,
  and crash reporting disabled. Keep `config/app.example.json` and the README
  configuration reference synchronized so enabled integrations document their
  required values.
- Preserve reusable auth, onboarding, billing, and platform capabilities. Use
  configuration to disable unused integrations; remove a capability only when the
  user requests that change for their project.
- Deliver complete behavior: state, navigation, persistence where needed,
  loading/error/empty states, and disabled-mode behavior. Do not add visible
  controls with empty callbacks, fake saves, or promises of unimplemented features.
- Keep product copy, assets, catalogs, and business rules in their feature or app
  configuration. Do not import Sitflow/Habito-specific design tokens, onboarding
  questions, analytics events, or billing assumptions into shared template code.

## Configuration and startup

Use `lib/src/config/app_features.dart` for integration switches/access mappings,
`app_config.dart` for configuration and validation, and `flavor/app_flavor.dart`
for dev/stg/prod selection. Update `config/app.example.json` and README recipes
when adding or changing defines.

- Preserve `AUTH_MODE=disabled|optional|required` and
  `BILLING_MODE=disabled|revenuecat`. Auth enables the backend; backend-only apps
  can set `BACKEND_ENABLED=true` without exposing auth UI.
- Enable onboarding, notifications, analytics, and crash reporting independently.
  `ONBOARDING_PAYWALL_ENABLED` requires billing and affects enabled onboarding.
- When configuring `FEATURE_ENTITLEMENTS` or `FEATURE_OFFERINGS`, use feature
  keys that exist in the app's guards and the exact RevenueCat entitlement and
  offering IDs supplied by the app owner. Agents may fill these mappings when
  those values are known; they must not invent product identifiers. For a simple
  one-entitlement/current-offering setup, leave both values as the valid empty
  mappings `{}`. Keep them as escaped JSON strings in `config/app.example.json`.
- Validate required values only for enabled services. Do not initialize disabled
  SDKs or resolve dependencies that require a disabled Supabase client.
- Preserve startup ordering in `lib/main.dart`: enabled backend, DI/session state,
  then dependent integrations. Keep the startup failure UI and splash cleanup.
- Dart defines ship inside the app. Use public SDK/publishable keys only. Keep
  service-role keys, store service accounts, private API keys, and signing files
  outside Flutter configuration, Git, logs, and template archives.

## Add or extend a feature

Use `lib/src/features/<feature_name>/` with snake_case filenames. Follow these
layers when needed; do not create empty layers simply to match a directory tree:

```text
<feature_name>/
  <feature_name>.dart           # public feature exports
  data/
    data_sources/              # local/remote sources and service wrappers
    models/                    # source-specific models and serialization
    repositories/              # repository implementations
  domain/
    entities/                  # business values
    repositories/              # repository contracts
    use_cases/                 # operations consumed by Cubits
  presentation/
    blocs/<operation>/         # Cubit and immutable state
    views/                     # route-level screens
    widgets/                   # feature components
```

1. Define whether the feature is local, account-only, backend-enabled, or paid,
   including guest, offline, and disabled-integration behavior.
2. Add entities, repository contracts, and use cases for data/business operations.
   Domain code must not depend on widgets, Cubits, concrete data implementations,
   or plugin clients. Follow `FutureEitherUseCase` / `Either<Failure, T>` conventions
   for repository-backed operations.
3. Implement data sources, serialization, mapping, and repositories in `data/`.
   Inject external boundaries with GetIt/Injectable. Register shared clients in
   `lib/src/config/register_module.dart`; use replaceable interfaces such as
   `BillingClient` for platform services.
4. Keep async work and state transitions in Cubits. Widgets render state and
   dispatch actions; keep HTTP, SQL, purchases, and SDK calls out of widget builds.
5. Update layer barrels and `<feature_name>.dart`. Export through
   `lib/src/features/_features.dart` when needed. Prefer narrow lower-layer imports
   so barrels do not introduce dependency cycles.
6. Wire routes, access policies, entry points, localization, and configuration.
   Add backend migrations/account cleanup if storing account data.
7. Regenerate affected outputs and validate the new flow and default app.

Shared infrastructure belongs in `lib/src/core/`, app wiring in
`lib/src/config/`, and reusable UI in `lib/src/features/app/`. Extract components
with reusable contracts; keep business-specific behavior inside its feature.

## State, routing, and lifecycle

- Use Bloc/Cubit and immutable state. Represent loading, failure, empty, and
  success explicitly, with retry/recovery actions where useful.
- `BlocProvider.value` exposes an existing DI singleton without closing it.
  `BlocProvider(create: ...)` owns a new route-scoped Cubit and closes it.
  Match provider ownership to the DI lifetime; do not reuse closed Cubits.
- Check `isClosed` after async work before emitting, and `context.mounted` or
  `mounted` before navigation, dialogs, or widget updates after an await.
- Dispose controllers, timers, subscriptions, and listeners at their owner's
  disposal. Handle fire-and-forget failures explicitly; `unawaited` does not
  handle errors. Serialize identity changes and discard stale async responses.
- Use selectors or `buildWhen` to avoid unrelated app-shell rebuilds. Do not fetch
  services, construct Cubits, or repeatedly start work from `build`.
- Add route definitions in `lib/src/config/router/app_router.dart`. Extend
  `consumer_route_policy.dart` for new account or integration-dependent routes.
  Hiding an entry point does not protect direct routes or backend operations.
- Preserve optional-auth browsing, account-route protection, required-auth
  redirects, legal access, recovery, and return navigation after sign-in. Validate
  route arguments/deep links; do not require `state.extra` for externally opened links.
- Use `AppSession` for reactive session/onboarding routing state rather than
  competing flags in individual screens.

## Authentication, backend, and persistence

- Supabase UUIDs are strings. The Retrofit get-by-integer-ID services for
  profile/settings/notifications/paywall are scaffolds, not working Supabase CRUD
  endpoints. Implement the real contract rather than copying placeholder URLs or
  models. Current profile editing uses `AuthActions`.
- Preserve password bytes; do not trim passwords or restrict them to ASCII.
  Keep signup verification, recovery, and disabled-provider behavior distinct.
- Changing an OAuth scheme requires updating `AUTH_REDIRECT_URL`, Android's
  intent filter, iOS `CFBundleURLTypes`, and the Supabase redirect allowlist.
  Preserve callback ownership so Flutter routing does not compete with Supabase
  app-link handling.
- Use `DataStorage` and centralized `DataStorageKeys` for preferences, secure
  storage for sensitive values, and Drift for structured data. Handle missing or
  malformed data and failed writes.
- Preserve `runCacheOperation` / `writeOptionalCache` semantics: optional cache
  writes must not turn successful remote requests into failures. Avoid unhandled
  cache futures; required saves must not silently report success after failure.
- Separate device-local data from account caches. Extend
  `AuthActions.clearAccountCache` when adding account data; sign-out, account
  switching, and deletion must clear it without wiping guest preferences.
- Drift starts with no tables. Add tables, bump the schema version, and implement
  upgrade migrations together. Preserve generated-app user data; `createAll`
  alone is not an upgrade strategy.
- Add schema, buckets, and RLS through migrations under `../supabase/`. Verify
  ownership server-side; keep roles, entitlements, and paid quotas server-managed.
  Uploads belong under `<userId>/...`. Extend the delete-account function for new
  user-owned records/buckets. Account deletion does not cancel store subscriptions;
  communicate that distinction in the account flow.

## Pricing, products, and access

Identify the requested kind of pricing before editing:

| Change | Configuration |
| --- | --- |
| Paid app download price | Project copies of `fastlane/pricing/prices.example.json` / `.csv`; see Fastlane README for platform limits |
| Subscriptions, lifetime unlocks, base plans, offers | Project copies of `fastlane/commerce/app_store.example.json` and `google_play.example.json` |
| Plans shown on a paywall | RevenueCat offerings/packages linked to store products |
| Feature unlocks | `REVENUECAT_ENTITLEMENT_ID`, `FEATURE_ENTITLEMENTS`, `FEATURE_OFFERINGS` |

- Keep examples generic and real catalogs project-owned. Replace store/app IDs,
  product IDs, subscription groups/base plans, currencies, regions, prices, and
  effective dates deliberately. Do not overwrite real catalogs with sample
  products or accidentally activate offers or migrate subscriber price cohorts.
- Dart price strings do not change store prices. Display
  `storeProduct.priceString` and the fetched package's billing period. Do not
  hardcode currencies, trial durations, discounts, or monthly/annual-only lists.
  Select packages by their actual identifiers, including lifetime unlocks.
- Update equivalent platform catalogs together and verify RevenueCat product,
  entitlement, and offering links. Successful payment or an unrelated active
  entitlement does not establish access to the requested feature.
- `FEATURE_ENTITLEMENTS` and `FEATURE_OFFERINGS` are JSON strings in define files.
  Null entitlement means free; guards without a feature key use the default
  entitlement. Named features require explicit mappings. Billing disabled denies
  premium guards; only explicitly free mappings or deliberate local allowances
  grant access. Client flags and snapshots are not server authorization.
  Unknown named offerings must show unavailable plans instead of silently using
  the default offering.
- Use `PremiumGuard` for UI and `PaywallAccess.requirePremium` / `run` for actions.
  Recheck access after a paywall closes before resuming the action. Soft paywalls
  are dismissible nudges; enforce paid API operations and quotas on the server.
- Preserve guest RevenueCat identity on cold starts. Serialize account changes,
  clear cross-account access immediately, and retain same-identity cached access
  during transient failures, bounded by known expiration. Explicit verification
  failures clear cached access. Keep SDK payloads in the data/presentation layers;
  domain entitlement contracts must remain independent of RevenueCat types.
  Unknown access needs retry rather than an assumption
  that the user is unsubscribed.
- Keep success, cancellation, pending approval, no restored access, and failures
  distinct. Preserve restore purchases and store subscription management.
- Follow `fastlane/README.md`: preflight, then review supported `dry_run:true`
  pricing/commerce operations. Dry runs may need credentials/network; do not
  describe them as offline checks. Live changes require an explicitly authorized
  store-update task; local config edits do not authorize publishing prices,
  activating products, or uploading listings.
- Extend existing Fastlane setup rather than replacing it. These listing,
  pricing, and commerce lanes do not upload app binaries.

## Optional subscription backend

- The module at `../supabase/modules/subscriptions/` is opt-in. Read its README
  before installing. Do not make backend/auth mandatory for free or offline apps.
- Signed-in Supabase UUIDs map to RevenueCat app user IDs. Never accept a client
  customer ID, guest alias, premium flag, or feature map as backend authorization.
- Keep RevenueCat secret keys/webhook authorization only in server secrets.
  Production policies must never accept sandbox grants.
- Apply `has_entitlement` to actual paid RLS policies or authenticated Edge
  Functions. Installing the module alone does not protect product APIs. Audit
  other permissive policies so they cannot bypass paid access.
- Run the module's isolated tests and, after installation, its pgTAP suite on the
  local Supabase stack. Keep account deletion cascades, freshness limits, retry
  behavior, and identity isolation when extending the module.

## Billing release preflight

- Read `config/README.md` and maintain `config/features.json` with every premium
  guard/action and every named free guard. Declare unnamed default premium guards
  through `default_premium_guard`. Keep exact feature keys and app-owned IDs.
- Free apps retain an empty catalog and disabled billing. Unnamed premium guards
  retain empty entitlement/offering mappings; named features require mappings.
- Production builds run `tool/check_billing_config.py` through Makefile targets.
  Keep the checked `APP_CONFIG` identical to the file passed to Flutter, and update
  the authored Makefile plus packaged `Makefile.prod` when changing build wiring.
- Run the preflight separately before a direct Flutter release command. It checks
  local consistency, not live RevenueCat catalogs or deployed server policies.
- A `server` declaration requires installed optional module artifacts and auth.
  It is public metadata, not proof that APIs have entitlement enforcement. Verify
  actual RLS/functions and server secrets before deploying the generated app.
- Never ship server credentials in Dart defines. Preflight checks known private
  credential types without printing values. Keep optional integrations optional.
- Validate tooling changes with `python3 -m unittest discover -s tool -p 'test_*.py'`
  and confirm generated archives include the catalog, validator, and build gate.

## Onboarding

Opt in through `ONBOARDING_ENABLED`. Customize
`lib/src/features/onboarding/presentation/` without making sample content,
authentication, or purchases mandatory for every generated app.

- Update `OnboardingView`, widgets, `OnboardingState`, and Cubit setters together.
  Preserve stable answer keys/backward-compatible serialization; regenerate
  JSON/Freezed output. Use stable values rather than translated labels for new answers.
- Synchronize step counts/indexes, progress, validation, back/next/skip behavior,
  and conditional notification pages. Handle persisted slide indexes safely when
  inserting/removing steps so returning users can resume.
- Persist answers through `OnboardingCubit`, await `save()`, then call
  `AppSession.completeOnboarding`. Navigate only after required writes succeed,
  show retry on failure, and preserve completion across relaunch.
- Make the final step work in all auth modes; hide disabled provider/account
  prompts. Show an optional onboarding paywall only when billing and
  `ONBOARDING_PAYWALL_ENABLED` are enabled; dismissal must continue into the app.
- Request permissions when users choose the feature. Respect
  `NOTIFICATIONS_ENABLED`, denial, and "not now"; completion must not require
  permission. Do not simulate profile analysis or promise unsupported features,
  trials, or reminders.

## Themes, shared UI, and settings

Theme paths below are under `lib/src/config/theme/`:

| Concern | File/module |
| --- | --- |
| Default light/dark palette | `app_color_scheme.dart` |
| Additional palettes/catalog | `color_schemes/` and `color_schemes/theme_state.dart` |
| Shared spacing, padding, typography, durations | `app_base_theme.dart` |
| Custom token types | `app_theme_data.dart` |
| Material component and text theme | `app_theme.dart` |
| Colors, shadows, gradients | Existing theme extensions |

- Derive styles from the supplied `ColorScheme`. Use `context.colorScheme`,
  `context.textTheme`, and existing custom theme data in widgets. Keep product
  colors and one-off shapes out of global tokens.
- Add tokens only for real shared needs; update constructors, `copyWith`, and
  transition behavior together. Prefer standard `TextTheme` styles to unused
  duplicate body/caption fields. `AppThemeData.lerp` currently does not interpolate
  nested values; implement it if smooth custom-token transitions are needed.
- Keep theme/locale IDs stable because selections are persisted. Preserve the
  default theme as the first catalog entry and migrate or fall back when retiring
  an ID. Supply both light/dark themes for every palette.
- Persist selections through `SettingsCubit`. Preserve `ThemeMode.system`,
  account-free language/theme settings, and root rebuild filtering.
- Use safe areas, shared spacing/padding, bounded content widths, readable contrast,
  accessible touch targets, and scrollable layouts as needed. Check small screens,
  keyboard visibility, larger text, RTL, and both brightness modes.
- Gate settings entries by the corresponding feature flags and auth state. Keep
  debug controls debug-only. App-specific release notes belong in
  `AppRelease.releases`; keep review/release prompts optional.

## Localization, branding, notifications, and logging

- Add user-facing text to `lib/src/localization/l10n/app_*.arb`, preserving
  placeholders and updating supported translations. Run `fvm flutter gen-l10n`;
  do not hand-edit localization outputs or propagate hardcoded sample copy.
- Use `AppConfig` for app name and support/legal/store URLs. Branding also includes
  native names/IDs, callback schemes, localized titles, icons, splash, and listings.
- Declare assets in `pubspec.yaml`, regenerate FlutterGen, and use `AppAssets` /
  `AppFonts`. Regenerate launcher icons/native splash only when inputs change.
- Keep notifications behind `NotificationManager` and its feature flag. Respect
  permission and persisted reminder preferences; use local timezone and actual
  entitlement expiration dates for trial reminders. Cancel reminders when identity,
  access, or preferences change. Introducing precise scheduling requires handling
  its platform permission requirements.
- Local reminders are not remote push or an inbox. Implement mobile/server
  delivery and registration together when adding push or notification records.
- Keep PostHog/Sentry opt-in. Use `AppLogger` for operation summaries and errors
  with stack traces. Never log passwords, tokens, personal models, or raw API
  responses; sanitization is an additional safeguard. Add product analytics and
  consent behavior deliberately rather than forcing tracking into defaults.

## Imports, generated code, and tooling

- Use relative imports for project-owned Dart files, including tests. Reserve
  `package:` imports for dependencies/SDK packages; do not add
  `package:pickwell/...` imports.
- Follow existing style: snake_case files, single quotes, `const` where possible,
  and the formatter's 100-column setting. Keep exports consistent.
- Edit source inputs, not generated `.g.dart`, `.freezed.dart`,
  `.auto_mappr.dart`, DI outputs, resources, or localization classes. Regenerate
  and review outputs. If a generator emits project-absolute imports, address its
  configuration or a reproducible generation step instead of repeated manual
  edits. Avoid unrelated generated formatting churn.
- Use FVM and existing dependency constraints. `.fvmrc` tracks `stable`;
  Flutter 3.47.7 / Dart 3.13.5 is the documented baseline, not a pinned FVM release.
  Dart package language mode stays at 3.12 for the current generator group.
  Upgrade compatible runtime/generator packages together; do not indiscriminately
  upgrade dependencies while adding a feature.
- Preserve iOS SPM, deployment target 15+, generated package references, and the
  Prepare Flutter Framework scheme pre-action. Do not restore CocoaPods or commit
  `ios/Flutter/ephemeral`; verify new plugins support SPM.
- Preserve Java 17, Android minimum SDK 26, compile SDK at least 37, and existing
  Flutter-managed SDK settings. Check build-tool/plugin changes on both platforms.
- Preserve template packaging: authored `Makefile` versus `Makefile.prod` renamed
  to `Makefile` for generated projects. Use `tool/package_template.py` and extend
  credential exclusions when adding files. Retain the existing Fastlane setup.
- The template currently prescribes local checks. Do not introduce hosted CI or
  replace deployment automation as an incidental feature change.

## Validate and finish

For application changes, run from `mobile/`:

```sh
fvm flutter pub get --enforce-lockfile
# When state, models, DI, mappings, assets, or database inputs changed:
fvm dart run build_runner build
fvm flutter analyze --no-pub
fvm flutter test --no-pub
```

Keep existing tests runnable without live credentials, using injected service
fakes. Add focused checks for meaningful routing, identity, async ordering,
persistence, and access changes. Do not impose blanket coverage or sample-content
assertions that force generated apps to retain product flows.

Treat tests as part of the template contract, not as immutable product
requirements. When an app intentionally changes or removes auth, billing,
onboarding, notifications, or another template capability, update or remove the
tests that assert the old behavior and add coverage for the replacement behavior.
Keep tests for capabilities the generated app still supports. Keep default-profile
smoke tests synchronized with the active defaults in `app.example.json`, and use
explicit injected configurations for tests that cover alternate modes.

Validate impacted combinations: offline defaults; disabled/optional/required auth;
billing with/without accounts; onboarding enabled/disabled; and notification
preferences. Check account isolation, direct routes, relaunch persistence,
failure/retry behavior, and light/dark themes as applicable.

- Native/plugin/build-config changes: `fvm flutter build apk --debug` and
  `fvm flutter build ios --debug --simulator` (requires macOS/Xcode).
- Backend changes: from the repository root, run `supabase db reset` and
  `supabase test db` on the local Docker stack. Do not use remote projects for local tests.
- Packaging changes: `python3 -m unittest discover -s tool -p 'test_*.py'`; inspect
  an archive for credentials/build caches and the production Makefile rename.
- OAuth, purchase/restore, account transfers, and reminders require the app's
  device/store-sandbox validation; unit/widget tests do not prove those integrations.
- Documentation-only edits: verify instructions, paths, and diff whitespace.
  Generation and native builds are unnecessary unless implementation also changes.

Before reporting completion, inspect the diff, preserve unrelated working-tree
changes, update setup/config examples when behavior changes, and state validation
and remaining device/service checks. Analysis alone does not prove runtime behavior.
