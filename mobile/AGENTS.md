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

Generate new feature skeletons from `mobile/` with
`mason make feature-cubit --name <feature_name>` after `make init-mason`
(alias: `make mason-init`). Use the checked-in `mason.yaml` and `mason-lock.json`.
Use the Cubit brick rather than event-based Bloc bricks. Preserve the full
generated scaffold and adapt it as functionality lands; unused example operations
must remain disconnected from live UI. Do not overwrite existing features by
regenerating them. Generate into a scratch directory first when reconciling an
existing feature, and inspect file conflicts explicitly.

The brick's remote/network examples, integer IDs, logging, and cache patterns are
scaffolds. Adapt them to Pickwell's actual repositories, identifiers, privacy,
and enabled integrations before wiring them. Generation does not authorize a
backend, SDK initialization, or additional product features. Do not copy `.mason/`
caches, generate a new base app, or invoke secrets/base bricks for feature creation.

Use `lib/src/features/<feature_name>/` with snake_case filenames. The generated
layers are:

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
  the `Makefile` when changing build wiring.
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

## Template UI conventions

- Before changing UI, read `../docs/APP_DESIGN_GUIDELINES.md` and any applicable
  app design specification. Review supplied references and check changed screens
  for spacing, typography, accessibility, and light/dark consistency.
- Search existing code before creating widgets, helpers, services, or tokens.
  Inspect `lib/src/features/app/`, especially `presentation/widgets/_widgets.dart`,
  and `lib/src/config/theme/`. Reuse or extend existing implementations rather
  than creating duplicates or a parallel design system.
- Define each widget in its own snake_case Dart file, including private widgets.
  Keep route screens in `presentation/views/`, feature widgets in that feature's
  `presentation/widgets/`, and reusable widgets under `features/app/`.
  Extract widget classes instead of widget-returning helper methods; update barrels.
- Use `Gap` from `package:gap/gap.dart` for sibling spacing, for example
  `Gap(context.themeData.dimensionsData.spacingMd)`. Use `SliverGap` in slivers.
  Reserve `SizedBox` for actual sizing/constraints or empty placeholders rather
  than spacing. Use padding presets for content insets.
- Use the existing `AppIcon` with `HugeIcons` icon data, for example
  `AppIcon(icon: HugeIcons.strokeRoundedHome01)`. `AppIcon` delegates HugeIcons
  rendering to `HugeIcon`; reuse that wrapper rather than creating another one.
  Use Material/Cupertino icon data through `AppIcon` when a platform-specific icon
  is needed. Use the named icon dimensions and theme colors.
- Edit `lib/src/config/theme/app_color_scheme.dart` for the default light/dark
  palette, and the existing theme modules below for shared styling. Use theme
  values in widgets rather than hardcoded colors or competing palette classes.
- Use `SheetDragHandle` and the sheet dimensions for shared floating sheets.

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
- Read dimensions through `context.themeData.dimensionsData` and inset presets
  through `context.themeData.edgeInsetsData`. New UI uses the explicit tokens:
  - Sibling gaps: `spacingXxs` 4, `spacingXs` 8, `spacingSm` 12, `spacingMd` 16,
    `spacingLg` 24, `spacingXl` 32, `spacingXxl` 40.
  - Insets: `paddingMicro` 2, `paddingXxs` 4, `paddingXs` 8, `paddingSm` 12,
    `paddingMd` 16, `paddingComfortable` 20, `paddingLg` 24, `paddingXl` 32,
    `paddingXxl` 40. Prefer existing `EdgeInsetsData` presets where applicable.
  - Shapes: `cornerRadius`, `cardCornerRadius`, `heroCornerRadius`,
    `nestedCornerRadius`, and `sheetCornerRadius`. Icons: `iconSmall`,
    `iconMedium`, `iconSize`, `iconLarge`; touch targets: `minimumTouchTarget`.
  Keep gaps, insets, shapes, and icon measurements separate. Do not invent
  variants through token arithmetic (such as `cornerRadius - 4`); use an existing
  token or add a justified shared dimension. Name one-off local measurements.
  Legacy spacing fields and inset presets retain their existing values for
  compatibility; do not silently change existing layouts when adopting new tokens.
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
- Preserve template packaging, including the existing `Makefile`. Use
  `tool/package_template.py` and extend
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
  an archive for credentials/build caches and the Makefile.
