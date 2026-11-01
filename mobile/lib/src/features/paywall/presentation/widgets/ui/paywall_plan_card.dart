import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/_core.dart';

class PaywallPlanCard extends StatelessWidget {
  const PaywallPlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.period,
    this.originalPrice,
    this.yearlyEquivalent,
    required this.isPopular,
    required this.isSelected,
    required this.onSelect,
  });

  final String title;
  final String price;
  final String period;
  final String? originalPrice;
  final String? yearlyEquivalent;
  final bool isPopular;
  final bool isSelected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    String saveText = 'Limited Time Offer';
    if (originalPrice != null) {
      final double priceVal = double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      final double originalVal =
          double.tryParse(originalPrice!.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      if (originalVal > 0) {
        final int percent = (((originalVal - priceVal) / originalVal) * 100).round();
        saveText = 'Limited Time $percent% OFF';
      }
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? context.colorScheme.primary
                  : context.colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(context.themeData.dimensionsData.cornerRadius),
            color: isSelected
                ? context.colorScheme.primary.withValues(alpha: 0.1)
                : context.colorScheme.surface,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onSelect,
              borderRadius: BorderRadius.circular(context.themeData.dimensionsData.cornerRadius),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: context.colorScheme.onSurface,
                                ),
                              ),
                              if (yearlyEquivalent != null) ...[
                                Gap(context.themeData.dimensionsData.textSpacing * 2),
                                Text(
                                  yearlyEquivalent!,
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: context.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                if (originalPrice != null) ...[
                                  Text(
                                    originalPrice!,
                                    style: context.textTheme.bodySmall?.copyWith(
                                      color: context.colorScheme.onSurfaceVariant,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const Gap(4),
                                ],
                                Text(
                                  price,
                                  style: context.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: context.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              period,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isPopular && originalPrice != null)
          Positioned(
            top: -8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.themeData.dimensionsData.smallSpacing,
                  vertical: context.themeData.dimensionsData.textSpacing,
                ),
                decoration: BoxDecoration(
                  color: context.colorScheme.primary,
                  borderRadius: BorderRadius.circular(
                    context.themeData.dimensionsData.cornerRadius - 4,
                  ),
                ),
                child: Text(
                  saveText,
                  style: context.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
