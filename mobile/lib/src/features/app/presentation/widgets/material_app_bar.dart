import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/_core.dart';
import '../../app.dart';

class MaterialAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final Widget icon;
  final Color? iconColor;
  final VoidCallback? onIconPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double elevation;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final bool themeModeAdaptive;
  final bool enforceSystemUiContrast;

  const MaterialAppBar({
    super.key,
    this.title,
    this.leading,
    this.icon = const AppIcon(icon: HugeIcons.strokeRoundedArrowLeft01, size: 30),
    this.iconColor,
    this.onIconPressed,
    this.actions,
    this.backgroundColor,
    this.elevation = 0,
    this.systemOverlayStyle,
    this.themeModeAdaptive = true,
    this.enforceSystemUiContrast = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

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
      title: title,
      leading:
          leading ??
          Center(
            child: IconButton(
              icon: icon,
              color: iconColor ?? context.colorScheme.onSurface,
              onPressed: onIconPressed ?? () => context.pop(context),
            ),
          ),
      actions: actions,
      backgroundColor: backgroundColor,
      elevation: elevation,
      systemOverlayStyle: style ?? defaultStyle,
      forceMaterialTransparency: true,
    );
  }
}
