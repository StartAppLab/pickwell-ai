import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/_core.dart';
import '../_domain.dart';

@lazySingleton
class GetPaywallUseCase implements FutureEitherUseCase<int, PaywallEntity> {
  final PaywallRepository _repository;

  @factoryMethod
  const GetPaywallUseCase(this._repository);

  @override
  Future<Either<Failure, PaywallEntity>> call(int input) {
    return _repository.getPaywall(id: input);
  }
}
