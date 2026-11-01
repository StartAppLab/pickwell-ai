import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../../../core/_core.dart';
import '../models/_models.dart';

const profileCacheKey = 'PROFILE_CACHE_KEY';

@lazySingleton
abstract class ProfileLocalSource {
  @factoryMethod
  const factory ProfileLocalSource({required DataStorage storage}) = _ProfileLocalSourceImpl;

  Future<bool?> setCache(ProfileModel? model);

  Future<ProfileModel?> getCache();

  Future<bool?> removeCache();
}

class _ProfileLocalSourceImpl implements ProfileLocalSource {
  final DataStorage storage;

  const _ProfileLocalSourceImpl({required this.storage});

  @override
  Future<bool?> setCache(ProfileModel? model) =>
      runCacheOperation('ProfileLocalSource.setCache', () async {
        if (model == null) throw CacheException();
        return await storage.write(profileCacheKey, jsonEncode(model.toJson()));
      });

  @override
  Future<ProfileModel?> getCache() => runCacheOperation('ProfileLocalSource.getCache', () async {
    final value = await storage.read(profileCacheKey);
    if (value == null) throw CacheException();
    if (value is! String) throw const FormatException('Cached value is not JSON text');
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Cached value is not an object');
    }
    return ProfileModel.fromJson(decoded);
  });

  @override
  Future<bool?> removeCache() => runCacheOperation('ProfileLocalSource.removeCache', () async {
    return await storage.remove(profileCacheKey);
  });
}
