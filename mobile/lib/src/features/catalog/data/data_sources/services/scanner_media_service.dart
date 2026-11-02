import 'dart:io';
import 'dart:ui' as ui;
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/label_photo.dart';

class LabelMediaException implements Exception {
  final String code;
  const LabelMediaException(this.code);
}

@lazySingleton
class ScannerMediaService {
  static const maxLabelBytes = 5 * 1024 * 1024;
  static const maxLabelDimension = 2400;
  static const _prefix = 'pickwell_label_draft_';
  final ImagePicker picker;
  ScannerMediaService() : picker = ImagePicker();
  ScannerMediaService.withPicker(this.picker);
  Future<Directory>? _directory;
  int _serial = 0;
  Future<String?> galleryBarcode() async =>
      (await picker.pickImage(source: ImageSource.gallery, requestFullMetadata: false))?.path;

  Future<void> prepareLabels() async {
    try {
      await (_directory ??= _prepare());
    } catch (_) {
      _directory = null; // A transient cache failure must be retryable.
      rethrow;
    }
  }

  Future<Directory> _prepare() async {
    // systemTemp is app-private cache on supported iOS/Android targets. Remove
    // prior-process drafts; no draft is restored after process death.
    final root = Directory.systemTemp;
    await for (final entry in root.list(followLinks: false)) {
      if (entry is Directory && entry.path.split(Platform.pathSeparator).last.startsWith(_prefix)) {
        await entry.delete(recursive: true);
      }
    }
    return root.createTemp(_prefix);
  }

  Future<LabelPhoto?> captureLabel() async {
    await prepareLabels();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: maxLabelDimension.toDouble(),
      maxHeight: maxLabelDimension.toDouble(),
      imageQuality: 90,
      requestFullMetadata: false,
    );
    if (photo == null) return null;
    LabelPhoto? prepared;
    try {
      prepared = await validateAndStoreLabel(photo);
      return prepared;
    } finally {
      // Camera picker output is temporary, unlike user-owned gallery originals.
      try {
        final file = File(photo.path);
        if (await file.exists()) await file.delete();
      } catch (_) {
        if (prepared != null) await discardLabel(prepared);
        rethrow;
      }
    }
  }

  // Public for targeted validation with local non-sensitive files. Camera callers
  // only; no arbitrary URL, client MIME or extension is trusted.
  Future<LabelPhoto> validateAndStoreLabel(XFile photo) async {
    final length = await photo.length();
    if (length <= 0 || length > maxLabelBytes) throw const LabelMediaException('image_size');
    final bytes = await photo.readAsBytes();
    if (bytes.length != length || bytes.length > maxLabelBytes) {
      throw const LabelMediaException('image_size');
    }
    final png =
        bytes.length >= 8 &&
        bytes[0] == 137 &&
        bytes[1] == 80 &&
        bytes[2] == 78 &&
        bytes[3] == 71 &&
        bytes[4] == 13 &&
        bytes[5] == 10 &&
        bytes[6] == 26 &&
        bytes[7] == 10;
    final jpeg = bytes.length >= 3 && bytes[0] == 255 && bytes[1] == 216 && bytes[2] == 255;
    if (!png && !jpeg) throw const LabelMediaException('image_format');
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    try {
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      if (descriptor.width <= 0 ||
          descriptor.height <= 0 ||
          descriptor.width > maxLabelDimension ||
          descriptor.height > maxLabelDimension) {
        throw const LabelMediaException('image_dimensions');
      }
      codec = await descriptor.instantiateCodec();
      final frame = await codec.getNextFrame();
      frame.image.dispose(); // Require decodable pixels, not just a valid header.
      final directory = await (_directory ??= _prepare());
      final file = File(
        '${directory.path}/${DateTime.now().microsecondsSinceEpoch}-${_serial++}.${png ? 'png' : 'jpg'}',
      );
      try {
        await file.writeAsBytes(bytes, flush: true);
      } catch (_) {
        if (await file.exists()) await file.delete();
        rethrow;
      }
      return LabelPhoto(
        path: file.path,
        mimeType: png ? 'image/png' : 'image/jpeg',
        byteLength: length,
        width: descriptor.width,
        height: descriptor.height,
        capturedAt: DateTime.now().toUtc(),
      );
    } on LabelMediaException {
      rethrow;
    } catch (_) {
      throw const LabelMediaException('image_decode');
    } finally {
      codec?.dispose();
      descriptor?.dispose();
      buffer.dispose();
    }
  }

  Future<void> discardLabel(LabelPhoto photo) async {
    final directory = _directory;
    if (directory == null) return;
    final root = await directory;
    // Only files owned by this service's private draft directory can be deleted.
    if (File(photo.path).parent.path != root.path) return;
    final file = File(photo.path);
    if (await file.exists()) await file.delete();
  }
}
