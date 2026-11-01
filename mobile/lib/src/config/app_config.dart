import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'app_features.dart';

@singleton
class AppConfig {
  final AppFeatures features;
  final String baseUrl;
  final String apiKey;
  final String sentryDsn;
  final String postHogApiKey;
  final String postHogHost;
  final String revenueCatAndroidApiKey;
  final String revenueCatiOSApiKey;
  final String revenueCatEntitlementId;

  @factoryMethod
  const AppConfig({
    @Named('features') this.features = const AppFeatures(),
    @Named('baseUrl') required this.baseUrl,
    @Named('apiKey') required this.apiKey,
    @Named('sentryDsn') required this.sentryDsn,
    @Named('postHogApiKey') required this.postHogApiKey,
    @Named('postHogHost') required this.postHogHost,
    @Named('revenueCatAndroidApiKey') required this.revenueCatAndroidApiKey,
    @Named('revenueCatiOSApiKey') required this.revenueCatiOSApiKey,
    @Named('revenueCatEntitlementId') required this.revenueCatEntitlementId,
  });

  String get appName => const String.fromEnvironment('APP_NAME', defaultValue: 'Pickwell');
  String get authRedirectUrl => const String.fromEnvironment(
    'AUTH_REDIRECT_URL',
    defaultValue: 'com.startapplab.pickwell://auth-callback',
  );
  String get termsUrl => const String.fromEnvironment('TERMS_URL');
  String get privacyUrl => const String.fromEnvironment('PRIVACY_URL');
  String get supportUrl => const String.fromEnvironment('SUPPORT_URL');
  String get storeUrlAndroid => const String.fromEnvironment('STORE_URL_ANDROID');
  String get storeUrliOS => const String.fromEnvironment('STORE_URL_IOS');
  String get storeUrlForCurrentPlatform => switch (defaultTargetPlatform) {
    TargetPlatform.android => storeUrlAndroid,
    TargetPlatform.iOS => storeUrliOS,
    _ => '',
  };

  String get revenueCatApiKeyForCurrentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return revenueCatiOSApiKey;
      case TargetPlatform.android:
        return revenueCatAndroidApiKey;
      default:
        throw UnsupportedError('RevenueCat billing requires iOS or Android.');
    }
  }

  void validate() {
    void requireValue(String name, String value) {
      if (value.trim().isEmpty || value.contains('{{') || value.toLowerCase().contains('your_')) {
        throw ArgumentError('Set $name before enabling its integration.');
      }
    }

    requireValue('APP_NAME', appName);
    // Reject privileged credentials before bootstrap, including disabled profiles.
    // This is configuration hygiene, not a substitute for server authorization.
    if (apiKey.isNotEmpty) {
      var publicKey =
          apiKey.startsWith('sb_publishable_') &&
          apiKey.length > 'sb_publishable_'.length &&
          apiKey == apiKey.trim();
      if (!publicKey) {
        try {
          final parts = apiKey.split('.');
          if (parts.length == 3) {
            final payload = jsonDecode(
              utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
            );
            publicKey = payload is Map<String, dynamic> && payload['role'] == 'anon';
          }
        } on FormatException {
          // Never include the key or decoder error in startup logs.
        }
      }
      if (!publicKey) {
        throw ArgumentError('SERVER_API_KEY requires a public Supabase key.');
      }
    }
    if (features.authEnabled && !features.backendEnabled) {
      throw ArgumentError('Authentication requires BACKEND_ENABLED.');
    }
    if (features.backendEnabled) {
      requireValue('SERVER_BASE_URL', baseUrl);
      requireValue('SERVER_API_KEY', apiKey);
      if (Uri.tryParse(baseUrl)?.hasScheme != true) {
        throw ArgumentError('SERVER_BASE_URL must be a URL.');
      }
    }
    if (features.authEnabled) requireValue('AUTH_REDIRECT_URL', authRedirectUrl);
    if (features.billingEnabled) {
      final keyName = defaultTargetPlatform == TargetPlatform.iOS
          ? 'REVENUECAT_IOS_API_KEY'
          : 'REVENUECAT_ANDROID_API_KEY';
      requireValue(keyName, revenueCatApiKeyForCurrentPlatform);
      requireValue('REVENUECAT_ENTITLEMENT_ID', revenueCatEntitlementId);
      for (final entitlement in features.featureEntitlements.values) {
        if (entitlement != null) requireValue('FEATURE_ENTITLEMENTS', entitlement);
      }
      for (final offering in features.featureOfferings.values) {
        requireValue('FEATURE_OFFERINGS', offering);
      }
    }
    if (features.analyticsEnabled) {
      requireValue('POSTHOG_API_KEY', postHogApiKey);
      requireValue('POSTHOG_HOST', postHogHost);
    }
    if (features.crashReportingEnabled) requireValue('SENTRY_DSN', sentryDsn);
    if (features.onboardingPaywallEnabled && !features.billingEnabled) {
      throw ArgumentError('ONBOARDING_PAYWALL_ENABLED requires BILLING_MODE=revenuecat.');
    }
  }
}
