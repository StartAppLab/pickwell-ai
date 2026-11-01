import 'dart:convert';

enum AuthMode { disabled, optional, required }

/// Product choices for a consumer app. Disabled integrations need no credentials.
class AppFeatures {
  const AppFeatures({
    this.authMode = AuthMode.disabled,
    this.backendEnabled = false,
    this.billingEnabled = false,
    this.onboardingEnabled = false,
    this.notificationsEnabled = true,
    this.analyticsEnabled = false,
    this.crashReportingEnabled = false,
    this.googleSignInEnabled = false,
    this.appleSignInEnabled = false,
    this.onboardingPaywallEnabled = false,
    this.featureEntitlements = const {},
    this.featureOfferings = const {},
  });

  factory AppFeatures.fromEnvironment() {
    const auth = String.fromEnvironment('AUTH_MODE', defaultValue: 'disabled');
    const billing = String.fromEnvironment('BILLING_MODE', defaultValue: 'disabled');
    final mode = AuthMode.values.where((value) => value.name == auth).firstOrNull;
    if (mode == null) throw ArgumentError('AUTH_MODE must be disabled, optional, or required.');
    if (!{'disabled', 'revenuecat'}.contains(billing)) {
      throw ArgumentError('BILLING_MODE must be disabled or revenuecat.');
    }
    const mappings = String.fromEnvironment('FEATURE_ENTITLEMENTS', defaultValue: '{}');
    final decoded = jsonDecode(mappings);
    if (decoded is! Map<String, dynamic> || decoded.values.any((v) => v is! String && v != null)) {
      throw ArgumentError('FEATURE_ENTITLEMENTS must map feature keys to entitlement IDs or null.');
    }
    const offerings = String.fromEnvironment('FEATURE_OFFERINGS', defaultValue: '{}');
    final offeringMap = jsonDecode(offerings);
    if (offeringMap is! Map<String, dynamic> || offeringMap.values.any((v) => v is! String)) {
      throw ArgumentError('FEATURE_OFFERINGS must map feature keys to offering IDs.');
    }
    return AppFeatures(
      authMode: mode,
      backendEnabled: const bool.fromEnvironment('BACKEND_ENABLED') || mode != AuthMode.disabled,
      billingEnabled: billing == 'revenuecat',
      onboardingEnabled: const bool.fromEnvironment('ONBOARDING_ENABLED'),
      notificationsEnabled: const bool.fromEnvironment('NOTIFICATIONS_ENABLED', defaultValue: true),
      analyticsEnabled: const bool.fromEnvironment('ANALYTICS_ENABLED'),
      crashReportingEnabled: const bool.fromEnvironment(
        'CRASH_REPORTING_ENABLED',
        defaultValue: false,
      ),
      googleSignInEnabled: const bool.fromEnvironment('GOOGLE_SIGN_IN_ENABLED'),
      appleSignInEnabled: const bool.fromEnvironment('APPLE_SIGN_IN_ENABLED'),
      onboardingPaywallEnabled: const bool.fromEnvironment(
        'ONBOARDING_PAYWALL_ENABLED',
        defaultValue: false,
      ),
      featureEntitlements: Map<String, String?>.unmodifiable(decoded.cast<String, String?>()),
      featureOfferings: Map<String, String>.unmodifiable(offeringMap.cast<String, String>()),
    );
  }

  final AuthMode authMode;
  final bool backendEnabled;
  final bool billingEnabled;
  final bool onboardingEnabled;
  final bool notificationsEnabled;
  final bool analyticsEnabled;
  final bool crashReportingEnabled;
  final bool googleSignInEnabled;
  final bool appleSignInEnabled;
  final bool onboardingPaywallEnabled;

  /// A null entitlement marks a feature as free; unknown named features are unavailable.
  /// Guards without a feature key use the configured default premium entitlement.
  final Map<String, String?> featureEntitlements;
  final Map<String, String> featureOfferings;

  bool get authEnabled => authMode != AuthMode.disabled;
}
