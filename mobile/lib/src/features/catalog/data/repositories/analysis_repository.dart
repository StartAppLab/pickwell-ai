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
  Future<Either<Failure, AnalysisResult>> cancelReview(String requestId, String barcode) async {
    try {
      return Right(AnalysisModel.parse(await api.cancelReview(requestId), barcode));
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
      if (result.product case final product?) {
        // Optional recent-index storage may fail; verified publication must not be resubmitted.
        local.products[product.barcode] = product;
        try {
          await local.remember(product);
        } catch (_) {}
      }
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
