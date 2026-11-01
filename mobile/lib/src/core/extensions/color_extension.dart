import 'package:flutter/material.dart';

extension ColorExtension on Color {
  Color? lighten({double intensity = 0.5}) {
    return Color.lerp(this, Colors.white, intensity);
  }

  Color? darken({double intensity = 0.5}) {
    return Color.lerp(this, Colors.black, intensity);
  }
}
