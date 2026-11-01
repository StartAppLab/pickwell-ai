import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

@lazySingleton
abstract class NetworkInfo {
  @factoryMethod
  const factory NetworkInfo({required InternetConnection connectionChecker}) = _NetworkInfoImpl;

  Future<bool> get isConnected;
}

class _NetworkInfoImpl implements NetworkInfo {
  final InternetConnection connectionChecker;

  const _NetworkInfoImpl({required this.connectionChecker});

  @override
  Future<bool> get isConnected => connectionChecker.hasInternetAccess;
}
