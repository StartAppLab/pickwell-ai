import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';

import '../../../../../core/_core.dart';
import '../../blocs/_blocs.dart';

class OtpPinInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const OtpPinInputField({super.key, required this.controller, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: context.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(context.themeData.dimensionsData.cornerRadius),
    );
    final pinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: context.textTheme.bodyLarge,
      decoration: decoration,
    );
    return Pinput(
      controller: controller,
      focusNode: focusNode,
      length: 6,
      defaultPinTheme: pinTheme,
      focusedPinTheme: pinTheme.copyWith(
        decoration: decoration.copyWith(
          border: Border.all(color: context.colorScheme.primary, width: 2),
        ),
      ),
      errorPinTheme: pinTheme.copyWith(
        decoration: decoration.copyWith(border: Border.all(color: context.colorScheme.error)),
      ),
      onChanged: (value) => context.read<OtpCubit>().setToken(value),
    );
  }
}
