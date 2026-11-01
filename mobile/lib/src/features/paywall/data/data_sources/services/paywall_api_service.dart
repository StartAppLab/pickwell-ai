import 'package:dio/dio.dart' hide Headers;
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../../config/_config.dart';
import '../../models/_models.dart';

part 'paywall_api_service.g.dart';

abstract class PaywallApiService {
  Future<PaywallModel?> getPaywall({required int id});
}

@RestApi()
@Injectable(as: PaywallApiService)
abstract class PaywallApiServiceImpl implements PaywallApiService {
  @factoryMethod
  factory PaywallApiServiceImpl(Dio dio, AppConfig appConfig) =>
      _PaywallApiServiceImpl(dio, baseUrl: appConfig.baseUrl);

  @override
  @GET('/paywalls/{id}')
  Future<PaywallModel?> getPaywall({@Path('id') required int id});
}
