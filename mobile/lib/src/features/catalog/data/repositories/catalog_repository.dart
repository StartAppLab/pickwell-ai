import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/_errors.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/entities/catalog_entity.dart';
import '../data_sources/catalog_local_source.dart';
import '../data_sources/catalog_remote_source.dart';
import '../models/catalog_model.dart';

@LazySingleton(as: CatalogRepository)
class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogLocalSource local;
  final CatalogRemoteSource remote;
  CatalogRepositoryImpl(this.local, this.remote);
  final Map<String, String> _refreshKeys = {};
  @override
  ProductRecord? cached(String barcode) => local.products[barcode];
  @override
  Future<Either<Failure, List<RecentProduct>>> recents() async {
    try {
      final rows = await local.load();
      final indexed = rows.map((row) => row.barcode).toSet();
      _refreshKeys.removeWhere((code, _) => !indexed.contains(code));
      var stopped = false;
      final resolved = <RecentProduct>[];
      for (final row in rows) {
        var product = local.products[row.barcode];
        if (product == null && !stopped) {
          try {
            // Refresh through the normal admission/quota endpoint. Do not call
            // getCatalog: hydration is not a new opening and must not reorder
            // the persisted index or create history for misses.
            final result = CatalogModel.parse(
              await remote.lookup(
                row.barcode,
                _refreshKeys.putIfAbsent(row.barcode, createCatalogRequestId),
              ),
              row.barcode,
            );
            if (result.status != LookupStatus.error ||
                {'idempotency_expired', 'idempotency_conflict'}.contains(result.errorCode)) {
              _refreshKeys.remove(row.barcode);
            }
            product = result.product;
            if (product != null) local.products[row.barcode] = product;
            if ({LookupStatus.denied, LookupStatus.error}.contains(result.status)) stopped = true;
          } catch (_) {
            // One offline/transport failure is enough; do not fan out 30 failures.
            stopped = true;
          }
        }
        resolved.add(RecentProduct(row.barcode, row.openedAt, product: product));
      }
      return Right(resolved);
    } catch (_) {
      return Left(
        CacheFailure(
          error: const DataError(stackTrace: 'recent_index_read', statusCode: 'storage'),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, CatalogEntity>> getCatalog({
    required String barcode,
    required String requestId,
    bool useMemory = false,
  }) async {
    try {
      final code = normalizeGtin(barcode);
      final p = useMemory ? cached(code) : null;
      if (p != null) {
        var saved = true;
        try {
          saved = await local.remember(p);
        } catch (_) {
          saved = false;
        }
        return Right(
          CatalogEntity(status: LookupStatus.found, barcode: code, product: p, recentSaved: saved),
        );
      }
      final result = CatalogModel.parse(await remote.lookup(code, requestId), code);
      if ({LookupStatus.miss, LookupStatus.processing}.contains(result.status)) {
        local.products.remove(code);
      }
      var saved = true;
      if (result.product != null) {
        try {
          saved = await local.remember(result.product!);
        } catch (_) {
          saved = false;
        }
      }
      return Right(
        CatalogEntity(
          status: result.status,
          barcode: code,
          product: result.product,
          quota: result.quota,
          errorCode: result.errorCode,
          recentSaved: saved,
        ),
      );
    } catch (_) {
      return Left(
        ServerFailure(
          error: const DataError(stackTrace: 'catalog_lookup_failed', statusCode: 'unavailable'),
        ),
      );
    }
  }
}
