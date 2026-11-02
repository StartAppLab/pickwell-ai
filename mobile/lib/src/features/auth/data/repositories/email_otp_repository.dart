import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/_errors.dart';
import '../../domain/repositories/email_otp_repository.dart';
import '../data_sources/services/email_otp_api_service.dart';

@LazySingleton(as: EmailOtpRepository)
class EmailOtpRepositoryImpl implements EmailOtpRepository {
  final EmailOtpApiService api;
  EmailOtpRepositoryImpl(this.api);
  @override
  int get resendAfter => api.resendAfter;
  Future<Either<Failure, bool>> _run(
    Future<bool> Function() operation, {
    bool verifying = false,
  }) async {
    try {
      return Right(await operation());
    } catch (error) {
      var code = 'unavailable';
      if (error is EmailGateException) code = error.code;
      if (error is AuthException) {
        if (error.statusCode == '429') code = 'rate_limited';
        if (verifying && ['400', '403'].contains(error.statusCode)) code = 'invalid_code';
        if ([
          'otp_expired',
          'otp_disabled',
          'invalid_credentials',
          'validation_failed',
        ].contains(error.code)) {
          code = 'invalid_code';
        }
      }
      // Never retain SDK exceptions, OTPs, sessions or emails in diagnostics.
      return Left(
        ServerFailure(
          error: DataError(stackTrace: 'email_otp', statusCode: code),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> send(String email) => _run(() async {
    await api.send(email);
    return true;
  });
  @override
  Future<Either<Failure, bool>> verify(String email, String code) =>
      _run(() => api.verify(email, code), verifying: true);
  @override
  Future<Either<Failure, bool>> authorize() => _run(api.authorize);
}
