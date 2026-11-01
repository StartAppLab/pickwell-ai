import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../features/app/app.dart';

import '../../../../core/_core.dart';
import 'ui/_ui.dart';

class PrivacyTrustWidget extends StatelessWidget {
  const PrivacyTrustWidget({super.key});

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
                        icon: HugeIcons.strokeRoundedShieldUser,
                        color: context.colorScheme.onSurface,
                        size: 100,
                      ),
                    ),
                    Gap(context.themeData.dimensionsData.largeSpacing),
                    Text(
                      'Thank you for trusting us',
                      textAlign: TextAlign.center,
                      style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Gap(context.themeData.dimensionsData.smallSpacing),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Your privacy and security matter to us. We promise to always keep your personal information private and secure.',
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ),
                    Gap(context.themeData.dimensionsData.largeSpacing),
                    OnboardingInfoBadge(
                      text: 'Your trust means the world to us!',
                      color: context.colorScheme.secondaryContainer,
                      textColor: context.colorScheme.onSecondaryContainer,
                      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
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
