import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../../../core/_core.dart';

class NutritionFactRow extends StatelessWidget {
  final Map<String, dynamic> nutrient;
  const NutritionFactRow({super.key, required this.nutrient});
  @override
  Widget build(BuildContext context) {
    final value = nutrient['value'], unit = nutrient['unit'];
    final unknown = value is! num || !value.isFinite || unit == 'unknown' || unit == null;
    final numberFormat = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    )..maximumFractionDigits = 12;
    final label = unknown
        ? context.l10n.pkUnknownValue
        : '${(value != 0 && value.abs() < 1e-12 ? value.toString() : numberFormat.format(value))} ${unit.toString().replaceFirst(RegExp(r'^ug\b'), 'µg').replaceFirst('%DV', '% DV')}';
    final source = nutrient['source'];
    return Container(
      padding: EdgeInsets.symmetric(vertical: context.themeData.dimensionsData.paddingXs),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colorScheme.outlineVariant)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(nutrient['name']?.toString() ?? context.l10n.pkUnknownValue),
          ),
          Gap(context.themeData.dimensionsData.spacingSm),
          Flexible(
            flex: 2,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.end,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (unknown && source is String && source.trim().isNotEmpty)
                    Text(
                      '“${source.trim()}”',
                      textAlign: TextAlign.end,
                      style: context.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
