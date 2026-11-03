import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../../../catalog/domain/entities/catalog_entity.dart';
import 'home_sort_popover.dart';
import 'home_sort_label.dart';
import 'home_control_metrics.dart';

class HomeSortMenu extends StatelessWidget {
  final RecentProductSort sort;
  final ValueChanged<RecentProductSort> onChanged;
  const HomeSortMenu({super.key, required this.sort, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final d = context.themeData.dimensionsData, colors = context.colorScheme;
    return Tooltip(
      message: context.l10n.pkSortProducts,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () async {
          final box = context.findRenderObject()! as RenderBox;
          final anchor = box.localToGlobal(Offset.zero) & box.size;
          final result = await showGeneralDialog<RecentProductSort>(
            context: context,
            barrierDismissible: true,
            barrierLabel: context.l10n.pkCancel,
            barrierColor: Colors.transparent,
            transitionDuration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 160),
            pageBuilder: (_, _, _) => HomeSortPopover(anchor: anchor, selected: sort),
            transitionBuilder: (_, animation, _, child) =>
                FadeTransition(opacity: animation, child: child),
          );
          if (result != null && context.mounted) onChanged(result);
        },
        child: Container(
          height: homeControlHeight(context),
          padding: EdgeInsets.symmetric(horizontal: d.paddingSm, vertical: d.paddingXs),
          decoration: ShapeDecoration(
            color: colors.surfaceContainerLowest,
            shape: StadiumBorder(
              side: BorderSide(
                color: Color.lerp(colors.outlineVariant, colors.onSurfaceVariant, .45)!,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(
                icon: HugeIcons.strokeRoundedSorting05,
                size: d.iconMedium,
                color: colors.primary,
              ),
              Gap(d.spacingXxs),
              Flexible(
                child: Text(
                  recentSortLabel(context, sort),
                  style: context.textTheme.titleMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
