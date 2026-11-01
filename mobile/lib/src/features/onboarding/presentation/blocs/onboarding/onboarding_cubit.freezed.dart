// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
OnboardingState _$OnboardingStateFromJson(
  Map<String, dynamic> json
) {
    return _OnboardingStateIdle.fromJson(
      json
    );
}

/// @nodoc
mixin _$OnboardingState {

 int get slideIndex; String? get name; String? get ageRange; String? get gender; String? get frequency; String? get goal; String? get challenge; String? get captureTime; bool? get hasUsedOtherApps; bool? get wantsDailyReminders; bool? get didAllowNotifications; List<String> get selectedUseCases;
/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingStateCopyWith<OnboardingState> get copyWith => _$OnboardingStateCopyWithImpl<OnboardingState>(this as OnboardingState, _$identity);

  /// Serializes this OnboardingState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingState&&(identical(other.slideIndex, slideIndex) || other.slideIndex == slideIndex)&&(identical(other.name, name) || other.name == name)&&(identical(other.ageRange, ageRange) || other.ageRange == ageRange)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.challenge, challenge) || other.challenge == challenge)&&(identical(other.captureTime, captureTime) || other.captureTime == captureTime)&&(identical(other.hasUsedOtherApps, hasUsedOtherApps) || other.hasUsedOtherApps == hasUsedOtherApps)&&(identical(other.wantsDailyReminders, wantsDailyReminders) || other.wantsDailyReminders == wantsDailyReminders)&&(identical(other.didAllowNotifications, didAllowNotifications) || other.didAllowNotifications == didAllowNotifications)&&const DeepCollectionEquality().equals(other.selectedUseCases, selectedUseCases));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slideIndex,name,ageRange,gender,frequency,goal,challenge,captureTime,hasUsedOtherApps,wantsDailyReminders,didAllowNotifications,const DeepCollectionEquality().hash(selectedUseCases));

@override
String toString() {
  return 'OnboardingState(slideIndex: $slideIndex, name: $name, ageRange: $ageRange, gender: $gender, frequency: $frequency, goal: $goal, challenge: $challenge, captureTime: $captureTime, hasUsedOtherApps: $hasUsedOtherApps, wantsDailyReminders: $wantsDailyReminders, didAllowNotifications: $didAllowNotifications, selectedUseCases: $selectedUseCases)';
}


}

