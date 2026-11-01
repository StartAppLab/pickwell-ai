import 'dart:ui';

import 'package:flutter_svg/flutter_svg.dart';

class SvgColorMapper implements ColorMapper {
  final Color fromPrimaryColor;
  final Color? fromSecondaryColor;
  final Color? fromTertiaryColor;
  final Color primaryColor;
  final Color? secondaryColor;
  final Color? tertiaryColor;

  const SvgColorMapper({
    required this.fromPrimaryColor,
    this.fromSecondaryColor,
    this.fromTertiaryColor,
    required this.primaryColor,
    this.secondaryColor,
    this.tertiaryColor,
  });

  @override
  Color substitute(String? id, String elementName, String attributeName, Color color) {
    if (color == fromPrimaryColor) return primaryColor;

    if (secondaryColor != null && color == fromSecondaryColor) return secondaryColor!;

    if (tertiaryColor != null && color == fromTertiaryColor) return tertiaryColor!;

    return color;
  }
}
