import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../config/_config.dart';
import '../../../../core/_core.dart';
import '../../domain/_domain.dart';
import '../data_sources/_data_sources.dart';

@Injectable(as: NotificationRepository)
abstract class NotificationRepositoryImpl implements NotificationRepository {
  @factoryMethod
  const factory NotificationRepositoryImpl({
    required NotificationLocalSource localSource,
    required NotificationRemoteSource remoteSource,
    required NetworkInfo networkInfo,
    required AutoMapper autoMapper,
    required DataStorage storage,
  }) = _NotificationRepositoryImpl;
}

class _NotificationRepositoryImpl implements NotificationRepositoryImpl {
  final NotificationLocalSource localSource;
  final NotificationRemoteSource remoteSource;
  final NetworkInfo networkInfo;
  final AutoMapper autoMapper;
  final DataStorage storage;

  const _NotificationRepositoryImpl({
    required this.localSource,
    required this.remoteSource,
    required this.networkInfo,
    required this.autoMapper,
    required this.storage,
  });

  final repositoryPath = 'NotificationRepository';
  final hasOfflineMode = false;

  @override
  Future<Either<Failure, NotificationEntity>> getNotification({required int id}) async {
    final path = '$repositoryPath.getNotification';
    if (await networkInfo.isConnected) {
      try {
        final remote = await remoteSource.getNotificationApiService.getNotification(id: id);
        if (remote == null) {
          throw _genericException;
        }
        // Success
        AppLogger.logInfo('Notification remote operation completed');
        await writeOptionalCache('notification.setCache', () => localSource.setCache(remote));
        return Right(autoMapper.convert(remote));
      } on DioException catch (e) {
        var stackTrace = 'A request exception has occured in $path: ${e.toString()}';
        if (e.response?.data != null && e.response?.data is NotificationEntity) {
          stackTrace = (e.response?.data as NotificationEntity).message;
        }
        return Left(_getServerFailure(stackTrace));
      } on ServerException catch (e) {
        final stackTrace = 'A server exception has occured in $path: ${e.toString()}';
        return Left(_getServerFailure(stackTrace));
      } on Exception catch (e) {
        final stackTrace = 'An exception has occured in $path: ${e.toString()}';
        return Left(_getServerFailure(stackTrace));
      }
    } else {
      if (!hasOfflineMode) {
        return Left(_getNetworkFailure(path));
      }
      try {
        final local = await localSource.getCache();
        if (local == null) {
          throw _genericException;
        }
        // Success
        AppLogger.logInfo('Notification loaded from local cache');
        return Right(autoMapper.convert(local));
      } on CacheException catch (e) {
        final stackTrace = 'A cache exception has occured in $path: ${e.toString()}';
        return Left(_getCacheFailure(stackTrace));
      } on Exception catch (e) {
        final stackTrace = 'An exception has occured in $path: ${e.toString()}';
        return Left(_getCacheFailure(stackTrace));
      }
    }
  }

  ServerFailure _getServerFailure(String stackTrace, {String? message, String? statusCode}) {
    final failure = ServerFailure(
      error: DataError(stackTrace: stackTrace, message: message, statusCode: statusCode),
    );
    AppLogger.logError('Notification operation failed');
    return failure;
  }

  CacheFailure _getCacheFailure(String stackTrace, {String? message, String? statusCode}) {
    final failure = CacheFailure(
      error: DataError(stackTrace: stackTrace, message: message, statusCode: statusCode),
    );
    AppLogger.logError('Notification operation failed');
    return failure;
  }

  NetworkFailure _getNetworkFailure(String errorPath) {
    const message = 'A network failure has occured';
    final stackTrace = '$message in $errorPath';
    final failure = NetworkFailure(
      error: DataError(stackTrace: stackTrace, message: message),
    );
    AppLogger.logError('Notification operation failed');
    return failure;
  }

  Exception get _genericException => Exception('Failed to get data from source');
}
