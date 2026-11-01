import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/_core.dart';
import '../blocs/_blocs.dart';
import '../widgets/_widgets.dart';

class CaptureTimeSelectionWidget extends StatelessWidget {
  const CaptureTimeSelectionWidget({super.key});

  static const List<String> _options = [
    'Morning commute',
    'During work/study',
    'Before bed',
    'Random moments',
    'All of the above',
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
                    const TextSpan(text: 'When do you usually take notes'),
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
            'Help us personalize your experience',
            textAlign: TextAlign.start,
            style: context.textTheme.bodyMedium?.copyWith(color: context.themeColor.grayTextColor),
          ),
          Gap(context.themeData.dimensionsData.mediumSpacing),
          // Options
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: BlocSelector<OnboardingCubit, OnboardingState, String?>(
                  selector: (state) => state.captureTime,
                  builder: (context, selectedOption) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _options.map((option) {
                        return SelectionOptionCard(
                          text: option,
                          isSelected: selectedOption == option,
                          onTap: () {
                            context.read<OnboardingCubit>().setCaptureTime(option);
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
