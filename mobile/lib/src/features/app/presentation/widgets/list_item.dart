import 'package:flutter/material.dart';

import 'package:gap/gap.dart';

import '../../../../core/_core.dart';
import '../../app.dart';

class ListItem extends StatelessWidget {
  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final Color? borderColor;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final Duration? pressDelay;
  final VoidCallback? onPressed;

  const ListItem({
    super.key,
    required this.child,
    this.leading,
    this.trailing,
    this.borderColor,
    this.backgroundColor,
    this.padding,
    this.pressDelay,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPressed: onPressed,
      pressDelay: pressDelay,
      borderColor: borderColor,
      backgroundColor: backgroundColor ?? context.colorScheme.surface,
      cornerRadius: context.themeData.dimensionsData.cornerRadius,
      padding: padding ?? context.themeData.edgeInsetsData.containerPadding,
      child: Row(
        children: [
          if (leading != null) ...{leading!, Gap(context.themeData.dimensionsData.smallSpacing)},
          Expanded(child: child),
          if (trailing != null) ...{Gap(context.themeData.dimensionsData.smallSpacing), trailing!},
        ],
      ),
    );
  }
}
