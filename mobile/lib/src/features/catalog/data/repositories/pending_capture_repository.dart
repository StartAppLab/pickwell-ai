import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/pending_capture.dart';
import '../../domain/entities/label_photo.dart';
import '../../domain/entities/catalog_entity.dart';
import '../../domain/repositories/pending_capture_repository.dart';
import '../data_sources/services/scanner_media_service.dart';

@LazySingleton(as: PendingCaptureRepository)
class PendingCaptureRepositoryImpl implements PendingCaptureRepository {
  final ScannerMediaService media;
  final Directory? _testRoot;
  @factoryMethod
  PendingCaptureRepositoryImpl(this.media) : _testRoot = null;
  PendingCaptureRepositoryImpl.testing(this.media, Directory root) : _testRoot = root;
  Future<Directory> _root() async {
    final base = _testRoot ?? await getApplicationCacheDirectory();
    final dir = Directory('${base.path}/pickwell_pending_analysis_v1');
    await dir.create(recursive: true);
    return dir;
  }

  Future<void> _tail = Future.value();
  Future<T> _serial<T>(Future<T> Function() action) {
    final next = _tail.then((_) => action());
    _tail = next.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return next;
  }

  // Legacy single-draft files are moved atomically into their barcode namespace.
  Future<void> _migrate(Directory root) async {
    final legacy = File('${root.path}/manifest.json');
    if (!await legacy.exists()) {
      await for (final entry in root.list(followLinks: false)) {
        if (entry is! Directory) await entry.delete();
      }
      return;
    }
    try {
      if (await legacy.length() > 4096) throw FormatException();
      final j = jsonDecode(await legacy.readAsString()) as Map;
      final code = normalizeGtin(j['barcode'] as String), dir = Directory('${root.path}/$code');
      final kind = await FileSystemEntity.type(dir.path, followLinks: false);
      if (kind != FileSystemEntityType.notFound && kind != FileSystemEntityType.directory) {
        throw FormatException();
      }
      await dir.create();
      if (!await File('${dir.path}/manifest.json').exists()) {
        for (final kind in ['nutrition', 'ingredients']) {
          if (j[kind] == null) continue;
          final name = (j[kind] as Map)['file'] as String;
          if (!RegExp(r'^(nutrition|ingredients)-[0-9]+\.(png|jpg)$').hasMatch(name)) {
            throw FormatException();
          }
          final path = '${root.path}/$name';
          if (await FileSystemEntity.type(path, followLinks: false) != FileSystemEntityType.file) {
            throw FormatException();
          }
          await File(path).copy('${dir.path}/$name');
        }
        final temp = await legacy.copy('${dir.path}/manifest.tmp');
        await temp.rename('${dir.path}/manifest.json');
      }
    } catch (error) {
      // Transient I/O failure must retain the legacy manifest for a later retry.
      if (error is! FormatException && error is! TypeError) rethrow;
    }
    await for (final entry in root.list(followLinks: false)) {
      if (entry is! Directory) await entry.delete();
    }
  }

  Future<void> _prune(Directory root) async {
    await for (final entry in root.list(followLinks: false)) {
      if (entry is! Directory) continue;
      if (!RegExp(
        r'^[0-9]{14}$',
      ).hasMatch(entry.uri.pathSegments.where((s) => s.isNotEmpty).last)) {
        await entry.delete(recursive: true);
        continue;
      }
      try {
        final manifest = File('${entry.path}/manifest.json');
        if (!await manifest.exists() || await manifest.length() > 4096) throw FormatException();
        final j = jsonDecode(await manifest.readAsString()) as Map;
        final expiry = DateTime.parse(j['expires_at'] as String).toUtc();
        if (!expiry.isAfter(DateTime.now().toUtc())) throw FormatException();
      } catch (error) {
        if (error is FileSystemException) rethrow;
        await entry.delete(recursive: true);
      }
    }
  }

