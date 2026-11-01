import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/_errors.dart';
import '../../../../core/use_cases/_use_cases.dart';
import '../_domain.dart';

@lazySingleton
class SignOutUseCase implements FutureEitherUseCase<SignOutScope, bool> {
  final AuthRepository _repository;

  @factoryMethod
  const SignOutUseCase(this._repository);

  @override
  Future<Either<Failure, bool>> call(SignOutScope input) {
    return _repository.signOut(scope: input);
  }
}
