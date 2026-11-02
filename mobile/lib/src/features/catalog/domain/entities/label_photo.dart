enum LabelKind { nutrition, ingredients }

// Transient, app-private file reference. Never persist this in recents/account data.
class LabelPhoto {
  final String path, mimeType;
  final int byteLength, width, height;
  final DateTime capturedAt;
  const LabelPhoto({
    required this.path,
    required this.mimeType,
    required this.byteLength,
    required this.width,
    required this.height,
    required this.capturedAt,
  });
}
