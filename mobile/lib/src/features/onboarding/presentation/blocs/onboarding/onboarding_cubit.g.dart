// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OnboardingStateIdle _$OnboardingStateIdleFromJson(Map<String, dynamic> json) =>
    _OnboardingStateIdle(
      slideIndex: (json['slideIndex'] as num?)?.toInt() ?? 0,
      name: json['name'] as String?,
      ageRange: json['ageRange'] as String?,
      gender: json['gender'] as String?,
      frequency: json['frequency'] as String?,
      goal: json['goal'] as String?,
      challenge: json['challenge'] as String?,
      captureTime: json['captureTime'] as String?,
      hasUsedOtherApps: json['hasUsedOtherApps'] as bool?,
      wantsDailyReminders: json['wantsDailyReminders'] as bool?,
      didAllowNotifications: json['didAllowNotifications'] as bool?,
      selectedUseCases:
          (json['selectedUseCases'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$OnboardingStateIdleToJson(
  _OnboardingStateIdle instance,
) => <String, dynamic>{
  'slideIndex': instance.slideIndex,
  'name': instance.name,
  'ageRange': instance.ageRange,
  'gender': instance.gender,
  'frequency': instance.frequency,
  'goal': instance.goal,
  'challenge': instance.challenge,
  'captureTime': instance.captureTime,
  'hasUsedOtherApps': instance.hasUsedOtherApps,
  'wantsDailyReminders': instance.wantsDailyReminders,
  'didAllowNotifications': instance.didAllowNotifications,
  'selectedUseCases': instance.selectedUseCases,
};
