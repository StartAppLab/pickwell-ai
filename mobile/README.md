# Consumer Flutter starter

A configurable starting point for offline utilities, free account-based apps,
guest-first freemium apps, and authenticated subscription apps.

## Run without external services

Use Flutter **3.47.7 / Dart 3.13.5** through FVM:

```sh
fvm install
fvm flutter pub get --enforce-lockfile
fvm flutter run
```

The default app disables auth, backend, billing, onboarding, analytics, and crash
reporting. Themes, language selection, and local reminder infrastructure remain
available. No service credentials are required to start.

For an app-specific configuration, copy `config/app.example.json` to an ignored
file such as `.secrets/dev.secrets`, then run:

```sh
fvm flutter run --dart-define-from-file=.secrets/dev.secrets
```

Dart defines are embedded in the app. Only public SDK/publishable keys belong in
these files. Server secrets and store signing credentials must stay outside them.

### Configuration reference

Start from `config/app.example.json` and replace the placeholders for the
services you enable. Boolean values must remain JSON booleans in the file;
`FEATURE_ENTITLEMENTS` and `FEATURE_OFFERINGS` are JSON objects encoded as
strings because Dart defines are strings.

| Define | What to provide |
| --- | --- |
| `APP_ENVIRONMENT` | `dev`, `stg`, or `prod`. |
| `APP_NAME` | The user-facing app name. |
| `AUTH_MODE` | `disabled`, `optional`, or `required`. |
| `BACKEND_ENABLED` | `true` only when Supabase backend access is needed; auth enables it automatically. |
| `BILLING_MODE` | `revenuecat` for purchases, or `disabled` for a free app. |
| `ONBOARDING_ENABLED` | Enable the product-specific onboarding flow. |
| `ONBOARDING_PAYWALL_ENABLED` | Enable the post-onboarding paywall; requires billing. |
| `NOTIFICATIONS_ENABLED` | Enable local reminders, notification settings, and onboarding reminder, streak, and permission pages. |
| `GOOGLE_SIGN_IN_ENABLED` / `APPLE_SIGN_IN_ENABLED` | Enable only after configuring each provider in Supabase and the native callback. |
| `ANALYTICS_ENABLED` | Keep `true` only when `POSTHOG_API_KEY` and `POSTHOG_HOST` are set. |
| `CRASH_REPORTING_ENABLED` | Keep `true` only when `SENTRY_DSN` is set. |
| `SERVER_BASE_URL` | Supabase project URL when backend/auth is enabled. |
| `SERVER_API_KEY` | Supabase publishable/anon key; never use a service-role key. |
| `AUTH_REDIRECT_URL` | App-specific callback scheme, also registered on Android, iOS, and in Supabase. |
| `REVENUECAT_ANDROID_API_KEY` / `REVENUECAT_IOS_API_KEY` | Public RevenueCat SDK key for each supported platform. |
| `REVENUECAT_ENTITLEMENT_ID` | The RevenueCat entitlement used for premium access. |
| `FEATURE_ENTITLEMENTS` | JSON string mapping feature keys to RevenueCat entitlement IDs; use `null` for free features. |
| `FEATURE_OFFERINGS` | JSON string mapping feature keys to RevenueCat offering IDs. |
| `POSTHOG_API_KEY` / `POSTHOG_HOST` | PostHog project key and host when analytics is enabled. |
| `SENTRY_DSN` | Sentry DSN when crash reporting is enabled. |
| `TERMS_URL` / `PRIVACY_URL` / `SUPPORT_URL` | Public URLs for the app’s legal and support surfaces. |
| `STORE_URL_ANDROID` / `STORE_URL_IOS` | Google Play and App Store listing URLs. The Share App action selects the current platform’s listing. |

## Supported languages

The app supports English, Spanish, Chinese, French, German, Portuguese, Arabic,
Hindi, Russian, Japanese, Korean, and Italian. It follows the system/app language
unless the user saves an override in Settings → Language. Select System
to clear that override. Unsupported system languages fall back to English.

When adding or removing languages, update the localization ARBs, `AppLocale`,
`LocaleState`, iOS `CFBundleLocalizations` and Xcode `knownRegions`, and Android
`res/xml/locales_config.xml` together. Android 13+ uses this list for its system
app-language picker. Store listing translations are configured separately.

