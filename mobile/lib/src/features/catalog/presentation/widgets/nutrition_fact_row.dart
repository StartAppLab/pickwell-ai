import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';

class NutritionFactRow extends StatelessWidget {
  final Map<String, dynamic> nutrient;
  final IconData? icon;
  const NutritionFactRow({super.key, required this.nutrient, this.icon});

  /// Hide missing amounts rather than rendering an unknown or implying zero.
  static bool hasKnownValue(Map nutrient) {
    final value = nutrient['value'], unit = nutrient['unit'];
    return value is num &&
        value.isFinite &&
        value >= 0 &&
        unit is String &&
        unit.trim().isNotEmpty &&
        unit.trim().toLowerCase() != 'unknown';
  }

  @override
  Widget build(BuildContext context) {
    final value = nutrient['value'], unit = nutrient['unit'];
    if (!hasKnownValue(nutrient)) return const SizedBox.shrink();
    final number = value as num;
    final numberFormat = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    )..maximumFractionDigits = 12;
    final label =
        '${(number != 0 && number.abs() < 1e-12 ? number.toString() : numberFormat.format(number))} ${unit.toString().replaceFirst(RegExp(r'^ug\b'), 'µg').replaceFirst('%DV', '% DV')}';
    return Container(
      padding: EdgeInsets.symmetric(vertical: context.themeData.dimensionsData.paddingXs),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colorScheme.outlineVariant)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            AppIcon(
              icon: icon!,
              size: context.themeData.dimensionsData.iconMedium,
              color: context.colorScheme.secondary,
            ),
            Gap(context.themeData.dimensionsData.spacingSm),
          ],
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
