import 'package:flutter/material.dart';

import 'package:gap/gap.dart';

import '../../../../../core/_core.dart';

class OtpResendButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const OtpResendButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.l10n.didntReceiveCode,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium,
        ),
        Gap(context.themeData.dimensionsData.textSpacing),
        TextButton(
          onPressed: onPressed,
          child: Text(
            context.l10n.resendCode,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
