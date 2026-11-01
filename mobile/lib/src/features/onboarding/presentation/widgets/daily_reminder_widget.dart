import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/_core.dart';
import '../../../app/app.dart';

class DailyReminderWidget extends StatelessWidget {
  const DailyReminderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.themeData.edgeInsetsData.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Daily reminders',
            textAlign: TextAlign.start,
            style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          Gap(context.themeData.dimensionsData.smallSpacing),
          Text(
            'Stay consistent with your note-taking habit',
            textAlign: TextAlign.start,
            style: context.textTheme.bodyMedium?.copyWith(color: context.themeColor.grayTextColor),
          ),
          Gap(context.themeData.dimensionsData.mediumSpacing),
          // Content
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: context.colorScheme.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: AppIcon(
                        icon: HugeIcons.strokeRoundedAlarmClock,
                        color: context.colorScheme.onSurface,
                        size: 100,
                      ),
                    ),
                    Gap(context.themeData.dimensionsData.largeSpacing),
                    Text(
                      'Would you like daily reminders to capture your ideas?',
                      textAlign: TextAlign.center,
                      style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Gap(context.themeData.dimensionsData.smallSpacing),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'A gentle nudge at the right time can help you build a lasting habit.',
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.themeColor.grayTextColor,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
