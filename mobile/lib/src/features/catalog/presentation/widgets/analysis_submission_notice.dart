import 'retake_diagnostic.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/_core.dart';
import '../../../../config/app_session.dart';
import 'quota_status.dart';
import '../../domain/_domain.dart';
import '../blocs/catalog/analysis_submission_cubit.dart';

class AnalysisSubmissionNotice extends StatelessWidget {
  final AnalysisSubmissionState state;
  final AppSession? session;
  final VoidCallback? retry, cleanup, reanalyzeSaved;
  const AnalysisSubmissionNotice({
    super.key,
    required this.state,
    this.retry,
    this.cleanup,
    this.reanalyzeSaved,
    this.session,
  });
  @override
  Widget build(BuildContext context) {
    final l = context.l10n, d = context.themeData.dimensionsData;
    final message = switch (state.phase) {
      AnalysisPhase.authenticating => l.pkAnalysisAuthenticating,
      AnalysisPhase.submitting => l.pkAnalysisSubmitting,
      AnalysisPhase.processing => l.pkAnalysisProcessing,
      AnalysisPhase.retake => l.pkAnalysisRetake,
      AnalysisPhase.authRequired => l.pkAnalysisAuthRequired,
      AnalysisPhase.denied =>
        state.error == 'service_budget_exceeded'
            ? l.pkAnalysisServiceDaily
            : state.error == 'quota_exceeded'
            ? l.pkAnalysisDenied
            : l.pkQuotaRateLimited,
      AnalysisPhase.cleanupFailed => l.pkCaptureCleanupError,
      AnalysisPhase.error => l.pkAnalysisUncertain,
      AnalysisPhase.blocked =>
        state.error == 'inference_disabled' ? l.pkAnalysisDisabled : l.pkAnalysisReview,
      _ => '',
    };
    if (message.isEmpty) return const SizedBox.shrink();
    return Semantics(
      liveRegion: true,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(d.paddingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(state.error == 'draft_save' ? l.pkPendingSaveError : message),
              if (state.phase == AnalysisPhase.denied && state.result?.retryAt != null)
                Text(
                  l.pkAnalysisRetryAt(
                    '${MaterialLocalizations.of(context).formatFullDate(state.result!.retryAt!.toLocal())} · ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(state.result!.retryAt!.toLocal()))} ${state.result!.retryAt!.toLocal().timeZoneName}',
                  ),
                ),
              if (state.phase == AnalysisPhase.denied &&
                  state.result?.retryAt == null &&
                  state.result?.retryable == true)
                Text(l.pkAnalysisTryAfter(state.result!.retryAfterSeconds)),
              if (state.result != null)
                QuotaStatus(
                  snapshot: state.result?.quota,
                  metric: QuotaMetric.aiAnalysis,
                  session: session,
                  rateLimited: state.error == 'rate_limited',
                  unavailable: state.phase == AnalysisPhase.authRequired,
                ),
              if (state.busy) ...[Gap(d.spacingSm), const LinearProgressIndicator()],
              if (state.phase == AnalysisPhase.retake)
                for (final target in state.result?.retake ?? <LabelKind>{})
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '${l.pkRetake}: ${target == LabelKind.front
                            ? l.pkFrontPackaging
                            : target == LabelKind.nutrition
                            ? l.pkNutrition
                            : l.pkIngredients}',
                      ),
                      if (state.result!.retakeDetails.where((d) => d.photo == target).isEmpty)
                        Text(l.pkRetakeCauseReasonUnavailable),
                      for (final detail in state.result!.retakeDetails.where(
                        (d) => d.photo == target,
                      ))
                        RetakeDiagnostic(detail: detail),
                    ],
                  ),
              if (reanalyzeSaved != null && state.result?.canReanalyzeSaved == true) ...[
                Text(l.pkRetakeRecheckCost),
                OutlinedButton(onPressed: reanalyzeSaved, child: Text(l.pkRetakeRecheckSaved)),
              ],
              if (retry != null) ...[
                Gap(d.spacingSm),
                OutlinedButton(onPressed: retry, child: Text(l.pkAnalysisCheckAgain)),
              ],
              if (cleanup != null) ...[
                Gap(d.spacingSm),
                OutlinedButton(onPressed: cleanup, child: Text(l.pkAnalysisRetryCleanup)),
              ],
              if (!state.canRetry &&
                  {AnalysisPhase.processing, AnalysisPhase.error}.contains(state.phase))
                Text(l.pkAnalysisRetryLimit),
            ],
          ),
        ),
      ),
    );
  }
}
