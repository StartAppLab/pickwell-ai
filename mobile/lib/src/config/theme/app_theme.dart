import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../resources/_resources.dart';
import '_theme.dart';

class AppTheme {
  static ThemeData lightTheme(ColorScheme colorScheme) => _createAppTheme(
    AppBaseTheme.lightTheme(colorScheme),
    colorScheme,
    [AppThemeColor(), AppThemeShadow(), AppThemeGradient.generate(colorScheme: colorScheme)],
  );

  static ThemeData darkTheme(ColorScheme colorScheme) =>
      _createAppTheme(AppBaseTheme.darkTheme(colorScheme), colorScheme, [
        AppThemeColor.dark(),
        AppThemeShadow.dark(),
        AppThemeGradient.generate(colorScheme: colorScheme),
      ]);

  static ThemeData _createAppTheme(
    AppThemeData base,
    ColorScheme colorScheme,
    List<ThemeExtension<dynamic>> extensions,
  ) {
    return ThemeData(
      useMaterial3: true,
      brightness: base.brightness,
      primaryColor: colorScheme.primary,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      fontFamily: AppFonts.manrope,
      visualDensity: VisualDensity.standard,
      extensions: [base, ...extensions],
      textTheme: _getTextTheme(),
      appBarTheme: _getAppBarTheme(base, colorScheme),
      elevatedButtonTheme: _getElevatedButtonTheme(base, colorScheme),
      outlinedButtonTheme: _getOutlinedButtonTheme(base, colorScheme),
      textButtonTheme: _getTextButtonTheme(base, colorScheme),
      inputDecorationTheme: _getInputDecorationTheme(base, colorScheme),
      dialogTheme: _getDialogTheme(base, colorScheme),
      cardTheme: _getCardTheme(base, colorScheme),
      bottomSheetTheme: _getBottomSheetTheme(base, colorScheme),
      checkboxTheme: _getCheckboxTheme(base, colorScheme),
      switchTheme: _getSwitchTheme(base, colorScheme),
    );
  }

  static TextTheme _getTextTheme() {
    const style = TextStyle(
      fontFamily: AppFonts.manrope,
      fontFeatures: [FontFeature.proportionalFigures()],
    );
    return TextTheme(
      displayLarge: style.merge(
        const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 57,
          height: 1.12,
          letterSpacing: -0.25,
        ),
      ),
      displayMedium: style.merge(
        const TextStyle(fontWeight: FontWeight.w400, fontSize: 45, height: 1.16, letterSpacing: 0),
      ),
      displaySmall: style.merge(
        const TextStyle(fontWeight: FontWeight.w400, fontSize: 36, height: 1.22, letterSpacing: 0),
      ),
      headlineLarge: style.merge(
        const TextStyle(fontWeight: FontWeight.w400, fontSize: 32, height: 1.25, letterSpacing: 0),
      ),
      headlineMedium: style.merge(
        const TextStyle(fontWeight: FontWeight.w400, fontSize: 28, height: 1.29, letterSpacing: 0),
      ),
      headlineSmall: style.merge(
        const TextStyle(fontWeight: FontWeight.w400, fontSize: 24, height: 1.33, letterSpacing: 0),
      ),
      titleLarge: style.merge(
        const TextStyle(fontWeight: FontWeight.w400, fontSize: 22, height: 1.27, letterSpacing: 0),
      ),
      titleMedium: style.merge(
        const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          height: 1.5,
          letterSpacing: 0.15,
        ),
      ),
      titleSmall: style.merge(
        const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          height: 1.43,
          letterSpacing: 0.1,
        ),
      ),
      labelLarge: style.merge(
        const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          height: 1.43,
          letterSpacing: 0.1,
        ),
      ),
      labelMedium: style.merge(
        const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          height: 1.33,
          letterSpacing: 0.5,
        ),
      ),
      labelSmall: style.merge(
        const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 11,
          height: 1.45,
          letterSpacing: 0.5,
        ),
      ),
      bodyLarge: style.merge(
        const TextStyle(fontWeight: FontWeight.w400, fontSize: 16, height: 1.5, letterSpacing: 0.5),
      ),
      bodyMedium: style.merge(
        const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 1.43,
          letterSpacing: 0.25,
        ),
      ),
      bodySmall: style.merge(
        const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
          height: 1.33,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  static AppBarTheme _getAppBarTheme(AppThemeData base, ColorScheme colorScheme) {
    return AppBarTheme(
      systemOverlayStyle: colorScheme.brightness == Brightness.light
          ? SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      backgroundColor: colorScheme.surface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: base.textStyleData.titleTextStyle,
      foregroundColor: colorScheme.onSurface,
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      actionsIconTheme: IconThemeData(color: colorScheme.primary),
    );
  }

  static ElevatedButtonThemeData _getElevatedButtonTheme(
    AppThemeData base,
    ColorScheme colorScheme,
  ) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, base.dimensionsData.buttonHeight),
        elevation: 0.5,
        foregroundColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.primary,
        textStyle: base.textStyleData.buttonTextStyle,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(base.dimensionsData.cornerRadius)),
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _getOutlinedButtonTheme(
    AppThemeData base,
    ColorScheme colorScheme,
  ) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, base.dimensionsData.buttonHeight),
        elevation: 0.5,
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.primary),
        textStyle: base.textStyleData.buttonTextStyle,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(base.dimensionsData.cornerRadius)),
        ),
      ),
    );
  }

  static TextButtonThemeData _getTextButtonTheme(AppThemeData base, ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: colorScheme.primary,
        textStyle: base.textStyleData.buttonTextStyle.copyWith(fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(base.dimensionsData.cornerRadius)),
        ),
      ),
    );
  }

  static InputDecorationTheme _getInputDecorationTheme(AppThemeData base, ColorScheme colorScheme) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(base.dimensionsData.cornerRadius),
      borderSide: BorderSide.none,
    );
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainer,
      contentPadding: base.edgeInsetsData.contentPadding,
      hintStyle: _getTextTheme().bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
      errorStyle: _getTextTheme().bodyMedium?.copyWith(color: colorScheme.error),
      errorMaxLines: 3,
      border: border,
      enabledBorder: border,
      disabledBorder: border.copyWith(borderSide: BorderSide(color: colorScheme.outlineVariant)),
      focusedBorder: border.copyWith(borderSide: BorderSide(color: colorScheme.primary, width: 2)),
      errorBorder: border.copyWith(borderSide: BorderSide(color: colorScheme.error)),
      focusedErrorBorder: border.copyWith(
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
    );
  }

  static DialogThemeData _getDialogTheme(AppThemeData base, ColorScheme colorScheme) {
    return DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(base.dimensionsData.cornerRadius)),
      ),
    );
  }

  static CardThemeData _getCardTheme(AppThemeData base, ColorScheme colorScheme) {
    return CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(base.dimensionsData.cornerRadius)),
      ),
    );
  }

  static BottomSheetThemeData _getBottomSheetTheme(AppThemeData base, ColorScheme colorScheme) {
    return const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
    );
  }

  static CheckboxThemeData _getCheckboxTheme(AppThemeData base, ColorScheme colorScheme) {
    return CheckboxThemeData(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: colorScheme.primary, width: 2),
    );
  }

  static SwitchThemeData _getSwitchTheme(AppThemeData base, ColorScheme colorScheme) {
    return SwitchThemeData(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? colorScheme.onPrimary
            : colorScheme.onSurfaceVariant,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
      ),
      trackOutlineColor: WidgetStatePropertyAll(colorScheme.primary),
    );
  }
}
