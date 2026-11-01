import '../_config.dart';

class AppFlavor extends AppConfig {
  static AppFlavor config = const AppFlavor.dev();
  final Flavor flavor;

  const AppFlavor.dev() : this._(Flavor.dev);
  const AppFlavor.stg() : this._(Flavor.stg);
  const AppFlavor.prod() : this._(Flavor.prod);

  const AppFlavor._(this.flavor)
    : super(
        baseUrl: const String.fromEnvironment('SERVER_BASE_URL'),
        apiKey: const String.fromEnvironment('SERVER_API_KEY'),
        sentryDsn: const String.fromEnvironment('SENTRY_DSN'),
        postHogApiKey: const String.fromEnvironment('POSTHOG_API_KEY'),
        postHogHost: const String.fromEnvironment('POSTHOG_HOST'),
        revenueCatAndroidApiKey: const String.fromEnvironment('REVENUECAT_ANDROID_API_KEY'),
        revenueCatiOSApiKey: const String.fromEnvironment('REVENUECAT_IOS_API_KEY'),
        revenueCatEntitlementId: const String.fromEnvironment(
          'REVENUECAT_ENTITLEMENT_ID',
          defaultValue: 'premium',
        ),
      );

  @override
  AppFeatures get features => AppFeatures.fromEnvironment();
}
