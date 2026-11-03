import '../entities/pending_capture.dart';

abstract class PendingCaptureRepository {
  Future<PendingCapture?> load([String? barcode]);
  Future<List<PendingCapture>> loadAll();
  Future<void> save(PendingCapture draft);
  Future<void> clear([String? barcode]);
}
