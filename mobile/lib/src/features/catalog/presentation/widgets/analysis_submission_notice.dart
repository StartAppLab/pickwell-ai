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
  final VoidCallback? retry, cleanup;
  const AnalysisSubmissionNotice({
    super.key,
    required this.state,
    this.retry,
    this.cleanup,
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
        state.error == 'quota_exceeded' ? l.pkAnalysisDenied : l.pkQuotaRateLimited,
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
              Text(message),
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
                  Text(
                    '${l.pkRetake}: ${target == LabelKind.nutrition ? l.pkNutrition : l.pkIngredients}',
                  ),
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
