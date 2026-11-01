import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/_core.dart';
import '../blocs/_blocs.dart';
import '../widgets/_widgets.dart';

class GoalSelectionWidget extends StatelessWidget {
  const GoalSelectionWidget({super.key});

  static const List<String> _goals = [
    'Boost my daily productivity',
    'Capture creative sparks',
    'Organize my knowledge',
    'Clear mental clutter',
    'Track my personal growth',
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
                    const TextSpan(text: 'What is your main goal'),
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
            'We will tailor your experience based on your choice',
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
                  selector: (state) => state.goal,
                  builder: (context, selectedGoal) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _goals.map((option) {
                        return SelectionOptionCard(
                          text: option,
                          textAlign: TextAlign.start,
                          isSelected: selectedGoal == option,
                          onTap: () {
                            context.read<OnboardingCubit>().setGoal(option);
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
