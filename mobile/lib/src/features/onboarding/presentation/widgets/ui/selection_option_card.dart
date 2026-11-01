import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../../core/_core.dart';
import '../../../../app/app.dart';

class SelectionOptionCard extends StatelessWidget {
  final String text;
  final String? description;
  final dynamic icon;
  final bool isSelected;
  final VoidCallback onTap;
  final TextAlign textAlign;
  final bool isMultiSelect;

  const SelectionOptionCard({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.description,
    this.icon,
    this.textAlign = TextAlign.center,
    this.isMultiSelect = false,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisAlignment = textAlign == TextAlign.left || textAlign == TextAlign.start
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;

    final mainAxisAlignment = textAlign == TextAlign.left || textAlign == TextAlign.start
        ? MainAxisAlignment.start
        : MainAxisAlignment.center;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: isSelected ? 4 : 0,
        shadowColor: context.colorScheme.primary.withValues(alpha: 0.3),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.colorScheme.primary
                  : context.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: mainAxisAlignment,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  AppIcon(
                    icon: icon,
                    color: isSelected
                        ? context.colorScheme.onPrimary
                        : context.colorScheme.onSurface,
                    size: 24,
                  ),
                  const Gap(16),
                ],
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: crossAxisAlignment,
                    children: [
                      Text(
                        text,
                        textAlign: textAlign,
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? context.colorScheme.onPrimary
                              : context.colorScheme.onSurface,
                        ),
                      ),
                      if (description != null) ...[
                        const Gap(4),
                        Text(
                          description!,
                          textAlign: textAlign,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? context.colorScheme.onPrimary.withValues(alpha: 0.8)
                                : context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isMultiSelect) ...[
                  const Gap(16),
                  AppIcon(
                    icon: isSelected
                        ? HugeIcons.strokeRoundedCheckmarkSquare02
                        : HugeIcons.strokeRoundedSquare,
                    color: isSelected
                        ? context.colorScheme.onPrimary
                        : context.colorScheme.onSurface,
                    size: 24,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
