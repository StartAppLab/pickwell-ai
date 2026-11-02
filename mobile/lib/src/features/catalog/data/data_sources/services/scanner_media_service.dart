import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ScannerMediaService {
  final ImagePicker picker = ImagePicker();
  Future<String?> galleryBarcode() async =>
      (await picker.pickImage(source: ImageSource.gallery, requestFullMetadata: false))?.path;
  Future<Uint8List?> captureLabel() async {
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 2400,
      imageQuality: 90,
      requestFullMetadata: false,
    );
    if (photo == null) return null;
    try {
      return await photo.readAsBytes();
    } finally {
      final file = File(photo.path);
      if (await file.exists()) await file.delete();
    }
  }
}
