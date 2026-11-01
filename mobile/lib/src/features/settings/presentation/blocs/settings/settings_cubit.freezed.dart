// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsState {

 LocaleState? get localeState; ThemeState? get themeState; ThemeMode? get themeMode; int get selectedLanguage; int get selectedTheme; int get selectedDarkMode; String? get errorText;
/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsStateCopyWith<SettingsState> get copyWith => _$SettingsStateCopyWithImpl<SettingsState>(this as SettingsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsState&&(identical(other.localeState, localeState) || other.localeState == localeState)&&(identical(other.themeState, themeState) || other.themeState == themeState)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.selectedLanguage, selectedLanguage) || other.selectedLanguage == selectedLanguage)&&(identical(other.selectedTheme, selectedTheme) || other.selectedTheme == selectedTheme)&&(identical(other.selectedDarkMode, selectedDarkMode) || other.selectedDarkMode == selectedDarkMode)&&(identical(other.errorText, errorText) || other.errorText == errorText));
}


@override
int get hashCode => Object.hash(runtimeType,localeState,themeState,themeMode,selectedLanguage,selectedTheme,selectedDarkMode,errorText);

@override
String toString() {
  return 'SettingsState(localeState: $localeState, themeState: $themeState, themeMode: $themeMode, selectedLanguage: $selectedLanguage, selectedTheme: $selectedTheme, selectedDarkMode: $selectedDarkMode, errorText: $errorText)';
}


}

/// @nodoc
abstract mixin class $SettingsStateCopyWith<$Res>  {
  factory $SettingsStateCopyWith(SettingsState value, $Res Function(SettingsState) _then) = _$SettingsStateCopyWithImpl;
@useResult
$Res call({
 LocaleState? localeState, ThemeState? themeState, ThemeMode? themeMode, int selectedLanguage, int selectedTheme, int selectedDarkMode, String? errorText
});




}
/// @nodoc
class _$SettingsStateCopyWithImpl<$Res>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._self, this._then);

  final SettingsState _self;
  final $Res Function(SettingsState) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? localeState = freezed,Object? themeState = freezed,Object? themeMode = freezed,Object? selectedLanguage = null,Object? selectedTheme = null,Object? selectedDarkMode = null,Object? errorText = freezed,}) {
  return _then(_self.copyWith(
localeState: freezed == localeState ? _self.localeState : localeState // ignore: cast_nullable_to_non_nullable
as LocaleState?,themeState: freezed == themeState ? _self.themeState : themeState // ignore: cast_nullable_to_non_nullable
as ThemeState?,themeMode: freezed == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode?,selectedLanguage: null == selectedLanguage ? _self.selectedLanguage : selectedLanguage // ignore: cast_nullable_to_non_nullable
as int,selectedTheme: null == selectedTheme ? _self.selectedTheme : selectedTheme // ignore: cast_nullable_to_non_nullable
as int,selectedDarkMode: null == selectedDarkMode ? _self.selectedDarkMode : selectedDarkMode // ignore: cast_nullable_to_non_nullable
as int,errorText: freezed == errorText ? _self.errorText : errorText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SettingsState].
extension SettingsStatePatterns on SettingsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _SettingsStateIdle value)?  idle,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingsStateIdle() when idle != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _SettingsStateIdle value)  idle,}){
final _that = this;
switch (_that) {
case _SettingsStateIdle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _SettingsStateIdle value)?  idle,}){
final _that = this;
switch (_that) {
case _SettingsStateIdle() when idle != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( LocaleState? localeState,  ThemeState? themeState,  ThemeMode? themeMode,  int selectedLanguage,  int selectedTheme,  int selectedDarkMode,  String? errorText)?  idle,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsStateIdle() when idle != null:
return idle(_that.localeState,_that.themeState,_that.themeMode,_that.selectedLanguage,_that.selectedTheme,_that.selectedDarkMode,_that.errorText);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( LocaleState? localeState,  ThemeState? themeState,  ThemeMode? themeMode,  int selectedLanguage,  int selectedTheme,  int selectedDarkMode,  String? errorText)  idle,}) {final _that = this;
switch (_that) {
case _SettingsStateIdle():
return idle(_that.localeState,_that.themeState,_that.themeMode,_that.selectedLanguage,_that.selectedTheme,_that.selectedDarkMode,_that.errorText);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( LocaleState? localeState,  ThemeState? themeState,  ThemeMode? themeMode,  int selectedLanguage,  int selectedTheme,  int selectedDarkMode,  String? errorText)?  idle,}) {final _that = this;
switch (_that) {
case _SettingsStateIdle() when idle != null:
return idle(_that.localeState,_that.themeState,_that.themeMode,_that.selectedLanguage,_that.selectedTheme,_that.selectedDarkMode,_that.errorText);case _:
  return null;

}
}

}

