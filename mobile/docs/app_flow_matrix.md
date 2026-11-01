# App flow matrix

This describes the application coordinator and its supported configuration/state
branches. Authentication and subscription access are independent. Onboarding,
paywall presentation, and Home-sheet history belong to this device.

## Coordinator order

`AppFlowResolver.resolve()` selects destinations in this order:

1. An active password-recovery session opens Change Password.
2. Enabled, unfinished onboarding opens Welcome on a fresh launch or resumes its
   saved step. Authentication success, recovery completion, and successful Welcome
   Restore enter onboarding directly, including step 1 when no answers exist.
3. Required authentication opens Sign In for a signed-out user, before resolving
   or fetching billing. Debug Skip Sign In is a debug-only guest allowance.
4. An enabled, pending onboarding paywall verifies the configured entitlement.
5. After setup/paywall completion, an authenticated user consumes the first valid
   requested product URL, otherwise the destination is Home.
6. Actual Home visibility starts the Welcome sheet and then matching What's New.

`ConsumerRoutePolicy` separately guards direct routes and disabled features. Legal
pages remain accessible during recovery. A protected account link can open Sign In
before setup resumes; successful sign-in then follows the coordinator. An already
accessible direct product route does not run a global onboarding/paywall guard.

## Configuration combinations

Compose one row from each table; account and entitlement states below then determine
remaining branches. Notification/provider switches do not change these rules.

| `AUTH_MODE` | Can finish as guest? | Account pages | Purchases |
| --- | --- | --- | --- |
| `disabled` | Yes; account UI hidden | Unavailable | Guest billing when enabled |
| `optional` | Yes; Save Progress offers Skip | Require sign-in | Guest or signed-in billing |
| `required` | No, except debug guest allowance | Require sign-in | Required sign-in precedes coordinator billing checks |

| Onboarding | Billing | Onboarding paywall | Result |
| --- | --- | --- | --- |
| Off | Off | Off | Skip setup and billing checks |
| Off | Off | On | Reject configuration: paywall requires billing |
| Off | On | Off | Skip setup and onboarding-paywall checks |
| Off | On | On | Ignore onboarding paywall, even with old pending flags |
| On | Off | Off | Run setup; skip billing checks |
| On | Off | On | Reject configuration: paywall requires billing |
| On | On | Off | Run setup; skip onboarding-paywall checks |
| On | On | On | Run setup, then verify a pending paywall |

When auth is enabled, Google and Apple buttons follow their independent provider
switches. Disabled providers cannot start OAuth. Notifications disabled removes
notification-specific onboarding pages while preserving saved slide IDs; it does
not grant authentication, skip other setup, or change entitlement requirements.

## Device and subscription states

The following assumes recovery is finished and integrations are enabled unless a
row says otherwise. Required auth still precedes a pending-paywall verification.

| State | Destination / effect |
| --- | --- |
| Fresh device; no saved progress | Startup → Welcome → Get Started → onboarding step 1 |
| Fresh device; successful Welcome sign-in | Onboarding step 1; signing in alone does not complete it |
| Saved onboarding answers/step | Resume the saved enabled step; preserve answers |
| Authenticated at active Save Progress | Save answers and finish automatically; Continue retries a failed save without re-authentication |
| Optional guest at Save Progress | May sign in/create an account or Skip |
| Required guest at Save Progress | Sign-in/account creation required; no production Skip |
| Device onboarding complete | Do not repeat it; continue through required auth/pending-paywall checks |
| Paywall already processed | No onboarding billing check; continue |
| Paywall pending; verified configured entitlement | Persist paywall completion; skip paywall without purchase/Congratulations |
| Paywall pending; verified no configured entitlement | Show dismissible paywall, regardless of account existence |
| Unrelated or expired entitlement | Does not qualify for subscriber bypass |
| Verification or required flag-write fails | Stay on retry UI; preserve intended URL; do not assume no subscription |
| Integrations disabled, including old pending flags | Skip corresponding checks without resolving disabled dependencies |

## Entry, completion, and cancellation paths

