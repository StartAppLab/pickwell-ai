import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/_errors.dart';
import '../../../../core/use_cases/_use_cases.dart';
import '../_domain.dart';

@lazySingleton
class ChangePasswordUseCase implements FutureEitherUseCase<String, UserResponse> {
  final AuthRepository _repository;

  @factoryMethod
  const ChangePasswordUseCase(this._repository);

  @override
  Future<Either<Failure, UserResponse>> call(String input) {
    return _repository.changePassword(password: input);
  }
}
