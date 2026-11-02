import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/_core.dart';
import '../repositories/email_otp_repository.dart';

@lazySingleton
class EmailOtpUseCase implements NoInputFutureEitherUseCase<bool> {
  final EmailOtpRepository repository;
  EmailOtpUseCase(this.repository);
  int get resendAfter => repository.resendAfter;
  @override
  Future<Either<Failure, bool>> call() => repository.authorize();
  Future<Either<Failure, bool>> send(String email) => repository.send(email);
  Future<Either<Failure, bool>> verify(String email, String code) => repository.verify(email, code);
}
