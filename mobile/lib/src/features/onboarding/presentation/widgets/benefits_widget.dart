import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/_core.dart';
import '../../../app/app.dart';

class BenefitsWidget extends StatelessWidget {
  const BenefitsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.themeData.edgeInsetsData.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Why take notes?',
            textAlign: TextAlign.start,
            style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          Gap(context.themeData.dimensionsData.smallSpacing),
          Text(
            'Unlock your potential with consistent capturing',
            textAlign: TextAlign.start,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          Gap(context.themeData.dimensionsData.mediumSpacing),
          // Content
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BenefitCard(
                  icon: HugeIcons.strokeRoundedBulb,
                  title: 'Never lose an idea',
                  description: 'Capture flashes of inspiration before they fade away.',
                ),
                Gap(context.themeData.dimensionsData.smallSpacing),
                _BenefitCard(
                  icon: HugeIcons.strokeRoundedBrain,
                  title: 'Clear your mind',
                  description: 'Reduce mental clutter by offloading thoughts to your second brain.',
                ),
                Gap(context.themeData.dimensionsData.smallSpacing),
                _BenefitCard(
                  icon: HugeIcons.strokeRoundedAnalyticsUp,
                  title: 'Connect the dots',
                  description:
                      'Reviewing your notes helps you find patterns and generate new insights.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final dynamic icon;
  final String title;
  final String description;

  const _BenefitCard({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colorScheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: AppIcon(icon: icon, color: context.colorScheme.onSecondaryContainer, size: 28),
          ),
          Gap(context.themeData.dimensionsData.mediumSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.onSurface,
                  ),
                ),
                const Gap(4),
                Text(
                  description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
