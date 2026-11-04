import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/_errors.dart';
import '../../domain/entities/analysis_entity.dart';
import '../../domain/repositories/analysis_repository.dart';
import '../data_sources/services/analysis_api_service.dart';
import '../data_sources/catalog_local_source.dart';
import '../models/analysis_model.dart';

@LazySingleton(as: AnalysisRepository)
class AnalysisRepositoryImpl implements AnalysisRepository {
  final AnalysisApiService api;
  final CatalogLocalSource local;
  AnalysisRepositoryImpl(this.api, this.local);
  @override
  Future<Either<Failure, AnalysisResult>> privateResult(String jobId, String barcode) async {
    try {
      final raw = await api.privateResult(jobId);
      final result = AnalysisModel.parse(
        raw,
        barcode.isEmpty ? raw['barcode'] as String? ?? '' : barcode,
      );
      final canonical =
          result.canonicalProduct ?? (result.phase == AnalysisPhase.ready ? result.product : null);
      if (canonical != null) local.products[canonical.barcode] = canonical;
      return Right(result);
    } catch (_) {
      return Left(
        ServerFailure(
          error: const DataError(
            stackTrace: 'private_result_unavailable',
            statusCode: 'unavailable',
          ),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AnalysisResult>> cancelReview(String requestId, String barcode) async {
    try {
      final result = AnalysisModel.parse(await api.cancelReview(requestId), barcode);
      final canonical =
          result.canonicalProduct ?? (result.phase == AnalysisPhase.ready ? result.product : null);
      if (canonical != null) local.products[canonical.barcode] = canonical;
      return Right(result);
    } catch (_) {
      return Left(
        ServerFailure(
          error: const DataError(stackTrace: 'review_cancel_failed', statusCode: 'unavailable'),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AnalysisResult>> submit(AnalysisRequest request) async {
    try {
      final result = AnalysisModel.parse(await api.submit(request), request.barcode);
      if (result.phase == AnalysisPhase.ready && result.product != null) {
        final product = result.product!;
        // Optional recent-index storage may fail; verified publication must not be resubmitted.
        local.products[product.barcode] = product;
        try {
          await local.remember(product);
        } catch (_) {}
      }
      final canonical = result.canonicalProduct;
      if (canonical != null) local.products[canonical.barcode] = canonical;
      return Right(result);
    } catch (_) {
      return Left(
        ServerFailure(
          error: const DataError(
            stackTrace: 'analysis_submission_failed',
            statusCode: 'unavailable',
          ),
        ),
      );
    }
  }
}
