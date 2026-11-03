# T07.1 — End-to-end acceptance and security pass

Date: 2026-11-03. Status: **COMPLETE for the owner-approved hackathon testing profile**, combining automated/hosted evidence with the owner's completed manual device checks. No known P0 blocker was observed within this scope. This is not a store-release certification.

## Scope and configuration

Reviewed the existing PRD v1.4, DESIGN v1.2, SPEC v1.2, DATABASE v1.0, TASKS v1.1, repository instructions and implemented pipeline. Preserved the Flutter template, Cubit architecture, extraction/interpretation engine and existing working flows.

The owner explicitly requested keeping cloud testing allowances: **1,000 authenticated barcode lookups and 100 successful analyses/day**. Approved Free **30/3**, dynamic reduction to 20, UTC rollover and concurrency boundaries passed in the isolated test database. Restore the approved production allowances before public release; do not describe today's cloud profile as 30/3. Billing remains disabled. T06.3 RevenueCat is explicitly deferred; no RevenueCat webhook is deployed.

The owner confirmed device QA (saved-photo restart/recovery, OTP expiry, retries, permissions, accessibility and cleanup) and further real-product/unreadable-label accuracy checks as completed. These are **user-reported passes**, not fresh agent-operated hardware tests. Historical fixture limitations in earlier reports remain historical evidence, not a guarantee that every label or ingredient is supported.

## Acceptance matrix

| Requirement | Result and evidence |
| --- | --- |
| Home | PASS: Flutter local persistence/dedup/search/filter, empty state, dock and navigation checks; restart/recovery also confirmed by owner. No fake Chat/cosmetics route shipped. |
| Cached path | PASS: hosted guest lookup returned a published result without an OTP wall; isolated handler tests assert zero provider invocation. Hosted provider ledger did not increase. |
| New path | PASS: owner's completed real flow plus existing genuine Meta evidence in the spike/interpretation reports; automated capture/auth/resume, protected orchestration, validated publication and common result UI. No new live inference was performed in this QA run. |
| Reuse | PASS: guest cached response and isolated cross-request reuse/idempotency tests; no repeat provider charge during hosted checks. |
| Bad input | PASS: malformed/contradictory data and label-specific retake tests, protected invalid-image rejection, quota release, plus owner's unreadable-label checks. Readable partial labels may retain unknown values under the approved relaxed extraction policy; this pass does not reintroduce the earlier strict whole-label rejection. |
| Quotas | PASS in isolation: lookup 30 allowed/31 denied, success 3 allowed/4 denied, mutable limit 20, UTC reset, parallel reservations, releases, spend/concurrency bounds and missing auth. Live 1,000/100 is an explicit owner-approved testing exception. |
| Security | PASS: RLS/role/owner isolation tests, 30 hosted boundary checks, repository/config and rebuilt APK scans. Clients cannot write shared catalog/jobs/usage/entitlements. Billing false; webhook checks not applicable while undeployed. Temporary spike handler returns disabled. |
| Privacy | PASS: transient draft/cleanup tests, owner confirmation, sanitized public projection; hosted Storage and analysis candidates empty at inspection. Automated retention/reconciliation scheduled and exercised. |
| Accessibility/recovery | PASS: readable status labels/icons independent of color, missing/error/loading/network/OTP states and widget tests, plus owner's manual confirmation. No new device accessibility audit claimed. |

## Findings and minimal fixes

1. **Settings auth navigation:** Settings still opened the template password screen, including after sign-out. Added an account Email OTP route using the existing Cubit/view, without implying a capture draft exists. Optional-auth sign-out now returns to guest Home. Capture/OTP resume remains unchanged. Added route/account-mode regression tests; template auth capabilities remain available.
2. **Hosted maintenance:** Existing retention/reconciliation functions lacked scheduled execution. Enabled hosted `pg_cron` 1.6.4 and applied migration `20261103000900_pickwell_maintenance_jobs.sql`. Private candidate cleanup and expired reservation reconciliation run every five minutes. Telemetry pruning runs daily at **00:17 UTC** (08:17 Manila), including seven-day retention for these jobs' cron run history. Native databases without pg_cron can still apply the application schema; a notice identifies the hosted prerequisite.
3. **Development flag:** The ignored local Flutter configuration had notifications enabled despite their deferred scope. Disabled that flag and rebuilt; no secret configuration was committed.
4. **Build credential check:** Extended the existing environment checker with streaming APK/AAB/IPA ZIP scanning and regression tests. Bare private-key parser markers inside SDK binaries are not key bodies; complete PEM keys and credential patterns are rejected. An initial marker-only false positive was investigated and corrected.

The permanent five-minute maintenance job recorded **four successful executions**, most recently 15:50 UTC on November 3. A temporary accelerated scheduler probe successfully ran the same cleanup/reconciliation/telemetry functions and was then removed. The persistent daily telemetry job is registered and active; its first natural midnight execution was not awaited.

