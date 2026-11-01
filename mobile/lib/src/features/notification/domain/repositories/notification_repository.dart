import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/_errors.dart';
import '../entities/_entities.dart';

abstract class NotificationRepository {
  Future<Either<Failure, NotificationEntity>> getNotification({required int id});
}