/// @nodoc
abstract mixin class $OnboardingStateCopyWith<$Res>  {
  factory $OnboardingStateCopyWith(OnboardingState value, $Res Function(OnboardingState) _then) = _$OnboardingStateCopyWithImpl;
@useResult
$Res call({
 int slideIndex, String? name, String? ageRange, String? gender, String? frequency, String? goal, String? challenge, String? captureTime, bool? hasUsedOtherApps, bool? wantsDailyReminders, bool? didAllowNotifications, List<String> selectedUseCases
});




}
/// @nodoc
class _$OnboardingStateCopyWithImpl<$Res>
    implements $OnboardingStateCopyWith<$Res> {
  _$OnboardingStateCopyWithImpl(this._self, this._then);

  final OnboardingState _self;
  final $Res Function(OnboardingState) _then;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slideIndex = null,Object? name = freezed,Object? ageRange = freezed,Object? gender = freezed,Object? frequency = freezed,Object? goal = freezed,Object? challenge = freezed,Object? captureTime = freezed,Object? hasUsedOtherApps = freezed,Object? wantsDailyReminders = freezed,Object? didAllowNotifications = freezed,Object? selectedUseCases = null,}) {
  return _then(_self.copyWith(
slideIndex: null == slideIndex ? _self.slideIndex : slideIndex // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,ageRange: freezed == ageRange ? _self.ageRange : ageRange // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,frequency: freezed == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String?,goal: freezed == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as String?,challenge: freezed == challenge ? _self.challenge : challenge // ignore: cast_nullable_to_non_nullable
as String?,captureTime: freezed == captureTime ? _self.captureTime : captureTime // ignore: cast_nullable_to_non_nullable
as String?,hasUsedOtherApps: freezed == hasUsedOtherApps ? _self.hasUsedOtherApps : hasUsedOtherApps // ignore: cast_nullable_to_non_nullable
as bool?,wantsDailyReminders: freezed == wantsDailyReminders ? _self.wantsDailyReminders : wantsDailyReminders // ignore: cast_nullable_to_non_nullable
as bool?,didAllowNotifications: freezed == didAllowNotifications ? _self.didAllowNotifications : didAllowNotifications // ignore: cast_nullable_to_non_nullable
as bool?,selectedUseCases: null == selectedUseCases ? _self.selectedUseCases : selectedUseCases // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingState].
extension OnboardingStatePatterns on OnboardingState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _OnboardingStateIdle value)?  idle,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingStateIdle() when idle != null:
return idle(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _OnboardingStateIdle value)  idle,}){
final _that = this;
switch (_that) {
case _OnboardingStateIdle():
return idle(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _OnboardingStateIdle value)?  idle,}){
final _that = this;
switch (_that) {
case _OnboardingStateIdle() when idle != null:
return idle(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int slideIndex,  String? name,  String? ageRange,  String? gender,  String? frequency,  String? goal,  String? challenge,  String? captureTime,  bool? hasUsedOtherApps,  bool? wantsDailyReminders,  bool? didAllowNotifications,  List<String> selectedUseCases)?  idle,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingStateIdle() when idle != null:
return idle(_that.slideIndex,_that.name,_that.ageRange,_that.gender,_that.frequency,_that.goal,_that.challenge,_that.captureTime,_that.hasUsedOtherApps,_that.wantsDailyReminders,_that.didAllowNotifications,_that.selectedUseCases);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int slideIndex,  String? name,  String? ageRange,  String? gender,  String? frequency,  String? goal,  String? challenge,  String? captureTime,  bool? hasUsedOtherApps,  bool? wantsDailyReminders,  bool? didAllowNotifications,  List<String> selectedUseCases)  idle,}) {final _that = this;
switch (_that) {
case _OnboardingStateIdle():
return idle(_that.slideIndex,_that.name,_that.ageRange,_that.gender,_that.frequency,_that.goal,_that.challenge,_that.captureTime,_that.hasUsedOtherApps,_that.wantsDailyReminders,_that.didAllowNotifications,_that.selectedUseCases);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int slideIndex,  String? name,  String? ageRange,  String? gender,  String? frequency,  String? goal,  String? challenge,  String? captureTime,  bool? hasUsedOtherApps,  bool? wantsDailyReminders,  bool? didAllowNotifications,  List<String> selectedUseCases)?  idle,}) {final _that = this;
switch (_that) {
case _OnboardingStateIdle() when idle != null:
return idle(_that.slideIndex,_that.name,_that.ageRange,_that.gender,_that.frequency,_that.goal,_that.challenge,_that.captureTime,_that.hasUsedOtherApps,_that.wantsDailyReminders,_that.didAllowNotifications,_that.selectedUseCases);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OnboardingStateIdle implements OnboardingState {
  const _OnboardingStateIdle({this.slideIndex = 0, this.name, this.ageRange, this.gender, this.frequency, this.goal, this.challenge, this.captureTime, this.hasUsedOtherApps, this.wantsDailyReminders, this.didAllowNotifications, final  List<String> selectedUseCases = const []}): _selectedUseCases = selectedUseCases;
  factory _OnboardingStateIdle.fromJson(Map<String, dynamic> json) => _$OnboardingStateIdleFromJson(json);

@override@JsonKey() final  int slideIndex;
@override final  String? name;
@override final  String? ageRange;
@override final  String? gender;
@override final  String? frequency;
@override final  String? goal;
@override final  String? challenge;
@override final  String? captureTime;
@override final  bool? hasUsedOtherApps;
@override final  bool? wantsDailyReminders;
@override final  bool? didAllowNotifications;
 final  List<String> _selectedUseCases;
@override@JsonKey() List<String> get selectedUseCases {
  if (_selectedUseCases is EqualUnmodifiableListView) return _selectedUseCases;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedUseCases);
}


/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingStateIdleCopyWith<_OnboardingStateIdle> get copyWith => __$OnboardingStateIdleCopyWithImpl<_OnboardingStateIdle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OnboardingStateIdleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingStateIdle&&(identical(other.slideIndex, slideIndex) || other.slideIndex == slideIndex)&&(identical(other.name, name) || other.name == name)&&(identical(other.ageRange, ageRange) || other.ageRange == ageRange)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.challenge, challenge) || other.challenge == challenge)&&(identical(other.captureTime, captureTime) || other.captureTime == captureTime)&&(identical(other.hasUsedOtherApps, hasUsedOtherApps) || other.hasUsedOtherApps == hasUsedOtherApps)&&(identical(other.wantsDailyReminders, wantsDailyReminders) || other.wantsDailyReminders == wantsDailyReminders)&&(identical(other.didAllowNotifications, didAllowNotifications) || other.didAllowNotifications == didAllowNotifications)&&const DeepCollectionEquality().equals(other._selectedUseCases, _selectedUseCases));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slideIndex,name,ageRange,gender,frequency,goal,challenge,captureTime,hasUsedOtherApps,wantsDailyReminders,didAllowNotifications,const DeepCollectionEquality().hash(_selectedUseCases));

