import '../../../../config/_config.dart';
import '../blocs/subscription/subscription_cubit.dart';

/// Decides only the optional onboarding paywall; authentication is routed separately.
class OnboardingPaywallAccess {
  const OnboardingPaywallAccess._();

  static Future<bool> shouldShow() async {
    final config = getIt<AppConfig>();
    final session = getIt<AppSession>();
    if (!config.features.onboardingEnabled ||
        !config.features.billingEnabled ||
        !config.features.onboardingPaywallEnabled ||
        !session.onboardingCompleted ||
        session.onboardingPaywallCompleted) {
      return false;
    }

    final subscription = getIt<SubscriptionCubit>();
    final identityRevision = subscription.identityRevision;
    final userId = session.userId;
    if (!subscription.state.isInitialized) {
      await subscription.init(userId: userId);
    } else {
      await subscription.refresh();
    }
    final state = subscription.state;
    if (subscription.isClosed ||
        identityRevision != subscription.identityRevision ||
        userId != session.userId ||
        state.isLoading ||
        state.errorText != null ||
        state.entitlementSnapshot == null ||
        state.entitlementSnapshot!.subjectId != userId) {
      throw StateError('Unable to verify onboarding subscription access.');
    }

    if (!subscription.hasAccess(entitlementId: config.revenueCatEntitlementId)) return true;
    // A bypass is a completed presentation step, not a new purchase or authentication.
    await session.completeOnboardingPaywall();
    return false;
  }
}
