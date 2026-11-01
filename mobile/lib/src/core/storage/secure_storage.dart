import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../_core.dart';

class SecureStorageKeys {
  static const accessToken = 'ACCESS_TOKEN';
}

@lazySingleton
abstract class SecureStorage extends Storage {
  @factoryMethod
  const factory SecureStorage({required FlutterSecureStorage storage}) = _SecureStorageImpl;
}

class _SecureStorageImpl implements SecureStorage {
  final FlutterSecureStorage storage;

  const _SecureStorageImpl({required this.storage});

  @override
  Future<bool?> write(String key, Object data) async {
    try {
      await storage.write(key: key, value: data as String);
      return true;
    } on Exception catch (e) {
      AppLogger.logException(e);
    }
    return false;
  }

  @override
  Future<Object?> read(String key) async {
    try {
      return await storage.read(key: key);
    } on Exception catch (e) {
      AppLogger.logException(e);
    }
    return null;
  }

  @override
  Future<bool?> remove(String key) async {
    try {
      await storage.delete(key: key);
      return true;
    } on Exception catch (e) {
      AppLogger.logException(e);
    }
    return false;
  }

  @override
  Future<bool?> removeAll() async {
    try {
      await storage.deleteAll();
      return true;
    } on Exception catch (e) {
      AppLogger.logException(e);
    }
    return false;
  }
}
