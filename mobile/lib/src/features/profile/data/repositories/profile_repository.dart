import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../config/_config.dart';
import '../../../../core/_core.dart';
import '../../domain/_domain.dart';
import '../data_sources/_data_sources.dart';

@Injectable(as: ProfileRepository)
abstract class ProfileRepositoryImpl implements ProfileRepository {
  @factoryMethod
  const factory ProfileRepositoryImpl({
    required ProfileLocalSource localSource,
    required ProfileRemoteSource remoteSource,
    required NetworkInfo networkInfo,
    required AutoMapper autoMapper,
    required DataStorage storage,
  }) = _ProfileRepositoryImpl;
}

class _ProfileRepositoryImpl implements ProfileRepositoryImpl {
  final ProfileLocalSource localSource;
  final ProfileRemoteSource remoteSource;
  final NetworkInfo networkInfo;
  final AutoMapper autoMapper;
  final DataStorage storage;

  const _ProfileRepositoryImpl({
    required this.localSource,
    required this.remoteSource,
    required this.networkInfo,
    required this.autoMapper,
    required this.storage,
  });

  final repositoryPath = 'ProfileRepository';
  final hasOfflineMode = false;

  @override
  Future<Either<Failure, ProfileEntity>> getProfile({required int id}) async {
    final path = '$repositoryPath.getProfile';
    if (await networkInfo.isConnected) {
      try {
        final remote = await remoteSource.getProfileApiService.getProfile(id: id);
        if (remote == null) {
          throw _genericException;
        }
        // Success
        AppLogger.logInfo('Profile remote operation completed');
        await writeOptionalCache('profile.setCache', () => localSource.setCache(remote));
        return Right(autoMapper.convert(remote));
      } on DioException catch (e) {
        var stackTrace = 'A request exception has occured in $path: ${e.toString()}';
        if (e.response?.data != null && e.response?.data is ProfileEntity) {
          stackTrace = (e.response?.data as ProfileEntity).message;
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
        AppLogger.logInfo('Profile loaded from local cache');
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
    AppLogger.logError('Profile operation failed');
    return failure;
  }

  CacheFailure _getCacheFailure(String stackTrace, {String? message, String? statusCode}) {
    final failure = CacheFailure(
      error: DataError(stackTrace: stackTrace, message: message, statusCode: statusCode),
    );
    AppLogger.logError('Profile operation failed');
    return failure;
  }

  NetworkFailure _getNetworkFailure(String errorPath) {
    const message = 'A network failure has occured';
    final stackTrace = '$message in $errorPath';
    final failure = NetworkFailure(
      error: DataError(stackTrace: stackTrace, message: message),
    );
    AppLogger.logError('Profile operation failed');
    return failure;
  }

  Exception get _genericException => Exception('Failed to get data from source');
}