## Consumer app recipes

| App | Configuration |
| --- | --- |
| Offline utility | `AUTH_MODE=disabled`, `BILLING_MODE=disabled`, onboarding and telemetry disabled |
| Free authenticated app | `AUTH_MODE=required`, billing disabled |
| Guest-first freemium app | `AUTH_MODE=optional`, `BILLING_MODE=revenuecat` |
| Subscription app without accounts | Auth disabled, `BILLING_MODE=revenuecat` |
| Authenticated subscription app | `AUTH_MODE=required`, `BILLING_MODE=revenuecat` |

Auth automatically enables the Supabase backend. `BACKEND_ENABLED=true` also
supports Supabase without exposing auth UI. Enable onboarding independently with
`ONBOARDING_ENABLED=true`. Its sample questions and answers are persisted locally;
customize them for your app. `ONBOARDING_PAYWALL_ENABLED=true` adds a paywall after
onboarding and requires billing. The paywall remains dismissible; paid features
use explicit guards.

Startup and onboarding completion verify the configured entitlement before showing
a pending onboarding paywall. Verified subscribers skip it and persist completion
of that step, without a new purchase or Congratulations screen. Account ownership
alone does not skip the paywall, and subscription access does not bypass required
authentication. Verification or completion-save failures offer retry instead of
assuming the user is unsubscribed. Disabled onboarding, disabled billing, and disabled
or already-completed onboarding paywalls skip this check, including when older device
flags still record a pending paywall.

`AppFlowResolver` in `lib/src/config/router/` owns startup, authentication,
recovery, Restore, and onboarding-completion destinations. Route access remains in
`ConsumerRoutePolicy`, and entitlement verification remains in
`OnboardingPaywallAccess`. Resolve the destination first, then call `takeLocation`
after lifecycle/auth checks so an abandoned screen cannot consume a requested URL.

With auth disabled, Restore on the initial Welcome screen verifies subscription
access, then starts or resumes unfinished device onboarding. It preserves saved
answers and steps; subscribers skip the paywall when onboarding finishes. If device
onboarding is already complete, a successful restore opens Home. Cancelled or
unsuccessful restores stay on Welcome and allow retry.
Restore on the sign-in options page also verifies identity/access before resuming
unfinished device onboarding or the shared destination checks. It confirms success;
cancelled, failed, or unverifiable restores stay on that page for retry.

On the first visit to Home, the app shows a localized welcome sheet with examples
matching the six note-taking use cases in sample onboarding. Continue persists its
completion on the device; failed saves leave the sheet open to retry. The current
version’s What’s New sheet follows when matching notes exist in `AppRelease.releases`.
Later launches skip seen sheets; upgrades show their matching release notes.
Authentication, onboarding, and an optional paywall finish before these Home sheets.
A verified purchase from either onboarding or a regular paywall opens a full-screen
Congratulations view with a plan-neutral message and Continue. Continue resumes the
requested page/Home for onboarding, or returns to the regular paywall’s origin
(Home when no origin exists). Onboarding Restore keeps a calm Access restored dialog;
regular Restore returns directly. Closing the paywall skips these confirmations.
For onboarding, paywall completion is saved after identity/access verification and
before the confirmation opens. Failed completion saves offer Try again without repeating
Purchase or Restore, and retain the original purchase/restore message through retries.
Continue rechecks identity/access and navigates; it does not perform another completion
save. Restarting while either confirmation is open skips that completed paywall and confirmation.
Congratulations includes one 1.8-second Flutter confetti burst using theme colors.
Continue is immediately available; reduced motion or accessible navigation disables
the effect. It adds no animation assets or dependencies and does not replay on rebuild.
The presentation flag does not grant premium access; feature guards still enforce
current entitlements if access expires or the account changes afterward.

