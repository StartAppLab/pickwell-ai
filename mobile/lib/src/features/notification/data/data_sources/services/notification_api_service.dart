import 'package:dio/dio.dart' hide Headers;
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../../config/_config.dart';
import '../../models/_models.dart';

part 'notification_api_service.g.dart';

abstract class NotificationApiService {
  Future<NotificationModel?> getNotification({required int id});
}

@RestApi()
@Injectable(as: NotificationApiService)
abstract class NotificationApiServiceImpl implements NotificationApiService {
  @factoryMethod
  factory NotificationApiServiceImpl(Dio dio, AppConfig appConfig) =>
      _NotificationApiServiceImpl(dio, baseUrl: appConfig.baseUrl);

  @override
  @GET('/notifications/{id}')
  Future<NotificationModel?> getNotification({@Path('id') required int id});
}
