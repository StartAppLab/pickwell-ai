# OCR-first extraction policy — 2026-11-03

User-approved change: display readable Meta-transcribed label information instead
of repeatedly rejecting a whole photo for transcription/source differences.
This supersedes the strict source/order/full-label rejection policy in earlier
validation reports. It does not replace the approved authentication architecture.

## Reproduced failure

The latest hosted job at 13:47:44 UTC returned nutrition retake with validation
numeric_source diagnostics for energy, fat, saturates, carbohydrate, fibre, sugars
and protein. These were backend diagnostics, not model blur/wrong-photo reasons.
The discarded raw candidate is unavailable, so its exact source formatting cannot
be reconstructed. Comparing two fields transcribed by the same model was blocking
useful OCR without providing an independent accuracy check.

## New behavior: model-transcription-v4

- Use Meta's typed extraction as the displayed nutrition/ingredient information.
  No regex equality or substring/order requirement rejects the whole extraction.
- Keep readable partial ingredient text and explicit unknown spans. If itemization
  is absent, display the readable transcription rather than inventing ingredients.
  Uncorroborated declared-allergen text becomes unknown; never claim allergen-free.
- Readable nutrition text may proceed with unknown amounts or an empty nutrient
  array. Empty text and explicit wrong/mismatched photos still need replacement.
- Model blur/cropping/retake advice is advisory when usable text is present.
  It cannot by itself discard the extracted information.
- Negative/nonfinite/malformed responses still fail the typed schema. Impossible
  amounts, inappropriate units, duplicate nutrient rows and contradictory amounts
  become unknown rather than forcing another capture.
- Source/basis/threshold checks remain solely for deterministic colour claims.
  Unmatched model values may be displayed, but cannot produce evidence-backed
  green/yellow/red findings. No numeric score or overall food certification.
- Results explicitly describe AI-transcribed information as potentially containing
  reading errors/missing text. It is not independently verified OCR. No provider
  promise of perfect image reading or complete product identity is made.

Private staged candidates normalize accepted advisory retakes to extracted before
storage and revalidate identically at publication. The small additive migration
20261103000600 permits readable nutrition with an empty nutrient array; it keeps
nonempty raw text and all existing numeric/unit/source checks and role grants.
No image or credential is added to storage, events or logs.

## Observed targeted validation

Two actual approved-model calls used the supplied local nutrition/ingredient pairs
through the existing private server-only adapter, with no public spike activation,
no shared-catalog writes and no automatic retry:

| Pair | Model / final status | Numeric entries retained | Duration | Input/output tokens |
| --- | --- | ---: | ---: | ---: |
| Product A | extracted / validated | 15 of 15 | 15.441 s | 2685/1870 |
| Product B | extracted / validated | 1 of 5; uncertain model amounts remain null | 20.635 s | 1565/1766 |

Model muse-spark-1.3, endpoint https://api.meta.ai/v1/chat/completions. Both returned
HTTP200 and finish_reason=stop with two images in one bounded request. Product A
returned 71 ingredient items; B returned 17. These counts do not establish complete
per-field accuracy. B's small two-column label remains difficult for the model;
this policy exposes unknowns instead of demanding another photo. No new unreadable
photo trial or physical-device test was performed. The files remain Git-ignored.

Total 4250 input / 3636 output tokens. Provider-reported cost was unavailable.
At the previously recorded $1.25/M input and $4.25/M output, the estimate is
$0.02077, not an invoice. These local diagnostics do not spend a successful-analysis
credit or appear in the production provider ledger; their usage is recorded here.

Targeted command:

    PICKWELL_NATIVE_STATUS=.secrets/native-status.json node --test --test-concurrency=1 supabase/tests/analyze_product.test.mjs supabase/tests/analysis_validation.test.mjs supabase/spikes/meta-vision/core.test.mjs

68 passed, zero failures/skips, using disposable native Auth/Postgres/REST with
mocked Meta for orchestration. This includes partial/text-only publication,
source/order inconsistencies, unknown/contradictory amounts, atomic save, one-credit
settlement, guest cache reuse without another provider call, same-key replay,
ownership and malformed-input rejection. The two real provider calls above are
separate from these mocked integration tests. Full device QA remains outstanding.

## Hosted deployment

Dry run showed only migration 20261103000600 pending; cloud push and the protected
analyze-product deployment succeeded. Hosted read-back confirms text-only nutrition
accepted, empty raw/negative amounts rejected, client configuration writes denied,
inference on and billing off (controls version5 unchanged). Guest analysis remains
HTTP401. Syntax/whitespace and changed/new-file secret-pattern checks passed with
zero findings. Native services were stopped afterward. No Flutter change/rebuild
is required. Existing numeric_source retake jobs can use Reanalyze saved photos;
replaying an old key alone correctly preserves its old outcome.
