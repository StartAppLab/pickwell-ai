import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/_core.dart';
import '../../../../app/app.dart';

class OnboardingInfoBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? textColor;
  final dynamic icon;

  const OnboardingInfoBadge({super.key, required this.text, this.color, this.textColor, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 16, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: color ?? context.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(context.themeData.dimensionsData.cornerRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          icon != null
              ? AppIcon(icon: icon, color: textColor ?? context.colorScheme.onSecondaryContainer)
              : const SizedBox.shrink(),
          Gap(8),
          Flexible(
            child: Text(
              text,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: textColor ?? context.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
