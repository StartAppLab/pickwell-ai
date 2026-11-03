import 'package:flutter/material.dart';
import '../../../../core/_core.dart';
import 'home_control_metrics.dart';

/// Reference-style category capsule; selection is conveyed by semantics too.
class HomeFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  const HomeFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final d = context.themeData.dimensionsData, colors = context.colorScheme;
    final height = homeControlHeight(context);
    return SizedBox(
      height: height,
      child: ChoiceChip(
        label: SizedBox(
          height: height,
          child: Center(widthFactor: 1, child: Text(label)),
        ),
        selected: selected,
        onSelected: (_) => onSelected(),
        showCheckmark: false,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.standard,
        selectedColor: colors.primary,
        backgroundColor: colors.surfaceContainerLowest,
        shape: const StadiumBorder(),
        side: BorderSide(
          color: selected
              ? colors.primary
              : Color.lerp(colors.outlineVariant, colors.onSurfaceVariant, .45)!,
        ),
        labelStyle: context.textTheme.titleMedium?.copyWith(
          color: selected ? colors.onPrimary : colors.primary,
          fontWeight: FontWeight.w700,
        ),
        labelPadding: EdgeInsets.zero,
        padding: EdgeInsets.symmetric(horizontal: d.paddingMd),
      ),
    );
  }
}
