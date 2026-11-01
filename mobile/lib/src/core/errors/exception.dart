class ServerException implements Exception {
  final String errorMessage;

  ServerException({this.errorMessage = 'Server exception occurred'});
}

class CacheException implements Exception {
  final String errorMessage;

  final Object? cause;
  final StackTrace? stackTrace;

  CacheException({this.errorMessage = 'Cache exception occurred', this.cause, this.stackTrace});
}

class NetworkException implements Exception {
  final String errorMessage;

  NetworkException({this.errorMessage = 'Network exception occurred'});
}
