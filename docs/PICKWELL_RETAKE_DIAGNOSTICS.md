# Photo-specific retake diagnostics

2026-11-03 — User-requested explanation of repeated retakes.

## Actual observations

The latest two real calls completed with Muse Spark 1.3 in 10.778 s and 16.350 s,
each with 7,394 input tokens and respectively 1,952 / 2,445 output tokens. Both
jobs ended needs_retake for nutrition. Five provider calls for that barcode had
completed, but rejected candidates and detailed reasons had not been retained.
These observations cannot establish whether Meta or validation caused the latest
retakes. No retrospective photo diagnosis is invented.

Meta documents image understanding for Muse Spark 1.3:
[official models](https://dev.meta.ai/docs/models). Existing trials demonstrate
partial extraction, but full two-product extraction/publication acceptance has
not passed.

## Implemented changes

- The shared adapter retained blanket unreadable-label retake wording. The analysis
  profile now supplies a consistent policy: resolve familiar nutrient words using
  context, proceed with readable facts and explicit unknown fields, and request
  retakes only under the existing essential-photo policy. The generic operator
  spike retains its own default. The old conflict may have encouraged retakes;
  it is not a proven diagnosis of historical requests.
- The SAME Meta request asks for up to six enum-only reasons with photo, code and
  affected field. No second diagnostic request or automatic retry is added.
  Model, minimal reasoning, 30-second timeout and 4,096 output-token bound remain.
  Reason fields add some prompt/output tokens; this is not a zero-token change.
- Backend validation records separate reasons for source mismatch, conflicting
  totals, invalid ranges, missing ingredients and other rejection gates. If all
  numeric values fail source checks, affected fields accompany that rejection.
  These are labeled Validation check, not assumed blur or glare. Individual
  uncertain amounts remain unknown without a retake if other facts are usable.
- UI groups reasons under Nutrition/Ingredients, identifying Meta photo review,
  Validation check or Earlier result, with relevant field and guidance. Old
  responses honestly show reason unavailable. Only allowlisted codes/fields are
  rendered; raw provider prose, label text and extra properties are not echoed.
- Migration 20261103000400_pickwell_retake_details.sql adds bounded enum-only job
  metadata and a service-only invoker RPC. Storage and retake/quota settlement
  share one transaction/advisory lock. Owner replay retrieves the same reasons
  without a provider call. SQL rejects arbitrary fields, invalid enums and large
  payloads. No image, email, key or raw label/provider text is stored in reasons.
- The owner-scoped status handler core also sanitizes these fields; that endpoint
  was not already deployed, so no new public endpoint was introduced. The app
  uses the deployed protected analyze-product replay path.
- Old stored candidates without reason fields still revalidate compatibly. New
  provider responses use the strict reason-aware schema; compatible v2 publication
  and rule provenance remain unchanged.

## Previously saved photos

Old jobs default to an empty reason list. Replay supplies reason unavailable and
an explicit allow_diagnostic_reanalysis hint. The app offers Reanalyze saved photos
only for those legacy retakes, with a notice that it starts a fresh Meta attempt.
It preserves both photos, persists a fresh key before sending, suppresses duplicate
taps and does not reappear on the new reason-bearing result. Unknown provider
outcomes always retain their key and cannot use this path. JWT/verified-email,
quotas, idempotency and spending controls still apply.

Five attempts had reached the prior five-attempt barcode cap. Within the user's
existing hackathon testing authorization, only that cap was raised to ten
(control version 4), under unchanged global 20 attempts/day and USD 30 budget.
Free 30/3, concurrency one, billing off and inference on remain. No ledger entries
were erased and no real Meta call was invoked by this implementation.

## Observed verification

- 106 catalog Flutter tests passed: typed parsing, redaction, photo/field/origin
  rendering, large text, historical fallback, explicit saved-photo reanalysis with
  one fresh key and no camera recapture.
- 82 backend tests passed, zero skips, against disposable Native Auth/REST/SQL and
  mocked Meta: durable reasons/replay, ownership and privileged RPC boundaries,
  malformed/raw reason rejection, quota release, historical replay with zero
  model calls, publication and consistent system-prompt assembly.
- Analyzer, syntax, whitespace and credential checks passed. Native services
  stopped after verification. No hardware test, new live diagnostic response or
  successful real-product publication is claimed.
- Dry run identified exactly the reason migration; it applied to the hosted
  project. Protected analyze-product deployed through CLI 2.122.0 API bundling.
  Hosted read-back confirms shape acceptance, raw-text denial, client/guest RPC
  denial, inference on and billing off.

Commands: fvm flutter gen-l10n; fvm flutter test --no-pub test/catalog;
fvm flutter analyze --no-pub (from mobile).
Native command from repository root:

    PICKWELL_NATIVE_STATUS=.secrets/native-status.json node --test --test-concurrency=1 supabase/tests/analyze_product.test.mjs supabase/tests/analysis_validation.test.mjs supabase/tests/retake_details.test.mjs supabase/tests/analysis_quota_response.test.mjs supabase/tests/security_boundary.test.mjs supabase/tests/get_product.test.mjs supabase/spikes/meta-vision/core.test.mjs

## Next device check

Rebuild/restart without uninstalling. Open the saved item and submit/replay it to
load its earlier status if necessary, then choose Reanalyze saved photos for an
explicit fresh diagnostic attempt. New retakes show reasons directly. Photos
remain available for independent relevant-label retake. This change explains
failures; it does not guarantee that every label passes. T05.2 real-image quality
and T07.1 device/full-flow acceptance remain open.

Primary files: new shared retake_details module, analysis_validation, analyze_product,
analysis_publication, catalog_boundary, shared Meta adapter, the new migration;
Flutter retake_detail entity/export, analysis entity/model/Cubit, capture view,
retake diagnostic and submission notice widgets, localized/generated messages;
targeted backend fixtures/validation/diagnostic/handler tests and client diagnostic/
submission tests. Prior uncommitted work was preserved. No live acceptance checkbox
was advanced based on mocked responses.

## Source-matcher correction

The explicit saved-photo action is also available for completed numeric_source
validation rejections. This supersedes the earlier legacy-only restriction; it
does not apply to unknown provider outcomes or auto-start another call. See
[numeric matching evidence](PICKWELL_NUMERIC_SOURCE_MATCHING.md) for reproduced
formatting bugs, exact-value safeguards and validation. Restart the app to refresh
an already loaded result. No new camera capture is required for the retry action.

## Superseding OCR-first policy

The 13:47 UTC job again recorded backend numeric_source failures across nutrition.
The user requested removal of those extraction restrictions. See
[OCR-first policy and results](PICKWELL_OCR_FIRST_POLICY.md): source mismatches and
partial OCR no longer request a retake, and source checks only gate colour claims.
Historical reason codes remain valid for replay. The saved-photo diagnostic retry
already offered for those numeric_source jobs starts a fresh request under the new
policy; it does not mutate the historical outcome or require new photos.