Debug settings provides **Show Welcome**, **Show What's New**, **Show Congratulations**,
and **Show Review Prompt**, in that order. These previews do not change automatic
presentation history. Congratulations previews return to Settings without purchasing
or changing subscription access or onboarding flags, including with billing disabled.
**Debug → Test Subscription** shows access status, refreshes after clearing the SDK’s
customer-info cache, and resets soft-paywall counters with visible failure/retry feedback.
Counter resets are queued with increments and never change purchases or premium access.
To repeat Apple sandbox purchases, clear the sandbox tester’s purchase history through
Apple’s sandbox controls, then refresh access. Local StoreKit tests use Xcode’s
transaction manager. The page links to the platform’s testing guide; app/onboarding
resets do not erase store purchase history.

Customize `lib/src/features/root/presentation/widgets/welcome_sheet.dart` and its
localization strings when adapting the template. The welcome guide works without
account or backend services.

**Debug → Reset Onboarding** clears saved onboarding answers/step, onboarding and
paywall completion, and the Welcome/What’s New presentation history. It returns to
the initial Welcome screen after the required saves succeed, so finishing setup
replays both Home sheets. Failed resets show an error and can be retried; earlier
successful preference removals may already have taken effect. Sign-in, purchases,
language/theme settings, reminder preferences, and OS permissions are preserved.

## Authentication and account management

See the [app flow matrix](docs/app_flow_matrix.md) for configuration combinations,
entry/completion paths, return navigation, Home-sheet history, and automated coverage.

Set `SERVER_BASE_URL` and the Supabase publishable/anon `SERVER_API_KEY`. Email
signup handles both immediate sessions and email verification. Password recovery,
email changes, profile saving, local sign-out, and account deletion are wired.

When `AUTH_MODE` is `optional` or `required`, the intended product flow is for
the Welcome screen to present authentication as sign-in for users who already
have an account. Account creation can be presented during onboarding, where the
app collects the new user’s setup information. This is a product-flow choice,
not an authorization boundary: if Supabase allows new signups, a provider OAuth
flow may still create a new user. Enforce sign-in-only behavior in Supabase Auth
if that distinction is required by the product.

The final onboarding account step offers branded Google/Apple buttons for enabled
providers and a “Continue with email” button opening email sign-in. Account
creation remains accessible from the email sign-in screen. Optional auth also shows
“Would you like to sign in later? Skip”; required auth hides Skip. Opening
authentication saves answers locally but does not mark onboarding complete. After
authentication (including email verification), users resume onboarding, see the
paywall if enabled, and return to any requested screen (or home). Password recovery
finishes before onboarding is completed. Failed or cancelled authentication leaves
onboarding available to retry. Relaunching with
unfinished onboarding resumes the saved step; the Welcome screen is used when
there is no saved progress.

After Google, Apple, or email sign-in, completed device onboarding goes through
the same startup paywall check before continuing to a requested screen or Home.
Verified subscribers skip a pending onboarding paywall; non-subscribers see it and
can dismiss it to continue. Verification failures offer retry without signing in
again. Debug Skip Sign In uses this same completion path with guest access rules.
The first valid requested product URL is retained through redirects, including its
query and fragment. Startup, auth, Welcome/onboarding, and onboarding-paywall URLs
are intermediate steps and cannot replace it or be replayed as a return destination.
Invalid or external URLs are ignored; the requested URL is consumed once when the
authenticated user finishes setup and any pending paywall.

After a successful password reset, unfinished device onboarding opens at its saved
step (or the first step). Completed onboarding uses the startup paywall check:
verified subscribers skip a pending paywall, while non-subscribers see it. Disabled
onboarding, billing, or onboarding paywalls bypass that check. Verification failures
offer retry without submitting another password reset. A valid intended destination
is preserved until onboarding and any pending paywall finish; otherwise users reach
Home and its usual welcome/release sheets.
Normal password changes opened from Account settings return to Account and leave
pending onboarding, paywall, and intended-destination state unchanged.
Startup resolves recovery first, then unfinished device onboarding, then required
authentication, before checking a pending onboarding paywall. A signed-out user in
required-auth mode is never verified as a guest subscriber during startup.

Google and Apple use Supabase browser OAuth. Enable the providers in the Supabase
dashboard and set `GOOGLE_SIGN_IN_ENABLED` / `APPLE_SIGN_IN_ENABLED` only after
configuring them. The native callback is initially:

```text
com.startapplab.pickwell://auth-callback
```

