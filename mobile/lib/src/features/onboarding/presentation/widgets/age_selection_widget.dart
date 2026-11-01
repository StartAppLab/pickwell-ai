import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/_core.dart';
import '../blocs/_blocs.dart';
import '_widgets.dart';

/// Widget for the age selection page in the onboarding flow.
///
/// Displays a list of age range options using [SelectionOptionCard] widgets
/// for a premium questionnaire-style selection experience.
class AgeSelectionWidget extends StatelessWidget {
  const AgeSelectionWidget({super.key});

  static const List<String> _ageRanges = [
    'Under 20',
    '20s',
    '30s',
    '40s',
    '50s',
    '60s',
    '70 and above',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.themeData.edgeInsetsData.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question
          Text(
            'Select your age',
            textAlign: TextAlign.start,
            style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          Gap(context.themeData.dimensionsData.smallSpacing),
          // Subtitle
          Text(
            'This will be used to personalize your experience',
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
                  selector: (state) => state.ageRange,
                  builder: (context, selectedAge) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _ageRanges.map((age) {
                        return SelectionOptionCard(
                          text: age,
                          isSelected: selectedAge == age,
                          onTap: () {
                            context.read<OnboardingCubit>().setAgeRange(age);
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
