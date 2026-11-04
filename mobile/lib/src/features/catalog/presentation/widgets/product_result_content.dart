import 'product_result_header.dart';
import 'product_nutrition_panel.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/_core.dart';
import '../../domain/entities/catalog_entity.dart';
import 'product_section.dart';
import 'product_finding_card.dart';
import 'interpretation_explanation.dart';

class ProductResultContent extends StatelessWidget {
  final ProductRecord product;
  final bool recentSaved;
  final Widget? statusNotice, footerNotice, privateThumbnail;
  const ProductResultContent({
    super.key,
    required this.product,
    this.recentSaved = true,
    this.statusNotice,
    this.footerNotice,
    this.privateThumbnail,
  });
  @override
  Widget build(BuildContext context) {
    final p = product, l = context.l10n, d = context.themeData.dimensionsData;
    final ingredients = p.ingredients['items'] as List? ?? [];
    final hasInterpretation = p.provenance['interpretation_version'] is String;
    final date = p.analyzedAt?.toLocal();
    return DefaultTextStyle.merge(
      style: context.textTheme.bodyLarge?.copyWith(height: 1.5),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: d.maxWidth),
          child: ListView(
            padding: context.themeData.edgeInsetsData.pagePadding.add(
              MediaQuery.paddingOf(context),
            ),
            children: [
              ProductResultHeader(product: p, privateThumbnail: privateThumbnail),
              if (p.isDemo) Text(l.pkDemo, style: context.textTheme.labelLarge),
              if (!recentSaved) Text(l.pkRecentNotSaved),
              Gap(d.spacingLg),
              ?statusNotice,
              ProductSection(
                title: l.pkOverview,
                children: [
                  Text(p.summary),
                  if (p.findings.isEmpty)
                    Text(
                      l.pkNoFindings,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  Text(
                    l.pkCaveat,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (p.findings.isNotEmpty)
                ProductSection(
                  title: l.pkFindings,
                  children: [
                    for (final finding in p.findings) ProductFindingCard(finding: finding),
                  ],
                ),
              ProductSection(
                title: l.pkIngredients,
                children: [
                  if (ingredients.isNotEmpty)
                    Text(ingredients.join(', '), maxLines: 3, overflow: TextOverflow.ellipsis),
                  for (final explanation in p.explanations.where(
                    (e) => e['photo'] == 'ingredients' && e['kind'] != null,
                  ))
                    InterpretationExplanation(explanation: explanation),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text(l.pkRawLabel, style: context.textTheme.titleSmall),
                    shape: const Border(),
                    collapsedShape: const Border(),
                    childrenPadding: EdgeInsets.only(bottom: d.paddingSm),
                    children: [
                      for (var index = 0; index < ingredients.length; index++)
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text('${index + 1}. ${ingredients[index]}'),
                        ),
                      Text(p.ingredients['raw']?.toString() ?? l.pkUnknownValue),
                      for (final explanation in p.explanations.where(
                        (e) => e['photo'] == 'ingredients' && e['kind'] == null,
                      ))
                        Text(explanation['text']?.toString() ?? l.pkUnknownValue),
                    ],
                  ),
                  Text(
                    l.pkDeclaredAllergens,
                    style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(p.ingredients['declared_allergens']?.toString() ?? l.pkUnknownAllergens),
                ],
              ),
              ProductNutritionPanel(
                nutrition: p.nutrition,
                explanations: p.explanations.where((e) => e['photo'] == 'nutrition').toList(),
              ),
              if (p.missingInformation.isNotEmpty)
                ProductSection(
                  title: l.pkMissingInformation,
                  children: [for (final information in p.missingInformation) Text(information)],
                ),
              ExpansionTile(
                tilePadding: EdgeInsets.symmetric(horizontal: d.paddingMd),
                childrenPadding: EdgeInsets.all(d.paddingMd),
                shape: const Border(),
                collapsedShape: const Border(),
                title: Text(
                  l.pkAnalysisDetails,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                subtitle: date == null
                    ? null
                    : Text(
                        '${l.pkAnalysisDate}: ${MaterialLocalizations.of(context).formatMediumDate(date)}',
                        style: context.textTheme.bodySmall,
                      ),
                expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SelectableText(p.barcode),
                  if (p.provenance['barcode_association'] case final Map association)
                    if (association['status'] == 'operator_reviewed')
                      Text(l.pkBarcodeOperatorReviewed),
                  if (p.provenance['identity'] is Map) Text(l.pkIdentityUnverified),
                  Text(hasInterpretation ? l.pkTranscriptionCaveat : l.pkLegacyInterpretation),
                  Text(
                    '${l.pkAnalysisDate}: ${date == null ? l.pkUnknownValue : '${MaterialLocalizations.of(context).formatMediumDate(date)} · ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(date))}'}',
                  ),
                  Text('${l.pkModelVersion}: ${p.modelVersion ?? l.pkUnknownValue}'),
                  Text('${l.pkRulesVersion}: ${p.rulesVersion ?? l.pkUnknownValue}'),
                  if (p.provenance['nutrition_context_rules_version'] is String)
                    Text('${l.pkRulesVersion}: ${p.provenance['nutrition_context_rules_version']}'),
                  Text(
                    '${l.pkPromptVersion}: ${p.provenance['prompt_version'] ?? l.pkUnknownValue}',
                  ),
                  if (hasInterpretation) ...[
                    Text('${l.pkInterpretationVersion}: ${p.provenance['interpretation_version']}'),
                    Text(
                      '${l.pkReferenceVersion}: ${p.provenance['reference_version'] ?? l.pkUnknownValue}',
                    ),
                  ],
                ],
              ),
              if (footerNotice != null) ...[Gap(d.spacingLg), footerNotice!],
              Gap(d.spacingLg),
            ],
          ),
        ),
      ),
    );
  }
}
