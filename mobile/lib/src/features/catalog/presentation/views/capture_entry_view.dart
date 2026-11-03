import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/_core.dart';
import '../../../../config/app_session.dart';
import '../../domain/entities/label_photo.dart';
import '../../domain/entities/quota_snapshot.dart';
import '../widgets/quota_status.dart';
import '../../domain/entities/analysis_entity.dart';
import '../blocs/catalog/analysis_submission_cubit.dart';
import '../widgets/analysis_submission_notice.dart';
import '../blocs/catalog/label_capture_cubit.dart';
import '../widgets/label_photo_card.dart';

class CaptureEntryView extends StatelessWidget {
  final String barcode;
  final AppSession? session;
  final QuotaSnapshot? entryQuota;
  const CaptureEntryView({super.key, required this.barcode, this.session, this.entryQuota});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: SafeArea(
      child: BlocConsumer<AnalysisSubmissionCubit, AnalysisSubmissionState>(
        listener: (context, submission) {
          if (submission.phase == AnalysisPhase.ready &&
              submission.barcode == barcode &&
              context.mounted) {
            context.replace('/product/$barcode', extra: submission.result?.quota);
          }
        },
        builder: (context, submission) => BlocBuilder<LabelCaptureCubit, LabelCaptureState>(
          builder: (context, state) {
            final l = context.l10n;
            final d = context.themeData.dimensionsData;
            final draft = context.read<LabelCaptureCubit>();
            final sender = context.read<AnalysisSubmissionCubit>();
            final busy =
                state.busy ||
                submission.busy ||
                (submission.phase == AnalysisPhase.cleanupFailed && submission.barcode == barcode);
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
                    if (entryQuota != null) QuotaStatus(snapshot: entryQuota, session: session),
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
                        busy: busy,
                        onRetake: () => draft.capture(LabelKind.nutrition),
                      ),
                    if (state.ingredients case final photo?)
                      LabelPhotoCard(
                        kind: LabelKind.ingredients,
                        photo: photo,
                        busy: busy,
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
                        onPressed: busy ? null : () => draft.capture(next),
                        child: Text(
                          '${l.pkCapture}: ${next == LabelKind.nutrition ? l.pkNutrition : l.pkIngredients}',
                        ),
                      ),
                    if (state.ready) ...[
                      Gap(d.spacingMd),
                      Text(l.pkLabelsReady, style: context.textTheme.titleLarge),
                      Text(l.pkCaptureReviewHint),
                      Gap(d.spacingSm),
                      Text(l.pkAnalysisSubmitHint),
                      Gap(d.spacingMd),
                      FilledButton(
                        onPressed: busy
                            ? null
                            : !sender.canStart
                            ? null
                            : () async {
                                if (!sender.beginAuthorization()) return;
                                var authorized = false;
                                try {
                                  authorized =
                                      await context.push<bool>('/capture-auth/${state.barcode}') ==
                                      true;
                                } finally {
                                  await sender.finishAuthorization(authorized);
                                }
                              },
                        child: Text(l.pkAnalyzeProduct),
                      ),
                    ],
                    if (submission.barcode == barcode &&
                        (sender.current ||
                            submission.phase == AnalysisPhase.cleanupFailed ||
                            submission.phase == AnalysisPhase.ready))
                      AnalysisSubmissionNotice(
                        state: submission,
                        session: session,
                        retry: sender.retryAvailable ? () => sender.retry() : null,
                        cleanup: submission.phase == AnalysisPhase.cleanupFailed
                            ? () => sender.retryCleanup()
                            : null,
                      ),
                    Gap(d.spacingMd),
                    Text(l.pkCapturePrivacy),
                    TextButton(
                      onPressed: busy ? null : () => draft.discard(),
                      child: Text(l.pkDiscardPhotos),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}
