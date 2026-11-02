import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/_errors.dart';

abstract class EmailOtpRepository {
  int get resendAfter;
  Future<Either<Failure, bool>> send(String email);
  Future<Either<Failure, bool>> verify(String email, String code);
  Future<Either<Failure, bool>> authorize();
}
