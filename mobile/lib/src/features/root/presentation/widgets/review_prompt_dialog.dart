import 'package:flutter/material.dart';

import 'package:gap/gap.dart';

import '../../../../config/_config.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';

/// Projects control prompting frequency and provide their own review action.
class ReviewPromptDialog extends StatefulWidget {
  const ReviewPromptDialog({super.key, required this.onRateNow});
  final Future<void> Function() onRateNow;

  static Future<void> show(BuildContext context, {required Future<void> Function() onRateNow}) =>
      showDialog<void>(
        context: context,
        builder: (_) => ReviewPromptDialog(onRateNow: onRateNow),
      );

  @override
  State<ReviewPromptDialog> createState() => _ReviewPromptDialogState();
}

class _ReviewPromptDialogState extends State<ReviewPromptDialog> {
  bool _isSubmitting = false;

  Future<void> _rate() async {
    setState(() => _isSubmitting = true);
    try {
      await widget.onRateNow();
      if (mounted) Navigator.of(context).pop();
    } catch (error, stackTrace) {
      AppLogger.logError(error, stackTrace: stackTrace);
      if (mounted) {
        setState(() => _isSubmitting = false);
        AppWidgets.showErrorSnackBar(context, context.l10n.reviewPromptError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final dimensions = context.themeData.dimensionsData;
    final insets = context.themeData.edgeInsetsData;

    return AlertDialog(
      scrollable: true,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      constraints: BoxConstraints(maxWidth: dimensions.maxWidth),
      insetPadding: insets.dialogPadding,
      titlePadding: insets.pagePadding.copyWith(bottom: dimensions.smallSpacing),
      contentPadding: insets.pagePadding.copyWith(top: 0, bottom: dimensions.mediumSpacing),
      actionsPadding: insets.pagePadding.copyWith(top: 0),
      title: Text(
        context.l10n.reviewPromptTitle,
        textAlign: TextAlign.center,
        style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: dimensions.maxWidth,
        child: Text(
          context.l10n.reviewPromptBody1(getIt<AppConfig>().appName),
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge,
        ),
      ),
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isSubmitting ? null : _rate,
              child: _isSubmitting
                  ? SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    )
                  : Text(context.l10n.reviewPromptAction, textAlign: TextAlign.center),
            ),
            Gap(dimensions.smallSpacing),
            Center(
              child: TextButton(
                onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                child: Text(context.l10n.reviewPromptMaybeLater, textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
