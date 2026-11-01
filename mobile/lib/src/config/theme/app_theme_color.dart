import 'package:flutter/material.dart';

class AppThemeColor extends ThemeExtension<AppThemeColor> {
  final Color primaryColor;
  final Color primaryLightColor;
  final Color grayTextColor;
  final Color graySurfaceColor;
  final Color socialMediaIconColor;

  AppThemeColor({
    this.primaryColor = const Color(0xff775cff),
    this.primaryLightColor = const Color(0xffe5deff),
    this.grayTextColor = const Color(0xff757575),
    this.graySurfaceColor = const Color(0xffeceded),
    this.socialMediaIconColor = const Color(0xfffbfaff),
  });

  factory AppThemeColor.dark() {
    return AppThemeColor(
      primaryColor: const Color(0xff775cff),
      primaryLightColor: const Color(0xffe5deff),
      grayTextColor: const Color(0xffeceded),
      graySurfaceColor: const Color(0xff757575),
      socialMediaIconColor: const Color(0xfffbfaff),
    );
  }

  @override
  AppThemeColor copyWith({
    Color? primaryColor,
    Color? primaryLightColor,
    Color? grayTextColor,
    Color? graySurfaceColor,
    Color? socialMediaIconColor,
  }) {
    return AppThemeColor(
      primaryColor: primaryColor ?? this.primaryColor,
      primaryLightColor: primaryLightColor ?? this.primaryLightColor,
      grayTextColor: grayTextColor ?? this.grayTextColor,
      graySurfaceColor: graySurfaceColor ?? this.graySurfaceColor,
      socialMediaIconColor: socialMediaIconColor ?? this.socialMediaIconColor,
    );
  }

  @override
  ThemeExtension<AppThemeColor> lerp(covariant ThemeExtension<AppThemeColor>? other, double t) {
    if (other == null) {
      return this;
    }
    return AppThemeColor();
  }
}
