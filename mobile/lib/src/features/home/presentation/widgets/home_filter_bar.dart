import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/_core.dart';
import '../../../catalog/domain/entities/catalog_entity.dart';
import 'home_filter_chip.dart';
import 'home_sort_menu.dart';
import 'home_sort_label.dart';

class HomeFilterBar extends StatelessWidget {
  final bool foodOnly;
  final ValueChanged<bool> onFoodChanged;
  final RecentProductSort sort;
  final ValueChanged<RecentProductSort> onSortChanged;
  const HomeFilterBar({
    super.key,
    required this.foodOnly,
    required this.onFoodChanged,
    required this.sort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final d = context.themeData.dimensionsData, l = context.l10n;
    final chips = Wrap(
      spacing: d.spacingXs,
      runSpacing: d.spacingXs,
      children: [
        HomeFilterChip(label: l.pkAll, selected: !foodOnly, onSelected: () => onFoodChanged(false)),
        HomeFilterChip(label: l.pkFood, selected: foodOnly, onSelected: () => onFoodChanged(true)),
      ],
    );
    final menu = HomeSortMenu(sort: sort, onChanged: onSortChanged);
    return LayoutBuilder(
      builder: (context, constraints) {
        // Measure translated/scaled labels so the sort never clips category chips.
        double width(String label) {
          final painter = TextPainter(
            text: TextSpan(
              text: label,
              style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout();
          final result = painter.width;
          painter.dispose();
          return result;
        }

        final chipsWidth = width(l.pkAll) + width(l.pkFood) + d.paddingMd * 4 + d.spacingXs;
        final menuWidth =
            width(recentSortLabel(context, sort)) + d.paddingSm * 2 + d.iconMedium + d.spacingXxs;
        if (chipsWidth + d.spacingMd + menuWidth <= constraints.maxWidth) {
          return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [chips, menu]);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            chips,
            Gap(d.spacingXs),
            Align(alignment: AlignmentDirectional.centerEnd, child: menu),
          ],
        );
      },
    );
  }
}
