import 'catalog_entity.dart';
import 'quota_snapshot.dart';
import 'label_photo.dart';

enum AnalysisPhase {
  idle,
  authenticating,
  submitting,
  processing,
  retake,
  authRequired,
  denied,
  error,
  blocked,
  cleanupFailed,
  ready,
}

class AnalysisRequest {
  final String barcode, requestId;
  final LabelPhoto nutrition, ingredients;
  const AnalysisRequest({
    required this.barcode,
    required this.requestId,
    required this.nutrition,
    required this.ingredients,
  });
}

class AnalysisResult {
  final AnalysisPhase phase;
  final ProductRecord? product;
  final QuotaSnapshot? quota;
  final Set<LabelKind> retake;
  final String? error;
  final bool retryable;
  final int retryAfterSeconds;
  const AnalysisResult(
    this.phase, {
    this.product,
    this.quota,
    this.retake = const {},
    this.error,
    this.retryable = false,
    this.retryAfterSeconds = 4,
  });
}
