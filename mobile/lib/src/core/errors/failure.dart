import 'data_error.dart';

abstract class Failure {
  final DataError error;

  const Failure({required this.error});
}

class ServerFailure extends Failure {
  ServerFailure({required super.error});
}

class CacheFailure extends Failure {
  CacheFailure({required super.error});
}

class NetworkFailure extends Failure {
  NetworkFailure({required super.error});
}
