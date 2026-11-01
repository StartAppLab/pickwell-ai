import 'package:flutter/material.dart';

import 'package:hugeicons/hugeicons.dart';

import '../../../../core/_core.dart';
import '../../app.dart';

class PasswordTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? errorText;
  final String? Function(String?)? passwordValidator;
  final bool enabled;
  final bool obscureText;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;

  const PasswordTextField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.focusNode,
    this.errorText,
    this.passwordValidator,
    this.enabled = true,
    this.obscureText = true,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      validator: passwordValidator,
      obscureText: obscureText,
      obscuringCharacter: '●',
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          onPressed: enabled ? onTap : null,
          icon: AppIcon(
            icon: obscureText ? HugeIcons.strokeRoundedViewOff : HugeIcons.strokeRoundedView,
            color: context.colorScheme.onSurfaceVariant,
            strokeWidth: 2,
            size: 24,
          ),
        ),
        hintText: hintText,
        errorText: errorText,
      ),
      style: context.textTheme.bodyLarge,
      enabled: enabled,
      onChanged: onChanged,
    );
  }
}
