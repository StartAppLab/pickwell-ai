import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/_errors.dart';
import '../../../../core/use_cases/_use_cases.dart';
import '../_domain.dart';

class SignInInput {
  final String email;
  final String password;

  const SignInInput({required this.email, required this.password});
}

@lazySingleton
class SignInUseCase implements FutureEitherUseCase<SignInInput, AuthResponse> {
  final AuthRepository _repository;

  @factoryMethod
  const SignInUseCase(this._repository);

  @override
  Future<Either<Failure, AuthResponse>> call(SignInInput input) {
    return _repository.signIn(email: input.email, password: input.password);
  }
}
