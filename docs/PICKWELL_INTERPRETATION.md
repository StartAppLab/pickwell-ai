# Evidence-aware product interpretation

## Initial reconciliation — 2026-11-03

PRD F05/F08 and SPEC section 7 require ingredient functions, nutrition context,
product summaries and evidence-aware explanations. The existing server adapter
already performs private two-image Meta extraction, with typed validation, trusted
identity/quota admission and single-attempt accounting. The existing validator
accepts only literal fact restatements, applies conservative UK per-100g nutrient
rules, and publishes immutable revisions with explanations/missing-information/
provenance JSON. Flutter displays these results but has no expandable ingredient
background explanations. Shared get-product only reads the published projection.

Missing: reviewed ingredient/reference coverage, contextual nutrition prose,
meaningful summary composition, interpretation versioning/refresh, and expanded
explanation UI. Preserve scan/capture/OTP/quota/provider accounting and existing
rules. A second paid explanation request would need separate provider accounting;
use the current single bounded request instead, with reviewed source statements
and structured model selections validated after extraction. Documents need an
implementation addendum for that bounded composition, schema, reference coverage
and operator refresh contract. Existing cached facts remain immutable.

Implementation and observed validation results are recorded below when verified.

## Implemented contract

`_shared/interpretation.mjs` provides `evidence-composition-v1`, reviewed-reference
version `2026-11-03`, and `fda-dv-5-20-v1`. It recognizes 11 bounded ingredient
families: starches, emulsifiers, thickeners, acidulants, preservatives, sweeteners,
humectants, antioxidants, flavourings, MSG and explicitly whole-grain ingredients.
Prefix/negation checks prevent matching MSG-free or unrelated names. General
functions are conditional background, not proof of exact formulation, dose,
individual sensitivity, blanket safety, or harm.

Primary references were inspected on 2026-11-03:

