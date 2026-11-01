import 'package:flutter/material.dart';

import '../../../../core/_core.dart';

class EmailTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? errorText;
  final bool enabled;
  final void Function(String)? onChanged;

  const EmailTextField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.focusNode,
    this.errorText,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.emailAddress,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(hintText: hintText, errorText: errorText),
      style: context.textTheme.bodyLarge,
      enabled: enabled,
      onChanged: onChanged,
    );
  }
}