For each generated app, use a unique scheme and update **all four** locations:
`AUTH_REDIRECT_URL`, Android's intent filter, iOS's `CFBundleURLTypes`, and the
Supabase redirect allowlist. Supabase handles the callback with app_links;
Flutter's default deep-link navigation is disabled to avoid competing handlers.
Configure the signup email template to expose the OTP token if using the OTP
screen; confirmation links are also supported by Supabase's callback handler.
Configure production SMTP and email confirmation in Supabase before release.

From the repository root, prepare a local backend using Docker:

```sh
supabase start
supabase db reset
supabase test db
supabase functions serve delete-account
```

Deploy the `delete-account` function and apply migrations to the app's own backend
before releasing account deletion. The function verifies the caller, removes
files in their images/documents/avatars folder, and deletes their auth account.
Extend cleanup when adding buckets. Account deletion does not cancel store
subscriptions. The mobile app never receives the service-role key.

## RevenueCat and access guards

Set `BILLING_MODE=revenuecat`, the public SDK key for each supported platform, and
`REVENUECAT_ENTITLEMENT_ID` (default `premium`). Configure store products, link them
to entitlements, and create a current offering in RevenueCat. The paywall displays
all packages from that offering, including monthly, annual, and lifetime unlocks.
It uses store-localized prices and makes no fixed trial promise. Pending purchases,
cancellations, failures, and no restored access have distinct outcomes.

Guest purchases retain their RevenueCat identity on cold start. Actual account
changes synchronize billing identity. Configure RevenueCat restore/transfer
behavior for your app and test guest-to-account conversion, account switching,
and reinstall/restore in the store sandbox.

These values are JSON objects encoded as strings because Flutter's
`--dart-define-from-file` values are strings. Copy these entries as-is, then
replace the feature keys and RevenueCat IDs with the ones used by your app:

```json
"FEATURE_ENTITLEMENTS": "{\"export\":\"premium\",\"advancedSearch\":\"search\",\"browse\":null}",
"FEATURE_OFFERINGS": "{\"export\":\"default\",\"advancedSearch\":\"search_plans\"}"
```

For a simple RevenueCat integration with one premium entitlement and the
current/default offering, leave both values as `{}` in `config/app.example.json`:

```json
"FEATURE_ENTITLEMENTS": "{}",
"FEATURE_OFFERINGS": "{}"
```

For tiered subscriptions, map each feature to the entitlement that should unlock
it. For example:

```json
"FEATURE_ENTITLEMENTS": "{\"export\":\"plus\",\"advancedSearch\":\"pro\",\"teamSharing\":\"max\"}"
```

In this example, the RevenueCat products must be configured to grant the
corresponding entitlements. If access is cumulative, configure Pro to grant
both `plus` and `pro`, and Max to grant `plus`, `pro`, and `max`. If access is
not cumulative, each tier grants only its own mapped features.

A guard without a feature key uses the default entitlement; named features must
be explicitly mapped. `null` makes a mapped feature free. Unknown named features
are unavailable, even when the user owns the default entitlement.
Guards open the mapped offering for that feature. You can also pass an explicit
`offeringId` to `PremiumGuard` or `requirePremium`. An unknown offering shows no
plans; it never silently substitutes the default offering.
Billing disabled makes premium guards unavailable; explicitly free mappings still
allow access without initializing the billing SDK. Free apps can omit premium
guards or explicitly map their guarded features to `null`.

```dart
PremiumGuard(
  featureKey: 'export',
  lockedChild: MyUpgradeCard(),
  child: ExportPanel(),
);

if (await PaywallAccess.requirePremium(context, featureKey: 'export')) {
  await exportData();
}

await PaywallAccess.run(
  context,
  featureKey: 'export',
  action: exportData,
);
```

The action guard refreshes access and rechecks after the paywall closes, allowing
it to resume the original action after a successful purchase. Guards support an
explicit `entitlementId`; PremiumGuard and requirePremium also accept `allowWhen`
for simple product-specific rules such as a local free allowance. Client snapshots
are presentation state, not authorization. Dart defines and client guards can be
modified. Paid API calls and metered quotas still require
server enforcement. `allowWhen` is an explicit local allowance and has no backend
authority.

