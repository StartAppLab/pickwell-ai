import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../../../core/_core.dart';
import '../models/_models.dart';

const notificationCacheKey = 'NOTIFICATION_CACHE_KEY';

@lazySingleton
abstract class NotificationLocalSource {
  @factoryMethod
  const factory NotificationLocalSource({required DataStorage storage}) =
      _NotificationLocalSourceImpl;

  Future<bool?> setCache(NotificationModel? model);

  Future<NotificationModel?> getCache();

  Future<bool?> removeCache();
}

class _NotificationLocalSourceImpl implements NotificationLocalSource {
  final DataStorage storage;

  const _NotificationLocalSourceImpl({required this.storage});

  @override
  Future<bool?> setCache(NotificationModel? model) =>
      runCacheOperation('NotificationLocalSource.setCache', () async {
        if (model == null) throw CacheException();
        return await storage.write(notificationCacheKey, jsonEncode(model.toJson()));
      });

  @override
  Future<NotificationModel?> getCache() =>
      runCacheOperation('NotificationLocalSource.getCache', () async {
        final value = await storage.read(notificationCacheKey);
        if (value == null) throw CacheException();
        if (value is! String) throw const FormatException('Cached value is not JSON text');
        final decoded = jsonDecode(value);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Cached value is not an object');
        }
        return NotificationModel.fromJson(decoded);
      });

  @override
  Future<bool?> removeCache() => runCacheOperation('NotificationLocalSource.removeCache', () async {
    return await storage.remove(notificationCacheKey);
  });
}
