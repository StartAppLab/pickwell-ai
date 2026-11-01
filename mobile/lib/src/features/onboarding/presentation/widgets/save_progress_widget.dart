import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../config/_config.dart';
import '../../../../core/_core.dart';
import '../../../auth/auth.dart';

class SaveProgressWidget extends StatelessWidget {
  const SaveProgressWidget({super.key, this.isActive = true});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final spacing = context.themeData.dimensionsData;
    return Padding(
      padding: context.themeData.edgeInsetsData.pagePadding.copyWith(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.saveProgressTitle,
            style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          Gap(spacing.smallSpacing),
          Text(
            context.l10n.saveProgressDescription,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          Gap(spacing.smallSpacing),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: SocialSignInWidget(
                  onboarding: true,
                  isActive: isActive,
                  showCreateAccount: true,
                  showSkip: getIt<AppConfig>().features.authMode == AuthMode.optional,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
