import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/_core.dart';
import '../../../../app/app.dart';
import '../../blocs/_blocs.dart';

class SignUpFirstNameTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const SignUpFirstNameTextField({super.key, required this.controller, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SignUpCubit, SignUpState, ValidatedString?>(
      selector: (state) {
        if (state is SignUpStateIdle) {
          return state.firstName;
        }
        return null;
      },
      builder: (context, state) {
        final firstNameText = context.l10n.firstName;
        final String? errorText;

        switch (state?.isValid) {
          case IsValid.empty:
            errorText = context.l10n.errorCannotBeEmpty(firstNameText);
            break;
          case IsValid.notLettersOnly:
            errorText = context.l10n.errorLettersOnly(firstNameText);
            break;
          case IsValid.tooShort:
            errorText = context.l10n.errorTooShort(firstNameText);
            break;
          case IsValid.tooLong:
            errorText = context.l10n.errorTooLong(firstNameText);
            break;
          default:
            errorText = null;
            break;
        }

        return DataTextField(
          controller: controller,
          focusNode: focusNode,
          errorText: errorText,
          hintText: firstNameText,
          keyboardType: TextInputType.name,
          onChanged: (value) => context.read<SignUpCubit>().setFirstName(value),
        );
      },
    );
  }
}
