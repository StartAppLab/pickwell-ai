import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/_core.dart';
import '../../../../app/app.dart';
import '../../blocs/_blocs.dart';

class ChangePasswordPasswordConfirmTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const ChangePasswordPasswordConfirmTextField({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      ChangePasswordCubit,
      ChangePasswordState,
      (ValidatedString, ValidatedString, bool)?
    >(
      selector: (state) {
        if (state is ChangePasswordStateIdle) {
          return (state.confirmPassword, state.password, state.obscureConfirmPassword);
        }
        return null;
      },
      builder: (context, state) {
        final confirmPassword = state?.$1;
        final password = state?.$2;
        final obscureConfirmPassword = state?.$3 ?? true;

        final confirmPasswordText = context.l10n.confirmNewPassword;
        final passwordText = context.l10n.newPassword;
        final String? errorText;

        if (confirmPassword?.isValid == IsValid.empty) {
          errorText = context.l10n.errorCannotBeEmpty(confirmPasswordText);
        } else if (confirmPassword?.isValid == IsValid.notAsciiOnly) {
          errorText = context.l10n.errorEnterValidValue(confirmPasswordText);
        } else if (confirmPassword?.value != password?.value) {
          errorText = context.l10n.errorDoNotMatch(passwordText);
        } else {
          errorText = null;
        }

        return PasswordTextField(
          controller: controller,
          focusNode: focusNode,
          errorText: errorText,
          hintText: confirmPasswordText,
          obscureText: obscureConfirmPassword,
          onChanged: (value) => context.read<ChangePasswordCubit>().setConfirmPassword(value),
          onTap: () =>
              context.read<ChangePasswordCubit>().showConfirmPassword(!obscureConfirmPassword),
        );
      },
    );
  }
}
