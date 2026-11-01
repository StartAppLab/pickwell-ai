import 'package:flutter/material.dart';

import '../../config/_config.dart';
import '../../localization/_localization.dart';
import '_extensions.dart';

extension ContextExtension on BuildContext {
  AppLocalizations get l10n => AppLocale.of(this);

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;

  TextTheme get primaryTextTheme => Theme.of(this).primaryTextTheme;

  AppThemeData get themeData => Theme.of(this).themeData;

  AppThemeColor get themeColor => Theme.of(this).themeColor;

  AppThemeShadow get themeShadow => Theme.of(this).themeShadow;

  AppThemeGradient get themeGradient => Theme.of(this).themeGradient;
}
