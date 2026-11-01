import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/_core.dart';
import '../../../../app/app.dart';
import '../../blocs/_blocs.dart';

class SignUpLastNameTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const SignUpLastNameTextField({super.key, required this.controller, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SignUpCubit, SignUpState, ValidatedString?>(
      selector: (state) {
        if (state is SignUpStateIdle) {
          return state.lastName;
        }
        return null;
      },
      builder: (context, state) {
        final lastNameText = context.l10n.lastName;
        final optionalText = context.l10n.optional;
        final String? errorText;

        switch (state?.isValid) {
          case IsValid.notLettersOnly:
            errorText = context.l10n.errorLettersOnly(lastNameText);
            break;
          case IsValid.tooShort:
            errorText = context.l10n.errorTooShort(lastNameText);
            break;
          case IsValid.tooLong:
            errorText = context.l10n.errorTooLong(lastNameText);
            break;
          default:
            errorText = null;
            break;
        }

        return DataTextField(
          controller: controller,
          focusNode: focusNode,
          errorText: errorText,
          hintText: '$lastNameText $optionalText',
          keyboardType: TextInputType.name,
          onChanged: (value) => context.read<SignUpCubit>().setLastName(value),
        );
      },
    );
  }
}