- OAuth, purchase/restore, account transfers, and reminders require the app's
  device/store-sandbox validation; unit/widget tests do not prove those integrations.
- Documentation-only edits: verify instructions, paths, and diff whitespace.
  Generation and native builds are unnecessary unless implementation also changes.

Before reporting completion, inspect the diff, preserve unrelated working-tree
changes, update setup/config examples when behavior changes, and state validation
and remaining device/service checks. Analysis alone does not prove runtime behavior.

## 1. Read first: mandatory order

1. Inspect the real repository root, directory layout, existing `AGENTS.md`, and current git diff/status. Preserve uncommitted user changes.
2. Read `PICKWELL_PRD.md` (v1.3), then `PICKWELL_DESIGN.md` (v1.1), `PICKWELL_SPEC.md` (v1.1), `PICKWELL_DATABASE.md` (v1.0), and `PICKWELL_TASKS.md` (v1.0). If filenames differ, locate the role-equivalent file; do not fabricate paths.
3. Follow the next verified unfinished TASKS task and its prerequisites. A stale unchecked box does not override real working code or user-reported completion.
4. Inspect existing Flutter templates, Cubit/Bloc patterns, routing, build flavors, package configuration, tests, Supabase migrations/functions, and dependency injection before modifying them.
5. When documents conflict, stop the *affected step*, report the conflict with file/section references, and preserve the latest user-approved product decisions below. Do not invent a new monetization, auth, or UX policy.

## 2. Locked MVP product decisions

- Project is **Pickwell AI V2**, repository `pickwell-ai`; this is a lasting product revival, not a disposable hackathon demo.
- Flutter iOS and Android, reusing existing StartAppLab boilerplate. Cubit/Bloc is preferred when already established in the template.
- **Barcode-first:** scan → secure Supabase lookup. For a `ready` barcode, return saved product data with **zero Meta AI calls**.
- Missing barcode: guided three-step flow **Barcode ✓ → Nutrition facts image → Ingredients image**. Support preview and retake. Product name and brand are optional.
- Guests may barcode-scan and view published cached results **without signing in**.
- A user may capture labels as a guest, but **must sign in using verified Supabase Email OTP before submitting new AI analysis**; retain photos and barcode through the auth interruption.
- New-product analysis runs **through authenticated Supabase Edge Functions**, calling an approved Meta multimodal model, then validating extracted ingredient/nutrition facts and reasoned findings on the server.
- Use **evidence-aware green/yellow/red findings with explicit reasons and references/rules**; never treat color as an independently verified health verdict. No arbitrary 0–100 score.
- Publish a reusable shared product only after automated validation. Incomplete/unreadable or inconsistent label data must request retake; never publish invented facts.
- No permanent retention of submitted label photos after successful extraction; temporary private storage, if needed, requires failure/orphan cleanup and access limits.
- **Free quotas:** initial 30 barcode lookups/day for attributable signed-in users, 3 successful new-product AI analyses/day per verified signed-in user, UTC midnight reset. Guests use best-effort lookup throttling, **not guaranteed per-person 30/day**. Quotas are mutable server-side.
- Both nutrition and ingredients images count as **one** analysis for one product. Failed extraction and bounded retakes do not consume successful-analysis credits. Reserve atomically to bound concurrent spend.
- Backend is **Supabase PostgreSQL, Edge Functions, Supabase Auth**. Meta API secrets and privileged Supabase credentials remain on server only.
- **RevenueCat is selected** for eventual paid subscriptions. Prepare server-side Free/Premium entitlements, identity mapping and safe webhook event handling, with **billing/paywall/purchases disabled** during hackathon. Do not assume Premium pricing, limits, or entitlement IDs.
- Minimal first-party operational analytics and AI cost tracking; no unrelated third-party analytics or billing services without approval.
- No unnecessary feature work: **AI chat, cosmetics, barcode-free analysis, numeric food score, product comparison, alternative recommendations, history/offline favorites, community, broad localization, elaborate onboarding, subscription paywall** remain deferred.

## 3. Operating boundaries

### Flutter (untrusted client)