@override
String toString() {
  return 'OnboardingState.idle(slideIndex: $slideIndex, name: $name, ageRange: $ageRange, gender: $gender, frequency: $frequency, goal: $goal, challenge: $challenge, captureTime: $captureTime, hasUsedOtherApps: $hasUsedOtherApps, wantsDailyReminders: $wantsDailyReminders, didAllowNotifications: $didAllowNotifications, selectedUseCases: $selectedUseCases)';
}


}

/// @nodoc
abstract mixin class _$OnboardingStateIdleCopyWith<$Res> implements $OnboardingStateCopyWith<$Res> {
  factory _$OnboardingStateIdleCopyWith(_OnboardingStateIdle value, $Res Function(_OnboardingStateIdle) _then) = __$OnboardingStateIdleCopyWithImpl;
@override @useResult
$Res call({
 int slideIndex, String? name, String? ageRange, String? gender, String? frequency, String? goal, String? challenge, String? captureTime, bool? hasUsedOtherApps, bool? wantsDailyReminders, bool? didAllowNotifications, List<String> selectedUseCases
});




}
/// @nodoc
class __$OnboardingStateIdleCopyWithImpl<$Res>
    implements _$OnboardingStateIdleCopyWith<$Res> {
  __$OnboardingStateIdleCopyWithImpl(this._self, this._then);

  final _OnboardingStateIdle _self;
  final $Res Function(_OnboardingStateIdle) _then;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slideIndex = null,Object? name = freezed,Object? ageRange = freezed,Object? gender = freezed,Object? frequency = freezed,Object? goal = freezed,Object? challenge = freezed,Object? captureTime = freezed,Object? hasUsedOtherApps = freezed,Object? wantsDailyReminders = freezed,Object? didAllowNotifications = freezed,Object? selectedUseCases = null,}) {
  return _then(_OnboardingStateIdle(
slideIndex: null == slideIndex ? _self.slideIndex : slideIndex // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,ageRange: freezed == ageRange ? _self.ageRange : ageRange // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,frequency: freezed == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String?,goal: freezed == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as String?,challenge: freezed == challenge ? _self.challenge : challenge // ignore: cast_nullable_to_non_nullable
as String?,captureTime: freezed == captureTime ? _self.captureTime : captureTime // ignore: cast_nullable_to_non_nullable
as String?,hasUsedOtherApps: freezed == hasUsedOtherApps ? _self.hasUsedOtherApps : hasUsedOtherApps // ignore: cast_nullable_to_non_nullable
as bool?,wantsDailyReminders: freezed == wantsDailyReminders ? _self.wantsDailyReminders : wantsDailyReminders // ignore: cast_nullable_to_non_nullable
as bool?,didAllowNotifications: freezed == didAllowNotifications ? _self.didAllowNotifications : didAllowNotifications // ignore: cast_nullable_to_non_nullable
as bool?,selectedUseCases: null == selectedUseCases ? _self._selectedUseCases : selectedUseCases // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
