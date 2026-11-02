# T04.2 — Email OTP and contribution authorization gate

2026-11-03. **Email OTP implementation and live auth checks pass. Overall acceptance
remains PARTIAL until the real T05 analysis endpoint enforces this boundary.**
Previous T04.1 changes, including the user's physical-camera confirmation, were
committed first as `20ae009`. No physical app OTP test is inferred from that report.

## Reconciliation and implemented scope

Reviewed root/mobile instructions, existing auth SDK/service/Cubits/routes/session,
backend README, and relevant PRD v1.4, DESIGN/SPEC v1.2, DATABASE/TASKS requirements.
The template OTP screen handles password-signup confirmation; its resend operation
uses signup resend. Preserved that reusable flow and added the contribution gate
inside the same auth feature using its existing Supabase client and email verify
operation. No new feature scaffold, package, provider or auth SDK initialization.

- Two-photo review now exposes **Analyze Product**. Only that explicit action opens
  the email gate; cached lookup, Home, scan and photo capture remain guest-accessible.
- `/capture-auth/:barcode` requires the matching two-photo draft. A missing or wrong
  draft returns to capture; invalid barcodes return to scan. Disabled auth shows an
  explicit unavailable view with back navigation, without resolving an SDK client.
- Existing backend-authorized sessions skip email entry. Expired sessions attempt
  normal SDK refresh; rejected refresh/session verification returns to email auth,
  preserving the draft. Auth outages remain errors rather than successful grants.
- Send/resend use passwordless `signInWithOtp`; verification reuses the template's
  `verifyOTP(type: email)`. This is not the signup-resend operation. No new password,
  OAuth, anonymous sign-in or administrative account-confirmation flow was added.
- Email validation, digit-only code entry/autofill, busy/error states, send/verify,
  change-email and cancel implemented. Resend cooldown survives route recreation
  through the shared service; reopening resumes the countdown. A transport-uncertain
  send attempt also holds the cooldown to avoid repeated duplicate mail requests.
- The code remains in its UI controller only and is cleared on resend/change-email,
  success/disposal; it is never a Cubit-state field or diagnostic. Backend SDK
  errors are mapped to fixed safe failure codes, not retained/logged verbatim.
- Successful verification returns to the identical app-owned two-photo draft.
  Cancel/back also preserves it. Optional-auth session refresh leaves this route
  in place; it is separate from template auth routes that redirect on sign-in.
- The same existing Supabase SDK owns session refresh/persistence. Dev config has
  optional auth; `main.dart` already enables session persistence and automatic
  refresh for enabled auth. SDK serialization/restoration is tested. No second
  token cache or app-supplied verified/Premium flag was added.
- This task verifies identity only. The review explicitly reports that analysis
  is not available yet and that no photos have been submitted. No pretend successful
  analysis, quota reservation, model invocation or published product was added.

## Cloud configuration and actual live evidence

Target: existing Pickwell project `bzmqgjinbjykhqqswdva`.

Authenticated CLI `config pull` ran in ignored `.secrets/otp-config-inspection`,
not the repository config. It confirms:

| Setting | Observed |
| --- | --- |
| Email confirmation | enabled |
| Numeric code length | **8** |
| Minimum send interval | **1 minute** |
| Supabase project email-send limit | **30/hour** |

DESIGN's six-digit example differs materially from the deployed eight-digit setting.
The gate supports six- or eight-digit input and leaves the server authoritative;
no cloud security setting was weakened to match a mockup. This is documented rather
than silently changing server settings. The existing custom SMTP setup was reused.
No SMTP credential/template setting or global email limit was changed.

A standalone Management API config read was rejected HTTP 401; the authenticated
CLI pull succeeded. Template HTML was not directly exported or claimed inspected.
Its numeric-code behavior was instead verified by actual mail/code verification.
Google sender-account-specific daily limits, high-volume deliverability and natural
code-age expiry were not load/wait tested. The project limits above are confirmed
settings, not promises of unlimited email delivery.

Fresh test through the normal public Auth API and the user's existing test inbox:

| Live case | Actual result |
| --- | --- |
| New `/auth/v1/otp` request | HTTP 200 |
| Incorrect numeric code | HTTP 403 |
| User saved the fresh 8-digit code in the ignored local file | Verification HTTP 200 |
| Auth identity | confirmed email, non-anonymous persistent user |
| New session against deployed authorization gate | HTTP 200, only `status=authorized` |
| Reuse of consumed code | HTTP 403 |

The user confirmed saving the newly delivered code. It was read privately, consumed,
then cleared from the file. Session credentials remain only in the mode-0600 ignored
session file. No OTP, token, user UUID, inbox address or SMTP password is in this
report. No user was created or administratively marked verified.

## Protected backend boundary

Deployed only POST `/functions/v1/authorize-analysis`, with gateway JWT verification
**enabled** and independent trusted Auth `/auth/v1/user` validation. It checks a UUID,
`is_anonymous=false`, nonempty email and a valid `email_confirmed_at`; client metadata,
body flags or the generic authenticated role are never sufficient.

The adapter reads only platform-injected URL/anon key. It needs no service-role
credential, DB grant or Meta credential. Input must be an empty bounded JSON object;
image payloads, claimed user IDs and verification/Premium fields are refused.
Responses contain no user identity and are marked no-store.

Additional real hosted checks passed:

- No session: HTTP 401.
- Public-key bearer alone: HTTP 401.
- Forged JWT: HTTP 401.
- Previously existing verified session: HTTP 200.
- Fresh OTP session: HTTP 200.

