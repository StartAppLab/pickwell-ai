import 'package:injectable/injectable.dart';

import 'services/_services.dart';

@lazySingleton
abstract class PaywallRemoteSource {
  @factoryMethod
  const factory PaywallRemoteSource({required PaywallApiService paywallApiService}) =
      _PaywallRemoteSourceImpl;

  PaywallApiService get getPaywallApiService;
}

class _PaywallRemoteSourceImpl implements PaywallRemoteSource {
  final PaywallApiService paywallApiService;

  const _PaywallRemoteSourceImpl({required this.paywallApiService});

  @override
  PaywallApiService get getPaywallApiService => paywallApiService;
}
