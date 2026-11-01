import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/_errors.dart';
import '../../../../core/use_cases/_use_cases.dart';
import '../_domain.dart';

@lazySingleton
class ForgotPasswordUseCase implements FutureEitherUseCase<String, bool> {
  final AuthRepository _repository;

  @factoryMethod
  const ForgotPasswordUseCase(this._repository);

  @override
  Future<Either<Failure, bool>> call(String input) {
    return _repository.forgotPassword(email: input);
  }
}
