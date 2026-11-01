import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/_core.dart';
import '../../../../app/app.dart';

class PaywallTimelineItem extends StatelessWidget {
  const PaywallTimelineItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.isFirst = false,
    this.isLast = false,
  });

  final dynamic icon;
  final String title;
  final String description;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isLast ? context.colorScheme.primary : context.colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: AppIcon(
                    icon: icon,
                    color: isLast ? context.colorScheme.onPrimary : context.colorScheme.onSecondary,
                    size: 24,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 10,
                    decoration: BoxDecoration(
                      borderRadius: isLast
                          ? const BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            )
                          : null,
                      color: isLast
                          ? context.colorScheme.primaryContainer
                          : context.colorScheme.secondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(8),
                Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Gap(4),
                Text(
                  description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Gap(32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
