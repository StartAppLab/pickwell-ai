import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/_core.dart';

class OnboardingYesNoButtons extends StatelessWidget {
  final String noLabel;
  final String yesLabel;
  final VoidCallback onNo;
  final VoidCallback onYes;

  const OnboardingYesNoButtons({
    super.key,
    required this.noLabel,
    required this.yesLabel,
    required this.onNo,
    required this.onYes,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onNo,
            child: Text(
              noLabel,
              style: context.themeData.textStyleData.buttonTextStyle.copyWith(
                color: context.colorScheme.primary,
              ),
            ),
          ),
        ),
        const Gap(16),
        Expanded(
          child: ElevatedButton(
            onPressed: onYes,
            child: Text(
              yesLabel,
              style: context.themeData.textStyleData.buttonTextStyle.copyWith(
                color: context.colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
