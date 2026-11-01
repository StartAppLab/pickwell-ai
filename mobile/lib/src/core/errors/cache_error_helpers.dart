import '../app_logger.dart';
import 'data_error.dart';
import 'exception.dart';
import 'failure.dart';

Future<T> runCacheOperation<T>(String operation, Future<T> Function() action) async {
  try {
    return await action();
  } on CacheException {
    rethrow;
  } on Exception catch (error, stackTrace) {
    throw CacheException(
      errorMessage: '$operation failed (${error.runtimeType})',
      cause: error,
      stackTrace: stackTrace,
    );
  }
}

CacheFailure cacheFailure({required String operation, required CacheException exception}) {
  AppLogger.logException(exception, stackTrace: exception.stackTrace);
  return CacheFailure(
    error: DataError(
      stackTrace: exception.stackTrace?.toString() ?? 'Cache failure in $operation',
      message: exception.errorMessage,
    ),
  );
}

/// Optional cache writes must not turn a successful remote request into a failure.
Future<void> writeOptionalCache(String operation, Future<bool?> Function() action) async {
  try {
    final saved = await runCacheOperation(operation, action);
    if (saved != true) AppLogger.logWarning('Cache write was not persisted in $operation');
  } on CacheException catch (error) {
    AppLogger.logException(error, stackTrace: error.stackTrace);
  }
}
