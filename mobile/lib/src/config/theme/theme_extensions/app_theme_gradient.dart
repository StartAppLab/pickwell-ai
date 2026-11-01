import 'package:flutter/material.dart';

class AppThemeGradient extends ThemeExtension<AppThemeGradient> {
  final Gradient backgroundGradient;
  final Gradient welcomeBgGradient;

  AppThemeGradient({required this.backgroundGradient, required this.welcomeBgGradient});

  factory AppThemeGradient.generate({required ColorScheme colorScheme}) {
    return AppThemeGradient(
      backgroundGradient: LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        stops: const [0.1, 0.2, 0.9, 0.9, 0.95, 1],
        colors: [
          colorScheme.surfaceTint,
          colorScheme.surfaceTint,
          colorScheme.onInverseSurface,
          colorScheme.onInverseSurface,
          colorScheme.onInverseSurface,
          colorScheme.onInverseSurface,
        ],
      ),
      welcomeBgGradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        stops: const [0.2, 1],
        colors: [
          colorScheme.primary.withValues(alpha: 0.75),
          colorScheme.secondary.withValues(alpha: 0.75),
        ],
      ),
    );
  }

  @override
  AppThemeGradient copyWith({Gradient? backgroundGradient, Gradient? welcomeBgGradient}) {
    return AppThemeGradient(
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      welcomeBgGradient: welcomeBgGradient ?? this.welcomeBgGradient,
    );
  }

  @override
  ThemeExtension<AppThemeGradient> lerp(
    covariant ThemeExtension<AppThemeGradient>? other,
    double t,
  ) {
    if (other == null) {
      return this;
    }
    return AppThemeGradient(
      backgroundGradient: backgroundGradient,
      welcomeBgGradient: welcomeBgGradient,
    );
  }
}
