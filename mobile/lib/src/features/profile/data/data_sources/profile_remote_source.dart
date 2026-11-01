import 'package:injectable/injectable.dart';

import 'services/_services.dart';

@lazySingleton
abstract class ProfileRemoteSource {
  @factoryMethod
  const factory ProfileRemoteSource({required ProfileApiService profileApiService}) =
      _ProfileRemoteSourceImpl;

  ProfileApiService get getProfileApiService;
}

class _ProfileRemoteSourceImpl implements ProfileRemoteSource {
  final ProfileApiService profileApiService;

  const _ProfileRemoteSourceImpl({required this.profileApiService});

  @override
  ProfileApiService get getProfileApiService => profileApiService;
}
