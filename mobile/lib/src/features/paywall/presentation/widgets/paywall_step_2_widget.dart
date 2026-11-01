import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/_core.dart';
import '../../../app/app.dart';

class PaywallStep2Widget extends StatelessWidget {
  const PaywallStep2Widget({super.key, required this.hasFreeTrial});

  final bool hasFreeTrial;

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
                  'We\'ll send you a reminder before your ${hasFreeTrial ? 'free trial' : 'subscription'} ends.',
                  style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Gap(context.themeData.dimensionsData.smallSpacing),
                // Subtitle
                Text(
                  'No surprise, no pressure',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                Gap(context.themeData.dimensionsData.mediumSpacing),
              ],
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AppIcon(
                      icon: HugeIcons.strokeRoundedNotification01,
                      size: 120,
                      color: context.colorScheme.primary,
                    ),
                    Positioned(
                      top: 0,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Text(
                          '1',
                          style: context.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
