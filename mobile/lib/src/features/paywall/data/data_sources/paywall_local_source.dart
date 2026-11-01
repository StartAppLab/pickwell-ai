import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../../../core/_core.dart';
import '../models/_models.dart';

const paywallCacheKey = 'PAYWALL_CACHE_KEY';

@lazySingleton
abstract class PaywallLocalSource {
  @factoryMethod
  const factory PaywallLocalSource({required DataStorage storage}) = _PaywallLocalSourceImpl;

  Future<bool?> setCache(PaywallModel? model);

  Future<PaywallModel?> getCache();

  Future<bool?> removeCache();
}

class _PaywallLocalSourceImpl implements PaywallLocalSource {
  final DataStorage storage;

  const _PaywallLocalSourceImpl({required this.storage});

  @override
  Future<bool?> setCache(PaywallModel? model) =>
      runCacheOperation('PaywallLocalSource.setCache', () async {
        if (model == null) throw CacheException();
        return await storage.write(paywallCacheKey, jsonEncode(model.toJson()));
      });

  @override
  Future<PaywallModel?> getCache() => runCacheOperation('PaywallLocalSource.getCache', () async {
    final value = await storage.read(paywallCacheKey);
    if (value == null) throw CacheException();
    if (value is! String) throw const FormatException('Cached value is not JSON text');
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Cached value is not an object');
    }
    return PaywallModel.fromJson(decoded);
  });

  @override
  Future<bool?> removeCache() => runCacheOperation('PaywallLocalSource.removeCache', () async {
    return await storage.remove(paywallCacheKey);
  });
}
