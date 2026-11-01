import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/_core.dart';
import '../../../app/app.dart';

class NotificationMissedWidget extends StatelessWidget {
  const NotificationMissedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.themeData.edgeInsetsData.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            "Don't miss out",
            textAlign: TextAlign.start,
            style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          Gap(context.themeData.dimensionsData.smallSpacing),
          Text(
            "Here's what you'll miss without notifications",
            textAlign: TextAlign.start,
            style: context.textTheme.bodyMedium?.copyWith(color: context.themeColor.grayTextColor),
          ),
          Gap(context.themeData.dimensionsData.mediumSpacing),
          // Content
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MissedBenefitCard(
                  icon: HugeIcons.strokeRoundedNotificationSnooze01,
                  title: 'Daily Reminders',
                  description: 'Build your note-taking habit with gentle nudges.',
                ),
                Gap(context.themeData.dimensionsData.smallSpacing),
                _MissedBenefitCard(
                  icon: HugeIcons.strokeRoundedIdea,
                  title: 'Productivity Tips',
                  description: 'Get occasional insights on how to better organize your life.',
                ),
                Gap(context.themeData.dimensionsData.smallSpacing),
                _MissedBenefitCard(
                  icon: HugeIcons.strokeRoundedAlert02,
                  title: 'Critical Updates',
                  description: 'Stay informed about important changes to your workspace.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissedBenefitCard extends StatelessWidget {
  final dynamic icon;
  final String title;
  final String description;

  const _MissedBenefitCard({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: context.colorScheme.error, shape: BoxShape.circle),
            child: AppIcon(icon: icon, color: context.colorScheme.onError, size: 28),
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
                    color: context.colorScheme.onErrorContainer,
                  ),
                ),
                const Gap(4),
                Text(
                  description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onErrorContainer,
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
