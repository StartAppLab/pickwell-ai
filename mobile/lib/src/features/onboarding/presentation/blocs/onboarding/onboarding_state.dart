part of 'onboarding_cubit.dart';

@freezed
abstract class OnboardingState with _$OnboardingState {
  const factory OnboardingState.idle({
    @Default(0) int slideIndex,
    String? name,
    String? ageRange,
    String? gender,
    String? frequency,
    String? goal,
    String? challenge,
    String? captureTime,
    bool? hasUsedOtherApps,
    bool? wantsDailyReminders,
    bool? didAllowNotifications,
    @Default([]) List<String> selectedUseCases,
  }) = _OnboardingStateIdle;

  factory OnboardingState.fromJson(Map<String, dynamic> json) => _$OnboardingStateFromJson(json);
}
