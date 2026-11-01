import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/_core.dart';
import 'ui/_ui.dart';

class PaywallStep3Widget extends StatelessWidget {
  const PaywallStep3Widget({super.key, this.trialDuration, this.trialDays});

  final String? trialDuration;
  final int? trialDays;

  @override
  Widget build(BuildContext context) {
    final durationDays = trialDays ?? 3;
    final reminderDays = durationDays == 3 ? 2 : durationDays - 2;
    final billingDays = durationDays;
    final timelineItems = [
      (
        icon: HugeIcons.strokeRoundedSquareUnlock01,
        title: 'Today',
        description: 'Unlock all premium features',
        isFirst: true,
        isLast: false,
      ),
      (
        icon: HugeIcons.strokeRoundedNotification01,
        title: 'In $reminderDays Days - Reminder',
        description: 'Get a reminder about your trial ending',
        isFirst: false,
        isLast: false,
      ),
      (
        icon: HugeIcons.strokeRoundedCrown,
        title: 'In $billingDays Days - Billing Starts',
        description: 'You\'ll be charged. Cancel anytime before.',
        isFirst: false,
        isLast: true,
      ),
    ];

    final headline = trialDuration == null
        ? 'Start your FREE trial to continue.'
        : 'Start your $trialDuration FREE trial to continue.';

    return ListView(
      padding: context.themeData.edgeInsetsData.pagePadding.copyWith(top: 0),
      children: [
        // Header
        Text(
          headline,
          textAlign: TextAlign.center,
          style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Gap(context.themeData.dimensionsData.smallSpacing),
        // Subtitle
        Text(
          'Nothing will be charged today',
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        Gap(context.themeData.dimensionsData.mediumSpacing),
        // Content
        ...timelineItems.map(
          (item) => PaywallTimelineItem(
            icon: item.icon,
            title: item.title,
            description: item.description,
            isFirst: item.isFirst,
            isLast: item.isLast,
          ),
        ),
        Gap(context.themeData.dimensionsData.mediumSpacing),
      ],
    );
  }
}
