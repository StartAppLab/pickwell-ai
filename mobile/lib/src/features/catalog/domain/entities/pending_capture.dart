import 'label_photo.dart';

// A device-private, expiring work-in-progress; never a published/offline product.
class PendingCapture {
  static const maxDrafts = 5;
  final bool saved;
  final String barcode, requestId;
  final DateTime expiresAt;
  final LabelPhoto? front, nutrition, ingredients;
  final int attempts;
  const PendingCapture({
    required this.barcode,
    required this.requestId,
    required this.expiresAt,
    this.front,
    this.nutrition,
    this.ingredients,
    this.attempts = 0,
    this.saved = true,
  });
}
