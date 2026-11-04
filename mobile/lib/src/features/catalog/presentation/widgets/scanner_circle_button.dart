import 'package:flutter/material.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';

/// Compact scanner controls with a full touch target over either camera or canvas.
class ScannerCircleButton extends StatelessWidget {
  final dynamic icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool overCamera, selected;
  const ScannerCircleButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.overCamera = false,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme, d = context.themeData.dimensionsData;
    // White camera controls must remain readable independently of app brightness.
    final foreground = selected
        ? colors.onPrimaryContainer
        : overCamera
        ? Colors.white
        : colors.primary;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: AppIcon(icon: icon, size: d.iconSize),
      style: IconButton.styleFrom(
        fixedSize: Size.square(d.minimumTouchTarget),
        minimumSize: Size.square(d.minimumTouchTarget),
        padding: EdgeInsets.zero,
        shape: const CircleBorder(),
        foregroundColor: foreground,
        disabledForegroundColor: overCamera ? Colors.white.withValues(alpha: .5) : null,
        backgroundColor: selected
            ? colors.primaryContainer
            : overCamera
            ? colors.scrim.withValues(alpha: .45)
            : colors.surfaceContainerLowest,
        side: BorderSide(
          color: overCamera ? Colors.white.withValues(alpha: .2) : colors.outlineVariant,
        ),
      ),
    );
  }
}
