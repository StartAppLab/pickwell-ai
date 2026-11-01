import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/_errors.dart';
import '../../../../core/use_cases/_use_cases.dart';
import '../_domain.dart';

@lazySingleton
class OtpResendUseCase implements FutureEitherUseCase<String, ResendResponse> {
  final AuthRepository _repository;

  @factoryMethod
  const OtpResendUseCase(this._repository);

  @override
  Future<Either<Failure, ResendResponse>> call(String input) {
    return _repository.otpResend(email: input);
  }
}
