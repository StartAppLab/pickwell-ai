import 'package:flutter/material.dart';

import '../../../../../core/_core.dart';

class OnboardingContinueButton extends StatelessWidget {
  final bool isValid;
  final bool isLastPage;
  final VoidCallback onPressed;
  final String? label;

  const OnboardingContinueButton({
    super.key,
    required this.isValid,
    required this.isLastPage,
    required this.onPressed,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isValid ? onPressed : null,
      child: Text(
        label ?? (isLastPage ? "Let's get started!" : 'Continue'),
        style: context.themeData.textStyleData.buttonTextStyle.copyWith(
          color: context.colorScheme.onPrimary,
        ),
      ),
    );
  }
}
