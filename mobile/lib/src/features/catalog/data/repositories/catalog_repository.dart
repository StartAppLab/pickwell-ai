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
  @override
  ProductRecord? cached(String barcode) => local.products[barcode];
  @override
  Future<Either<Failure, List<RecentProduct>>> recents() async {
    try {
      return Right(await local.load());
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
