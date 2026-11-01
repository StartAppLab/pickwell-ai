class DataError {
  final String stackTrace;
  final String? message;
  final String? statusCode;

  const DataError({required this.stackTrace, this.message, this.statusCode});
}
