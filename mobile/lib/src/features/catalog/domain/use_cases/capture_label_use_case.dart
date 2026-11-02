import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/_core.dart';
import '../entities/label_photo.dart';
import '../repositories/label_capture_repository.dart';

@lazySingleton
class CaptureLabelUseCase implements NoInputFutureEitherUseCase<LabelPhoto?> {
  final LabelCaptureRepository repository;
  CaptureLabelUseCase(this.repository);
  @override
  Future<Either<Failure, LabelPhoto?>> call() => repository.capture();
  Future<void> prepare() => repository.prepare();
  Future<void> discard(LabelPhoto photo) => repository.discard(photo);
}
