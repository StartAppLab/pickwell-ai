import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/_core.dart';

class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SystemUiOverlayStyle? systemOverlayStyle;
  final bool themeModeAdaptive;
  final bool enforceSystemUiContrast;

  const EmptyAppBar({
    super.key,
    this.systemOverlayStyle,
    this.themeModeAdaptive = true,
    this.enforceSystemUiContrast = true,
  });

  @override
  Size get preferredSize => const Size(0, 0);

  @override
  Widget build(BuildContext context) {
    final defaultStyle = (context.colorScheme.brightness == Brightness.light)
        ? SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: context.colorScheme.surface,
            systemNavigationBarIconBrightness: Brightness.dark,
            systemStatusBarContrastEnforced: enforceSystemUiContrast,
            systemNavigationBarContrastEnforced: enforceSystemUiContrast,
          )
        : SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: context.colorScheme.surface,
            systemNavigationBarIconBrightness: Brightness.light,
            systemStatusBarContrastEnforced: enforceSystemUiContrast,
            systemNavigationBarContrastEnforced: enforceSystemUiContrast,
          );
    var style = systemOverlayStyle;
    if (systemOverlayStyle != null) {
      style = systemOverlayStyle!.copyWith(
        statusBarBrightness: themeModeAdaptive
            ? (systemOverlayStyle?.statusBarBrightness ??
                  (context.colorScheme.brightness == Brightness.light
                      ? Brightness.dark
                      : Brightness.light))
            : systemOverlayStyle?.statusBarBrightness,
        statusBarIconBrightness: themeModeAdaptive
            ? (systemOverlayStyle?.statusBarIconBrightness ??
                  (context.colorScheme.brightness == Brightness.light
                      ? Brightness.dark
                      : Brightness.light))
            : systemOverlayStyle?.statusBarIconBrightness,
        systemNavigationBarIconBrightness: themeModeAdaptive
            ? (systemOverlayStyle?.systemNavigationBarIconBrightness ??
                  (context.colorScheme.brightness == Brightness.light
                      ? Brightness.dark
                      : Brightness.light))
            : systemOverlayStyle?.systemNavigationBarIconBrightness,
        statusBarColor: systemOverlayStyle?.statusBarColor ?? Colors.transparent,
        systemNavigationBarColor:
            systemOverlayStyle?.systemNavigationBarColor ?? context.colorScheme.surface,
        systemStatusBarContrastEnforced:
            systemOverlayStyle?.systemStatusBarContrastEnforced ?? enforceSystemUiContrast,
        systemNavigationBarContrastEnforced:
            systemOverlayStyle?.systemNavigationBarContrastEnforced ?? enforceSystemUiContrast,
      );
    }
    return AppBar(
      elevation: 0,
      systemOverlayStyle: style ?? defaultStyle,
      forceMaterialTransparency: true,
    );
  }
}
