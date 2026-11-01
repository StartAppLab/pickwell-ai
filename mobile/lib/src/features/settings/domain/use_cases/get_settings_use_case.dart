import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/_core.dart';
import '../_domain.dart';

@lazySingleton
class GetSettingsUseCase implements FutureEitherUseCase<int, SettingsEntity> {
  final SettingsRepository _repository;

  @factoryMethod
  const GetSettingsUseCase(this._repository);

  @override
  Future<Either<Failure, SettingsEntity>> call(int input) {
    return _repository.getSettings(id: input);
  }
}