- The Flutter app may contain the **Supabase URL and publishable key only**; an existing legacy anon key is acceptable only if the repository already uses it.
- Do **not** include Meta API keys, Supabase secret/service-role keys, raw database passwords, RevenueCat webhook secrets, or admin bypass tokens in Flutter binaries, `.env` assets or public repo.
- Backend determines `plan`, `entitlement`, quota remaining, whether a record is published, findings, and trusted user identity. Client-controlled flags must not authorize privileged behavior.
- Keep UI responsive and states explicit: `scanning`, `checking`, `ready`, `not_found`, `processing`, `needs_retake`, `auth_required`, `rate_limited`, `quota_exceeded`, `network_error`.
- A network timeout or DB failure is **not** a product-not-found result.
- Follow DESIGN for scan, capture, OTP, processing, result, and minimal account/settings states; retain readable icons/text independent of colors.
- Request camera access only when needed. Choose existing project-approved camera/gallery packages before adding dependencies. Do not claim camera functionality is validated without actual device testing.

### Supabase database and Edge Functions

- Enforce RLS on exposed tables, deny **direct client writes** to the shared catalog, analyses, usage, jobs, entitlements and RevenueCat events.
- `get-product` is a controlled **public lookup** with sanitized published output and protective throttling; **never invokes Meta AI**.
- `analyze-product` is a **verified-user-only** expensive operation. Verify JWT/identity and verified email **inside backend**, then check barcode cache, plan and quota; validate images, charge/reserve atomically, invoke Meta, validate and publish.
- Do not interpret a Supabase `authenticated` database role alone as proof of verified non-anonymous identity.
- Use normalized/validated barcodes, unique constraints, transaction-safe job leases, idempotency keys, bounded retries, and duplicate prevention so two concurrent submitters do not publish conflicting records or issue unnecessary repeated AI calls.
- Protect all security-definer functions and grants; test with public and authenticated roles, not only privileged service clients.
- Limit image count, byte size, formats and processing time. Never log raw images, passwords, OTP codes, tokens, private API payloads, or personally identifying information unnecessarily.
- Avoid permanent photo retention. If private temporary storage is required, clean it on success and through a bounded orphan/failed-job expiry process.
- Configure quota limits in server data, not app constants; UTC resets, exact signed-in usage, guest best-effort throttling. Separate **user quota** from **global AI spend and concurrency** limits.

### Meta API and evidence requirements

- First critical integration gate: **actual** Supabase Edge Function makes a successful multimodal Meta API call with both nutrition and ingredient photos; model/account access and current request limits remain unverified until tested.
- Model output must be schema validated. Preserve literal printed label values, units, serving-size basis, raw ingredient text, missing fields, provenance, model and prompt versions.
- Never invent references, nutritional quantities, dosage implications, ingredient dangers or medical advice. Distinguish label facts, explanatory inferences, and external evidence.
- AI can draft explanations, but code must own deterministic thresholds, final classifications, and publication acceptance. If evidence insufficient, ask for retake/mark unknown rather than asserting safety.
- Use product-specific wording; do not label a food as universally “healthy” or “unhealthy” or guarantee allergen absence.

### RevenueCat readiness (no live billing)

- Prepare future `free`/`premium` plan resolution, entitlements, stable verified Supabase user identity linkage, and protected, idempotent webhook/event ledger according to DATABASE/SPEC.
- Keep `billing_enabled=false` and normal users on Free. Backend test Premium grants must be privileged, labeled and isolated; **never** trust app-supplied Premium.
- RevenueCat purchase products, offering IDs, subscription prices, trial details and Premium daily allowances are not approved. Do not invent them.
- If not configured to validate webhook authentication and reconcile out-of-order/duplicate events, **do not deploy a public webhook**.
- Do not add RevenueCat SDK checkout, paywall screens, purchase buttons or entitlement-granting client paths in the hackathon build. Future integration is a deliberate post-hackathon stage.

## 4. Coding standards and changes

