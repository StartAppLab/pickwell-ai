import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/_core.dart';
import '../_domain.dart';

@lazySingleton
class GetProfileUseCase implements FutureEitherUseCase<int, ProfileEntity> {
  final ProfileRepository _repository;

  @factoryMethod
  const GetProfileUseCase(this._repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(int input) {
    return _repository.getProfile(id: input);
  }
}
