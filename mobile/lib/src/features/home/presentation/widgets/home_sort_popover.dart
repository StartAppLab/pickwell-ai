import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../../../catalog/domain/entities/catalog_entity.dart';
import 'home_sort_label.dart';

class HomeSortPopover extends StatelessWidget {
  final Rect anchor;
  final RecentProductSort selected;
  const HomeSortPopover({super.key, required this.anchor, required this.selected});

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme, d = context.themeData.dimensionsData;
    final media = MediaQuery.of(context);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.of(context).pop(),
      },
      child: Focus(
        autofocus: true,
        child: CustomSingleChildLayout(
          delegate: _SortPosition(
            anchor,
            media.viewPadding.copyWith(
              bottom: math.max(media.viewPadding.bottom, media.viewInsets.bottom),
            ),
            Directionality.of(context),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(d.cardCornerRadius),
              border: Border.all(color: colors.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: .14),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(d.cardCornerRadius),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(d.paddingXs),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(d.paddingXs),
                      child: Text(
                        context.l10n.pkSortProducts,
                        style: context.textTheme.labelLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    for (final option in RecentProductSort.values)
                      Semantics(
                        selected: option == selected,
                        child: CupertinoButton(
                          key: ValueKey('sort-option-${option.name}'),
                          minimumSize: Size(d.minimumTouchTarget, d.minimumTouchTarget),
                          padding: EdgeInsets.all(d.paddingSm),
                          color: option == selected ? colors.primaryContainer : Colors.transparent,
                          borderRadius: BorderRadius.circular(d.nestedCornerRadius),
                          onPressed: () => Navigator.of(context).pop(option),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  recentSortLabel(context, option),
                                  style: context.textTheme.bodyLarge?.copyWith(
                                    color: option == selected
                                        ? colors.onPrimaryContainer
                                        : colors.onSurface,
                                    fontWeight: option == selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                              Gap(d.spacingXs),
                              if (option == selected)
                                AppIcon(
                                  icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                                  color: colors.onPrimaryContainer,
                                  size: d.iconMedium,
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SortPosition extends SingleChildLayoutDelegate {
  final Rect anchor;
  final EdgeInsets insets;
  final TextDirection direction;
  static const _margin = 16.0, _preferredWidth = 256.0, _anchorGap = 8.0;
  const _SortPosition(this.anchor, this.insets, this.direction);

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => BoxConstraints(
    minWidth: math.min(
      _preferredWidth,
      math.max(0, constraints.maxWidth - insets.horizontal - _margin * 2),
    ),
    maxWidth: math.min(
      _preferredWidth,
      math.max(0, constraints.maxWidth - insets.horizontal - _margin * 2),
    ),
    maxHeight: math.max(0, constraints.maxHeight - insets.vertical - _margin * 2),
  );
  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final left = insets.left + _margin, top = insets.top + _margin;
    final x = direction == TextDirection.rtl ? anchor.left : anchor.right - childSize.width;
    final below = anchor.bottom + _anchorGap;
    final y = below + childSize.height <= size.height - insets.bottom - _margin
        ? below
        : anchor.top - childSize.height - _anchorGap;
    return Offset(
      x.clamp(left, math.max(left, size.width - insets.right - _margin - childSize.width)),
      y.clamp(top, math.max(top, size.height - insets.bottom - _margin - childSize.height)),
    );
  }

  @override
  bool shouldRelayout(covariant _SortPosition oldDelegate) =>
      oldDelegate.anchor != anchor ||
      oldDelegate.insets != insets ||
      oldDelegate.direction != direction;
}
