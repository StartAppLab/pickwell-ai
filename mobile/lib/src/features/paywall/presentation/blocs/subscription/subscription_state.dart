part of 'subscription_cubit.dart';

@freezed
abstract class SubscriptionState with _$SubscriptionState {
  const factory SubscriptionState.idle({
    @Default(false) bool isInitialized,
    @Default(false) bool isLoading,
    @Default(false) bool isPremium,
    @Default(false) bool isTrialActive,
    CustomerInfo? customerInfo,
    EntitlementSnapshot? entitlementSnapshot,
    // Time-derived access changes rebuild guards even when the premium summary is unchanged.
    @Default(<String>{}) Set<String> activeEntitlementIds,
    DateTime? lastRefreshedAt,
    String? errorText,
  }) = _SubscriptionStateIdle;
}
