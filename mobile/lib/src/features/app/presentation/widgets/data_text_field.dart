import 'package:flutter/material.dart';

import '../../../../core/_core.dart';

class DataTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final int? maxLength;
  final double? rightPadding;
  final double? leftPadding;
  final bool readOnly;
  final bool enabled;
  final void Function(String)? onChanged;

  const DataTextField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.maxLength,
    this.rightPadding,
    this.leftPadding,
    this.readOnly = false,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType ?? TextInputType.text,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      textAlignVertical: TextAlignVertical.center,
      maxLength: maxLength,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        hintText: hintText,
        errorText: errorText,
        contentPadding: context.themeData.edgeInsetsData.contentPadding.copyWith(
          right: rightPadding,
          left: leftPadding,
        ),
      ),
      style: context.textTheme.bodyLarge,
      readOnly: readOnly,
      enabled: enabled,
      onChanged: onChanged,
    );
  }
}