Shared `_shared/analysis_authorization.mjs` exports `requireVerifiedEmail` for T05.
**A prior preflight response is not a capability.** The actual `analyze-product`
handler must call the guard again for every request and enforce quota/spend admission.
That handler does not exist yet; guest rejection on a real image-submission endpoint
is therefore not claimed verified. The auth-only gate processes no images/jobs.

## Validation and commands

```sh
# mobile/
flutter gen-l10n
dart run build_runner build
flutter test test/catalog
flutter analyze --no-pub
flutter build apk --debug --dart-define-from-file=.secrets/dev.secrets

# repository root
node --test supabase/tests/analysis_authorization.test.mjs supabase/tests/get_product.test.mjs
npx --yes supabase@2.122.0 config pull --project-ref bzmqgjinbjykhqqswdva --workdir .secrets/otp-config-inspection --yes
npx --yes supabase@2.122.0 functions deploy authorize-analysis --project-ref bzmqgjinbjykhqqswdva --use-api
```

- **54 Flutter tests passed**, including capture/recent regressions and ten new gate
  checks plus two SDK/loopback HTTP tests. Actual Analyze action → email entry →
  code → cancel/verify → identical capture review is exercised through real widgets.
- SDK HTTP tests cover passwordless send vs signup resend, cooldown suppression,
  wrong/expired code mapping, trusted preflight failures, session serialization and
  restoration, expired refresh rejection and disabled-mode behavior.
- **12 backend tests passed**, **1 native-stack integration test skipped** because
  that stack was not started. New boundary tests deny anonymous/unverified users,
  forged metadata and payloads; Auth timeout/outage/oversize fail closed. Existing
  lookup unit tests confirm guest/cached paths still do not invoke Meta.
- **Static analysis: no issues.** Android debug APK built successfully on final code
  at `mobile/build/app/outputs/flutter-apk/app-debug.apk`; no device install was run.
  Existing plugin Kotlin migration warnings were non-blocking; no unrelated plugin
  upgrade was made. No full-project regression or iOS/device success is claimed.
- Formatting, diff hygiene and changed-file secret checks passed. Session, OTP,
  config inspection and evidence files are ignored/untracked.

Initial widget tests waited on an intentional loading spinner before starting their
check; that fixture ordering was corrected. An SDK test's error fixture used the
wrong protocol field; it now uses `error_code`, with compatibility handling for
legacy code responses. A cancel/reopen resend-countdown issue was also fixed and
covered. All final checks above passed; failures are not counted as passing runs.

## Security/cost and remaining acceptance

Post-task cloud assertions: zero provider ledger rows, billing/inference/Premium
still disabled, one unchanged Auth user, the single existing labeled demo product,
and unchanged protected client ACLs/RPC privileges. No Meta call, image upload,
analysis credit charge, schema migration or billing activation. Ordinary Auth mail,
Edge and DB verification requests use existing project resources; no load test.

TASKS: send/configuration, contextual prompting and recovery/resume checkboxes now
verified. Backend analysis-boundary checkbox stays open until T05 invokes the guard
on the actual submission handler. Full app OTP on the physical device and session
survival across a device/process restart remain unverified, although real Auth and
SDK/widget restoration checks pass. Existing T04.1 photo-draft TTL still applies;
no OTP process can preserve a draft after expiry, discard or process death.

No missing credentials block this implemented gate. Natural TTL expiry, Google
sender-specific throughput and further-device validation remain unverified. New copy
uses existing English fallbacks in non-English locale files; translation review is
pending. No new visual/reference assets were required.

**Next: T05.1 — secure analyze-product orchestration**, followed by T05.2 validation
and T05.3 publication/cleanup. Do not confuse this auth checkpoint with completed AI
integration. T01.1's remaining real-label extraction limitations are still recorded.

Primary references: [Supabase passwordless Email OTP](https://supabase.com/docs/guides/auth/auth-email-passwordless)
and [Auth rate limits](https://supabase.com/docs/guides/auth/rate-limits).

## Exact repository files changed

- `docs/PICKWELL_EMAIL_OTP_GATE.md`
- `docs/PICKWELL_TASKS.md`
- `mobile/README.md`
- `mobile/lib/src/config/injection_container.config.dart`
- `mobile/lib/src/config/router/app_router.dart`
- `mobile/lib/src/features/auth/data/data_sources/services/_services.dart`
- `mobile/lib/src/features/auth/data/data_sources/services/email_otp_api_service.dart`
- `mobile/lib/src/features/auth/data/repositories/_repositories.dart`
- `mobile/lib/src/features/auth/data/repositories/email_otp_repository.dart`
- `mobile/lib/src/features/auth/domain/repositories/_repositories.dart`
- `mobile/lib/src/features/auth/domain/repositories/email_otp_repository.dart`
- `mobile/lib/src/features/auth/domain/use_cases/_use_cases.dart`
- `mobile/lib/src/features/auth/domain/use_cases/email_otp_use_case.dart`
- `mobile/lib/src/features/auth/presentation/blocs/_blocs.dart`
- `mobile/lib/src/features/auth/presentation/blocs/email_otp/email_otp_cubit.dart`
- `mobile/lib/src/features/auth/presentation/views/_views.dart`
- `mobile/lib/src/features/auth/presentation/views/email_otp_gate_view.dart`
- `mobile/lib/src/features/catalog/presentation/views/capture_entry_view.dart`
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
- `mobile/test/catalog/email_otp_sdk_test.dart`
- `mobile/test/catalog/email_otp_test.dart`
- `supabase/README.md`
- `supabase/config.toml`
- `supabase/functions/_shared/analysis_authorization.mjs`
- `supabase/functions/_shared/catalog_boundary.mjs`
- `supabase/functions/authorize-analysis/index.ts`
- `supabase/tests/analysis_authorization.test.mjs`