- Respect existing repo conventions and package versions. Avoid wholesale scaffold replacement, unnecessary architecture refactors, broad reformatting, new services, and packages unrelated to the current task.
- Prefer small, reversible modifications and migrations; no destructive database operations without explicit authorization.
- Follow existing dependency injection and Cubit/Bloc convention; if a layer/pattern does not exist, document the smallest justified addition.
- Structured results and statuses must be typed and validated at trust boundaries. Error responses should not leak secrets or stack traces.
- Do not create artwork, mock product data pretending to be real, or false screenshots. Use labeled fixtures/placeholders when appropriate.
- Keep environmental values in `.env.example` as placeholders only; never store real credentials.
- For SQL schema creation, treat DATABASE.md's examples as a **blueprint**, not production-ready scripts. Write migrations against the actual existing schema and run RLS and role tests.
- For every added network/dependency integration, identify the minimum real verification required to claim it functions.

## 5. Task execution protocol

For each task:
1. Read its exact TASKS ID, prerequisites, acceptance criteria, related docs and current code.
2. State the planned minimal edits, known blockers, and whether any existing work already satisfies the task.
3. Implement only that task and immediately affected dependencies; defer adjacent phases.
4. Run **targeted tests** for changed code, permissions and server routes. Avoid blanket full-repository regression unless specifically requested or in final QA phase.
5. Update the relevant TASKS checkbox **only after actual verification**; do not mark speculative work done.
6. Deliver a completion report containing:
   - Task ID and what works
   - Actual changed files
   - Commands/tests run with observed results
   - Security, cost and performance considerations
   - Remaining blockers, credentials or approved UI assets needed
   - TASKS status changes, if any

**Do not** claim an Edge Function is deployed, a database migration is applied, a live Meta call completed, or an OTP email was sent unless it was actually verified. Never expose secrets in the report.

## 6. Definition of Done / gating checks

A task is done only when independently observable acceptance criteria are satisfied. Key critical-path gates:

1. Meta model can interpret two real product-label images through secured Supabase backend.
2. Guest cached scan returns a validated result, no sign-in, no AI call.
3. Unknown product leads to three-step capture, verified OTP, and secure analysis request preserving captured images.
4. Backend extracts and validates, requests retakes when needed, publishes safe shared analysis, and cleans up temp photos.
5. A new guest can scan that same barcode and receive cached data without any AI request.
6. Free quotas (30/3), UTC reset, concurrency and safe failures work; server config changes limits without app update.
7. Public database role cannot create/edit products or grant entitlements, bypass quotas or read private jobs.
8. RevenueCat-ready schema/event logic cannot grant Premium through arbitrary client input; no paywall flow is exposed.
9. Results remain understandable without color alone; no fabricated ingredients, nutrition or evidence.

## 7. Implementation priorities and escalation

- Prioritize Meta two-image API spike and Email OTP delivery early; both are external integration risks.
- Protect the main barcode → cache → capture → AI → publish → cache path first.
- If hackathon schedule tightens, postpone cosmetic polish, manual barcode entry, optional product-name editing and unconfigured RevenueCat webhook deployment; **never trade away verified auth, credential secrecy, RLS, quota controls, idempotency and truthful results**.
- If Meta multimodal API access is unavailable, record it as a blocker rather than silently swapping model providers.
- Only request user input when truly necessary (e.g., unavailable credentials/irreconcilable project conflict); otherwise make safe defaults consistent with docs and report assumptions.

## 8. Task/dependency index

- **Phase 0** `T00.1–T00.2`: repo audit and secret-safe configuration.
- **Phase 1** `T01.1`: Meta multimodal integration spike (hard feasibility gate).
- **Phase 2** `T02.1–T02.4`: migrations, RLS, quotas, minimal telemetry.
- **Phase 3** `T03.1–T03.2`: public lookup + Flutter scanning.
- **Phase 4** `T04.1–T04.2`: three-step image capture + Email OTP.
- **Phase 5** `T05.1–T05.3`: secure AI jobs, validation, publish and cleanup.
- **Phase 6** `T06.1–T06.4`: results, quota UI, RevenueCat backend readiness, minimal Settings.
- **Phase 7** `T07.1–T07.2`: integrated QA and hackathon handoff.

All future feature ideas go to a separately approved ROADMAP, not to TASKS checkboxes.

---

**Reminder:** The repository is not attached to this document. The coding agent must inspect the real working tree and existing instructions before applying `AGENTS.md` or beginning development.
