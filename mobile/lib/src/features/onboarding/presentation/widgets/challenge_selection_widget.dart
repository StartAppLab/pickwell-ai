import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/_core.dart';
import '../blocs/_blocs.dart';
import '../widgets/_widgets.dart';

class ChallengeSelectionWidget extends StatelessWidget {
  const ChallengeSelectionWidget({super.key});

  static final List<({String title, dynamic icon})> _options = [
    (title: 'Forgetting to write things down', icon: HugeIcons.strokeRoundedNote),
    (title: 'Finding notes later', icon: HugeIcons.strokeRoundedSearch01),
    (title: 'Organizing everything', icon: HugeIcons.strokeRoundedCheckmarkCircle01),
    (title: 'Staying consistent', icon: HugeIcons.strokeRoundedCalendar03),
  ];

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
                    const TextSpan(text: 'What\'s your biggest challenge with note-taking'),
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
            "We'll help you overcome it",
            textAlign: TextAlign.start,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          Gap(context.themeData.dimensionsData.mediumSpacing),
          // Options
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: BlocSelector<OnboardingCubit, OnboardingState, String?>(
                  selector: (state) => state.challenge,
                  builder: (context, selectedOption) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _options.map((option) {
                        return SelectionOptionCard(
                          text: option.title,
                          icon: option.icon,
                          textAlign: TextAlign.left,
                          isSelected: selectedOption == option.title,
                          onTap: () {
                            context.read<OnboardingCubit>().setChallenge(option.title);
                          },
                        );
                      }).toList(),
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
