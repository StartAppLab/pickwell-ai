import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/_core.dart';
import '../_domain.dart';

@lazySingleton
class GetNotificationUseCase implements FutureEitherUseCase<int, NotificationEntity> {
  final NotificationRepository _repository;

  @factoryMethod
  const GetNotificationUseCase(this._repository);

  @override
  Future<Either<Failure, NotificationEntity>> call(int input) {
    return _repository.getNotification(id: input);
  }
}
