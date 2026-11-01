import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/_core.dart';
import '../blocs/_blocs.dart';
import '../widgets/_widgets.dart';

/// Widget for the gender selection page in the onboarding flow.
///
/// Displays a list of gender options using [SelectionOptionCard] widgets
/// for a premium questionnaire-style selection experience.
class GenderSelectionWidget extends StatelessWidget {
  const GenderSelectionWidget({super.key});

  static const List<String> _genderOptions = ['Male', 'Female', 'Others'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.themeData.edgeInsetsData.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question
          Text(
            'Select your gender',
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
                  selector: (state) => state.gender,
                  builder: (context, selectedGender) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _genderOptions.map((option) {
                        return SelectionOptionCard(
                          text: option,
                          isSelected: selectedGender == option,
                          onTap: () {
                            context.read<OnboardingCubit>().setGender(option);
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
