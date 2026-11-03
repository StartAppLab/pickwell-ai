import 'package:flutter/material.dart';

class AppColorScheme {
  static ColorScheme lightColorScheme =
      ColorScheme.fromSeed(
        seedColor: const Color(0xFF168A3B),
        brightness: Brightness.light,
      ).copyWith(
        primary: const Color(0xFF173A25),
        onPrimary: const Color(0xFFFFFFFF),
        primaryContainer: const Color(0xFFEAF5E9),
        onPrimaryContainer: const Color(0xFF173A25),
        secondary: const Color(0xFF167237),
        onSecondary: const Color(0xFFFFFFFF),
        tertiary: const Color(0xFF935600),
        tertiaryContainer: const Color(0xFFFFD428),
        surface: const Color(0xFFFFF7D6),
        surfaceContainerLowest: const Color(0xFFFFFFFF),
        onSurface: const Color(0xFF17251D),
        onSurfaceVariant: const Color(0xFF647068),
        outlineVariant: const Color(0xFFE5E9E2),
      );
  static ColorScheme darkColorScheme =
      ColorScheme.fromSeed(
        seedColor: const Color(0xFF168A3B),
        brightness: Brightness.dark,
      ).copyWith(
        primary: const Color(0xFF9DD8A4),
        onPrimary: const Color(0xFF173A25),
        tertiary: const Color(0xFFFFD428),
        surface: const Color(0xFF142019),
        surfaceContainerLowest: const Color(0xFF1C2C22),
        secondary: const Color(0xFF9DD8A4),
        primaryContainer: const Color(0xFF294A32),
        onPrimaryContainer: const Color(0xFFD5F2D5),
        outlineVariant: const Color(0xFF405345),
        onSurfaceVariant: const Color(0xFFB8C9BA),
        onSurface: const Color(0xFFF4F7EF),
      );
}
