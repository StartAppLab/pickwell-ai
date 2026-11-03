import '../../domain/entities/analysis_entity.dart';
import '../../domain/entities/label_photo.dart';
import 'catalog_model.dart';
import 'quota_model.dart';
import '../../domain/entities/quota_snapshot.dart';

class AnalysisModel {
  static AnalysisResult parse(Map<String, dynamic> json, String barcode) {
    final quota = QuotaModel.parse(json, QuotaMetric.aiAnalysis);
    final status = json['status'];
    if (['ready', 'already_exists'].contains(status)) {
      final product = CatalogModel.parse({...json, 'status': 'ready'}, barcode).product!;
      return AnalysisResult(AnalysisPhase.ready, product: product, quota: quota);
    }
    if (json['barcode'] != null && json['barcode'] != barcode) throw const FormatException();
    if (status == 'auth_required') return const AnalysisResult(AnalysisPhase.authRequired);
    if (status == 'needs_retake') {
      final targets = json['retake'];
      if (targets is! List ||
          targets.isEmpty ||
          !targets.every((e) => ['nutrition', 'ingredients'].contains(e))) {
        throw const FormatException();
      }
      return AnalysisResult(
        AnalysisPhase.retake,
        quota: quota,
        retake: targets
            .map((v) => v == 'nutrition' ? LabelKind.nutrition : LabelKind.ingredients)
            .toSet(),
      );
    }
    if (status == 'processing') {
      final blocked =
          json['retryable'] == false || json['stage'] == 'provider_reconciliation_required';
      final after = json['retry_after_seconds'];
      return AnalysisResult(
        blocked ? AnalysisPhase.blocked : AnalysisPhase.processing,
        quota: quota,
        error: blocked ? 'provider_outcome_unknown' : null,
        retryable: !blocked,
        retryAfterSeconds: after is int ? after.clamp(1, 60) : 4,
      );
    }
    if (['rate_limited', 'quota_exceeded'].contains(status)) {
      return AnalysisResult(
        AnalysisPhase.denied,
        error: status as String,
        quota: quota,
        retryable: status == 'quota_exceeded',
      );
    }
    final error = json['error'];
    if (['unauthorized', 'email_unverified', 'verified_identity_required'].contains(error)) {
      return const AnalysisResult(AnalysisPhase.authRequired);
    }
    if (status == 'analysis_failed') {
      return AnalysisResult(AnalysisPhase.blocked, error: 'analysis_failed', quota: quota);
    }
    if (status == 'error') {
      if ([
        'rate_limited',
        'quota_exceeded',
        'service_budget_exceeded',
        'concurrency_limited',
        'provider_attempt_limit',
        'retry_denied',
      ].contains(error)) {
        return AnalysisResult(AnalysisPhase.denied, quota: quota, error: error as String?);
      }
      if (error == 'inference_disabled' ||
          error == 'idempotency_conflict' ||
          error == 'invalid_input') {
        return AnalysisResult(
          AnalysisPhase.blocked,
          quota: quota,
          error: error == 'inference_disabled' ? 'inference_disabled' : 'analysis_failed',
          retryable: error == 'inference_disabled',
        );
      }
      return AnalysisResult(
        AnalysisPhase.error,
        quota: quota,
        error: 'service_unavailable',
        retryable: true,
      );
    }
    throw const FormatException();
  }
}
