import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/_core.dart';
import '../../domain/entities/label_photo.dart';
import 'capture_photo_preview.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../app/app.dart';

class LabelPhotoCard extends StatelessWidget {
  final LabelKind kind;
  final LabelPhoto photo;
  final bool busy;
  final VoidCallback onRetake;
  const LabelPhotoCard({
    super.key,
    required this.kind,
    required this.photo,
    required this.busy,
    required this.onRetake,
  });
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final d = context.themeData.dimensionsData;
    final title = switch (kind) {
      LabelKind.front => l.pkFrontPackaging,
      LabelKind.nutrition => l.pkNutrition,
      LabelKind.ingredients => l.pkIngredients,
    };
    return Card(
      elevation: 0,
      color: context.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(d.cardCornerRadius),
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      margin: EdgeInsets.only(bottom: d.spacingSm),
      child: Padding(
        padding: EdgeInsets.all(d.paddingMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 96,
              child: CapturePhotoPreview(photo: photo, label: title, compact: true),
            ),
            Gap(d.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Gap(d.spacingXxs),
                  Tooltip(
                    message: '${l.pkRetake}: $title',
                    child: TextButton.icon(
                      onPressed: busy ? null : onRetake,
                      icon: const AppIcon(icon: HugeIcons.strokeRoundedCamera01),
                      label: Text(l.pkRetake),
                    ),
                  ),
                ],
              ),
            ),
            Gap(d.spacingXs),
            Icon(
              Icons.check_circle_rounded,
              color: context.colorScheme.secondary,
              semanticLabel: l.pkCapturePhotoCaptured,
            ),
          ],
        ),
      ),
    );
  }
}
