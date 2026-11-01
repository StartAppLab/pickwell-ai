import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/_core.dart';
import '../../../app/app.dart';

class NotificationPromptWidget extends StatelessWidget {
  const NotificationPromptWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.themeData.edgeInsetsData.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Stay in the flow',
            textAlign: TextAlign.start,
            style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          Gap(context.themeData.dimensionsData.smallSpacing),
          Text(
            'Never miss a moment of inspiration',
            textAlign: TextAlign.start,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
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
                        icon: HugeIcons.strokeRoundedNotification01,
                        color: context.colorScheme.onSurface,
                        size: 100,
                      ),
                    ),
                    Gap(context.themeData.dimensionsData.largeSpacing),
                    Text(
                      'Turn on notifications',
                      textAlign: TextAlign.center,
                      style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Gap(context.themeData.dimensionsData.smallSpacing),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'We will help you stay consistent with gentle reminders to capture your thoughts and ideas throughout the day.',
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
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
