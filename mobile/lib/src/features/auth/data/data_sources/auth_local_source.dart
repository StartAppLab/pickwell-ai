import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../../../core/_core.dart';
import '../models/_models.dart';

const authCacheKey = 'AUTH_CACHE_KEY';

@lazySingleton
abstract class AuthLocalSource {
  @factoryMethod
  const factory AuthLocalSource({required DataStorage storage}) = _AuthLocalSourceImpl;

  Future<bool?> setCache(UserModel? model);

  Future<UserModel?> getCache();

  Future<bool?> removeCache();
}

class _AuthLocalSourceImpl implements AuthLocalSource {
  final DataStorage storage;

  const _AuthLocalSourceImpl({required this.storage});

  @override
  Future<bool?> setCache(UserModel? model) =>
      runCacheOperation('AuthLocalSource.setCache', () async {
        if (model == null) throw CacheException();
        return await storage.write(authCacheKey, jsonEncode(model.toJson()));
      });

  @override
  Future<UserModel?> getCache() => runCacheOperation('AuthLocalSource.getCache', () async {
    final value = await storage.read(authCacheKey);
    if (value == null) throw CacheException();
    if (value is! String) throw const FormatException('Cached value is not JSON text');
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Cached value is not an object');
    }
    return UserModel.fromJson(decoded);
  });

  @override
  Future<bool?> removeCache() => runCacheOperation('AuthLocalSource.removeCache', () async {
    return await storage.remove(authCacheKey);
  });
}
