import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../features/app/app.dart';

import '../../../../core/_core.dart';
import 'ui/_ui.dart';

class AllDoneWidget extends StatelessWidget {
  const AllDoneWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.themeData.edgeInsetsData.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        icon: HugeIcons.strokeRoundedHealtcare,
                        color: context.colorScheme.onSurface,
                        size: 100,
                      ),
                    ),
                    Gap(context.themeData.dimensionsData.largeSpacing),
                    OnboardingInfoBadge(
                      text: 'All done!',
                      color: context.colorScheme.secondaryContainer,
                      textColor: context.colorScheme.onSecondaryContainer,
                      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                    ),
                    Gap(context.themeData.dimensionsData.smallSpacing),
                    Text(
                      'Time to generate your personal workspace!',
                      textAlign: TextAlign.center,
                      style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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
