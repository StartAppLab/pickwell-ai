import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/_errors.dart';
import '../entities/label_photo.dart';

abstract class LabelCaptureRepository {
  Future<Either<Failure, LabelPhoto?>> capture();
  Future<void> prepare();
  Future<void> discard(LabelPhoto photo);
}
