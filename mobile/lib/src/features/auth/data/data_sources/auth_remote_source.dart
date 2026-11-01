import 'package:injectable/injectable.dart';

import 'services/_services.dart';

@lazySingleton
abstract class AuthRemoteSource {
  @factoryMethod
  const factory AuthRemoteSource({required AuthApiService authApiService}) = _AuthRemoteSourceImpl;

  AuthApiService get getAuthApiService;
}

class _AuthRemoteSourceImpl implements AuthRemoteSource {
  final AuthApiService authApiService;

  const _AuthRemoteSourceImpl({required this.authApiService});

  @override
  AuthApiService get getAuthApiService => authApiService;
}
