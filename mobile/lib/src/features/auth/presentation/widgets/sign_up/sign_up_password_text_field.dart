import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/_core.dart';
import '../../../../app/app.dart';
import '../../blocs/_blocs.dart';

class SignUpPasswordTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const SignUpPasswordTextField({super.key, required this.controller, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SignUpCubit, SignUpState, (ValidatedString, bool)?>(
      selector: (state) {
        if (state is SignUpStateIdle) {
          return (state.password, state.obscurePassword);
        }
        return null;
      },
      builder: (context, state) {
        final password = state?.$1;
        final obscurePassword = state?.$2 ?? true;

        final passwordText = context.l10n.password;
        final String? errorText;

        switch (password?.isValid) {
          case IsValid.empty:
            errorText = context.l10n.errorCannotBeEmpty(passwordText);
            break;
          case IsValid.notAsciiOnly:
            errorText = context.l10n.errorEnterValidValue(passwordText);
            break;
          default:
            errorText = null;
            break;
        }

        return PasswordTextField(
          controller: controller,
          focusNode: focusNode,
          errorText: errorText,
          hintText: passwordText,
          obscureText: obscurePassword,
          onChanged: (value) => context.read<SignUpCubit>().setPassword(value),
          onTap: () => context.read<SignUpCubit>().showPassword(!obscurePassword),
        );
      },
    );
  }
}
