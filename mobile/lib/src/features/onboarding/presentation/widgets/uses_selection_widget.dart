import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/_core.dart';
import '../blocs/_blocs.dart';
import '../widgets/_widgets.dart';

class UsesSelectionWidget extends StatelessWidget {
  const UsesSelectionWidget({super.key});

  static const List<String> _useCases = [
    'Grocery lists',
    'Journaling',
    'Studying',
    'Storing ideas',
    'Work notes',
    'Personal planning',
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
                    const TextSpan(text: 'Where do you use notes'),
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
            'Select all that apply',
            style: context.textTheme.bodyMedium?.copyWith(color: context.themeColor.grayTextColor),
          ),
          Gap(context.themeData.dimensionsData.mediumSpacing),
          // Options
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: BlocSelector<OnboardingCubit, OnboardingState, List<String>>(
                  selector: (state) => state.selectedUseCases,
                  builder: (context, selectedUseCases) {
                    return Column(
                      children: _useCases.map((useCase) {
                        final isSelected = selectedUseCases.contains(useCase);
                        return SelectionOptionCard(
                          text: useCase,
                          isSelected: isSelected,
                          onTap: () {
                            context.read<OnboardingCubit>().toggleUseCase(useCase);
                          },
                          isMultiSelect: true,
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
