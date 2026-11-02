import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/_errors.dart';
import '../../domain/entities/label_photo.dart';
import '../../domain/repositories/label_capture_repository.dart';
import '../data_sources/services/scanner_media_service.dart';

@LazySingleton(as: LabelCaptureRepository)
class LabelCaptureRepositoryImpl implements LabelCaptureRepository {
  final ScannerMediaService media;
  LabelCaptureRepositoryImpl(this.media);
  @override
  Future<Either<Failure, LabelPhoto?>> capture() async {
    try {
      return Right(await media.captureLabel());
    } catch (error) {
      return Left(
        ServerFailure(
          error: DataError(
            stackTrace: 'label_capture',
            statusCode: error is LabelMediaException ? error.code : 'camera',
          ),
        ),
      );
    }
  }

  @override
  Future<void> prepare() => media.prepareLabels();
  @override
  Future<void> discard(LabelPhoto photo) => media.discardLabel(photo);
}
