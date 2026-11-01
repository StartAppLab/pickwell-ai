import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/_config.dart';
import '../../../../core/_core.dart';
import '../../domain/_domain.dart';
import '../data_sources/_data_sources.dart';

@Injectable(as: AuthRepository)
abstract class AuthRepositoryImpl implements AuthRepository {
  @factoryMethod
  const factory AuthRepositoryImpl({
    required AuthLocalSource localSource,
    required AuthRemoteSource remoteSource,
    required NetworkInfo networkInfo,
    required AutoMapper autoMapper,
    required DataStorage storage,
  }) = _AuthRepositoryImpl;
}

class _AuthRepositoryImpl implements AuthRepositoryImpl {
  final AuthLocalSource localSource;
  final AuthRemoteSource remoteSource;
  final NetworkInfo networkInfo;
  final AutoMapper autoMapper;
  final DataStorage storage;

  const _AuthRepositoryImpl({
    required this.localSource,
    required this.remoteSource,
    required this.networkInfo,
    required this.autoMapper,
    required this.storage,
  });

  final repositoryPath = 'AuthRepository';
  final hasOfflineMode = false;

  @override
  Future<Either<Failure, AuthResponse>> signUp({
    required String email,
    required String password,
    required String firstName,
    String? lastName,
  }) async {
    final path = '$repositoryPath.signUp';
    if (await networkInfo.isConnected) {
      try {
        final remote = await remoteSource.getAuthApiService.signUp(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
        );
        if (remote.user == null) {
          throw _genericException;
        }
        // Success
        AppLogger.logInfo('Auth remote operation completed');
        return Right(remote);
      } on AuthException catch (e) {
        var stackTrace = 'An auth exception has occured in $path: ${e.toString()}';
        return Left(_getServerFailure(stackTrace, message: e.message, statusCode: e.statusCode));
      } on DioException catch (e) {
        var stackTrace = 'A request exception has occured in $path: ${e.toString()}';
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
        AppLogger.logInfo('Auth loaded from local cache');
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

  @override
  Future<Either<Failure, AuthResponse>> signIn({
    required String email,
    required String password,
  }) async {
    final path = '$repositoryPath.signIn';
    if (await networkInfo.isConnected) {
      try {
        final remote = await remoteSource.getAuthApiService.signIn(
          email: email,
          password: password,
        );
        if (remote.user == null) {
          throw _genericException;
        }
        // Success
        AppLogger.logInfo('Auth remote operation completed');
        return Right(remote);
      } on AuthException catch (e) {
        var stackTrace = 'An auth exception has occured in $path: ${e.toString()}';
        return Left(_getServerFailure(stackTrace, message: e.message, statusCode: e.statusCode));
      } on DioException catch (e) {
        var stackTrace = 'A request exception has occured in $path: ${e.toString()}';
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
        AppLogger.logInfo('Auth loaded from local cache');
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

  @override
  Future<Either<Failure, bool>> signOut({required SignOutScope scope}) async {
    try {
      await remoteSource.getAuthApiService.signOut(scope: scope);
      await localSource.removeCache();
      await storage.remove('PROFILE_CACHE_KEY');
      await storage.remove('NOTIFICATION_CACHE_KEY');
      return const Right(true);
    } catch (error) {
      // Supabase removes the local session before requesting remote revocation.
      // A failed network request must not leave the device UI signed in.
      if (scope == SignOutScope.local) {
        await localSource.removeCache();
        await storage.remove('PROFILE_CACHE_KEY');
        await storage.remove('NOTIFICATION_CACHE_KEY');
        return const Right(true);
      }
      return Left(_getServerFailure('Unable to sign out', message: 'Unable to sign out.'));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> otpVerify({
    required String email,
    required String token,
  }) async {
    final path = '$repositoryPath.otpVerify';
    if (await networkInfo.isConnected) {
      try {
        final remote = await remoteSource.getAuthApiService.otpVerify(email: email, token: token);
        if (remote.user == null) {
          throw _genericException;
        }
        // Success
        AppLogger.logInfo('Auth remote operation completed');
        return Right(remote);
      } on AuthException catch (e) {
        var stackTrace = 'An auth exception has occured in $path: ${e.toString()}';
        return Left(_getServerFailure(stackTrace, message: e.message, statusCode: e.statusCode));
      } on DioException catch (e) {
        var stackTrace = 'A request exception has occured in $path: ${e.toString()}';
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
        AppLogger.logInfo('Auth loaded from local cache');
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

  @override
  Future<Either<Failure, ResendResponse>> otpResend({required String email}) async {
    final path = '$repositoryPath.otpResend';
    if (await networkInfo.isConnected) {
      try {
        final remote = await remoteSource.getAuthApiService.otpResend(email: email);
        // Success
        AppLogger.logInfo('Auth remote operation completed');
        return Right(remote);
      } on AuthException catch (e) {
        var stackTrace = 'An auth exception has occured in $path: ${e.toString()}';
        return Left(_getServerFailure(stackTrace, message: e.message, statusCode: e.statusCode));
      } on DioException catch (e) {
        var stackTrace = 'A request exception has occured in $path: ${e.toString()}';
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
        AppLogger.logInfo('Auth loaded from local cache');
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

  @override
  Future<Either<Failure, bool>> forgotPassword({required String email}) async {
    final path = '$repositoryPath.forgotPassword';
    if (await networkInfo.isConnected) {
      try {
        await remoteSource.getAuthApiService.forgotPassword(email: email);
        // Success
        AppLogger.logInfo('Resetting Password...');
        return const Right(true);
      } on AuthException catch (e) {
        var stackTrace = 'An auth exception has occured in $path: ${e.toString()}';
        return Left(_getServerFailure(stackTrace, message: e.message, statusCode: e.statusCode));
      } on DioException catch (e) {
        var stackTrace = 'A request exception has occured in $path: ${e.toString()}';
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
        AppLogger.logInfo('Auth loaded from local cache');
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

  @override
  Future<Either<Failure, UserResponse>> changePassword({required String password}) async {
    final path = '$repositoryPath.changePassword';
    if (await networkInfo.isConnected) {
      try {
        final remote = await remoteSource.getAuthApiService.changePassword(password: password);
        if (remote.user == null) {
          throw _genericException;
        }
        // Success
        AppLogger.logInfo('Auth remote operation completed');
        return Right(remote);
      } on AuthException catch (e) {
        var stackTrace = 'An auth exception has occured in $path: ${e.toString()}';
        return Left(_getServerFailure(stackTrace, message: e.message, statusCode: e.statusCode));
      } on DioException catch (e) {
        var stackTrace = 'A request exception has occured in $path: ${e.toString()}';
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
        AppLogger.logInfo('Auth loaded from local cache');
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
    AppLogger.logError('Auth operation failed');
    return failure;
  }

  CacheFailure _getCacheFailure(String stackTrace, {String? message, String? statusCode}) {
    final failure = CacheFailure(
      error: DataError(stackTrace: stackTrace, message: message, statusCode: statusCode),
    );
    AppLogger.logError('Auth operation failed');
    return failure;
  }

  NetworkFailure _getNetworkFailure(String errorPath) {
    const message = 'A network failure has occured';
    final stackTrace = '$message in $errorPath';
    final failure = NetworkFailure(
      error: DataError(stackTrace: stackTrace, message: message),
    );
    AppLogger.logError('Auth operation failed');
    return failure;
  }

  Exception get _genericException => Exception('Failed to get data from source');
}
