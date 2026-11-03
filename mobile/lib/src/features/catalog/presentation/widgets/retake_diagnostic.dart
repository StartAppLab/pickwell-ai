import 'package:flutter/material.dart';
import '../../../../core/_core.dart';
import '../../domain/entities/retake_detail.dart';

class RetakeDiagnostic extends StatelessWidget {
  final RetakeDetail detail;
  const RetakeDiagnostic({super.key, required this.detail});
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final source = switch (detail.origin) {
      RetakeOrigin.model => l.pkRetakeSourceModel,
      RetakeOrigin.validation => l.pkRetakeSourceValidation,
      RetakeOrigin.legacy => l.pkRetakeSourceLegacy,
    };
    final field = switch (detail.field) {
      RetakeField.nutritionPanel => l.pkRetakeFieldNutritionPanel,
      RetakeField.ingredientsList => l.pkRetakeFieldIngredientsList,
      RetakeField.productIdentity => l.pkRetakeFieldProductIdentity,
      RetakeField.servingBasis => l.pkRetakeFieldServingBasis,
      RetakeField.servingSize => l.pkRetakeFieldServingSize,
      RetakeField.allergens => l.pkRetakeFieldAllergens,
      RetakeField.energy => l.pkRetakeFieldEnergy,
      RetakeField.fat => l.pkRetakeFieldFat,
      RetakeField.saturates => l.pkRetakeFieldSaturates,
      RetakeField.carbohydrate => l.pkRetakeFieldCarbohydrate,
      RetakeField.sugars => l.pkRetakeFieldSugars,
      RetakeField.addedSugars => l.pkRetakeFieldAddedSugars,
      RetakeField.protein => l.pkRetakeFieldProtein,
      RetakeField.salt => l.pkRetakeFieldSalt,
      RetakeField.sodium => l.pkRetakeFieldSodium,
      RetakeField.fibre => l.pkRetakeFieldFibre,
      RetakeField.other => l.pkRetakeFieldOther,
    };
    final reason = switch (detail.cause) {
      RetakeCause.allergenSource => l.pkRetakeCauseAllergenSource,
      RetakeCause.blurOrGlare => l.pkRetakeCauseBlurOrGlare,
      RetakeCause.contradictoryEnergy => l.pkRetakeCauseContradictoryEnergy,
      RetakeCause.contradictoryMass => l.pkRetakeCauseContradictoryMass,
      RetakeCause.contradictoryTotals => l.pkRetakeCauseContradictoryTotals,
      RetakeCause.croppedLabel => l.pkRetakeCauseCroppedLabel,
      RetakeCause.duplicateNutrient => l.pkRetakeCauseDuplicateNutrient,
      RetakeCause.incompleteIngredients => l.pkRetakeCauseIncompleteIngredients,
      RetakeCause.ingredientOrderOrSource => l.pkRetakeCauseIngredientOrderOrSource,
      RetakeCause.missingIngredients => l.pkRetakeCauseMissingIngredients,
      RetakeCause.missingNutrition => l.pkRetakeCauseMissingNutrition,
      RetakeCause.modelRequested => l.pkRetakeCauseModelRequested,
      RetakeCause.noReadableValues =>
        detail.origin == RetakeOrigin.model
            ? l.pkRetakeModelNoValues
            : l.pkRetakeCauseNoReadableValues,
      RetakeCause.numericRange => l.pkRetakeCauseNumericRange,
      RetakeCause.numericSource => l.pkRetakeCauseNumericSource,
      RetakeCause.other => l.pkRetakeCauseOther,
      RetakeCause.productMismatch => l.pkRetakeCauseProductMismatch,
      RetakeCause.reasonUnavailable => l.pkRetakeCauseReasonUnavailable,
      RetakeCause.unitMismatch => l.pkRetakeCauseUnitMismatch,
      RetakeCause.unreadableText => l.pkRetakeCauseUnreadableText,
      RetakeCause.unspecifiedRetake => l.pkRetakeCauseUnspecifiedRetake,
      RetakeCause.wrongPhoto => l.pkRetakeCauseWrongPhoto,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('$source · $field', style: context.textTheme.titleSmall),
          Text(reason),
        ],
      ),
    );
  }
}
