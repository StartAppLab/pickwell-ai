part of 'paywall_cubit.dart';

@freezed
abstract class PaywallState with _$PaywallState {
  const factory PaywallState.idle({
    @Default(0) int slideIndex,
    @Default('') String selectedPlan,
    @Default(false) bool isLoading,
    DataError? error,
    @Default(false) bool isSuccess,
    @Default(false) bool isPurchaseSuccess,
    String? errorText,
    Offerings? offerings,
    Offering? offering,
  }) = _PaywallStateIdle;
}
