import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/analysis_entity.dart';

abstract class AnalysisRepository {
  Future<Either<Failure, AnalysisResult>> submit(AnalysisRequest request);
  Future<Either<Failure, AnalysisResult>> cancelReview(String requestId, String barcode);
}
