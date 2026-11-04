import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/_core.dart';
import '../../../../config/app_session.dart';
import '../../../app/app.dart';
import '../../domain/entities/label_photo.dart';
import '../../domain/entities/quota_snapshot.dart';
import '../../domain/entities/analysis_entity.dart';
import '../blocs/catalog/analysis_submission_cubit.dart';
import '../blocs/catalog/label_capture_cubit.dart';
import '../widgets/analysis_submission_notice.dart';
import '../widgets/capture_analysis_loading.dart';
import '../widgets/capture_page_scaffold.dart';
import '../widgets/capture_photo_preview.dart';
import '../widgets/capture_step_timeline.dart';
import '../widgets/label_photo_card.dart';
import '../widgets/product_not_found_content.dart';
import '../widgets/quota_status.dart';

class CaptureEntryView extends StatefulWidget {
  final String barcode;
  final AppSession? session;
  final QuotaSnapshot? entryQuota;
  const CaptureEntryView({super.key, required this.barcode, this.session, this.entryQuota});
  @override
  State<CaptureEntryView> createState() => _CaptureEntryViewState();
}

class _CaptureEntryViewState extends State<CaptureEntryView> {
  final _scroll = ScrollController();
  bool _adding = false;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _restorePresentation();
  }

  void _restorePresentation() {
    final state = context.read<LabelCaptureCubit>().state;
    _adding = state.barcode == widget.barcode && state.count > 0;
    _step = _firstMissing(state);
  }

  @override
  void didUpdateWidget(covariant CaptureEntryView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.barcode != widget.barcode) _restorePresentation();
  }

  int _firstMissing(LabelCaptureState state) => state.front == null
      ? 0
      : state.nutrition == null
      ? 1
      : state.ingredients == null
      ? 2
      : 3;

  LabelPhoto? _photo(LabelCaptureState state, LabelKind kind) => switch (kind) {
    LabelKind.front => state.front,
    LabelKind.nutrition => state.nutrition,
    LabelKind.ingredients => state.ingredients,
  };

  void _select(int step) {
    setState(() => _step = step);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) _scroll.jumpTo(0);
    });
  }

  Future<void> _capture(LabelKind kind, {bool returnToReview = false}) async {
    final draft = context.read<LabelCaptureCubit>();
    final previous = _photo(draft.state, kind);
    await draft.capture(kind);
    if (!mounted || draft.state.barcode != widget.barcode) return;
    final captured = _photo(draft.state, kind);
    // Advance only from a successful capture action, never from a rebuild,
    // visiting an existing photo, camera cancellation, or validation failure.
    if (captured != null && !identical(previous, captured) && draft.state.error == null) {
      _select(returnToReview ? 3 : kind.index + 1);
    }
  }

  Future<void> _discard() async {
    final draft = context.read<LabelCaptureCubit>();
    await draft.discard();
    if (mounted && draft.state.count == 0 && draft.state.error == null) _select(0);
  }

  Future<void> _analyze() async {
    final sender = context.read<AnalysisSubmissionCubit>();
    final draft = context.read<LabelCaptureCubit>();
    if (!sender.beginAuthorization()) return;
    var authorized = false;
    try {
      authorized = await context.push<bool>('/capture-auth/${draft.state.barcode}') == true;
    } finally {
      await sender.finishAuthorization(authorized);
    }
  }

  void _leave() => context.canPop() ? context.pop() : context.go('/home');

  void _back({bool analyzing = false}) {
    if (analyzing || !_adding) {
      _leave();
    } else if (_step > 0) {
      _select(_step - 1);
    } else {
      setState(() => _adding = false);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<AnalysisSubmissionCubit, AnalysisSubmissionState>(
    listener: (context, submission) {
      if (submission.phase == AnalysisPhase.privateReady &&
          submission.barcode == widget.barcode &&
          submission.result?.jobId != null) {
        context.replace('/analysis/${submission.result!.jobId}', extra: widget.barcode);
        return;
      }
      if (submission.phase == AnalysisPhase.ready && submission.barcode == widget.barcode) {
        context.replace('/product/${widget.barcode}', extra: submission.result?.quota);
      }
    },
    builder: (context, submission) => BlocBuilder<LabelCaptureCubit, LabelCaptureState>(
      builder: (context, state) {
        final l = context.l10n, d = context.themeData.dimensionsData;
        final draft = context.read<LabelCaptureCubit>();
        final sender = context.read<AnalysisSubmissionCubit>();
        final related = submission.barcode == widget.barcode;
        final busy =
            state.busy ||
            submission.busy ||
            (submission.phase == AnalysisPhase.cleanupFailed && related);
        final showNotice =
            related &&
            (sender.current ||
                submission.phase == AnalysisPhase.cleanupFailed ||
                submission.phase == AnalysisPhase.ready);
        final analyzing =
            showNotice &&
            {AnalysisPhase.submitting, AnalysisPhase.processing}.contains(submission.phase);
        final title = switch (_step) {
          0 => l.pkCaptureFrontTitle,
          1 => l.pkCaptureNutritionTitle,
          2 => l.pkCaptureIngredientsTitle,
          _ => l.pkCaptureReviewTitle,
        };
        final description = switch (_step) {
          0 => l.pkFrontPackagingHint,
          1 => l.pkNutritionHint,
          2 => l.pkIngredientsHint,
          _ => l.pkCaptureReviewHint,
        };
        final error = switch (state.error) {
          null => null,
          'image_size' => l.pkCaptureSizeError,
          'image_format' || 'image_decode' => l.pkCaptureFormatError,
          'image_dimensions' => l.pkCaptureDimensionsError,
          'draft_expired' => l.pkCaptureExpired,
          'cleanup' => l.pkCaptureCleanupError,
          'draft_save' => l.pkPendingSaveError,
          'draft_limit' => l.pkPendingLimit(LabelCaptureCubit.maxDrafts),
          _ => l.pkCaptureCameraError,
        };
        final kind = _step < 3 ? LabelKind.values[_step] : null;
        final selectedPhoto = kind == null ? null : _photo(state, kind);
        final prerequisite = _step > 0 && _step < 3 && state.front == null
            ? l.pkCaptureFrontFirst
            : _step == 2 && state.nutrition == null
            ? l.pkCaptureNutritionFirst
            : null;
        final notice = AnalysisSubmissionNotice(
          state: submission,
          session: widget.session,
          cancelReview: submission.phase == AnalysisPhase.review
              ? () => sender.cancelReview()
              : null,
          reanalyzeSaved: sender.current && submission.result?.canReanalyzeSaved == true
              ? () => sender.reanalyzeSaved()
              : null,
          retry: sender.retryAvailable ? () => sender.retry() : null,
          cleanup: submission.phase == AnalysisPhase.cleanupFailed
              ? () => sender.retryCleanup()
              : null,
        );
        return PopScope(
          canPop: !_adding || analyzing,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _back();
          },
          child: CapturePageScaffold(
            decorated: !_adding || analyzing,
            title: _adding && !analyzing ? l.pkAddProductTitle : null,
            onBack: () => _back(analyzing: analyzing),
            actions: state.count == 0
                ? null
                : [
                    PopupMenuButton<String>(
                      tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
                      onSelected: (_) => _discard(),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'discard',
                          enabled: !busy,
                          child: Text(l.pkPendingDelete),
                        ),
                      ],
                    ),
                  ],
            bottomActions: analyzing
                ? null
                : !_adding
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton.icon(
                        style: FilledButton.styleFrom(shape: const StadiumBorder()),
                        onPressed: busy
                            ? null
                            : () {
                                setState(() {
                                  _adding = true;
                                  _step = _firstMissing(state);
                                });
                              },
                        icon: const AppIcon(icon: HugeIcons.strokeRoundedCamera01),
                        label: Text(l.pkAddProduct),
                      ),
                      Gap(d.spacingSm),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
                        onPressed: busy ? null : () => context.replace('/scan'),
                        icon: const AppIcon(icon: HugeIcons.strokeRoundedBarcodeScan),
                        label: Text(l.pkScanAnother),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (kind != null) ...[
                        FilledButton.icon(
                          style: FilledButton.styleFrom(shape: const StadiumBorder()),
                          key: const ValueKey('capture-photo-action'),
                          onPressed: busy || prerequisite != null ? null : () => _capture(kind),
                          icon: const AppIcon(icon: HugeIcons.strokeRoundedCamera01),
                          label: Text(selectedPhoto == null ? l.pkCapture : l.pkRetake),
                        ),
                        if (selectedPhoto != null)
                          TextButton(
                            onPressed: busy ? null : () => _select(_step + 1),
                            child: Text(l.pkContinue),
                          ),
                      ] else
                        FilledButton.icon(
                          style: FilledButton.styleFrom(shape: const StadiumBorder()),
                          key: const ValueKey('capture-analyze-action'),
                          onPressed: busy || !state.ready || !sender.canStart ? null : _analyze,
                          icon: const AppIcon(icon: HugeIcons.strokeRoundedSparkles),
                          label: Text(l.pkAnalyzeProduct),
                        ),
                      if (state.count > 0)
                        TextButton(
                          onPressed: busy ? null : _discard,
                          child: Text(l.pkDiscardPhotos),
                        ),
                    ],
                  ),
            body: analyzing
                ? CaptureAnalysisLoading(
                    requestNotice: submission.phase == AnalysisPhase.processing ? notice : null,
                  )
                : !_adding
                ? ProductNotFoundContent(
                    barcode: state.barcode ?? widget.barcode,
                    additionalInformation: widget.entryQuota == null
                        ? null
                        : ExpansionTile(
                            title: Text(l.pkQuotaBarcode),
                            children: [
                              QuotaStatus(snapshot: widget.entryQuota, session: widget.session),
                            ],
                          ),
                  )
                : ListView(
                    controller: _scroll,
                    padding: context.themeData.edgeInsetsData.pagePadding,
                    children: [
                      CaptureStepTimeline(
                        selected: _step,
                        state: state,
                        busy: busy,
                        onSelected: _select,
                      ),
                      Gap(d.spacingLg),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colorScheme.primary,
                        ),
                      ),
                      Gap(d.spacingSm),
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Gap(d.spacingLg),
                      if (error != null) ...[
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            error,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.error,
                            ),
                          ),
                        ),
                        Gap(d.spacingMd),
                      ],
                      if (state.busy) ...[const LinearProgressIndicator(), Gap(d.spacingMd)],
                      if (draft.attempts >= 3) ...[Text(l.pkAnalysisRetryLimit), Gap(d.spacingMd)],
                      if (showNotice) ...[notice, Gap(d.spacingMd)],
                      if (kind != null) ...[
                        if (prerequisite != null) ...[
                          Text(prerequisite, textAlign: TextAlign.center),
                          Gap(d.spacingSm),
                        ],
                        AspectRatio(
                          aspectRatio: 4 / 3,
                          child: CapturePhotoPreview(
                            key: ValueKey('capture-preview-${kind.name}'),
                            photo: selectedPhoto,
                            label: title,
                          ),
                        ),
                      ] else ...[
                        for (final photoKind in LabelKind.values)
                          if (_photo(state, photoKind) case final photo?)
                            LabelPhotoCard(
                              kind: photoKind,
                              photo: photo,
                              busy: busy,
                              onRetake: () => _capture(photoKind, returnToReview: true),
                            )
                          else
                            OutlinedButton(
                              onPressed: busy ? null : () => _select(photoKind.index),
                              child: Text(
                                '${l.pkCapture}: ${switch (photoKind) {
                                  LabelKind.front => l.pkFrontPackaging,
                                  LabelKind.nutrition => l.pkNutrition,
                                  LabelKind.ingredients => l.pkIngredients,
                                }}',
                              ),
                            ),
                        Text(
                          l.pkAnalysisSubmitHint,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      Gap(d.spacingMd),
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        shape: const Border(),
                        collapsedShape: const Border(),
                        title: Text(l.pkCapturePhotoPrivacy, style: context.textTheme.bodyMedium),
                        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (state.count > 0)
                            Text(
                              state.saving
                                  ? l.pkPendingSaving
                                  : state.error == 'draft_save'
                                  ? l.pkPendingSaveError
                                  : l.pkPendingSaved,
                            ),
                          Gap(d.spacingXs),
                          Text(l.pkCapturePrivacy),
                        ],
                      ),
                      Gap(d.spacingLg),
                    ],
                  ),
          ),
        );
      },
    ),
  );
}
