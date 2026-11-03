# T05.2 — Extract, interpret and validate

2026-11-03. **PARTIAL.** Versioned validation, rule evidence and protected orchestration
integration are implemented and tested. Three fresh real two-photo Meta calls ran,
but neither supplied product pair passed whole-product validation. No product was
published. Two successful representative real products and a genuine unreadable
photo remain unverified. This does not reopen completed orchestration work or claim
that the full mobile analysis flow is ready.

## Reconciliation and implementation

Reviewed root instructions, backend README, PRD v1.4, DESIGN/SPEC v1.2, DATABASE v1.0,
TASKS, the existing spike and T05.1 handoff. The working tree started clean at
`9a112df`. Flutter, authentication, quotas, billing and migrations are preserved.
The existing `analysis_candidates` JSON shape supports the additional validated
handoff, so no schema change, new table or migration was needed.

New `_shared/analysis_validation.mjs` supplies `label-analysis-v2`, a strict bounded
schema and a pure deterministic gate. The existing adapter accepts an optional
profile; its original v1 spike schema/defaults and all eleven tests still work.
Production orchestration now requests v2 and stages only accepted private candidates
with `candidate.validation`, model/prompt/rules versions and validation timestamp.
Retakes settle through the existing exactly-once reservation logic. No publication
or successful-analysis credit is created here. The public processing stage remains
`validation_pending` for compatibility until the publication/status task is wired;
the private validation status distinguishes the accepted handoff.

The model transcribes facts and produces tightly constrained readable statements
in the **same bounded call**, logically extracting before explaining. This differs
from SPEC's illustrative second explanation pass: a separate paid request would
need its own provider admission/accounting. No untracked second request was added.
Explanations currently restate literal label facts with an attributed prefix;
unsupported prose, health claims and invented numbers are omitted. Broad ingredient
background descriptions are not implemented or presented as established evidence.

## Validation contract

- Preserve raw ingredients, literal ordered ingredient items and visible declared
  allergen text. Repeated ingredients in compound components are allowed only at
  distinct ordered source positions; missing/reordered spans fail. Explicit cropped
  transcription markers require an ingredient retake. Allergen declarations need
  literal evidence; unknown declaration never means allergen-free.
- Preserve raw nutrition, serving text, values, units and one explicit source basis.
  Optional unknown nutrients stay null. Energy, fat, carbohydrate and protein must
  be readable. A per-serving panel needs literal serving context. No mixed-column
  or per-serving-to-100g conversion is inferred.
- Check numeric/unit source spans, duplicate canonical nutrients, mass/energy bounds,
  sugar/carbohydrate, added-sugar/sugar, saturated-fat/fat and kcal/kJ contradictions.
  `mcg`, `µg` and `ug` source spellings can represent schema unit `ug`; Calories can
  evidence kcal without an invented printed unit. Broad physical bounds are guards,
  not nutrition classifications. Not all possible nutritional inconsistencies are
  detectable, particularly when no mass quantity is printed.
- Compare discernible names and model mismatch observation. Mismatches require both
  photos. Unknown identity stays explicit; this is not proof that both photos match
  the scanned barcode. There is no independent OCR or package/barcode identity proof.
- Return only `needs_retake` plus relevant photo targets on failed fact validation;
  no partial findings/result are published. Malformed model schemas fail closed.
- Limit combined candidate/validation JSON before private staging. Raw photos remain
  request-local; no image bytes/URLs, auth tokens or contributor email are added to
  persistence, operational events or public responses.

## Versioned colour rules

