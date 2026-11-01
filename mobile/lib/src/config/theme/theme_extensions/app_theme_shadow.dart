import 'package:flutter/material.dart';

class AppThemeShadow extends ThemeExtension<AppThemeShadow> {
  final BoxShadow primaryShadow;

  AppThemeShadow({
    this.primaryShadow = const BoxShadow(
      color: Color(0xFF6750A4),
      blurRadius: 10,
      spreadRadius: 10,
      offset: Offset(-10, 10),
      blurStyle: BlurStyle.outer,
    ),
  });

  factory AppThemeShadow.dark() {
    return AppThemeShadow(
      primaryShadow: const BoxShadow(
        color: Color(0xFF381E72),
        blurRadius: 10,
        spreadRadius: 10,
        offset: Offset(-10, 10),
        blurStyle: BlurStyle.outer,
      ),
    );
  }

  @override
  AppThemeShadow copyWith({BoxShadow? primaryShadow}) {
    return AppThemeShadow(primaryShadow: primaryShadow ?? this.primaryShadow);
  }

  @override
  ThemeExtension<AppThemeShadow> lerp(covariant ThemeExtension<AppThemeShadow>? other, double t) {
    if (other == null) {
      return this;
    }
    return AppThemeShadow();
  }
}
