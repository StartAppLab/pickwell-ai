import 'package:flutter/material.dart';
import '../../../../core/_core.dart';
import 'nutrition_fact_row.dart';
import 'interpretation_explanation.dart';
import 'product_section.dart';

/// Presentation only: printed values/basis are never converted or classified here.
class ProductNutritionPanel extends StatelessWidget {
  final Map<String, dynamic> nutrition;
  final List<Map<String, dynamic>> explanations;
  const ProductNutritionPanel({super.key, required this.nutrition, required this.explanations});
  @override
  Widget build(BuildContext context) {
    final l = context.l10n, d = context.themeData.dimensionsData;
    final nutrients = (nutrition['nutrients'] as List? ?? [])
        .whereType<Map>()
        .where(NutritionFactRow.hasKnownValue)
        .toList();
    if (nutrients.isEmpty) return const SizedBox.shrink();
    final basis = switch (nutrition['basis']) {
      'per_100g' => l.pkPer100g,
      'per_100ml' => l.pkPer100ml,
      'per_serving' => l.pkPerServing,
      _ => null,
    };
    Map? find(Set<String> names) => nutrients
        .where((n) => names.contains(n['name']?.toString().trim().toLowerCase()))
        .firstOrNull;
    final metrics = [
      (l.pkRetakeFieldEnergy, Icons.local_fire_department_outlined, find({'energy', 'calories'})),
      (
        l.pkRetakeFieldSugars,
        Icons.grain_outlined,
        find({'sugar', 'sugars', 'total sugar', 'total sugars'}),
      ),
      (l.pkRetakeFieldSodium, Icons.water_drop_outlined, find({'sodium'})),
      (l.pkRetakeFieldProtein, Icons.fitness_center_outlined, find({'protein'})),
    ];
    return ProductSection(
      title: l.pkNutrition,
      children: [
        Wrap(
          spacing: d.spacingXs,
          runSpacing: d.spacingXxs,
          children: [
            if (basis != null)
              Text(
                basis,
                style: context.textTheme.labelLarge?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            if (nutrition['serving_size'] case final String serving
                when serving.trim().isNotEmpty && serving.trim().toLowerCase() != 'unknown')
              Text('${l.pkServingSize}: $serving', style: context.textTheme.bodySmall),
          ],
        ),
        for (final (name, icon, nutrient) in metrics)
          if (nutrient != null)
            NutritionFactRow(
              nutrient: {...Map<String, dynamic>.from(nutrient), 'name': name},
              icon: icon,
            ),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(l.pkAllNutrition, style: context.textTheme.titleSmall),
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final nutrient in nutrients)
              NutritionFactRow(nutrient: Map<String, dynamic>.from(nutrient)),
            for (final explanation in explanations)
              if (explanation['kind'] != null)
                InterpretationExplanation(explanation: explanation)
              else
                Text(explanation['text']?.toString() ?? l.pkUnknownValue),
          ],
        ),
      ],
    );
  }
}
