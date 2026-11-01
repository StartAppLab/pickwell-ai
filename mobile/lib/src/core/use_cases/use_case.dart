import 'package:fpdart/fpdart.dart';

import '../errors/_errors.dart';

abstract class UseCase<INPUT, OUTPUT> {
  OUTPUT call(INPUT input);
}

abstract class FutureUseCase<INPUT, OUTPUT> extends UseCase<INPUT, Future<OUTPUT>> {}

abstract class EitherUseCase<INPUT, OUTPUT> extends UseCase<INPUT, Either<Failure, OUTPUT>> {}

abstract class FutureEitherUseCase<INPUT, OUTPUT>
    extends UseCase<INPUT, Future<Either<Failure, OUTPUT>>> {}

abstract class NoInputUseCase<OUTPUT> {
  OUTPUT call();
}

abstract class NoInputFutureUseCase<OUTPUT> extends NoInputUseCase<Future<OUTPUT>> {}

abstract class NoInputEitherUseCase<OUTPUT> extends NoInputUseCase<Either<Failure, OUTPUT>> {}

abstract class NoInputFutureEitherUseCase<OUTPUT>
    extends NoInputUseCase<Future<Either<Failure, OUTPUT>>> {}
