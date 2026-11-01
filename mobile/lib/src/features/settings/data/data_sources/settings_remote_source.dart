import 'package:injectable/injectable.dart';

import 'services/_services.dart';

@lazySingleton
abstract class SettingsRemoteSource {
  @factoryMethod
  const factory SettingsRemoteSource({required SettingsApiService settingsApiService}) =
      _SettingsRemoteSourceImpl;

  SettingsApiService get getSettingsApiService;
}

class _SettingsRemoteSourceImpl implements SettingsRemoteSource {
  final SettingsApiService settingsApiService;

  const _SettingsRemoteSourceImpl({required this.settingsApiService});

  @override
  SettingsApiService get getSettingsApiService => settingsApiService;
}
