enum LabelKind { front, nutrition, ingredients }

// App-private working photo. Only the expiring pending draft may persist a copy;
// never store this in published recents or account/cloud history.
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
