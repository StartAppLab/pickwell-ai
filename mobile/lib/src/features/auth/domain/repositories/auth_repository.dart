import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/_errors.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> signUp({
    required String email,
    required String password,
    required String firstName,
    String? lastName,
  });

  Future<Either<Failure, AuthResponse>> signIn({required String email, required String password});

  Future<Either<Failure, bool>> signOut({required SignOutScope scope});

  Future<Either<Failure, AuthResponse>> otpVerify({required String email, required String token});

  Future<Either<Failure, ResendResponse>> otpResend({required String email});

  Future<Either<Failure, bool>> forgotPassword({required String email});

  Future<Either<Failure, UserResponse>> changePassword({required String password});
}
