import 'package:flutter/material.dart';

class Pressable extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? cornerRadius;
  final Duration? pressDelay;
  final VoidCallback? onPressed;

  const Pressable({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.cornerRadius,
    this.pressDelay,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        side: borderColor != null ? BorderSide(color: borderColor!) : BorderSide.none,
        borderRadius: BorderRadius.circular(cornerRadius ?? 0),
      ),
      child: InkWell(
        onTap: () async {
          if (onPressed == null) return;
          if (pressDelay == null || pressDelay == Duration.zero) {
            onPressed!();
            return;
          }
          await Future.delayed(pressDelay!);
          onPressed!();
        },
        borderRadius: BorderRadius.circular(cornerRadius ?? 0),
        child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
      ),
    );
  }
}
