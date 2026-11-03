import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../../domain/entities/catalog_entity.dart';
import 'product_section.dart';
import 'product_finding_card.dart';
import 'nutrition_fact_row.dart';
import 'interpretation_explanation.dart';

class ProductResultContent extends StatelessWidget {
  final ProductRecord product;
  final bool recentSaved;
  final Widget? statusNotice;
  const ProductResultContent({
    super.key,
    required this.product,
    this.recentSaved = true,
    this.statusNotice,
  });
  @override
  Widget build(BuildContext context) {
    final p = product, l = context.l10n, d = context.themeData.dimensionsData;
    final basis = switch (p.nutrition['basis']) {
      'per_100g' => l.pkPer100g,
      'per_100ml' => l.pkPer100ml,
      'per_serving' => l.pkPerServing,
      _ => l.pkUnknownValue,
    };
    final nutrients = p.nutrition['nutrients'] as List? ?? [];
    final ingredients = p.ingredients['items'] as List? ?? [];
    final hasInterpretation = p.provenance['interpretation_version'] is String;
    final date = p.analyzedAt?.toLocal();
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: d.maxWidth),
        child: ListView(
          padding: context.themeData.edgeInsetsData.pagePadding,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  label: l.pkNoProductPhoto,
                  child: const AppIcon(icon: Icons.inventory_2_outlined, size: 64),
                ),
                Gap(d.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name ?? l.pkFoodProduct, style: context.textTheme.headlineSmall),
                      if (p.brand?.trim().isNotEmpty == true) Text(p.brand!),
                      SelectableText(p.barcode, style: context.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            Gap(d.spacingMd),
            if (p.isDemo) Text(l.pkDemo, style: context.textTheme.labelLarge),
            if (!recentSaved) Text(l.pkRecentNotSaved),
            Gap(d.spacingSm),
            ?statusNotice,
            ProductSection(
              title: l.pkOverview,
              children: [
                Text(p.summary),
                Text(l.pkCaveat, style: context.textTheme.bodySmall),
                if (hasInterpretation)
                  Text(l.pkTranscriptionCaveat, style: context.textTheme.bodySmall),
                if (!hasInterpretation)
                  Text(l.pkLegacyInterpretation, style: context.textTheme.bodySmall),
              ],
            ),
            ProductSection(
              title: l.pkFindings,
              children: [
                if (p.findings.isEmpty) Text(l.pkNoFindings),
                for (final finding in p.findings) ProductFindingCard(finding: finding),
              ],
            ),
            ProductSection(
              title: l.pkIngredients,
              children: [
                for (final explanation in p.explanations.where(
                  (e) => e['photo'] == 'ingredients' && e['kind'] != null,
                ))
                  InterpretationExplanation(explanation: explanation),
                if (hasInterpretation)
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text(l.pkRawLabel),
                    children: [
                      for (var index = 0; index < ingredients.length; index++)
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text('${index + 1}. ${ingredients[index]}'),
                        ),
                      Text(p.ingredients['raw']?.toString() ?? l.pkUnknownValue),
                    ],
                  ),
                if (!hasInterpretation)
                  for (var index = 0; index < ingredients.length; index++)
                    Text('${index + 1}. ${ingredients[index]}'),
                if (ingredients.isEmpty) Text(l.pkUnknownValue),
                if (!hasInterpretation) ...[
                  Text(l.pkRawLabel, style: context.textTheme.titleSmall),
                  Text(p.ingredients['raw']?.toString() ?? l.pkUnknownValue),
                ],
                Text(l.pkDeclaredAllergens, style: context.textTheme.titleMedium),
                Text(p.ingredients['declared_allergens']?.toString() ?? l.pkUnknownAllergens),
                for (final explanation in p.explanations.where(
                  (e) => e['photo'] == 'ingredients' && e['kind'] == null,
                ))
                  Text(explanation['text']?.toString() ?? l.pkUnknownValue),
              ],
            ),
            ProductSection(
              title: l.pkNutrition,
              children: [
                Text('${l.pkBasis}: $basis', style: context.textTheme.titleMedium),
                if (p.nutrition['serving_size'] is String)
                  Text('${l.pkServingSize}: ${p.nutrition['serving_size']}'),
                if (nutrients.isEmpty) Text(l.pkUnknownValue),
                for (final nutrient in nutrients)
                  if (nutrient is Map)
                    NutritionFactRow(nutrient: Map<String, dynamic>.from(nutrient)),
                for (final explanation in p.explanations.where((e) => e['photo'] == 'nutrition'))
                  if (explanation['kind'] != null)
                    InterpretationExplanation(explanation: explanation)
                  else
                    Text(explanation['text']?.toString() ?? l.pkUnknownValue),
              ],
            ),
            ProductSection(
              title: l.pkMissingInformation,
              children: [
                if (p.missingInformation.isEmpty) Text(l.pkNoMissingReported),
                for (final information in p.missingInformation) Text(information),
              ],
            ),
            ProductSection(
              title: l.pkAnalysisMethod,
              children: [
                Text(
                  '${l.pkAnalysisDate}: ${date == null ? l.pkUnknownValue : '${MaterialLocalizations.of(context).formatMediumDate(date)} · ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(date))}'}',
                ),
                Text('${l.pkModelVersion}: ${p.modelVersion ?? l.pkUnknownValue}'),
                Text('${l.pkRulesVersion}: ${p.rulesVersion ?? l.pkUnknownValue}'),
                if (p.provenance['nutrition_context_rules_version'] is String)
                  Text('${l.pkRulesVersion}: ${p.provenance['nutrition_context_rules_version']}'),
                Text('${l.pkPromptVersion}: ${p.provenance['prompt_version'] ?? l.pkUnknownValue}'),
                if (hasInterpretation) ...[
                  Text('${l.pkInterpretationVersion}: ${p.provenance['interpretation_version']}'),
                  Text(
                    '${l.pkReferenceVersion}: ${p.provenance['reference_version'] ?? l.pkUnknownValue}',
                  ),
                ],
              ],
            ),
            Gap(d.spacingLg),
          ],
        ),
      ),
    );
  }
}
