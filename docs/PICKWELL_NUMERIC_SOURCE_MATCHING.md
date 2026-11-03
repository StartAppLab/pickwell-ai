# Numeric source-matching regression fix

2026-11-03 — Follow-up to repeated numeric_source retakes.

## Evidence and cause

The latest two inspected retake jobs (08:07 and 08:09 UTC) recorded validation
numeric_source failures across energy, fat, carbohydrate, protein and other fields.
That code is generated after Meta returns a non-null amount which our validator
cannot verify against its quoted source/transcription. It does not mean that the
model returned no text or that the camera image was necessarily unreadable.
The rejected raw candidate is not retained, so the precise formatting of those
particular responses cannot be reconstructed.

The previous matcher demonstrably rejected otherwise valid fixtures for uppercase
units (3G versus 3g) and compact source spacing (3g quoted against 3 g). Regression
inputs explicitly assert that their formatting was changed, avoiding no-op tests.
The fix addresses those reproduced bugs without claiming ground-truth accuracy
for the user's unretained extraction.

## Implemented behavior

Nutrition-only evidence comparison now accepts NFKC/case/spacing equivalence,
common gram/milligram/microgram unit spellings, explicit parenthesized row units
before/after values (Protein (g): 8), leading decimals, unambiguous decimal printing
and repeated identical values. Calories rows can omit kcal and include a separate
percent-daily-value figure. Serving and basis source checks use the same formatting
normalization, so legitimate compact/word units do not silently erase context.

The original raw transcription and selected numeric amount remain unchanged.
No OCR digit correction, amount inference or mass/energy conversion is introduced.
Exact numeric equality is required after parsing; even tiny discrepancies at
traffic-light thresholds are not rounded across classification boundaries.
Different column values, percentage-only amounts, negative/inequality expressions
and ambiguous thousands/decimal forms remain unknown. Decimal punctuation keeps
its meaning during source comparison. A missing optional value still does not
require a retake if other numeric facts are usable.

The Meta instructions explicitly ask for the selected row value/unit as source,
not an entire panel. Provider request count, timeout and output bound are unchanged.
The extraction policy provenance is now contextual-label-words-v2; rule thresholds
and public storage schema are unchanged.

## Existing saved-photo retries

The server now also offers the existing explicit Reanalyze saved photos action
for completed validation numeric_source retakes, rather than only historical
reason-less retakes. This is a deliberate fresh provider attempt with a persisted
new key, not automatic retry or a bypass of any quota/auth/spend control.
Provider uncertainty cannot enter this path. Existing reason UI can consume the
same flag, so no client rebuild is required for this backend fix. Restart/reopen
the app to refresh a previously loaded result; open the saved item, submit its
existing key to reload status if necessary, then choose Reanalyze saved photos.
Do not uninstall or recapture the labels merely to retry the corrected matcher.

## Validation

The targeted native suite covers format-equivalent values becoming a real local
published product, consistent revalidation at publication, cache/idempotent replay
with one mocked provider call, source-failure replay eligibility, and unchanged
authorization, quota and public projection boundaries. Pure fixtures additionally
cover units, spacing, repeated values, column ambiguity, percent/inequality input,
numeric threshold precision, decimal and thousands ambiguity. Models are mocked;
these tests are not fresh live-image success evidence.

Commands:

    node --test supabase/tests/analysis_validation.test.mjs supabase/tests/retake_details.test.mjs supabase/spikes/meta-vision/core.test.mjs
    PICKWELL_NATIVE_STATUS=.secrets/native-status.json node --test --test-concurrency=1 supabase/tests/analyze_product.test.mjs supabase/tests/analysis_validation.test.mjs supabase/tests/retake_details.test.mjs supabase/tests/analysis_quota_response.test.mjs supabase/tests/security_boundary.test.mjs supabase/tests/get_product.test.mjs supabase/spikes/meta-vision/core.test.mjs

