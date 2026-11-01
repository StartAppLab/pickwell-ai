import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../config/_config.dart';
import '../../../../core/_core.dart';
import '../../domain/_domain.dart';
import '../data_sources/_data_sources.dart';

@Injectable(as: PaywallRepository)
abstract class PaywallRepositoryImpl implements PaywallRepository {
  @factoryMethod
  const factory PaywallRepositoryImpl({
    required PaywallLocalSource localSource,
    required PaywallRemoteSource remoteSource,
    required NetworkInfo networkInfo,
    required AutoMapper autoMapper,
    required DataStorage storage,
  }) = _PaywallRepositoryImpl;
}

class _PaywallRepositoryImpl implements PaywallRepositoryImpl {
  final PaywallLocalSource localSource;
  final PaywallRemoteSource remoteSource;
  final NetworkInfo networkInfo;
  final AutoMapper autoMapper;
  final DataStorage storage;

  const _PaywallRepositoryImpl({
    required this.localSource,
    required this.remoteSource,
    required this.networkInfo,
    required this.autoMapper,
    required this.storage,
  });

  final repositoryPath = 'PaywallRepository';
  final hasOfflineMode = false;

  @override
  Future<Either<Failure, PaywallEntity>> getPaywall({required int id}) async {
    final path = '$repositoryPath.getPaywall';
    if (await networkInfo.isConnected) {
      try {
        final remote = await remoteSource.getPaywallApiService.getPaywall(id: id);
        if (remote == null) {
          throw _genericException;
        }
        // Success
        AppLogger.logInfo('Paywall remote operation completed');
        await writeOptionalCache('paywall.setCache', () => localSource.setCache(remote));
        return Right(autoMapper.convert(remote));
      } on DioException catch (e) {
        var stackTrace = 'A request exception has occured in $path: ${e.toString()}';
        if (e.response?.data != null && e.response?.data is PaywallEntity) {
          stackTrace = (e.response?.data as PaywallEntity).message;
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
        AppLogger.logInfo('Paywall loaded from local cache');
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
    AppLogger.logError('Paywall operation failed');
    return failure;
  }

  CacheFailure _getCacheFailure(String stackTrace, {String? message, String? statusCode}) {
    final failure = CacheFailure(
      error: DataError(stackTrace: stackTrace, message: message, statusCode: statusCode),
    );
    AppLogger.logError('Paywall operation failed');
    return failure;
  }

  NetworkFailure _getNetworkFailure(String errorPath) {
    const message = 'A network failure has occured';
    final stackTrace = '$message in $errorPath';
    final failure = NetworkFailure(
      error: DataError(stackTrace: stackTrace, message: message),
    );
    AppLogger.logError('Paywall operation failed');
    return failure;
  }

  Exception get _genericException => Exception('Failed to get data from source');
}
