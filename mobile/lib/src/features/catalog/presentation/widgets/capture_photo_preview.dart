import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../../domain/entities/label_photo.dart';

class CapturePhotoPreview extends StatelessWidget {
  final LabelPhoto? photo;
  final String label;
  final bool compact;
  const CapturePhotoPreview({
    super.key,
    required this.photo,
    required this.label,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final d = context.themeData.dimensionsData, colors = context.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(compact ? d.nestedCornerRadius : d.heroCornerRadius),
        border: Border.all(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: photo == null
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(d.paddingMd),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIcon(
                      icon: HugeIcons.strokeRoundedCamera01,
                      size: compact ? d.iconSize : 48,
                      color: colors.onSurfaceVariant,
                    ),
                    if (!compact) ...[
                      Gap(d.spacingSm),
                      Text(
                        context.l10n.pkCaptureEmptyPhoto,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          : Image.file(
              File(photo!.path),
              fit: BoxFit.contain,
              cacheWidth: 600,
              semanticLabel: label,
              errorBuilder: (_, _, _) => Center(
                child: Padding(
                  padding: EdgeInsets.all(d.paddingSm),
                  child: compact
                      ? Tooltip(
                          message: context.l10n.pkCapturePreviewMissing,
                          child: AppIcon(
                            icon: Icons.image_not_supported_outlined,
                            color: colors.onSurfaceVariant,
                          ),
                        )
                      : Text(
                          context.l10n.pkCapturePreviewMissing,
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodySmall,
                        ),
                ),
              ),
            ),
    );
  }
}