`uk-fop-2016-conservative-v1` references the UK government's November 2016
[front-of-pack guidance, Annex 3 Table 2](https://www.foodstandards.gov.scot/downloads/FoP_Nutrition_labelling_UK_guidance_November_2016.pdf).
These are nutrient-specific reference criteria, not a Philippine legal certification
or a whole-food health rating. No energy colour, numeric score or ingredient
safety judgement is generated.

| Nutrient | Green maximum, g/100g | Red above, g/100g | Red above per portion when portion >100g |
| --- | ---: | ---: | ---: |
| Fat | 3 | 17.5 | 21 g |
| Saturates | 1.5 | 5 | 6 g |
| Total sugars | 5 | 22.5 | 27 g |
| Salt | 0.3 | 1.5 | 1.8 g |

Between low/high thresholds is yellow. Only explicitly per-100g solid-food values
are classified. A known gram portion is needed for green/yellow; a high density can
remain red without portion context. Large-portion high overrides are applied where
known. Per-serving, liquids/per-100ml, unknown food form, sodium-to-salt conversion,
missing values and unsupported context receive no inferred classification. Each
finding preserves rule/version, reference, thresholds, source span, value/unit/basis
and any portion calculation. Model prose cannot set a colour.

## Actual live evidence

Used the existing isolated `meta-vision-spike` function with gateway JWT verification,
operator token, trusted confirmed non-anonymous user allowlist, three-call process
cap and one active call. The existing session was refreshed normally. Keys stayed in
protected server configuration; no token/key/OTP was printed or committed. Normal
`analyze-product` inference and billing remained OFF throughout.

Model **muse-spark-1.3**, endpoint **https://api.meta.ai/v1/chat/completions**.
Each call used two different actual local JPEGs, one bounded request, no automatic
retry, 4096 output-token limit and 30-second timeout. All provider responses were
HTTP 200, `finish_reason=stop`, and strict v2-schema compatible.

| Pair | Initial protected handler result | Provider duration | Input / output tokens | Final gate on saved candidate |
| --- | --- | ---: | ---: | --- |
| Product A | 200, retake ingredients + nutrition | 16.571 s | 2262 / 1859 | Retake ingredients |
| Product B | 200, retake nutrition + ingredients | 9.077 s | 1142 / 1041 | Retake both |
| Known mismatched pair | 200, retake both | 11.224 s | 3275 / 1835 | Retake both |

**Total three new calls: 6,679 input / 4,735 output tokens.** No provider cost was
reported; `estimated_cost_usd=null`. No fresh price or invoice was independently
verified, so no new USD estimate is asserted. Durations include provider response
parsing/validation and exclude upload/OTP/deployment. These spike calls use its
separate operator protections, not production quota/ledger admission; their usage is
recorded here/private receipts, not falsely claimed present in `ai_usage`.

Product A's model candidate preserves 15 nutrition entries, per serving, package
105g, including 430 kcal, fat 14g, sodium 1280mg and carbohydrate 66g, consistent with
prior label comparison. Ingredients include explicit cropped markers and the model
requested an ingredient retake. It is not a complete accepted product.

Product B's essential fat/carbohydrate/protein are null, its tiny dual-column panel
is not safely resolved, and its new ordered ingredient candidate has missing or
inconsistent source entries. No inferred missing nutrient was accepted.

The third file named `unreadable_label.jpeg` is readable cookie packaging; paired
with Product A nutrition it is a **mismatch**, not an unreadable-image test. The
model flagged mismatch and the backend rejected both. A genuinely unreadable real
fixture is still absent; synthetic missing/invalid fields cover the local gate only.

Live evidence exposed false rejections for legitimate repeated compound ingredients,
printed `mcg` and added-sugar word order. Corrected those checks and added regressions.
The final column is an **offline rerun of the exact saved live candidates with the
corrected gate**, not another live inference or a newly successful extraction.
The guarded deployment used for these three calls was disabled afterward, operator
token rotated, and HTTP 503 `spike_disabled` verified. Original T01.1 findings remain
unchanged. Photos and private evidence stay ignored/owner-only; the directory the
user reconfirmed still contains the same five original files, not clearer replacements.

## Targeted validation and deployment

Passed **43 tests, zero failures/skips**:

```sh
PICKWELL_NATIVE_STATUS=.secrets/native-status.json node --test --test-concurrency=1 \
  supabase/tests/analyze_product.test.mjs \
  supabase/tests/analysis_validation.test.mjs \
  supabase/spikes/meta-vision/core.test.mjs
```

Includes 14 pure schema/rule tests; 11 unchanged spike tests; and 18 handler/native
Auth/REST/PostgreSQL tests, including the native parent test. Two synthetic foods
exercise colours and evidence, not live OCR. Checks cover exact threshold boundaries,
portion overrides, null facts, units, mismatches, contradictory/malformed payloads,
separate retakes, ignored unsupported prose, size bounds, parallel submissions,
image-bound replay, quota release, denied clients and versioned private staging.

Native Runtime used pinned CLI 2.122.0 and a disposable loopback database, without
Docker. Only that guarded local database was reset. Startup/status output went to
ignored private files. The native stack was stopped after validation. JS syntax,
diff whitespace, a known-private-credential scan across 1,262 tracked/new file paths
and credential-pattern checks of changed files also passed with zero matches.

Protected `analyze-product` was updated via `functions deploy --use-api` with the
explicit existing Pickwell project ref. No migrations, data reset, billing or
inference switches were changed. Hosted smoke passed six checks: guest/public-key/forged bearer 401; verified malformed
input 400; valid unknown multipart 503 `inference_disabled`; published demo 200
`already_exists` with eight nutrient entries and zero production Meta calls. Read-only
DB checks after deployment confirm one Auth user, one demo product, zero jobs,
candidates and production provider-ledger rows; all 29 public tables retain RLS and
protected grants/RPC execution remain denied. The cache smoke added one private
fingerprint receipt (two total), without image bytes. Inference/billing remain false.
The three operator-only real calls above are separately recorded and were not routed
through this disabled production endpoint. The operator-only `analysis-index.ts` and v2 manifest template retain
the reproducible spike entry; the existing runner accepts v1 `extracted` or v2
`validated` expectations and still fails when two required successful cases retake.
Never supply this server environment to Flutter or enable unauthenticated inference.

## Remaining acceptance and next dependency

**Unmet:** two real complete validated products; a genuine unreadable real-image
retake; substantive non-medical ingredient background explanations beyond factual
label restatements. Readability/source-validation limits are not waived to meet the
hackathon timeline. Clearer full Product A ingredients and Product B nutrition are
required, and Product B ingredients should be recaptured if inconsistent extraction
persists. No additional credentials are currently missing.

T05.3 may consume the validated private handoff when requested, but must revalidate,
atomically publish/finalize once, preserve provenance and retain these quality gates.
It is not implemented here. Flutter upload/results wiring, automatic retention
scheduling and genuine end-to-end mobile submission remain separate prerequisites.

## Exact repository files changed

- `docs/PICKWELL_ANALYSIS_VALIDATION.md` — inventory, rules, live and targeted evidence.
- `docs/PICKWELL_TASKS.md` — T05.2 partial status; last three implementation checks verified.
- `supabase/README.md` — current validation handoff and remaining constraints.
- `supabase/functions/_shared/analysis_validation.mjs` — schema, validation, rules/provenance.
- `supabase/functions/_shared/analyze_product.mjs` — protected v2 validation/staging/retakes.
- `supabase/spikes/meta-vision/core.mjs` — optional schema/parser profile, preserved v1 defaults.
- `supabase/spikes/meta-vision/analysis-index.ts` — guarded v2 operator entry.
- `supabase/spikes/meta-vision/cases.analysis.example.json` — placeholder v2 manifest.
- `supabase/spikes/meta-vision/run.mjs` — v1/v2 success expectation support.
- `supabase/tests/analysis_validation.test.mjs` — deterministic positive/negative coverage.
- `supabase/tests/fixtures/label_analysis.mjs` — explicitly synthetic rule/schema facts.
- `supabase/tests/analyze_product.test.mjs` — real local integration with mocked v2 provider.

Commands additionally executed: pinned CLI native start; guarded loopback-only
`db reset`; native stop; `functions deploy analyze-product --project-ref
bzmqgjinbjykhqqswdva --use-api`; six hosted HTTP smoke assertions; read-only
`db query --linked --project-ref ... --file ... --output json` before/after;
protected spike deployment and secrets set from ignored files, followed by lockdown;
`node --check` on changed JS modules; `git diff --check`; credential scans and
`git check-ignore` on all five real fixture paths. All final checks succeeded.
No full-project regression, new device run, migration or T05.3 implementation occurred.
Private receipts/runner environments are ignored. This implementation is prepared
for the requested commit; no fixture, credential or private receipt is included.

User follow-up (2026-11-03): defer the remaining full-flow/device and real-label
acceptance tests until the full flow is connected. T05.2 remains PARTIAL and its
quality gates remain enforced; this deferral is not evidence that those tests pass.
Keep targeted authorization, quota and validation checks for subsequent changes.
T05.3 is the recommended next implementation task, not started by this commit.
