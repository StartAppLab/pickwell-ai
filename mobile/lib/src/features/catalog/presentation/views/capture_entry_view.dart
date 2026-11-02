import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/_core.dart';
import '../../domain/entities/label_photo.dart';
import '../blocs/catalog/label_capture_cubit.dart';
import '../widgets/label_photo_card.dart';

class CaptureEntryView extends StatelessWidget {
  final String barcode;
  const CaptureEntryView({super.key, required this.barcode});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: SafeArea(
      child: BlocBuilder<LabelCaptureCubit, LabelCaptureState>(
        builder: (context, state) {
          final l = context.l10n;
          final d = context.themeData.dimensionsData;
          final draft = context.read<LabelCaptureCubit>();
          final next = state.nutrition == null ? LabelKind.nutrition : LabelKind.ingredients;
          final error = switch (state.error) {
            null => null,
            'image_size' => l.pkCaptureSizeError,
            'image_format' || 'image_decode' => l.pkCaptureFormatError,
            'image_dimensions' => l.pkCaptureDimensionsError,
            'draft_expired' => l.pkCaptureExpired,
            'cleanup' => l.pkCaptureCleanupError,
            _ => l.pkCaptureCameraError,
          };
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: d.maxWidth),
              child: ListView(
                padding: context.themeData.edgeInsetsData.pagePadding,
                children: [
                  Text(l.pkUnknown, style: context.textTheme.headlineSmall),
                  Gap(d.spacingSm),
                  Text(state.barcode ?? barcode),
                  Gap(d.spacingLg),
                  Wrap(
                    spacing: d.spacingXs,
                    runSpacing: d.spacingXs,
                    children: [
                      Chip(label: Text(l.pkCaptureStepBarcode)),
                      Chip(
                        label: Text(
                          '${l.pkCaptureStepNutrition}${state.nutrition != null ? ' ✓' : ''}',
                        ),
                      ),
                      Chip(
                        label: Text(
                          '${l.pkCaptureStepIngredients}${state.ingredients != null ? ' ✓' : ''}',
                        ),
                      ),
                    ],
                  ),
                  Gap(d.spacingSm),
                  LinearProgressIndicator(
                    value: (1 + state.count) / 3,
                    semanticsLabel: l.pkCaptureProgress,
                  ),
                  Gap(d.spacingLg),
                  if (!state.ready) ...[
                    Text(next == LabelKind.nutrition ? l.pkNutritionHint : l.pkIngredientsHint),
                    Gap(d.spacingMd),
                  ],
                  if (state.nutrition case final photo?)
                    LabelPhotoCard(
                      kind: LabelKind.nutrition,
                      photo: photo,
                      busy: state.busy,
                      onRetake: () => draft.capture(LabelKind.nutrition),
                    ),
                  if (state.ingredients case final photo?)
                    LabelPhotoCard(
                      kind: LabelKind.ingredients,
                      photo: photo,
                      busy: state.busy,
                      onRetake: () => draft.capture(LabelKind.ingredients),
                    ),
                  if (error != null) ...[
                    Gap(d.spacingMd),
                    Semantics(liveRegion: true, child: Text(error)),
                  ],
                  if (state.busy) ...[
                    Gap(d.spacingMd),
                    const Center(child: CircularProgressIndicator()),
                  ],
                  if (!state.ready)
                    FilledButton(
                      onPressed: state.busy ? null : () => draft.capture(next),
                      child: Text(
                        '${l.pkCapture}: ${next == LabelKind.nutrition ? l.pkNutrition : l.pkIngredients}',
                      ),
                    ),
                  if (state.ready) ...[
                    Gap(d.spacingMd),
                    Text(l.pkLabelsReady, style: context.textTheme.titleLarge),
                    Text(l.pkCaptureReviewHint),
                    Gap(d.spacingSm),
                    Text(l.pkCaptureSubmissionPending),
                    Gap(d.spacingMd),
                    FilledButton(
                      onPressed: state.busy
                          ? null
                          : () async {
                              final authorized = await context.push<bool>(
                                '/capture-auth/${state.barcode}',
                              );
                              if (context.mounted && authorized == true) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text(l.pkAnalysisPending)));
                              }
                            },
                      child: Text(l.pkAnalyzeProduct),
                    ),
                  ],
                  Gap(d.spacingMd),
                  Text(l.pkCapturePrivacy),
                  TextButton(
                    onPressed: state.busy ? null : () => draft.discard(),
                    child: Text(l.pkDiscardPhotos),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
