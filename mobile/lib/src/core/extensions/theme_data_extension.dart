import 'package:flutter/material.dart';

import '../../config/_config.dart';

extension ThemeDataExtension on ThemeData {
  AppThemeData get themeData => extension<AppThemeData>() ?? AppBaseTheme.lightTheme(colorScheme);

  AppThemeColor get themeColor => extension<AppThemeColor>() ?? AppThemeColor();

  AppThemeShadow get themeShadow => extension<AppThemeShadow>() ?? AppThemeShadow();

  AppThemeGradient get themeGradient =>
      extension<AppThemeGradient>() ?? AppThemeGradient.generate(colorScheme: colorScheme);
}
