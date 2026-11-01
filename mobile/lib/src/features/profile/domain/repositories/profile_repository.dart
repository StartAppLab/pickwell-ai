import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/_errors.dart';
import '../entities/_entities.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile({required int id});
}