## Commands and observed outcomes

Commands ran from `mobile/` unless stated otherwise. Private orchestration and receipts remain in ignored `.secrets/`; they are not distributable credentials or public fixtures.

| Command/check | Observed result |
| --- | --- |
| `fvm flutter pub get --enforce-lockfile` | PASS; no dependency/lockfile change. |
| `fvm flutter analyze --no-pub` | PASS; no issues. |
| `fvm flutter test --no-pub` | **115 passed** after fixes. |
| `python3 -m unittest discover -s tool -p 'test_*.py'` | **21 passed**. |
| Root: `node .secrets/t071-backend-suite.mjs` | **146 passed, zero failures/skips** across 12 backend/spike test files; native-mutating suites isolated by reset. |
| Root: `node .secrets/analysis-native-run.mjs reset` and `test` | PASS; **6 SQL files / 142 assertions**. Repeated after maintenance migration. No Docker required. |
| Catalog migration fixture suite after new migration | **9 passed**; clean migration application remains valid. Included in backend total above, not additional tests. |
| Root: protected hosted boundary runner | **30 HTTP checks passed**: guest/verified protected-table writes and private job reads denied; forged/guest analysis rejected; invalid images rejected before provider; malformed barcode, published hit and explicit miss checked. |
| Root: protected spike lock check | HTTP 503 `spike_disabled`; no inference. |
| Supabase linked migration dry-run and push | Only maintenance migration pending; applied successfully. Hosted scheduler activation and execution verified. |
| `fvm flutter build apk --debug --dart-define-from-file=.secrets/dev.secrets` | PASS; fresh Android debug APK. No fresh hardware installation or signed store build claimed. |
| `python3 tool/check_environment.py --config .secrets/dev.secrets --artifact build/app/outputs/flutter-apk/app-debug.apk` | PASS; public-only config, tracked/nonignored known-pattern scan and APK scan. |
| Private exact-value APK scan | PASS; 674 ZIP entries, 350,911,183 uncompressed bytes, three known protected credential values checked in multiple encodings; zero findings. |

Backend suite breakdown: authorization 5; quota response 4; extraction validation 32; orchestration 30; schema 9; lookup 11; interpretation 8; events 8; quota boundaries 19; retake details 2; RLS boundary 7; spike core 11.

Final artifact: `mobile/build/app/outputs/flutter-apk/app-debug.apk`.
SHA-256: `7d369d2a9c4b1bf9453aefc324d247333a4d5838f53a955ba8f576c040c1538a`.

## Hosted safety and cost observations

At inspection, the cloud had four ready products, 15 successful provider ledger rows, three finalized successful-analysis credits, no in-flight/unknown provider rows, zero analysis candidates and zero Storage objects. Provider rows and finalized credits were unchanged by hosted QA. Inference was already enabled for testing; this pass made **zero Meta calls** and did not reset allowances, alter existing product data or enable billing. The existing model is `muse-spark-1.3` at `https://api.meta.ai/v1/chat/completions`; this report makes no new latency/token/cost claim.

All exposed public tables had RLS enabled; no protected-table anonymous/authenticated DML grants were found. Hosted direct-write checks covered 11 protected tables with both guest and verified-user credentials. Public output omitted private contributor/session/image data. The deployed spike remains handler-disabled. Secret checks cover current tracked/nonignored files and the built APK; they do not establish a full Git-history audit or prove the absence of every possible credential format.

## Modified files

- `mobile/lib/src/config/router/app_router.dart`
- `mobile/lib/src/config/router/consumer_route_policy.dart`
- `mobile/lib/src/features/auth/presentation/views/email_otp_gate_view.dart`
- `mobile/lib/src/features/settings/presentation/views/settings_view.dart`
- `mobile/test/catalog/email_otp_test.dart`
- `mobile/tool/check_environment.py`
- `mobile/tool/test_check_environment.py`
- `supabase/migrations/20261103000900_pickwell_maintenance_jobs.sql`
- `docs/PICKWELL_TASKS.md`
- `docs/PICKWELL_END_TO_END_QA.md`

Ignored local development configuration also changed (notifications disabled); private test receipts were retained outside Git.

## Handoff and remaining work

T07.1's nine checks are recorded above, with the live quota exception and manual evidence source explicit. No additional credentials or assets are required for this testing-profile sign-off. Next: **T07.2 hackathon submission handoff**, requiring a truthful actual-flow demo and direct verification of organizer rules/deadline. Do not automatically start it.

T06.3 remains deferred at the owner's request. T06.4 remains a P1 Settings/account/privacy polish task; the small auth-navigation correction does not complete that broader task. Public-release work still includes restoring production allowances, validating release signing/iOS/store artifacts as applicable and observing the first naturally scheduled daily retention run. None of these is represented here as already performed.
