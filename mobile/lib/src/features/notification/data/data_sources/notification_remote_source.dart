import 'package:injectable/injectable.dart';

import 'services/_services.dart';

@lazySingleton
abstract class NotificationRemoteSource {
  @factoryMethod
  const factory NotificationRemoteSource({required NotificationApiService notificationApiService}) =
      _NotificationRemoteSourceImpl;

  NotificationApiService get getNotificationApiService;
}

class _NotificationRemoteSourceImpl implements NotificationRemoteSource {
  final NotificationApiService notificationApiService;

  const _NotificationRemoteSourceImpl({required this.notificationApiService});

  @override
  NotificationApiService get getNotificationApiService => notificationApiService;
}
