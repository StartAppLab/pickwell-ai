import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/_core.dart';
import '../../domain/entities/label_photo.dart';

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
    final title = kind == LabelKind.nutrition ? l.pkNutrition : l.pkIngredients;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(d.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: context.textTheme.titleMedium),
            Gap(d.spacingSm),
            Image.file(
              File(photo.path),
              height: 180,
              fit: BoxFit.contain,
              cacheWidth: 600,
              semanticLabel: title,
              errorBuilder: (_, _, _) => Text(l.pkCapturePreviewMissing),
            ),
            Gap(d.spacingSm),
            TextButton.icon(
              onPressed: busy ? null : onRetake,
              icon: const Icon(Icons.camera_alt_outlined),
              label: Text('${l.pkRetake}: $title'),
            ),
          ],
        ),
      ),
    );
  }
}
