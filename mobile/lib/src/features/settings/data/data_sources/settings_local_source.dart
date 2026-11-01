import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../../../core/_core.dart';
import '../models/_models.dart';

const settingsCacheKey = 'SETTINGS_CACHE_KEY';

@lazySingleton
abstract class SettingsLocalSource {
  @factoryMethod
  const factory SettingsLocalSource({required DataStorage storage}) = _SettingsLocalSourceImpl;

  Future<bool?> setCache(SettingsModel? model);

  Future<SettingsModel?> getCache();

  Future<bool?> removeCache();
}

class _SettingsLocalSourceImpl implements SettingsLocalSource {
  final DataStorage storage;

  const _SettingsLocalSourceImpl({required this.storage});

  @override
  Future<bool?> setCache(SettingsModel? model) =>
      runCacheOperation('SettingsLocalSource.setCache', () async {
        if (model == null) throw CacheException();
        return await storage.write(settingsCacheKey, jsonEncode(model.toJson()));
      });

  @override
  Future<SettingsModel?> getCache() => runCacheOperation('SettingsLocalSource.getCache', () async {
    final value = await storage.read(settingsCacheKey);
    if (value == null) throw CacheException();
    if (value is! String) throw const FormatException('Cached value is not JSON text');
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Cached value is not an object');
    }
    return SettingsModel.fromJson(decoded);
  });

  @override
  Future<bool?> removeCache() => runCacheOperation('SettingsLocalSource.removeCache', () async {
    return await storage.remove(settingsCacheKey);
  });
}