Access snapshots come from `EntitlementProvider`, independently of `BillingClient`
purchase operations. The default RevenueCat adapter reports active grants and
their expiration; `SubscriptionCubit.withProvider` accepts another provider for
future server verification. A server provider never receives access from a client
purchase result: it must refresh its own authoritative state. Provider errors
preserve same-identity cached access only within its known validity. Identity
changes clear previous access immediately. Non-expiring grants are supported;
missing or malformed subscription expiration does not imply lifetime access.
Explicit RevenueCat verification failures clear cached access and show retry;
transport failures alone may retain still-valid access. Non-expiring store purchases
and RevenueCat promotional grants are supported. This does not enable or require
cryptographic verification where the SDK reports it as not requested.

Consumable credit accounting is an app-specific extension; this starter gates
entitlement-based access.

`maybeShowSoftPaywall(featureKey: ..., showEvery: 3)` is an optional nudge and does
not block an action. Subscription management uses RevenueCat's store management
URL. Configure `TERMS_URL` and `PRIVACY_URL` for your own business before launch.

### Optional server enforcement

For premium APIs or protected data, install the optional Supabase subscription
module described in [../supabase/modules/subscriptions/README.md](../supabase/modules/subscriptions/README.md).
It uses authenticated Supabase UUIDs, server-only RevenueCat credentials,
production entitlement checks, and webhook/refresh reconciliation. Each app must
apply the SQL helper to its actual paid operations. Guest purchases remain
available locally; protected backend operations require sign-in. A mobile server
provider adapter can be connected through `SubscriptionCubit.withProvider` later.

## Notifications, branding, and observability

`NOTIFICATIONS_ENABLED` controls local reminders, permission requests, and the
reminder preference screen. When disabled, startup cancels existing local
notifications without initializing notification delivery or requesting permission.
The device's reminder preference is preserved. Android includes scheduled and
reboot receivers.
Startup completes notification and timezone setup before loading subscription
access. Failed notification initialization leaves reminder scheduling disabled.
Trial reminders use the actual entitlement expiration date; they require system
permission and an enabled device preference. Remote push, token registration,
and a notification inbox are not implemented by this local reminder module.
`send-notification` creates a database notification for the verified caller only.

Use `APP_NAME`, `SUPPORT_URL`, `STORE_URL_ANDROID`, `STORE_URL_IOS`, `TERMS_URL`,
and `PRIVACY_URL` instead of hardcoded business links. Native display names, IDs, icons, store listings, sample
onboarding copy, and localization ARBs also need app-specific branding.

PostHog and Sentry are disabled by default. Enable PostHog with
`ANALYTICS_ENABLED=true` and provide `POSTHOG_API_KEY` and `POSTHOG_HOST`; enable
Sentry with `CRASH_REPORTING_ENABLED=true` and provide `SENTRY_DSN`. Add
product-specific analytics events and consent behavior as needed.

## Billing release preflight

Production Android/iOS Makefile targets validate the selected define file against
`config/features.json` before building. Follow [config/README.md](config/README.md)
for free, client-only paid, and server-protected recipes. Empty mappings remain
supported for unnamed premium guards. Named feature keys must match the catalog,
and declared premium features cannot ship with billing disabled.

```sh
make preflight-billing PLATFORM=android APP_CONFIG=.secrets/prod.secrets
make preflight-billing PLATFORM=ios APP_CONFIG=.secrets/prod.secrets
```

The catalog is public build metadata, not server authorization. Local validation
does not verify live RevenueCat products, backend deployment, or every guarded
operation. The default free catalog requires no external service credentials.

## Generate features with Mason

From `mobile/`:

```sh
make init-mason
# Alias: make mason-init
mason make feature-cubit --name feature_name
fvm dart run build_runner build
```

The target activates `mason_cli` through FVM and runs `mason get`. Keep Dart's
global executable directory on PATH. The manifest and lockfile pin the bricks to
`81fc50c84603366a840a43ee829a333a1a31f16f`; the CLI itself is not version-pinned.
Use the Cubit brick and preserve its scaffold. Adapt remote-service, ID, logging,
and cache examples to the feature's actual behavior before wiring them. Generate
into a scratch directory to compare an existing feature; never overwrite it blindly.
Do not copy `.mason/` caches or invoke base/secrets bricks during feature creation.
The manifest, lockfile, and production Makefile are included in template archives.

