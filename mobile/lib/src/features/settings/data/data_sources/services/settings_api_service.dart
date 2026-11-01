import 'package:dio/dio.dart' hide Headers;
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../../config/_config.dart';
import '../../models/_models.dart';

part 'settings_api_service.g.dart';

abstract class SettingsApiService {
  Future<SettingsModel?> getSettings({required int id});
}

@RestApi()
@Injectable(as: SettingsApiService)
abstract class SettingsApiServiceImpl implements SettingsApiService {
  @factoryMethod
  factory SettingsApiServiceImpl(Dio dio, AppConfig appConfig) =>
      _SettingsApiServiceImpl(dio, baseUrl: appConfig.baseUrl);

  @override
  @GET('/settingss/{id}')
  Future<SettingsModel?> getSettings({@Path('id') required int id});
}
