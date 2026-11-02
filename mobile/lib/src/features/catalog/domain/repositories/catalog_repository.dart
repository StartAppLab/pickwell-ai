import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/catalog_entity.dart';

abstract class CatalogRepository {
  Future<Either<Failure, CatalogEntity>> getCatalog({
    required String barcode,
    required String requestId,
    bool useMemory = false,
  });
  Future<Either<Failure, List<RecentProduct>>> recents();
  ProductRecord? cached(String barcode);
}