Shared UI conventions are in [AGENTS.md](AGENTS.md): one widget per file, `Gap`
for spacing, `AppIcon` with HugeIcons, and reuse of `features/app/` components.
`DimensionsData` supplies `spacingXxs` through `spacingXxl`, separate padding,
shape, icon, touch-target, and sheet tokens, plus `copyWith` for overrides.
`SheetDragHandle` provides the shared floating-sheet handle. Existing legacy
spacing and inset values remain unchanged.

## Development and validation

```sh
fvm dart run build_runner build
fvm flutter analyze --no-pub
fvm flutter test --no-pub
fvm flutter build apk --debug
fvm flutter build ios --debug --simulator
```

The package keeps Dart 3.12 language mode for the compatible AutoMappr/Freezed
generator group. Generated code is committed and must be regenerated after
changing models, immutable state, DI, mappings, or database inputs.

Tests exercise consumer routing, guest billing identity, account switching,
refresh failures, package selection, purchase results, guard resumption,
onboarding persistence, and the actual offline app shell. Backend policy tests
live in `supabase/tests/`. OAuth and real store transactions need separate device
and sandbox verification.

The generic Retrofit get-by-ID services and empty Drift database are extension
scaffolds. They are not a working synced CRUD feature; add a real feature and
matching migrations together. See AGENTS.md for the implementation conventions.

## Native builds and distribution

- iOS uses Swift Package Manager and targets iOS 15+. New native dependencies
  must support SPM. Build once before opening `ios/Runner.xcworkspace`.
- Android uses Java 17, minimum SDK 26, and compile SDK at least 37. Add release
  signing using local credentials; never include them in template archives.
- Run the local analysis, test, build, and Supabase checks before release; the template does not configure a hosted CI provider.
- Fastlane listing, pricing, and commerce setup is documented in
  `fastlane/README.md`. Build uploads still need project-specific release setup.

Package a credential-free template from the repository root:

```sh
python3 mobile/tool/package_template.py --output /tmp/pickwell.zip
```

The archive includes Flutter’s basic `test/widget_test.dart` as a reference for
new Flutter users. The real app smoke test, broader template contract tests, and
their fakes remain in the repository for template maintenance and are excluded
from the archive. Adapt or remove those maintenance tests when a generated app
changes its supported capabilities.


## Pickwell barcode/Home integration (T03.2)

The guest Home, Home/Settings dock and separate Scan action now use the approved
lemon palette. The source lemon mark is not in this repository: Home uses a labeled
emoji placeholder; native icon/splash remain template assets. Scanner uses
mobile_scanner 7.5.0 and image_picker 1.2.4 with iOS SPM and native permission copy.
Camera/gallery/manual EAN/UPC input calls the existing `get-product` function via
public Supabase configuration and any current session. No AI or client quota writes.

Use the existing ignored define file for backend-enabled development; keep optional
auth, onboarding disabled and billing disabled. Default builds remain offline-capable
for local UI but do not pretend lookup works without enabled/configured Supabase.
The configured hosted function returned 404 during this task: review/deploy the
T03.1 backend before expecting real ready/miss responses. Do not put server keys
or network-HMAC secrets into mobile defines.

Recents persist only 30 barcode/timestamp references. Product details live in RAM;
opening a reference after relaunch makes a normal metered lookup. Fresh camera scans
always hit the backend; reopening a currently loaded result can use memory. Capture
entry holds two photos locally without submission; full review/OTP/analysis remains
later work. New feature copy is English fallback in other locales.

See [T03.2 evidence, checks and deferred hardware test](../docs/PICKWELL_SCANNER_HOME.md).
After a full build_runner run, generate formatted Home state with:

```sh
fvm dart run build_runner build --define=freezed:freezed=format=true --build-filter=lib/src/features/home/presentation/blocs/home/home_cubit.freezed.dart
fvm flutter test --no-pub test/catalog test/app_config_security_test.dart
```
