import 'package:flutter/material.dart';

import '../../resources/_resources.dart';
import '_theme.dart';

class AppBaseTheme {
  static AppThemeData lightTheme(ColorScheme colorScheme) => _baseTheme(colorScheme);

  static AppThemeData darkTheme(ColorScheme colorScheme) => _baseTheme(colorScheme);

  static AppThemeData _baseTheme(ColorScheme colorScheme) {
    return AppThemeData(
      brightness: colorScheme.brightness,
      dimensionsData: const DimensionsData(
        maxWidth: 512,
        cornerRadius: 16,
        buttonHeight: 50,
        textFieldSpacing: 24,
        textSpacing: 2,
        smallSpacing: 12,
        mediumSpacing: 24,
        largeSpacing: 36,
        indicatorSpacing: 16,
      ),
      edgeInsetsData: const EdgeInsetsData(
        pagePadding: EdgeInsets.all(24),
        containerPadding: EdgeInsets.all(12),
        dialogPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        contentPadding: EdgeInsets.all(14),
      ),
      durationData: const DurationData(buttonPressDelay: Duration(milliseconds: 300)),
      textStyleData: TextStyleData(
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.manrope,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
          fontSize: 20,
        ),
        buttonTextStyle: const TextStyle(
          fontFamily: AppFonts.manrope,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      buttonStyleData: ButtonStyleData(
        noSplashButtonStyle: const ButtonStyle(
          overlayColor: WidgetStatePropertyAll(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
        ),
      ),
    );
  }
}
