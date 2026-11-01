import '../app_features.dart';
import 'app_flow_resolver.dart';

/// Pure route decisions, shared by the router and the consumer-mode tests.
class ConsumerRoutePolicy {
  static const authRoutes = {'/auth-options', '/sign-in', '/sign-up', '/otp', '/forgot-password'};
  static const accountRoutes = {'/profile', '/settings-account', '/change-password'};
  static const legalRoutes = {'/terms-of-use', '/privacy-policy'};
  static const onboardingRoutes = {'/welcome', '/onboarding'};
  static const flowRoutes = {'/', ...authRoutes, ...onboardingRoutes, '/onboarding-paywall'};

  static String? redirect({
    required AppFeatures features,
    required bool isAuthenticated,
    required bool recoveringPassword,
    required bool onboardingCompleted,
    required String path,
    bool debugGuestMode = false,
  }) {
    if (recoveringPassword &&
        features.authEnabled &&
        path != '/change-password' &&
        !legalRoutes.contains(path)) {
      return '/change-password';
    }
    if (!features.authEnabled && (authRoutes.contains(path) || accountRoutes.contains(path))) {
      return '/home';
    }
    if (!features.billingEnabled &&
        {'/paywall', '/onboarding-paywall', '/settings-subscription-debug'}.contains(path)) {
      return '/home';
    }
    if (path == '/onboarding-paywall' &&
        (!features.onboardingEnabled || !features.onboardingPaywallEnabled)) {
      return '/home';
    }
    if (!features.notificationsEnabled &&
        {'/notification', '/settings-notifications'}.contains(path)) {
      return '/home';
    }
    if (!features.onboardingEnabled && onboardingRoutes.contains(path)) return '/home';
    if (path == '/') return null;
    if (AppFlowResolver.needsOnboarding(
          features: features,
          onboardingCompleted: onboardingCompleted,
        ) &&
        path == '/home') {
      return '/welcome';
    }
    if (features.authEnabled &&
        !isAuthenticated &&
        !debugGuestMode &&
        accountRoutes.contains(path)) {
      return '/sign-in';
    }
    if (features.authMode == AuthMode.required &&
        !isAuthenticated &&
        !debugGuestMode &&
        !authRoutes.contains(path) &&
        !legalRoutes.contains(path) &&
        !onboardingRoutes.contains(path)) {
      return '/sign-in';
    }
    if (isAuthenticated && authRoutes.contains(path)) {
      // Startup verifies any pending paywall before consuming the intended destination.
      return AppFlowResolver.afterAuthentication(
        features: features,
        onboardingCompleted: onboardingCompleted,
      );
    }
    return null;
  }
}
