import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/_core.dart';
import '../blocs/_blocs.dart';
import '../widgets/_widgets.dart';

class ExperienceSelectionWidget extends StatelessWidget {
  const ExperienceSelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.themeData.edgeInsetsData.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question
          BlocSelector<OnboardingCubit, OnboardingState, String?>(
            selector: (state) => state.name,
            builder: (context, name) {
              return Text.rich(
                TextSpan(
                  style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  children: [
                    const TextSpan(text: 'Have you tried other notes apps'),
                    if (name != null) const TextSpan(text: ', '),
                    TextSpan(
                      text: name,
                      style: TextStyle(color: context.colorScheme.secondary),
                    ),
                    const TextSpan(text: '?'),
                  ],
                ),
                textAlign: TextAlign.start,
              );
            },
          ),
          Gap(context.themeData.dimensionsData.smallSpacing),
          // Subtitle
          Text(
            'Help us understand your experience',
            textAlign: TextAlign.start,
            style: context.textTheme.bodyMedium?.copyWith(color: context.themeColor.grayTextColor),
          ),
          Gap(context.themeData.dimensionsData.mediumSpacing),
          // Options
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: BlocSelector<OnboardingCubit, OnboardingState, bool?>(
                  selector: (state) => state.hasUsedOtherApps,
                  builder: (context, hasUsedOtherApps) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SelectionOptionCard(
                          text: 'No',
                          description: "I'm new to digital note-taking",
                          icon: HugeIcons.strokeRoundedThumbsDown,
                          textAlign: TextAlign.left,
                          isSelected: hasUsedOtherApps == false,
                          onTap: () {
                            context.read<OnboardingCubit>().setHasUsedOtherApps(false);
                          },
                        ),
                        SelectionOptionCard(
                          text: 'Yes',
                          description: "I've used other tools before",
                          icon: HugeIcons.strokeRoundedThumbsUp,
                          textAlign: TextAlign.left,
                          isSelected: hasUsedOtherApps == true,
                          onTap: () {
                            context.read<OnboardingCubit>().setHasUsedOtherApps(true);
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
