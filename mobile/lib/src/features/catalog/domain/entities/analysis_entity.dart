import 'retake_detail.dart';
import 'catalog_entity.dart';
import 'quota_snapshot.dart';
import 'label_photo.dart';

enum AnalysisPhase {
  idle,
  authenticating,
  submitting,
  processing,
  review,
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
  final LabelPhoto front, nutrition, ingredients;
  const AnalysisRequest({
    required this.barcode,
    required this.requestId,
    required this.front,
    required this.nutrition,
    required this.ingredients,
  });
}

class AnalysisResult {
  final AnalysisPhase phase;
  final ProductRecord? product;
  final QuotaSnapshot? quota;
  final Set<LabelKind> retake;
  final List<RetakeDetail> retakeDetails;
  final String? error;
  final bool retryable;
  final bool restartAllowed;
  final bool canReanalyzeSaved;
  final int retryAfterSeconds;
  final DateTime? retryAt, reviewExpiresAt;
  const AnalysisResult(
    this.phase, {
    this.product,
    this.quota,
    this.retake = const {},
    this.retakeDetails = const [],
    this.error,
    this.retryable = false,
    this.restartAllowed = false,
    this.canReanalyzeSaved = false,
    this.retryAfterSeconds = 4,
    this.retryAt,
    this.reviewExpiresAt,
  });
}
