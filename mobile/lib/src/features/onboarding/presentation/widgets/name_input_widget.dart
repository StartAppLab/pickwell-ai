import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../blocs/_blocs.dart';

class NameInputWidget extends StatefulWidget {
  final TextEditingController controller;

  const NameInputWidget({super.key, required this.controller});

  @override
  State<NameInputWidget> createState() => _NameInputWidgetState();
}

class _NameInputWidgetState extends State<NameInputWidget> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingCubit, OnboardingState>(
      listenWhen: (previous, current) => previous.slideIndex != current.slideIndex,
      listener: (context, state) {
        if (state.slideIndex == 2) {
          // Delay slightly to allow the page transition to complete
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && state.slideIndex == 2) {
              _focusNode.requestFocus();
            }
          });
        }
      },
      child: Padding(
        padding: context.themeData.edgeInsetsData.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question
            Text(
              'What is your name?',
              textAlign: TextAlign.start,
              style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            Gap(context.themeData.dimensionsData.smallSpacing),
            // Subtitle
            Text(
              "We'd love to know what to call you",
              textAlign: TextAlign.start,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            Gap(context.themeData.dimensionsData.mediumSpacing),
            // Name Input Field
            DataTextField(
              hintText: 'Enter your name',
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onChanged: (value) =>
                  context.read<OnboardingCubit>().setName(value.trim().capitalize()),
            ),
          ],
        ),
      ),
    );
  }
}
