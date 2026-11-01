import 'package:flutter/material.dart';

class AppThemeData extends ThemeExtension<AppThemeData> {
  final Brightness brightness;
  final DimensionsData dimensionsData;
  final EdgeInsetsData edgeInsetsData;
  final DurationData durationData;
  final TextStyleData textStyleData;
  final ButtonStyleData buttonStyleData;

  const AppThemeData({
    required this.brightness,
    required this.dimensionsData,
    required this.edgeInsetsData,
    required this.durationData,
    required this.textStyleData,
    required this.buttonStyleData,
  });

  @override
  AppThemeData copyWith({
    Brightness? brightness,
    DimensionsData? dimensionsData,
    EdgeInsetsData? edgeInsetsData,
    DurationData? durationData,
    TextStyleData? textStyleData,
    ButtonStyleData? buttonStyleData,
  }) {
    return AppThemeData(
      brightness: brightness ?? this.brightness,
      dimensionsData: dimensionsData ?? this.dimensionsData,
      edgeInsetsData: edgeInsetsData ?? this.edgeInsetsData,
      durationData: durationData ?? this.durationData,
      textStyleData: textStyleData ?? this.textStyleData,
      buttonStyleData: buttonStyleData ?? this.buttonStyleData,
    );
  }

  @override
  ThemeExtension<AppThemeData> lerp(covariant ThemeExtension<AppThemeData>? other, double t) {
    if (other == null) {
      return this;
    }
    return AppThemeData(
      brightness: brightness,
      dimensionsData: dimensionsData,
      edgeInsetsData: edgeInsetsData,
      durationData: durationData,
      textStyleData: textStyleData,
      buttonStyleData: buttonStyleData,
    );
  }
}

class DimensionsData {
  final double maxWidth;
  final double cornerRadius;
  final double buttonHeight;
  final double textFieldSpacing;
  final double textSpacing;
  final double smallSpacing;
  final double mediumSpacing;
  final double largeSpacing;
  final double indicatorSpacing;

  const DimensionsData({
    required this.maxWidth,
    required this.cornerRadius,
    required this.buttonHeight,
    required this.textFieldSpacing,
    required this.textSpacing,
    required this.smallSpacing,
    required this.mediumSpacing,
    required this.largeSpacing,
    required this.indicatorSpacing,
  });
}

class EdgeInsetsData {
  final EdgeInsets pagePadding;
  final EdgeInsets containerPadding;
  final EdgeInsets dialogPadding;
  final EdgeInsets contentPadding;

  const EdgeInsetsData({
    required this.pagePadding,
    required this.containerPadding,
    required this.dialogPadding,
    required this.contentPadding,
  });
}

class DurationData {
  final Duration buttonPressDelay;

  const DurationData({required this.buttonPressDelay});
}

class TextStyleData {
  final TextStyle titleTextStyle;
  final TextStyle buttonTextStyle;

  const TextStyleData({
    required this.titleTextStyle,
    required this.buttonTextStyle,
  });
}

class ButtonStyleData {
  final ButtonStyle noSplashButtonStyle;

  ButtonStyleData({required this.noSplashButtonStyle});
}
