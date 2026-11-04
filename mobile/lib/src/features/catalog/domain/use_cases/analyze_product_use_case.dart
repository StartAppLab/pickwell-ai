import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/_core.dart';
import '../entities/analysis_entity.dart';
import '../repositories/analysis_repository.dart';

@lazySingleton
class AnalyzeProductUseCase implements FutureEitherUseCase<AnalysisRequest, AnalysisResult> {
  final AnalysisRepository repository;
  AnalyzeProductUseCase(this.repository);
  Future<Either<Failure, AnalysisResult>> cancelReview(String requestId, String barcode) =>
      repository.cancelReview(requestId, barcode);
  @override
  Future<Either<Failure, AnalysisResult>> call(AnalysisRequest input) => repository.submit(input);
}