Final observed result: **90 native/backend tests passed, zero skips**, including
publication of the uppercase/compact-source fixture and one-call cache replay.
The pure schema/matcher subset also passed 41 tests. Syntax/whitespace and secret
checks passed. The final handler was deployed through CLI 2.122.0 API bundling;
hosted guest analysis remains 401. Read-back confirms inference on, billing off,
global 20/day, barcode 10/day and USD 30 admission budget unchanged. No real Meta
inference was invoked by these checks. Native services stopped afterward.
Client functionality did not change (only its retry-method comment was updated),
so a new app build is not required for this server-side patch. Real-photo success
must still be verified on the user's next explicit submission.
No database migration, new package, new secret, quota increase or automatic paid
request was required. T05.2 real-label quality and T07.1 device/full-flow acceptance
remain open.

Files: analysis_validation.mjs and analyze_product.mjs shared handlers, their two
targeted test files, the client Cubit comment documenting the broadened server
hint, this evidence, and linked task/validation reports. Prior commits are intact.

## Real-fixture reproduction and correction — 2026-11-03

Three bounded real Meta calls used the existing server-only adapter and approved
`muse-spark-1.3` at `https://api.meta.ai/v1/chat/completions`, directly from a
private local diagnostic harness. No public spike was enabled, shared catalog
written, user analysis credit consumed, or photo uploaded to permanent storage.
These diagnostic calls are recorded here rather than in production `ai_usage`.
The five supplied JPEGs remain Git-ignored. Both product pairs were visually
inspected; the file called unreadable_label is still not a genuine unreadable test.

The first Product A call validated all 15 extracted nutrition entries. The first
Product B call returned `extracted`, but the backend returned `needs_retake`:
Meta's separate `nutrition.raw` listed nutrient names without most quantities,
while individual source rows contained the amounts/units. Exact inclusion of every
row in raw therefore erased every numeric value. This was a reproduced validator
failure, not a claim that the camera or model could read nothing.

Policy `contextual-label-words-v3` accepts a complete named source row with its
matching amount/unit when raw omitted that row's quantity. A row for another
nutrient, conflicting digits in raw, an unsupported unit, or an amount that does
not match its source remains unknown. Raw and source are both model transcriptions,
not independent OCR measurements; this check does not prove image accuracy.
The prompt now asks for named selected-column rows in raw and source, avoiding
cereal/milk column mixing. Bilingual Calories/Calorías now supports printed energy
without requiring an invented kcal suffix.

| Real call | Initial result | Final validator on same response | Duration | Input/output tokens |
| --- | --- | --- | ---: | ---: |
| Product A pair | Validated | Validated, 15/15 numeric entries | 10.319 s | 2648/1716 |
| Product B pair, reproduction | Retake, numeric_source/no_readable_values | Validated, 5/10 entries; others unknown | 11.434 s | 1528/1818 |
| Product B pair, revised prompt | Validated | Validated, 17/17 entries including bilingual calories fix | 9.186 s | 1556/1420 |

All three provider responses were HTTP 200, finish_reason=stop, strict-schema
compatible, using the actual nutrition/ingredient JPEG pairs in test_fixtures.
Total: 5,732 input and 4,954 output tokens; no automatic retries. At the previously
recorded Standard rates ($1.25/M input, $4.25/M output), the calculated estimate is
$0.02822, not an invoice or a provider-reported charge. Provider cost was not returned.

Minimal final checks: `node --test supabase/tests/analysis_validation.test.mjs
supabase/spikes/meta-vision/core.test.mjs` — 41 passed, zero failures/skips.
New cases cover omitted raw quantities, conflicting/unrelated rows, publication
revalidation stability and bilingual calories. Earlier native checks above predate
this final row fallback; no new full native/device regression is claimed.

Both real pairs now produce schema-valid results, but validation is not an OCR
accuracy guarantee. Product B's small bilingual two-column image produced varying
amounts/nulls across calls; full per-field ground-truth review remains outstanding.
No new unreadable-image trial, hosted end-to-end publication or physical-device
flow was performed. T05.2 and T07.1 remain partial rather than claiming those gates.

Final handler deployment through CLI 2.122.0 API bundling succeeded. Hosted guest
POST remains HTTP 401. Syntax, whitespace and changed-file secret-pattern checks
passed (zero findings). No migration, mobile rebuild or quota/billing change needed.
