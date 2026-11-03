import 'label_photo.dart';

enum RetakeOrigin { model, validation, legacy }

enum RetakeCause {
  allergenSource('allergen_source'),
  blurOrGlare('blur_or_glare'),
  contradictoryEnergy('contradictory_energy'),
  contradictoryMass('contradictory_mass'),
  contradictoryTotals('contradictory_totals'),
  croppedLabel('cropped_label'),
  duplicateNutrient('duplicate_nutrient'),
  incompleteIngredients('incomplete_ingredients'),
  ingredientOrderOrSource('ingredient_order_or_source'),
  missingIngredients('missing_ingredients'),
  missingNutrition('missing_nutrition'),
  modelRequested('model_requested'),
  noReadableValues('no_readable_values'),
  numericRange('numeric_range'),
  numericSource('numeric_source'),
  other('other'),
  productMismatch('product_mismatch'),
  reasonUnavailable('reason_unavailable'),
  unitMismatch('unit_mismatch'),
  unreadableText('unreadable_text'),
  unspecifiedRetake('unspecified_retake'),
  wrongPhoto('wrong_photo');

  final String value;
  const RetakeCause(this.value);
}

enum RetakeField {
  nutritionPanel('nutrition_panel'),
  ingredientsList('ingredients_list'),
  productIdentity('product_identity'),
  servingBasis('serving_basis'),
  servingSize('serving_size'),
  allergens('allergens'),
  energy('energy'),
  fat('fat'),
  saturates('saturates'),
  carbohydrate('carbohydrate'),
  sugars('sugars'),
  addedSugars('added_sugars'),
  protein('protein'),
  salt('salt'),
  sodium('sodium'),
  fibre('fibre'),
  other('other');

  final String value;
  const RetakeField(this.value);
}

class RetakeDetail {
  final LabelKind photo;
  final RetakeOrigin origin;
  final RetakeCause cause;
  final RetakeField field;
  const RetakeDetail({
    required this.photo,
    required this.origin,
    required this.cause,
    required this.field,
  });
}
