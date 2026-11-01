import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/_core.dart';

class OnboardingContinueWithSkipButton extends StatelessWidget {
  final String continueLabel;
  final String skipLabel;
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const OnboardingContinueWithSkipButton({
    super.key,
    required this.continueLabel,
    required this.skipLabel,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onContinue,
          child: Text(
            continueLabel,
            style: context.themeData.textStyleData.buttonTextStyle.copyWith(
              color: context.colorScheme.onPrimary,
            ),
          ),
        ),
        const Gap(8),
        OutlinedButton(
          onPressed: onSkip,
          child: Text(
            skipLabel,
            style: context.themeData.textStyleData.buttonTextStyle.copyWith(
              color: context.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
