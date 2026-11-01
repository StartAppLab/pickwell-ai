import 'package:flutter/material.dart';

import 'package:hugeicons/hugeicons.dart';

/// A unified icon widget that supports both Material [IconData] and
/// HugeIcons [List<List<dynamic>>] icon formats.
///
/// This widget acts as a single interface for rendering icons regardless
/// of their underlying type. It inspects the runtime type of the provided
/// [icon] and delegates rendering to either Flutter's built-in [Icon] widget
/// or the [HugeIcon] widget accordingly.
///
/// ### Usage
///
/// **With Material Icons:**
/// ```dart
/// AppIcon(icon: Icons.home, size: 24, color: Colors.blue)
/// ```
///
/// **With HugeIcons:**
/// ```dart
/// AppIcon(icon: HugeIcons.strokeRoundedHome01, size: 24, color: Colors.blue)
/// ```
class AppIcon extends StatelessWidget {
  /// The icon to display.
  ///
  /// Accepts either:
  /// - [IconData] for Material/Cupertino icons
  /// - [List<List<dynamic>>] for HugeIcons
  final dynamic icon;

  /// The size of the icon in logical pixels.
  ///
  /// Defaults to `24.0`.
  final double size;

  /// The primary color used to draw the icon.
  ///
  /// If `null`, the icon inherits its color from the nearest [IconTheme]
  /// (for Material icons) or defaults to the current text color (for HugeIcons).
  final Color? color;

  /// The secondary color for duotone/twotone HugeIcons.
  ///
  /// This is only applicable to HugeIcons and has no effect on Material icons.
  /// If not specified, defaults to [color] (single color mode).
  final Color? secondaryColor;

  /// The stroke width for stroke-based HugeIcons.
  ///
  /// This is only applicable to HugeIcons and has no effect on Material icons.
  /// If not specified, the default stroke width from the icon data is used.
  final double? strokeWidth;

  /// Creates a unified icon widget.
  ///
  /// The [icon] parameter must be either an [IconData] or a
  /// [List<List<dynamic>>] (HugeIcons format).
  const AppIcon({
    super.key,
    required this.icon,
    this.size = 24.0,
    this.color,
    this.secondaryColor,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    // --- Material / Cupertino IconData ---
    if (icon is IconData) {
      return Icon(icon as IconData, size: size, color: color);
    }

    // --- HugeIcons (List<List<dynamic>>) ---
    if (icon is List<List<dynamic>>) {
      return HugeIcon(
        icon: icon as List<List<dynamic>>,
        size: size,
        color: color,
        secondaryColor: secondaryColor,
        strokeWidth: strokeWidth,
      );
    }

    // --- Fallback: unsupported icon type ---
    assert(
      false,
      'AppIcon received an unsupported icon type: ${icon.runtimeType}. '
      'Expected IconData or List<List<dynamic>> (HugeIcons).',
    );
    return SizedBox.square(dimension: size);
  }
}
