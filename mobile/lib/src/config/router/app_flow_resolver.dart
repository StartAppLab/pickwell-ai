import '../../features/onboarding/presentation/blocs/onboarding/onboarding_cubit.dart';
import '../../features/paywall/presentation/utils/onboarding_paywall_access.dart';
import '../app_config.dart';
import '../app_features.dart';
import '../app_session.dart';
import '../injection_container.dart';
import 'app_router.dart';
import 'consumer_route_policy.dart';

/// Chooses flow destinations; route access guards remain in ConsumerRoutePolicy.
class AppFlowResolver {
  const AppFlowResolver._();

  static bool needsOnboarding({required AppFeatures features, required bool onboardingCompleted}) =>
      features.onboardingEnabled && !onboardingCompleted;

  /// Sign-in, recovery, and debug sign-in resume setup or enter the startup check.
  static String afterAuthentication({
    required AppFeatures features,
    required bool onboardingCompleted,
  }) => needsOnboarding(features: features, onboardingCompleted: onboardingCompleted)
      ? AppRouter.onboardingRoute
      : AppRouter.splashRoute;

  /// A verified Welcome restore resumes setup without repeating the billing check.
  static String afterWelcomeRestore({
    required AppFeatures features,
    required bool onboardingCompleted,
  }) => needsOnboarding(features: features, onboardingCompleted: onboardingCompleted)
      ? AppRouter.onboardingRoute
      : AppRouter.homeRoute;

  /// Startup and completed onboarding share the pending-paywall decision.
  /// Does not consume a requested URL while asynchronous verification is running.
  static Future<String> resolve() async {
    final session = getIt<AppSession>();
    final features = getIt<AppConfig>().features;
    if (features.authEnabled && session.recoveringPassword) {
      return AppRouter.changePasswordRoute;
    }
    if (needsOnboarding(features: features, onboardingCompleted: session.onboardingCompleted)) {
      return getIt<OnboardingCubit>().hasProgress
          ? AppRouter.onboardingRoute
          : AppRouter.welcomeRoute;
    }
    if (features.authMode == AuthMode.required && !session.hasAuthenticatedUi) {
      return AppRouter.signInRoute;
    }
    return await OnboardingPaywallAccess.shouldShow()
        ? AppRouter.onboardingPaywallRoute
        : AppRouter.homeRoute;
  }

  /// Keep the first valid product destination through intermediate auth/setup routes.
  static void rememberRequestedLocation(Uri location) {
    if (location.hasScheme ||
        location.hasAuthority ||
        !location.toString().startsWith('/') ||
        ConsumerRoutePolicy.flowRoutes.contains(location.path)) {
      return;
    }
    final session = getIt<AppSession>();
    final pending = session.pendingReturnLocation;
    if (pending == null || ConsumerRoutePolicy.flowRoutes.contains(Uri.parse(pending).path)) {
      session.returnLocation = location.toString();
    }
  }

  /// Call only once the caller is ready to navigate, after lifecycle/auth checks.
  static String takeLocation(String destination) {
    if (destination != AppRouter.homeRoute) return destination;
    final requested = getIt<AppSession>().takeReturnLocation();
    if (requested == null || ConsumerRoutePolicy.flowRoutes.contains(Uri.parse(requested).path)) {
      return AppRouter.homeRoute;
    }
    return requested;
  }
}
