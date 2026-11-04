import 'package:flutter/material.dart';
import '../../../../core/_core.dart';
import '../blocs/catalog/label_capture_cubit.dart';

class CaptureStepTimeline extends StatelessWidget {
  final int selected;
  final LabelCaptureState state;
  final bool busy;
  final ValueChanged<int> onSelected;
  const CaptureStepTimeline({
    super.key,
    required this.selected,
    required this.state,
    required this.onSelected,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme, d = context.themeData.dimensionsData, l = context.l10n;
    final labels = [l.pkFrontPackaging, l.pkNutrition, l.pkIngredients, l.pkCaptureReviewStep];
    final complete = [
      state.front != null,
      state.nutrition != null,
      state.ingredients != null,
      false,
    ];
    return Row(
      children: [
        for (var i = 0; i < 4; i++) ...[
          if (i > 0)
            Expanded(
              child: Divider(
                thickness: 2,
                color: complete[i - 1] ? colors.secondary : colors.outlineVariant,
              ),
            ),
          Semantics(
            selected: selected == i,
            label: '${i + 1}. ${labels[i]}',
            button: true,
            child: Tooltip(
              message: labels[i],
              child: SizedBox.square(
                dimension: d.minimumTouchTarget,
                child: TextButton(
                  key: ValueKey('capture-step-$i'),
                  onPressed: busy ? null : () => onSelected(i),
                  style: TextButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                    backgroundColor: selected == i
                        ? colors.primary
                        : complete[i]
                        ? colors.primaryContainer
                        : colors.surfaceContainerLowest,
                    foregroundColor: selected == i ? colors.onPrimary : colors.primary,
                    side: BorderSide(color: selected == i ? colors.primary : colors.outlineVariant),
                  ),
                  child: complete[i] && selected != i
                      ? const Icon(Icons.check_rounded)
                      : Text(
                          '${i + 1}',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: selected == i ? colors.onPrimary : colors.primary,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
