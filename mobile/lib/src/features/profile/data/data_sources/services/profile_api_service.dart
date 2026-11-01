import 'package:dio/dio.dart' hide Headers;
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../../config/_config.dart';
import '../../models/_models.dart';

part 'profile_api_service.g.dart';

abstract class ProfileApiService {
  Future<ProfileModel?> getProfile({required int id});
}

@RestApi()
@Injectable(as: ProfileApiService)
abstract class ProfileApiServiceImpl implements ProfileApiService {
  @factoryMethod
  factory ProfileApiServiceImpl(Dio dio, AppConfig appConfig) =>
      _ProfileApiServiceImpl(dio, baseUrl: appConfig.baseUrl);

  @override
  @GET('/profiles/{id}')
  Future<ProfileModel?> getProfile({@Path('id') required int id});
}
