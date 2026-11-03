# Printed nutrient units — 2026-11-03

## Confirmed Vitamin D issue

The latest saved analysis (14:00:48 UTC) includes the source `Vitamin D 71 IU`.
The old schema admitted only g/mg/ug/kcal/kJ/unknown, so Meta returned that row
with unit unknown and value null. The original source survived in the published
record and the missing-information list included vitamin D. This was a unit
representation gap, not evidence that the photo could not be read. The user
confirmed the transcribed 71 IU was correct.

## Implementation

The shared strict extraction schema, backend validator, additive database
migration and Flutter parser now accept IU, ug RAE, ug DFE, mg NE, mg α-TE, % and
%DV in addition to existing units. Micrograms display as µg; %DV displays as % DV.
Printed equivalents/percentages remain distinct units. No automatic IU-to-mass,
vitamin-form, daily-value-to-mass or dose conversion is introduced.

The model instructions explicitly preserve these measures, map mcg/µg spelling
to ug, and retain an unsupported printed amount/unit in its source even when the
structured amount stays unknown. The UI now quotes that original source beside
unknown amounts. The already-published Vitamin D entry will therefore show its
71 IU source after rebuilding the app; its immutable stored null is not silently
rewritten or replaced with another paid analysis. Newly analyzed entries can store
value 71 and unit IU directly.

Mass and percent-daily-value rows for the same nutrient no longer collide as
duplicates. Non-mass micronutrient measures remain display facts, and percent
measures never participate in gram-based range/totals/traffic-light calculations.
The existing numerical/source/basis rules still gate supported colour claims.

These label conventions are documented in the FDA's
[Daily Value reference](https://www.fda.gov/food/nutrition-facts-label/daily-value-nutrition-and-supplement-facts-labels)
and [unit guidance](https://www.fda.gov/media/129863/download). These references
support unit representation, not a claim that a captured label is accurate or that
an amount meets nutritional needs. Local dietary recommendations are not added.

## Targeted observed validation

- 71 native/backend/schema/adapter tests passed, zero skips/failures, using
  disposable native Auth/Postgres/REST with a mocked Meta provider. Added cases
  exercise exact IU/qualified values through publication and guest lookup with
  only one provider attempt, percent/mass separation, and no vitamin colour claims.
- 14 focused Flutter repository/results tests passed. Parser and widgets preserve
  all added units, render µg and % DV, and show the source for historical unknown
  amounts without fabricating a parsed value. Analyzer on the four touched Dart
  files reported no issues. Formatting/whitespace checks passed.
- Migration 20261103000700 was the only pending migration in dry run and applied
  to the existing cloud project. Hosted assertions accept IU/qualified units and
  reject negative/unsupported amounts; client catalog inserts remain denied.
- No new live inference, account/OTP action or existing product mutation was
  required. No new dependency, image retention, credential or billing setting.
  Native services stopped after validation. Full physical-device verification
  remains outstanding.

Commands:

    PICKWELL_NATIVE_STATUS=.secrets/native-status.json node --test --test-concurrency=1 supabase/tests/analyze_product.test.mjs supabase/tests/analysis_validation.test.mjs supabase/spikes/meta-vision/core.test.mjs
    fvm flutter test --no-pub test/catalog/catalog_repository_test.dart test/catalog/product_results_test.dart
    fvm dart analyze lib/src/features/catalog/data/models/catalog_model.dart lib/src/features/catalog/presentation/widgets/nutrition_fact_row.dart test/catalog/catalog_repository_test.dart test/catalog/product_results_test.dart

The protected analyze-product handler uses extraction policy
model-transcription-units-v5. The existing get-product projection already preserves
unit/source fields, so its deployment was not changed. **Rebuild/restart the mobile
app** for its expanded parser and source fallback; the old installed parser rejects
new unit enum values. No app installation or device result is claimed here.
