import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/_core.dart';

class PaywallStep1Widget extends StatelessWidget {
  const PaywallStep1Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.themeData.edgeInsetsData.pagePadding.copyWith(top: 0),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Header
                Text(
                  'Make meaningful progress with tools designed for you.',
                  style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Gap(context.themeData.dimensionsData.mediumSpacing),
              ],
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: context.themeData.edgeInsetsData.pagePadding,
                child: AspectRatio(
                  aspectRatio: 1.15,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 56,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
