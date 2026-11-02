import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/_core.dart';
import '../entities/catalog_entity.dart';
import '../repositories/catalog_repository.dart';

@lazySingleton
class GetCatalogUseCase implements FutureEitherUseCase<(String, String, bool), CatalogEntity> {
  final CatalogRepository repository;
  GetCatalogUseCase(this.repository);
  @override
  Future<Either<Failure, CatalogEntity>> call((String, String, bool) input) =>
      repository.getCatalog(barcode: input.$1, requestId: input.$2, useMemory: input.$3);
}

@lazySingleton
class GetRecentProductsUseCase implements NoInputFutureEitherUseCase<List<RecentProduct>> {
  final CatalogRepository repository;
  GetRecentProductsUseCase(this.repository);
  @override
  Future<Either<Failure, List<RecentProduct>>> call() => repository.recents();
}
