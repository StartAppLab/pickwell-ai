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

  /// Generic sibling gaps, independent of the existing compatibility fields.
  final double spacingXxs, spacingXs, spacingSm, spacingMd, spacingLg, spacingXl, spacingXxl;

  /// Insets are separate from gaps, shapes and icon sizes.
  final double paddingMicro, paddingXxs, paddingXs, paddingSm, paddingMd;
  final double paddingComfortable, paddingLg, paddingXl, paddingXxl;
  final double cardCornerRadius, heroCornerRadius, nestedCornerRadius;
  final double minimumTouchTarget, iconSmall, iconMedium, iconSize, iconLarge;
  final double sheetCornerRadius, sheetHandleWidth, sheetHandleHeight, sheetHandleTopInset;

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
    this.spacingXxs = 4,
    this.spacingXs = 8,
    this.spacingSm = 12,
    this.spacingMd = 16,
    this.spacingLg = 24,
    this.spacingXl = 32,
    this.spacingXxl = 40,
    this.paddingMicro = 2,
    this.paddingXxs = 4,
    this.paddingXs = 8,
    this.paddingSm = 12,
    this.paddingMd = 16,
    this.paddingComfortable = 20,
    this.paddingLg = 24,
    this.paddingXl = 32,
    this.paddingXxl = 40,
    this.cardCornerRadius = 20,
    this.heroCornerRadius = 24,
    this.nestedCornerRadius = 12,
    this.minimumTouchTarget = 48,
    this.iconSmall = 12,
    this.iconMedium = 20,
    this.iconSize = 24,
    this.iconLarge = 28,
    this.sheetCornerRadius = 24,
    this.sheetHandleWidth = 36,
    this.sheetHandleHeight = 4,
    this.sheetHandleTopInset = 12,
  });
  DimensionsData copyWith({
    double? maxWidth,
    double? cornerRadius,
    double? buttonHeight,
    double? textFieldSpacing,
    double? textSpacing,
    double? smallSpacing,
    double? mediumSpacing,
    double? largeSpacing,
    double? indicatorSpacing,
    double? spacingXxs,
    double? spacingXs,
    double? spacingSm,
    double? spacingMd,
    double? spacingLg,
    double? spacingXl,
    double? spacingXxl,
    double? paddingMicro,
    double? paddingXxs,
    double? paddingXs,
    double? paddingSm,
    double? paddingMd,
    double? paddingComfortable,
    double? paddingLg,
    double? paddingXl,
    double? paddingXxl,
    double? cardCornerRadius,
    double? heroCornerRadius,
    double? nestedCornerRadius,
    double? minimumTouchTarget,
    double? iconSmall,
    double? iconMedium,
    double? iconSize,
    double? iconLarge,
    double? sheetCornerRadius,
    double? sheetHandleWidth,
    double? sheetHandleHeight,
    double? sheetHandleTopInset,
  }) => DimensionsData(
    maxWidth: maxWidth ?? this.maxWidth,
    cornerRadius: cornerRadius ?? this.cornerRadius,
    buttonHeight: buttonHeight ?? this.buttonHeight,
    textFieldSpacing: textFieldSpacing ?? this.textFieldSpacing,
    textSpacing: textSpacing ?? this.textSpacing,
    smallSpacing: smallSpacing ?? this.smallSpacing,
    mediumSpacing: mediumSpacing ?? this.mediumSpacing,
    largeSpacing: largeSpacing ?? this.largeSpacing,
    indicatorSpacing: indicatorSpacing ?? this.indicatorSpacing,
    spacingXxs: spacingXxs ?? this.spacingXxs,
    spacingXs: spacingXs ?? this.spacingXs,
    spacingSm: spacingSm ?? this.spacingSm,
    spacingMd: spacingMd ?? this.spacingMd,
    spacingLg: spacingLg ?? this.spacingLg,
    spacingXl: spacingXl ?? this.spacingXl,
    spacingXxl: spacingXxl ?? this.spacingXxl,
    paddingMicro: paddingMicro ?? this.paddingMicro,
    paddingXxs: paddingXxs ?? this.paddingXxs,
    paddingXs: paddingXs ?? this.paddingXs,
    paddingSm: paddingSm ?? this.paddingSm,
    paddingMd: paddingMd ?? this.paddingMd,
    paddingComfortable: paddingComfortable ?? this.paddingComfortable,
    paddingLg: paddingLg ?? this.paddingLg,
    paddingXl: paddingXl ?? this.paddingXl,
    paddingXxl: paddingXxl ?? this.paddingXxl,
    cardCornerRadius: cardCornerRadius ?? this.cardCornerRadius,
    heroCornerRadius: heroCornerRadius ?? this.heroCornerRadius,
    nestedCornerRadius: nestedCornerRadius ?? this.nestedCornerRadius,
    minimumTouchTarget: minimumTouchTarget ?? this.minimumTouchTarget,
    iconSmall: iconSmall ?? this.iconSmall,
    iconMedium: iconMedium ?? this.iconMedium,
    iconSize: iconSize ?? this.iconSize,
    iconLarge: iconLarge ?? this.iconLarge,
    sheetCornerRadius: sheetCornerRadius ?? this.sheetCornerRadius,
    sheetHandleWidth: sheetHandleWidth ?? this.sheetHandleWidth,
    sheetHandleHeight: sheetHandleHeight ?? this.sheetHandleHeight,
    sheetHandleTopInset: sheetHandleTopInset ?? this.sheetHandleTopInset,
  );
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

  const TextStyleData({required this.titleTextStyle, required this.buttonTextStyle});
}

class ButtonStyleData {
  final ButtonStyle noSplashButtonStyle;

  ButtonStyleData({required this.noSplashButtonStyle});
}
