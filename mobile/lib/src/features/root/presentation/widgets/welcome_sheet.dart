import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/_config.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';

/// An introduction to the sample note-taking use cases from onboarding.
class WelcomeSheet extends StatefulWidget {
  const WelcomeSheet({super.key, this.onContinue});

  final Future<void> Function()? onContinue;

  static Future<void> show(BuildContext context, {Future<void> Function()? onContinue}) =>
      showModalBottomSheet<void>(
        context: context,
        isDismissible: onContinue == null,
        enableDrag: onContinue == null,
        useRootNavigator: true,
        useSafeArea: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => WelcomeSheet(onContinue: onContinue),
      );

  @override
  State<WelcomeSheet> createState() => _WelcomeSheetState();
}

class _WelcomeSheetState extends State<WelcomeSheet> {
  bool _isContinuing = false;
  String? _error;

  Future<void> _continue() async {
    if (_isContinuing) return;
    setState(() {
      _isContinuing = true;
      _error = null;
    });
    try {
      await widget.onContinue?.call();
      if (mounted) Navigator.of(context).pop();
    } catch (error, stackTrace) {
      AppLogger.logError(error, stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _isContinuing = false;
          _error = context.l10n.authContinueError;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final dimensions = context.themeData.dimensionsData;
    final insets = context.themeData.edgeInsetsData;
    final cards = [
      (
        icon: HugeIcons.strokeRoundedShoppingCart01,
        title: context.l10n.welcomeGroceriesTitle,
        description: context.l10n.welcomeGroceriesDescription,
      ),
      (
        icon: HugeIcons.strokeRoundedBook04,
        title: context.l10n.welcomeJournalTitle,
        description: context.l10n.welcomeJournalDescription,
      ),
      (
        icon: HugeIcons.strokeRoundedMortarboard01,
        title: context.l10n.welcomeStudyTitle,
        description: context.l10n.welcomeStudyDescription,
      ),
      (
        icon: HugeIcons.strokeRoundedBulb,
        title: context.l10n.welcomeIdeasTitle,
        description: context.l10n.welcomeIdeasDescription,
      ),
      (
        icon: HugeIcons.strokeRoundedBriefcase01,
        title: context.l10n.welcomeWorkTitle,
        description: context.l10n.welcomeWorkDescription,
      ),
      (
        icon: HugeIcons.strokeRoundedCalendar03,
        title: context.l10n.welcomePlanningTitle,
        description: context.l10n.welcomePlanningDescription,
      ),
    ];

    return PopScope(
      canPop: widget.onContinue == null,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.9,
              maxWidth: dimensions.maxWidth,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(28),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: insets.pagePadding.copyWith(bottom: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.l10n.welcomeTitle(getIt<AppConfig>().appName),
                          textAlign: TextAlign.center,
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Gap(dimensions.smallSpacing),
                        Text(
                          context.l10n.welcomeGuideSubtitle,
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        Gap(dimensions.mediumSpacing),
                        for (var index = 0; index < cards.length; index++) ...[
                          if (index > 0) Gap(dimensions.smallSpacing),
                          Container(
                            padding: insets.containerPadding,
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(dimensions.cornerRadius),
                              border: Border.all(color: colors.outlineVariant),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: colors.primaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: AppIcon(
                                      icon: cards[index].icon,
                                      size: 22,
                                      color: colors.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                Gap(dimensions.smallSpacing),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cards[index].title,
                                        style: context.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        cards[index].description,
                                        style: context.textTheme.bodyMedium?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: insets.pagePadding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_error != null) ...[
                        Text(
                          _error!,
                          style: context.textTheme.bodyMedium?.copyWith(color: colors.error),
                        ),
                        Gap(dimensions.smallSpacing),
                      ],
                      ElevatedButton(
                        onPressed: _isContinuing ? null : _continue,
                        child: _isContinuing
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(context.l10n.continueButton),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