  @override
  Future<void> clear([String? barcode]) => _serial(() async {
    final root = await _root();
    await _migrate(root);
    if (barcode != null) {
      final dir = Directory('${root.path}/${normalizeGtin(barcode)}');
      if (await dir.exists()) await dir.delete(recursive: true);
    } else {
      await for (final entry in root.list(followLinks: false)) {
        await entry.delete(recursive: true);
      }
    }
  });
  @override
  Future<void> save(PendingCapture draft) => _serial(() async {
    if (!draft.expiresAt.isAfter(DateTime.now().toUtc())) throw StateError('draft_expired');
    final base = await _root();
    await _migrate(base);
    await _prune(base);
    final code = normalizeGtin(draft.barcode), root = Directory('${base.path}/$code');
    final type = await FileSystemEntity.type(root.path, followLinks: false);
    if (type != FileSystemEntityType.notFound && type != FileSystemEntityType.directory) {
      throw FormatException();
    }
    if (!await root.exists()) {
      var count = 0;
      await for (final e in base.list(followLinks: false)) {
        if (e is Directory) count++;
      }
      if (count >= PendingCapture.maxDrafts) throw StateError('draft_limit');
      await root.create();
    }
    final keep = <String>{'manifest.json'};
    Future<Object?> photo(LabelPhoto? p, String kind) async {
      if (p == null) return null;
      if (p.byteLength <= 0 || p.byteLength > ScannerMediaService.maxLabelBytes) {
        throw StateError('image_size');
      }
      final name =
          '$kind-${p.capturedAt.microsecondsSinceEpoch}.${p.mimeType == 'image/png' ? 'png' : 'jpg'}';
      final source = File(p.path);
      if (await source.length() != p.byteLength) throw StateError('image_size');
      final destination = File('${root.path}/$name');
      if (source.path != destination.path) await source.copy(destination.path);
      keep.add(name);
      return {'file': name, 'captured_at': p.capturedAt.toUtc().toIso8601String()};
    }

    final value = {
      'v': 1,
      'barcode': draft.barcode,
      'request_id': draft.requestId,
      'expires_at': draft.expiresAt.toUtc().toIso8601String(),
      'attempts': draft.attempts,
      'nutrition': await photo(draft.nutrition, 'nutrition'),
      'ingredients': await photo(draft.ingredients, 'ingredients'),
    };
    final temp = File('${root.path}/manifest.tmp');
    await temp.writeAsString(jsonEncode(value), flush: true);
    await temp.rename('${root.path}/manifest.json');
    await for (final entry in root.list(followLinks: false)) {
      if (!keep.contains(entry.uri.pathSegments.last)) await entry.delete(recursive: true);
    }
  });
  @override
  Future<PendingCapture?> load([String? barcode]) async {
    final all = await loadAll();
    if (barcode == null) return all.isEmpty ? null : all.first;
    final code = normalizeGtin(barcode);
    for (final item in all) {
      if (item.barcode == code) return item;
    }
    return null;
  }

  @override
  Future<List<PendingCapture>> loadAll() => _serial(() async {
    final root = await _root();
    await _migrate(root);
    await _prune(root);
    final result = <PendingCapture>[];
    await for (final dir in root.list(followLinks: false)) {
      if (dir is! Directory) continue;
      final name = dir.uri.pathSegments.where((s) => s.isNotEmpty).last;
      if (!RegExp(r'^[0-9]{14}$').hasMatch(name)) continue;
      final saved = await _read(dir);
      if (saved != null && saved.barcode == name) {
        result.add(saved);
      } else if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    }
    result.sort((a, b) => b.expiresAt.compareTo(a.expiresAt));
    return result;
  });
  Future<PendingCapture?> _read(Directory root) async {
    final manifest = File('${root.path}/manifest.json');
    if (!await manifest.exists()) return null;
    final restored = <LabelPhoto>[];
    try {
      if (await manifest.length() > 4096) throw FormatException();
      final j = jsonDecode(await manifest.readAsString()) as Map;
      final expires = DateTime.parse(j['expires_at'] as String).toUtc();
      if (j['v'] != 1 ||
          !expires.isAfter(DateTime.now().toUtc()) ||
          expires.difference(DateTime.now().toUtc()) > const Duration(hours: 24)) {
        throw FormatException();
      }
      final code = normalizeGtin(j['barcode'] as String), key = j['request_id'] as String;
      if (!RegExp(r'^[a-f0-9-]{36}$').hasMatch(key) ||
          j['attempts'] is! int ||
          j['attempts'] < 0 ||
          j['attempts'] > 3) {
        throw FormatException();
      }
      Future<LabelPhoto?> photo(Object? value) async {
        if (value == null) return null;
        final p = value as Map, name = p['file'] as String;
        if (!RegExp(r'^(nutrition|ingredients)-[0-9]+\.(png|jpg)$').hasMatch(name)) {
          throw FormatException();
        }
        final path = '${root.path}/$name';
        if (await FileSystemEntity.type(path, followLinks: false) != FileSystemEntityType.file) {
          throw FormatException();
        }
        final validated = await media.validateAndStoreLabel(XFile(path));
        final result = LabelPhoto(
          path: validated.path,
          mimeType: validated.mimeType,
          byteLength: validated.byteLength,
          width: validated.width,
          height: validated.height,
          capturedAt: DateTime.parse(p['captured_at'] as String).toUtc(),
        );
        restored.add(result);
        return result;
      }

      final n = await photo(j['nutrition']), i = await photo(j['ingredients']);
      return PendingCapture(
        barcode: code,
        requestId: key,
        expiresAt: expires,
        nutrition: n,
        ingredients: i,
        attempts: j['attempts'],
      );
    } catch (error) {
      for (final p in restored) {
        await media.discardLabel(p);
      }
      if (error is FileSystemException) rethrow;
      await for (final entry in root.list(followLinks: false)) {
        await entry.delete(recursive: true);
      }
      return null;
    }
  }
}
