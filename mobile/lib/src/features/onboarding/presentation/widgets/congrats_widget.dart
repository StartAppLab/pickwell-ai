import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../blocs/_blocs.dart';

class CongratsWidget extends StatelessWidget {
  final bool isLoading;

  const CongratsWidget({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: context.themeData.edgeInsetsData.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            Gap(context.themeData.dimensionsData.largeSpacing),
            Text(
              'Calibrating your profile...',
              style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            Gap(context.themeData.dimensionsData.smallSpacing),
            Text(
              'Preparing your personalized workspace...',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: context.themeData.edgeInsetsData.pagePadding.copyWith(bottom: 0),
      child: BlocBuilder<OnboardingCubit, OnboardingState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.colorScheme.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: AppIcon(
                        icon: HugeIcons.strokeRoundedTick02,
                        color: context.colorScheme.onSecondaryContainer,
                        size: 20,
                      ),
                    ),
                    Gap(context.themeData.dimensionsData.smallSpacing),
                    Text(
                      'Congratulations\nyour workspace is ready!',
                      style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Gap(context.themeData.dimensionsData.largeSpacing),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Your Profile Summary',
                        style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'You can edit this information later',
                        style: context.textTheme.titleSmall?.copyWith(
                          color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    Gap(context.themeData.dimensionsData.mediumSpacing),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  if (state.frequency != null)
                    _SummaryItem(
                      icon: HugeIcons.strokeRoundedNoteEdit,
                      label: 'Note frequency',
                      value: state.frequency!,
                    ),
                  if (state.hasUsedOtherApps != null)
                    _SummaryItem(
                      icon: HugeIcons.strokeRoundedNotebook,
                      label: 'Experience',
                      value: state.hasUsedOtherApps!
                          ? 'Used other apps'
                          : 'New to digital note-taking',
                    ),
                  if (state.selectedUseCases.isNotEmpty)
                    _SummaryItem(
                      icon: HugeIcons.strokeRoundedFolder01,
                      label: 'Use cases',
                      value: state.selectedUseCases.join(', '),
                    ),
                  if (state.captureTime != null)
                    _SummaryItem(
                      icon: HugeIcons.strokeRoundedTime01,
                      label: 'Capture time',
                      value: state.captureTime!,
                    ),
                  if (state.goal != null)
                    _SummaryItem(
                      icon: HugeIcons.strokeRoundedFlag01,
                      label: 'Goal',
                      value: state.goal!,
                    ),
                  if (state.challenge != null)
                    _SummaryItem(
                      icon: HugeIcons.strokeRoundedAlert02,
                      label: 'Challenge',
                      value: state.challenge!,
                    ),
                  if (state.wantsDailyReminders != null)
                    _SummaryItem(
                      icon: HugeIcons.strokeRoundedAlarmClock,
                      label: 'Daily Reminders',
                      value: state.wantsDailyReminders! ? 'Enabled' : 'Disabled',
                    ),
                  _SummaryItem(
                    icon: HugeIcons.strokeRoundedNotification01,
                    label: 'Notifications',
                    value: (state.didAllowNotifications ?? false) ? 'Enabled' : 'Disabled',
                  ),
                  // Add extra padding at the bottom for scrolling past the button
                  const Gap(100),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final dynamic icon;
  final String label;
  final String value;

  const _SummaryItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(context.themeData.dimensionsData.cornerRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcon(icon: icon, size: 20, color: context.colorScheme.primary),
          Gap(context.themeData.dimensionsData.mediumSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Gap(4),
                Text(
                  value,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
