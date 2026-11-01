import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../../../settings/domain/entities/app_release.dart';

/// A reusable release-notes sheet; projects decide when to show it.
class WhatsNewSheet extends StatelessWidget {
  const WhatsNewSheet({super.key, required this.release});
  final AppRelease release;

  static Future<void> show(BuildContext context, {required AppRelease release}) =>
      showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        useSafeArea: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => WhatsNewSheet(release: release),
      );

  @override
  Widget build(BuildContext context) {
    final dimensions = context.themeData.dimensionsData;
    final pagePadding = context.themeData.edgeInsetsData.pagePadding;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.82,
            maxWidth: context.themeData.dimensionsData.maxWidth,
          ),
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
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
                    color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Padding(
                padding: pagePadding.copyWith(bottom: dimensions.mediumSpacing),
                child: Text(
                  "What's New",
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Padding(
                padding: pagePadding.copyWith(top: 0, bottom: dimensions.smallSpacing),
                child: Text(
                  'v${release.version} · ${release.title}',
                  textAlign: TextAlign.left,
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: pagePadding.copyWith(top: 0, bottom: dimensions.smallSpacing),
                  itemCount: release.notes.length,
                  separatorBuilder: (_, _) => Gap(dimensions.smallSpacing),
                  itemBuilder: (context, index) => Container(
                    padding: context.themeData.edgeInsetsData.containerPadding,
                    decoration: BoxDecoration(
                      color: context.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(dimensions.cornerRadius),
                      border: Border.all(color: context.colorScheme.outlineVariant),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: AppIcon(
                            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                            size: 20,
                            color: context.colorScheme.primary,
                          ),
                        ),
                        Gap(dimensions.smallSpacing),
                        Expanded(
                          child: Text(release.notes[index], style: context.textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: pagePadding.copyWith(top: dimensions.smallSpacing),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