- Ingredient roles: [FDA Types of Food Ingredients](https://www.fda.gov/food/food-additives-and-gras-ingredients-information-consumers/types-food-ingredients),
  [MedlinePlus additives](https://medlineplus.gov/ency/article/002435.htm).
- MSG context: [FDA MSG questions and answers](https://www.fda.gov/food/food-additives-petitions/questions-and-answers-monosodium-glutamate-msg).
- Whole grains: [Health Canada](https://www.canada.ca/en/health-canada/services/food-guide/explore/healthy-eating-recommendations/eat-variety/eat-whole-grains.html).
  Whole wheat alone is not treated as proof of whole-grain content.
- Nutrition context and reference thresholds: [FDA label use](https://www.fda.gov/food/nutrition-facts-label/how-understand-and-use-nutrition-facts-label),
  [FDA added sugars](https://www.fda.gov/food/nutrition-facts-label/added-sugars-nutrition-facts-label),
  [FDA Daily Values](https://www.fda.gov/food/nutrition-facts-label/daily-value-nutrition-and-supplement-facts-labels).
- General nutrient functions: [MedlinePlus protein](https://medlineplus.gov/ency/article/002467.htm),
  [NIH Vitamin D](https://ods.od.nih.gov/factsheets/VitaminD-Consumer/).

Meta receives the catalog in the same private, bounded two-image request. Its new
structured interpretation plan selects ingredient indices/reference IDs, up to five
nutrition topics and summary priorities. It composes reviewed plain-language
statements by returning the allowed catalog text. The backend verifies the exact
statement and ingredient/topic link, then supplies accepted quantities and basis.
It deliberately does not accept unrestricted paraphrases or model-authored
medical claims/citations. Invented prose/references are omitted with uncertainty,
not treated as a new reason to recapture the label. Older stored candidates retain
their legacy interpretation behavior for publication compatibility.

Nutrition topics cover energy, protein, Vitamin D, sodium, saturated fat, total
sugars, added sugars and fibre. Printed Vitamin D IU remain IU. Unknown amounts
are not invented, and total sugars never implies added grams. Model-transcribed
values remain distinguishable from reviewed background and derived reference
classifications. Existing UK per-100g rules are unchanged. The additional US FDA
rules only use source-backed, unambiguous per-serving mass values with serving
context: 5% DV or less is low; 20% or more is high. These refer to the stated US
adults/children-aged-4+ reference population, not personal targets or Philippine
legal claims. Thresholds are 2300mg sodium, 20g saturated fat, 50g added sugars,
28g fibre. High fibre can be favorable; high limiting nutrients become concerns.
No high/low total-sugar DV rule exists. Valid declared allergen text adds a
label-grounded caution rather than implying universal risk. Missing information
never becomes allergen-free or an overall health certification.

Accepted explanations cache in existing JSON fields with source spans, approved
reference IDs/titles/URLs/review dates, origin and limitations. The summary combines
accepted nutrient context, relevant concerns, declared allergens and a selected
ingredient function. Payload limits remain bounded. Public projection explicitly
allowlists nested metadata; model-supplied URLs or private fields are not copied.
Flutter reuses the existing nested Product Details, findings cards and theme;
background/reference explanations expand, raw ingredient text remains available,
and uncertainty/version information is visible. No score, purchase control,
new route, package, provider or generated artwork was introduced. New UI labels
use generated English fallbacks in other locales; reference prose is English.

## Cache refresh

Migration `20261103000800` adds a service-only invoker RPC with an empty search path.
It requires a ready product and expected immutable revision/version, preserves
nutrition/ingredients/findings exactly, writes a new sealed revision and atomically
switches the catalog pointer. Concurrent same-version refreshes create one revision;
stale different-version writes fail. Client calls, fact edits and invalidated
products are denied. Existing revisions and accounting remain intact.

The operator CLI requires explicit project and barcode, authenticates via the
existing Supabase CLI profile, defaults to dry run and prints no credentials:

    node supabase/scripts/refresh-interpretation.mjs --project-ref PROJECT_REF --barcode BARCODE
    node supabase/scripts/refresh-interpretation.mjs --project-ref PROJECT_REF --barcode BARCODE --apply

Refresh composes reviewed background from stored facts without Meta. Its provenance
explicitly says reference refresh/no new inference; it does not pretend to be fresh
AI analysis or to correct OCR. It preserves existing classifications rather than
silently rerating a product. Ordinary get-product never refreshes or invokes AI.
A future source/rule review must increment the appropriate versions and explicitly
refresh selected products; there is no automatic batch/cron/public refresh endpoint.

## Real provider checks

The existing private server-only harness sent the supplied two actual JPEG pairs
through the same approved adapter/profile. No public spike was enabled and no
fixture product was published. Model `muse-spark-1.3`, endpoint
`https://api.meta.ai/v1/chat/completions`; one request per trial, 30-second timeout,
4096 output-token bound, store=false, no automatic retry.

| Trial | Structured interpretation | Provider duration | Input/output tokens |
| --- | --- | ---: | ---: |
| Product A, ramen | Validated; 13 contextual explanations, ingredient functions, sodium/saturated-fat context | 19.939 s | 4099/2265 |
| Product B, cereal | Validated structure; 6 explanations; sugar transcription inconsistent | 29.476 s | 2979/2946 |
| Product B, shorter legacy-output instruction | Validated partial result; 3 ingredient explanations, uncertain nutrition omitted | 19.559 s | 2978/1786 |

The third call was started to reduce duplicated legacy explanation output and
measure duration, before the user deferred further cereal tests. No further
product calls were made after that direction. All responses were HTTP200 with
finish_reason=stop. Outputs explain emulsification, thickening, freshness,
sugar distinctions or whole-grain context rather than only restating label values.
The reference catalog was finalized with protein/Vitamin-D context afterward;
those additions have targeted deterministic/native coverage, not a new image call.

Total diagnostic usage: 10,056 input / 6,997 output tokens. Provider-reported cost
was unavailable. At the previously recorded Standard rates of $1.25/M input and
$4.25/M output, estimated cost is $0.04231, not a provider invoice. These diagnostic
calls are recorded here/private receipts rather than falsely claimed as production
ai_usage entries. No user successful-analysis credit was consumed by the harness.

**Important accuracy limit:** Product B is only 256 pixels wide. Its sugar readings
varied, so the initial high-added-sugar finding is conditional on an inconsistent
transcription and is not established ground truth. Its subsequent uncertain result
omits unsupported numeric interpretations. The user explicitly deferred further
products/accuracy tests. This work verifies meaningful grounded composition, not
perfect OCR or complete ingredient coverage. Comparing model source fields is not
independent verification of a photograph. No genuine unreadable-image or new
physical-device full-flow acceptance is claimed.

## Targeted tests and deployment evidence

- **99 backend/native tests passed**, zero failures/skips. Native Postgres/Auth/REST
  with mocked Meta covers model/reference selection validation, invented prose,
  unknown additives, partial nutrition, sugar distinctions, exact 5/20 boundaries,
  IU context, allergen evidence, publication/revalidation, lookup zero-model trace,
  authorization, concurrency/idempotency, immutable refresh/rollback and preservation
  of usage credits and facts. Existing barcode/cache/security regressions passed.
- **34 Flutter tests passed** for results/expanders/references, malformed reference
  rejection, green/yellow/red/unknown states, barcode lookup/Cubit and recent caching.
  Analyzer on touched code/tests reported no issues. The new expansion was rendered
  and visually inspected with synthetic widget data; no hardware behavior claimed.
- Dry run showed only the refresh migration pending; it applied to the existing
  cloud project. Protected analyze-product and guest-capable get-product were
  deployed via CLI API bundling. No key, plan limit, billing or auth setting changed.
- One existing real cached product was previewed and refreshed with the operator
  CLI. The new revision preserved label facts and prior findings, supplied five
  reference-backed explanations, and guest lookup returned ready/version/references.
  Hosted provider-row and successful-credit counts were unchanged; guest direct
  analysis remains HTTP401. Inference stays on, billing off, controls version5.
  Other cached products remain unchanged until an explicit refresh.

Commands:

    PICKWELL_NATIVE_STATUS=.secrets/native-status.json node --test --test-concurrency=1 supabase/tests/analyze_product.test.mjs supabase/tests/analysis_validation.test.mjs supabase/tests/interpretation.test.mjs supabase/spikes/meta-vision/core.test.mjs supabase/tests/security_boundary.test.mjs supabase/tests/get_product.test.mjs
    fvm flutter test --no-pub test/catalog/product_results_test.dart test/catalog/catalog_repository_test.dart test/catalog/catalog_cubit_test.dart test/catalog/recent_products_test.dart
    fvm dart analyze lib/src/features/catalog/data/models/catalog_model.dart lib/src/features/catalog/presentation/widgets/product_result_content.dart lib/src/features/catalog/presentation/widgets/interpretation_explanation.dart test/catalog/product_results_test.dart test/catalog/catalog_repository_test.dart

Primary changed files: shared interpretation/validation/public projection modules;
refresh migration/operator CLI; details/explanation widget/parser/barrel; English
ARB/generated localization outputs; backend and Flutter tests; PRD/SPEC/DATABASE/
TASKS and this evidence report. Scan/capture/OTP/provider admission infrastructure
is preserved. The understandable-explanations checkbox is verified; broader T05.2
accuracy/device gates remain open. **Rebuild/restart the mobile app** for expandable
references and stale-version messaging. No store release or device install done.

## Outcome and remaining scope

The evidence-aware layer is implemented for the reviewed catalog and supported
nutrition contexts. It meets meaningful explanation, source/uncertainty, structured
validation, caching, version/refresh and UI requirements within that bounded
coverage. It is not an exhaustive ingredient-safety database, unrestricted medical
reasoning engine or full product-accuracy certification. Further clear-label
products, final device/full-flow QA and translated reference prose remain pending;
no additional testing beyond the user's deferred scope is implied.

Final checks: syntax/whitespace and changed/new-file secret-pattern scans passed
with zero findings. Native services stopped after the 99-test run. Final Flutter
34-test run and touched-file analyzer passed after adding the visible AI-transcription
caveat. Final analyze-product deployment succeeded after reconciling the old
no-colour caveat with newly supported nutrition classifications.
