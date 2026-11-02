import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../../../../core/storage/data_storage.dart';
import '../../domain/entities/catalog_entity.dart';

@lazySingleton
class CatalogLocalSource {
  final DataStorage storage;
  CatalogLocalSource(this.storage);
  final Map<String, ProductRecord> products = {};
  Future<List<RecentProduct>> load() async {
    final raw = await storage.read(DataStorageKeys.recentProducts);
    if (raw is! String) return [];
    try {
      final rows = jsonDecode(raw) as List;
      final unique = <String, RecentProduct>{};
      for (final value in rows.take(100)) {
        try {
          final row = value as Map;
          final code = normalizeGtin(row['barcode'] as String);
          final time = DateTime.parse(row['opened_at'] as String).toUtc();
          if (!unique.containsKey(code) || time.isAfter(unique[code]!.openedAt)) {
            unique[code] = RecentProduct(code, time, product: products[code]);
          }
        } catch (_) {
          continue;
        }
      }
      final result = unique.values.toList()..sort((a, b) => b.openedAt.compareTo(a.openedAt));
      return result.take(30).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writes = Future.value();
  Future<bool> remember(ProductRecord product) {
    final result = _writes.then((_) => _remember(product));
    _writes = result.then<void>((_) {}).catchError((Object _) {});
    return result;
  }

  Future<bool> _remember(ProductRecord product) async {
    products[product.barcode] = product;
    final rows = await load();
    rows.removeWhere((e) => e.barcode == product.barcode);
    rows.insert(0, RecentProduct(product.barcode, DateTime.now().toUtc(), product: product));
    final kept = rows.take(30).map((row) => row.barcode).toSet();
    products.removeWhere((code, _) => !kept.contains(code));
    // Only references/timestamps persist. No photos, account IDs or analysis payload.
    return await storage.write(
          DataStorageKeys.recentProducts,
          jsonEncode(
            rows
                .take(30)
                .map((r) => {'barcode': r.barcode, 'opened_at': r.openedAt.toIso8601String()})
                .toList(),
          ),
        ) ==
        true;
  }
}
