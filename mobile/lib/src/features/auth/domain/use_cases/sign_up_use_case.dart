import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/_errors.dart';
import '../../../../core/use_cases/_use_cases.dart';
import '../_domain.dart';

class SignUpInput {
  final String email;
  final String password;
  final String firstName;
  final String? lastName;

  const SignUpInput({
    required this.email,
    required this.password,
    required this.firstName,
    this.lastName,
  });
}

@lazySingleton
class SignUpUseCase implements FutureEitherUseCase<SignUpInput, AuthResponse> {
  final AuthRepository _repository;

  @factoryMethod
  const SignUpUseCase(this._repository);

  @override
  Future<Either<Failure, AuthResponse>> call(SignUpInput input) {
    return _repository.signUp(
      email: input.email,
      password: input.password,
      firstName: input.firstName,
      lastName: input.lastName,
    );
  }
}
