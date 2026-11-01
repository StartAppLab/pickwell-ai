import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/_errors.dart';
import '../entities/_entities.dart';

abstract class PaywallRepository {
  Future<Either<Failure, PaywallEntity>> getPaywall({required int id});
}
