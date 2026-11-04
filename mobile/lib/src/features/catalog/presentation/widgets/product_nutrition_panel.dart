import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
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
    final nutrients = (nutrition['nutrients'] as List? ?? []).whereType<Map>().toList();
    final basis = switch (nutrition['basis']) {
      'per_100g' => l.pkPer100g,
      'per_100ml' => l.pkPer100ml,
      'per_serving' => l.pkPerServing,
      _ => l.pkUnknownValue,
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
            Text(
              basis,
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            if (nutrition['serving_size'] case final String serving)
              Text('${l.pkServingSize}: $serving', style: context.textTheme.bodySmall),
          ],
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns =
                constraints.maxWidth >= 280 && MediaQuery.textScalerOf(context).scale(14) < 18
                ? 4
                : 2;
            final width = (constraints.maxWidth - d.spacingSm * (columns - 1)) / columns;
            return Wrap(
              spacing: d.spacingSm,
              runSpacing: d.spacingMd,
              children: [
                for (final (name, icon, nutrient) in metrics)
                  SizedBox(
                    width: width,
                    child: _NutrientMetric(name: name, icon: icon, nutrient: nutrient),
                  ),
              ],
            );
          },
        ),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(l.pkAllNutrition, style: context.textTheme.titleSmall),
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (nutrients.isEmpty) Text(l.pkUnknownValue),
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

class _NutrientMetric extends StatelessWidget {
  final String name;
  final IconData icon;
  final Map? nutrient;
  const _NutrientMetric({required this.name, required this.icon, this.nutrient});
  @override
  Widget build(BuildContext context) {
    final value = nutrient?['value'], unit = nutrient?['unit'];
    final known = value is num && value.isFinite && unit is String && unit != 'unknown';
    final formatter = NumberFormat.decimalPattern(Localizations.localeOf(context).toLanguageTag())
      ..maximumFractionDigits = 12;
    final label = known
        ? '${(value != 0 && value.abs() < 1e-12 ? value.toString() : formatter.format(value))} ${unit.replaceFirst(RegExp(r'^ug\b'), 'µg').replaceFirst('%DV', '% DV')}'
        : context.l10n.pkUnknownValue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: context.themeData.dimensionsData.iconMedium,
              color: context.colorScheme.secondary,
            ),
            Gap(context.themeData.dimensionsData.spacingXxs),
            Expanded(child: Text(name, style: context.textTheme.bodySmall)),
          ],
        ),
        Gap(context.themeData.dimensionsData.spacingXs),
        Text(label, style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
