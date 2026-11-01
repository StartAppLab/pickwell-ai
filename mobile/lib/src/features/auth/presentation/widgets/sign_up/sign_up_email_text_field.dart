import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/_core.dart';
import '../../../../app/app.dart';
import '../../blocs/_blocs.dart';

class SignUpEmailTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const SignUpEmailTextField({super.key, required this.controller, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SignUpCubit, SignUpState, ValidatedString?>(
      selector: (state) {
        if (state is SignUpStateIdle) {
          return state.email;
        }
        return null;
      },
      builder: (context, state) {
        final emailText = context.l10n.email;
        final String? errorText;

        switch (state?.isValid) {
          case IsValid.empty:
            errorText = context.l10n.errorCannotBeEmpty(emailText);
            break;
          case IsValid.notEmail:
            errorText = context.l10n.errorEnterValidValue(emailText);
            break;
          default:
            errorText = null;
            break;
        }

        return EmailTextField(
          controller: controller,
          focusNode: focusNode,
          errorText: errorText,
          hintText: emailText,
          onChanged: (value) => context.read<SignUpCubit>().setEmail(value),
        );
      },
    );
  }
}
