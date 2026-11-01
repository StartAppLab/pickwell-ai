import 'package:flutter/material.dart';

import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../../core/_core.dart';
import 'app_icon.dart';
import 'animated_loading_text.dart';

class AppWidgets {
  static Future loadingDialog(
    BuildContext context, {
    int? millisecondsDelay,
    String? loadingText,
    Color? indicatorColor,
    Future<void> Function()? onLoading,
  }) async {
    final loadingDialog = AlertDialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      content: Container(
        width: double.minPositive,
        padding: context.themeData.edgeInsetsData.dialogPadding,
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(context.themeData.dimensionsData.cornerRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            loadingIndicator(context, color: indicatorColor),
            Gap(context.themeData.dimensionsData.indicatorSpacing),
            Flexible(
              child: Text(
                loadingText ?? context.l10n.loading,
                textWidthBasis: TextWidthBasis.longestLine,
                style: context.textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.themeData.dimensionsData.cornerRadius),
      ),
    );
    showDialog(context: context, barrierDismissible: false, builder: (context) => loadingDialog);
    await Future.delayed(Duration(milliseconds: millisecondsDelay ?? 500));
    if (onLoading != null) {
      await onLoading().whenComplete(() {
        if (context.mounted && Navigator.canPop(context)) Navigator.pop(context);
      });
    }
  }

  static Widget loadingIndicator(
    BuildContext context, {
    Color? color,
    double? size,
    Indicator? indicatorType,
  }) {
    return SizedBox(
      width: size ?? 30,
      height: size ?? 30,
      child: LoadingIndicator(
        colors: [color ?? context.colorScheme.primary],
        indicatorType: indicatorType ?? Indicator.lineSpinFadeLoader,
      ),
    );
  }

  static Widget animatedLoadingText(
    BuildContext context, {
    List<String>? words,
    Duration? animationDuration,
    TextStyle? textStyle,
  }) {
    return AnimatedLoadingText(
      words: words ?? ['Analyzing', 'Crafting', 'Polishing', 'Perfecting', 'Finalizing'],
      animationDuration: animationDuration ?? const Duration(milliseconds: 1500),
      textStyle: textStyle ?? context.textTheme.bodyLarge,
    );
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(_snackBar(context, message, type: _SnackBarType.info));
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(_snackBar(context, message, type: _SnackBarType.success));
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(_snackBar(context, message, type: _SnackBarType.error));
  }

  static void showConfirmationDialog(BuildContext context, {String? title, String? text}) {
    final confirmationDialog = AlertDialog(
      elevation: 0,
      icon: AppIcon(icon: HugeIcons.strokeRoundedAlert02),
      iconColor: Colors.yellow,
      title: Text(
        title ?? '',
        textWidthBasis: TextWidthBasis.longestLine,
        style: context.textTheme.titleMedium,
      ),
      content: Container(
        width: double.minPositive,
        padding: context.themeData.edgeInsetsData.dialogPadding,
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(context.themeData.dimensionsData.cornerRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Gap(context.themeData.dimensionsData.smallSpacing),
            Flexible(
              child: Text(
                text ?? '',
                textWidthBasis: TextWidthBasis.longestLine,
                style: context.textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () {}, child: const Text('Yes')),
        TextButton(onPressed: () {}, child: const Text('Cancel')),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.themeData.dimensionsData.cornerRadius),
      ),
    );
    showDialog(context: context, builder: (context) => confirmationDialog);
  }

  static SnackBar _snackBar(
    BuildContext context,
    String message, {
    int? millisecondsDuration,
    _SnackBarType type = _SnackBarType.info,
  }) {
    final (backgroundColor, textColor) = switch (type) {
      _SnackBarType.error => (
        context.colorScheme.errorContainer,
        context.colorScheme.onErrorContainer,
      ),
      _SnackBarType.success => (context.colorScheme.primary, context.colorScheme.onPrimary),
      _SnackBarType.info => (
        context.colorScheme.surfaceContainerHighest,
        context.colorScheme.onSurface,
      ),
    };

    return SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      duration: Duration(milliseconds: millisecondsDuration ?? 3000),
      clipBehavior: Clip.none,
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: context.textTheme.bodyMedium?.copyWith(color: textColor),
      ),
      backgroundColor: backgroundColor,
    );
  }
}

enum _SnackBarType { info, success, error }
