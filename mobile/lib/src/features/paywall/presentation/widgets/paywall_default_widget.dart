import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/_core.dart';
import '../../../app/app.dart';

class PaywallDefaultWidget extends StatelessWidget {
  const PaywallDefaultWidget({super.key});

  static const _features = [
    'Unlimited note capture & storage',
    'Advanced organization & tagging',
    'Smart search across all notes',
    'Personalized daily insights',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: context.themeData.edgeInsetsData.pagePadding.copyWith(top: 0),
      children: [
        // Header
        AppIcon(icon: HugeIcons.strokeRoundedCrown, size: 80, color: context.colorScheme.primary),
        Gap(context.themeData.dimensionsData.mediumSpacing),
        Text(
          'Unlock Premium Features',
          textAlign: TextAlign.center,
          style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Gap(context.themeData.dimensionsData.smallSpacing),
        // Subtitle
        Text(
          'Unlock the full power of StartAppNotes and never lose an idea',
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        Gap(context.themeData.dimensionsData.mediumSpacing),
        // Content
        ..._features.map(
          (feature) => Padding(
            padding: EdgeInsets.only(bottom: context.themeData.dimensionsData.smallSpacing),
            child: Row(
              children: [
                AppIcon(
                  icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                  color: context.colorScheme.primary,
                  size: context.themeData.dimensionsData.mediumSpacing,
                ),
                Gap(context.themeData.dimensionsData.smallSpacing),
                Expanded(
                  child: Text(
                    feature,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Gap(context.themeData.dimensionsData.mediumSpacing),
      ],
    );
  }
}