/// @nodoc


class _SettingsStateIdle implements SettingsState {
  const _SettingsStateIdle({this.localeState, this.themeState, this.themeMode, this.selectedLanguage = -1, this.selectedTheme = 0, this.selectedDarkMode = 0, this.errorText});
  

@override final  LocaleState? localeState;
@override final  ThemeState? themeState;
@override final  ThemeMode? themeMode;
@override@JsonKey() final  int selectedLanguage;
@override@JsonKey() final  int selectedTheme;
@override@JsonKey() final  int selectedDarkMode;
@override final  String? errorText;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsStateIdleCopyWith<_SettingsStateIdle> get copyWith => __$SettingsStateIdleCopyWithImpl<_SettingsStateIdle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsStateIdle&&(identical(other.localeState, localeState) || other.localeState == localeState)&&(identical(other.themeState, themeState) || other.themeState == themeState)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.selectedLanguage, selectedLanguage) || other.selectedLanguage == selectedLanguage)&&(identical(other.selectedTheme, selectedTheme) || other.selectedTheme == selectedTheme)&&(identical(other.selectedDarkMode, selectedDarkMode) || other.selectedDarkMode == selectedDarkMode)&&(identical(other.errorText, errorText) || other.errorText == errorText));
}


@override
int get hashCode => Object.hash(runtimeType,localeState,themeState,themeMode,selectedLanguage,selectedTheme,selectedDarkMode,errorText);

@override
String toString() {
  return 'SettingsState.idle(localeState: $localeState, themeState: $themeState, themeMode: $themeMode, selectedLanguage: $selectedLanguage, selectedTheme: $selectedTheme, selectedDarkMode: $selectedDarkMode, errorText: $errorText)';
}


}

/// @nodoc
abstract mixin class _$SettingsStateIdleCopyWith<$Res> implements $SettingsStateCopyWith<$Res> {
  factory _$SettingsStateIdleCopyWith(_SettingsStateIdle value, $Res Function(_SettingsStateIdle) _then) = __$SettingsStateIdleCopyWithImpl;
@override @useResult
$Res call({
 LocaleState? localeState, ThemeState? themeState, ThemeMode? themeMode, int selectedLanguage, int selectedTheme, int selectedDarkMode, String? errorText
});




}
/// @nodoc
class __$SettingsStateIdleCopyWithImpl<$Res>
    implements _$SettingsStateIdleCopyWith<$Res> {
  __$SettingsStateIdleCopyWithImpl(this._self, this._then);

  final _SettingsStateIdle _self;
  final $Res Function(_SettingsStateIdle) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? localeState = freezed,Object? themeState = freezed,Object? themeMode = freezed,Object? selectedLanguage = null,Object? selectedTheme = null,Object? selectedDarkMode = null,Object? errorText = freezed,}) {
  return _then(_SettingsStateIdle(
localeState: freezed == localeState ? _self.localeState : localeState // ignore: cast_nullable_to_non_nullable
as LocaleState?,themeState: freezed == themeState ? _self.themeState : themeState // ignore: cast_nullable_to_non_nullable
as ThemeState?,themeMode: freezed == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode?,selectedLanguage: null == selectedLanguage ? _self.selectedLanguage : selectedLanguage // ignore: cast_nullable_to_non_nullable
as int,selectedTheme: null == selectedTheme ? _self.selectedTheme : selectedTheme // ignore: cast_nullable_to_non_nullable
as int,selectedDarkMode: null == selectedDarkMode ? _self.selectedDarkMode : selectedDarkMode // ignore: cast_nullable_to_non_nullable
as int,errorText: freezed == errorText ? _self.errorText : errorText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
