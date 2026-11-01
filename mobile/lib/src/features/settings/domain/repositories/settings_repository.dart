import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/_errors.dart';
import '../entities/_entities.dart';

abstract class SettingsRepository {
  Future<Either<Failure, SettingsEntity>> getSettings({required int id});
}
