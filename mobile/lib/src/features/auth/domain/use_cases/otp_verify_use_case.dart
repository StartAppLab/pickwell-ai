import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/_errors.dart';
import '../../../../core/use_cases/_use_cases.dart';
import '../_domain.dart';

class OtpVerifyInput {
  final String email;
  final String token;

  const OtpVerifyInput({required this.email, required this.token});
}

@lazySingleton
class OtpVerifyUseCase implements FutureEitherUseCase<OtpVerifyInput, AuthResponse> {
  final AuthRepository _repository;

  @factoryMethod
  const OtpVerifyUseCase(this._repository);

  @override
  Future<Either<Failure, AuthResponse>> call(OtpVerifyInput input) {
    return _repository.otpVerify(email: input.email, token: input.token);
  }
}