| Entry/action | Path |
| --- | --- |
| Google/Apple OAuth returns an authenticated SDK session | Resume setup, or startup check → pending paywall/requested page/Home |
| OAuth launch fails or user closes the browser without authenticating | Stay in auth; preserve answers and intended URL |
| Email sign-in succeeds | Same coordinator path as OAuth |
| Signup returns an immediate session | Resume onboarding; account creation alone does not mark setup complete |
| Signup requires email verification | Stay in verification until a session exists; successful OTP or confirmation-link SDK event resumes the coordinator |
| Password-recovery SDK event | Change Password takes precedence; setup cannot auto-complete behind it |
| Recovery password update succeeds | Resume onboarding or startup checks; keep intended URL until prerequisites finish |
| Normal password update from Account succeeds | Return to Account; leave setup/paywall flags and intended URL unchanged |
| Password update fails | Stay on the form; do not change recovery/setup flags |
| Welcome Restore succeeds | Resume unfinished onboarding; verified restored access skips the later paywall; completed setup opens Home |
| Welcome Restore cancelled / no access / fails | Stay on Welcome and allow retry |
| Onboarding purchase/restore succeeds | Verify identity/access → persist presentation completion → recheck identity/access → purchase: full-screen Congratulations, restore: calm Access restored dialog → recheck identity/access → requested page/Home |
| Completion save fails after a verified purchase/restore | Show Try again; retry verification/save without another store transaction; preserve original purchase/restore copy even if retrying through Restore or X; confirmation waits for a successful save |
| Access/identity changes during purchase/restore, completion save, or Congratulations | Block celebration/continuation as appropriate; show error/retry; an already-saved presentation flag remains separate from premium access |
| App terminates while Congratulations is open | Fresh startup reads completed presentation state; skips paywall/confirmation and proceeds through normal auth/return/Home rules |
| Store purchase is cancelled | Remain on the paywall |
| Paywall X on final page | Persist presentation completion without granting paid access → requested page/Home |
| Paywall-dismissal save fails | Remain on paywall for retry |
| Debug Reset Onboarding | Clear device answers/setup/paywall/Home-sheet flags → Welcome; preserve sign-in/purchases/preferences |

A skipped subscriber paywall and a dismissed paywall do not show Congratulations.
Verified regular-paywall purchases also open the full-screen Congratulations view.
Continue returns to the presenting page, or Home when there is no previous page.
Regular Restore returns directly without a purchase celebration. The confirmation is
an ephemeral Navigator page, not a public destination or a persisted startup step.
Its decorative confetti plays once for 1.8 seconds, honors reduced motion/accessibility
settings, and never delays Continue. Restore, cancellation, and subscriber bypass
do not play it.

## Intended destinations and Home sheets

- Accept internal product URLs only; keep query parameters and fragments.
- Retain the first valid pending URL until consumed or an explicit reset clears it.
- Startup, Welcome, onboarding, auth, and onboarding-paywall routes are intermediate
  steps, not return destinations. They cannot overwrite a pending product URL.
- Previously captured intermediate URLs and invalid/external URLs fall back to Home
  when continuation is allowed. A guest or active recovery session cannot consume
  a pending authenticated destination.
- Consume a valid requested URL once, only after mounted/auth checks at navigation.
  Resolver verification alone never consumes it.
- A requested destination can replace Home. Welcome/What's New wait until Home is
  actually visible, rather than appearing over Account or another requested page.
- First Home visit: unseen Welcome → Continue (required successful history save) →
  matching version's What's New → record version. Missing matching notes produce no
  release sheet. Later visits skip seen content; upgrades show matching new notes.
- Failed history writes allow retry. Debug sheet previews do not record automatic
  presentation history; Debug Reset Onboarding clears that history for replay.

## Automated coverage and boundaries

| Area | Regression files under `test/` |
| --- | --- |
| Auth/config/device-state coordinator matrix, ordering, URL retention | `app_flow_resolver_test.dart`, `consumer_modes_test.dart` |
| Actual router: auth before billing; query/fragment preservation; no repeated paywall after X | `auth_routes_test.dart` |
| Email, Google, Apple, debug skip, cancellation/failure, verification retry | `sign_in_completion_flow_test.dart`, `auth_options_footer_test.dart` |
| SDK-delivered OAuth/confirmation/recovery callbacks, real OTP view verification | `auth_callback_flow_test.dart` |
| Save Progress, persistence failures, resume/relaunch, notification switches | `onboarding_auth_test.dart`, `startup_onboarding_test.dart`, `onboarding_notifications_test.dart`, `persistence_test.dart` |
| Recovery versus normal Account password updates | `password_recovery_flow_test.dart` |
| Welcome Restore | `welcome_restore_flow_test.dart` |
| Subscriber bypass, entitlement/identity/expiration, required-save retry | `onboarding_paywall_access_test.dart`, `onboarding_paywall_bypass_test.dart`, `subscription_test.dart`, `entitlement_provider_test.dart` |
| Purchase/restore completion, cancellation, X, Home-sheet order/history/reset | `paywall_completion_flow_test.dart`, `paywall_test.dart`, `home_sheets_test.dart`, `debug_onboarding_reset_test.dart` |

These are local automated tests using injected service/store fakes. Callback tests
exercise app behavior after SDK session delivery; they do not prove provider browser
redirects, native app-link registration, real email delivery/token exchange, store
transactions/transfers, or device permissions. No live/device validation is claimed.

The OTP input uses `pinput` 6.x while the app uses `package:flutter/material.dart`.
Version 7 uses the separate `material_ui` widget family and cannot inherit this
app's Material ancestors; see the [package migration notes](https://pub.dev/packages/pinput/changelog).
Keep that constraint until an explicitly planned app-wide Material migration.
