// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_notifications_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsNotificationsState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsNotificationsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SettingsNotificationsState()';
}


}

/// @nodoc
class $SettingsNotificationsStateCopyWith<$Res>  {
$SettingsNotificationsStateCopyWith(SettingsNotificationsState _, $Res Function(SettingsNotificationsState) __);
}


/// Adds pattern-matching-related methods to [SettingsNotificationsState].
extension SettingsNotificationsStatePatterns on SettingsNotificationsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SettingsNotificationsStateIdle value)?  idle,TResult Function( SettingsNotificationsStateLoading value)?  loading,TResult Function( SettingsNotificationsStateSaving value)?  saving,TResult Function( SettingsNotificationsStatePermissionDenied value)?  permissionDenied,TResult Function( SettingsNotificationsStateSuccess value)?  success,TResult Function( SettingsNotificationsStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SettingsNotificationsStateIdle() when idle != null:
return idle(_that);case SettingsNotificationsStateLoading() when loading != null:
return loading(_that);case SettingsNotificationsStateSaving() when saving != null:
return saving(_that);case SettingsNotificationsStatePermissionDenied() when permissionDenied != null:
return permissionDenied(_that);case SettingsNotificationsStateSuccess() when success != null:
return success(_that);case SettingsNotificationsStateError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SettingsNotificationsStateIdle value)  idle,required TResult Function( SettingsNotificationsStateLoading value)  loading,required TResult Function( SettingsNotificationsStateSaving value)  saving,required TResult Function( SettingsNotificationsStatePermissionDenied value)  permissionDenied,required TResult Function( SettingsNotificationsStateSuccess value)  success,required TResult Function( SettingsNotificationsStateError value)  error,}){
final _that = this;
switch (_that) {
case SettingsNotificationsStateIdle():
return idle(_that);case SettingsNotificationsStateLoading():
return loading(_that);case SettingsNotificationsStateSaving():
return saving(_that);case SettingsNotificationsStatePermissionDenied():
return permissionDenied(_that);case SettingsNotificationsStateSuccess():
return success(_that);case SettingsNotificationsStateError():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SettingsNotificationsStateIdle value)?  idle,TResult? Function( SettingsNotificationsStateLoading value)?  loading,TResult? Function( SettingsNotificationsStateSaving value)?  saving,TResult? Function( SettingsNotificationsStatePermissionDenied value)?  permissionDenied,TResult? Function( SettingsNotificationsStateSuccess value)?  success,TResult? Function( SettingsNotificationsStateError value)?  error,}){
final _that = this;
switch (_that) {
case SettingsNotificationsStateIdle() when idle != null:
return idle(_that);case SettingsNotificationsStateLoading() when loading != null:
return loading(_that);case SettingsNotificationsStateSaving() when saving != null:
return saving(_that);case SettingsNotificationsStatePermissionDenied() when permissionDenied != null:
return permissionDenied(_that);case SettingsNotificationsStateSuccess() when success != null:
return success(_that);case SettingsNotificationsStateError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( bool enabled)?  idle,TResult Function()?  loading,TResult Function( bool enabled)?  saving,TResult Function( bool enabled)?  permissionDenied,TResult Function( bool enabled)?  success,TResult Function( bool enabled,  String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SettingsNotificationsStateIdle() when idle != null:
return idle(_that.enabled);case SettingsNotificationsStateLoading() when loading != null:
return loading();case SettingsNotificationsStateSaving() when saving != null:
return saving(_that.enabled);case SettingsNotificationsStatePermissionDenied() when permissionDenied != null:
return permissionDenied(_that.enabled);case SettingsNotificationsStateSuccess() when success != null:
return success(_that.enabled);case SettingsNotificationsStateError() when error != null:
return error(_that.enabled,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( bool enabled)  idle,required TResult Function()  loading,required TResult Function( bool enabled)  saving,required TResult Function( bool enabled)  permissionDenied,required TResult Function( bool enabled)  success,required TResult Function( bool enabled,  String message)  error,}) {final _that = this;
switch (_that) {
case SettingsNotificationsStateIdle():
return idle(_that.enabled);case SettingsNotificationsStateLoading():
return loading();case SettingsNotificationsStateSaving():
return saving(_that.enabled);case SettingsNotificationsStatePermissionDenied():
return permissionDenied(_that.enabled);case SettingsNotificationsStateSuccess():
return success(_that.enabled);case SettingsNotificationsStateError():
return error(_that.enabled,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( bool enabled)?  idle,TResult? Function()?  loading,TResult? Function( bool enabled)?  saving,TResult? Function( bool enabled)?  permissionDenied,TResult? Function( bool enabled)?  success,TResult? Function( bool enabled,  String message)?  error,}) {final _that = this;
switch (_that) {
case SettingsNotificationsStateIdle() when idle != null:
return idle(_that.enabled);case SettingsNotificationsStateLoading() when loading != null:
return loading();case SettingsNotificationsStateSaving() when saving != null:
return saving(_that.enabled);case SettingsNotificationsStatePermissionDenied() when permissionDenied != null:
return permissionDenied(_that.enabled);case SettingsNotificationsStateSuccess() when success != null:
return success(_that.enabled);case SettingsNotificationsStateError() when error != null:
return error(_that.enabled,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class SettingsNotificationsStateIdle implements SettingsNotificationsState {
  const SettingsNotificationsStateIdle({required this.enabled});
  

 final  bool enabled;

/// Create a copy of SettingsNotificationsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsNotificationsStateIdleCopyWith<SettingsNotificationsStateIdle> get copyWith => _$SettingsNotificationsStateIdleCopyWithImpl<SettingsNotificationsStateIdle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsNotificationsStateIdle&&(identical(other.enabled, enabled) || other.enabled == enabled));
}


@override
int get hashCode => Object.hash(runtimeType,enabled);

@override
String toString() {
  return 'SettingsNotificationsState.idle(enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class $SettingsNotificationsStateIdleCopyWith<$Res> implements $SettingsNotificationsStateCopyWith<$Res> {
  factory $SettingsNotificationsStateIdleCopyWith(SettingsNotificationsStateIdle value, $Res Function(SettingsNotificationsStateIdle) _then) = _$SettingsNotificationsStateIdleCopyWithImpl;
@useResult
$Res call({
 bool enabled
});




}
/// @nodoc
class _$SettingsNotificationsStateIdleCopyWithImpl<$Res>
    implements $SettingsNotificationsStateIdleCopyWith<$Res> {
  _$SettingsNotificationsStateIdleCopyWithImpl(this._self, this._then);

  final SettingsNotificationsStateIdle _self;
  final $Res Function(SettingsNotificationsStateIdle) _then;

/// Create a copy of SettingsNotificationsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? enabled = null,}) {
  return _then(SettingsNotificationsStateIdle(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class SettingsNotificationsStateLoading implements SettingsNotificationsState {
  const SettingsNotificationsStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsNotificationsStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SettingsNotificationsState.loading()';
}


}




/// @nodoc


class SettingsNotificationsStateSaving implements SettingsNotificationsState {
  const SettingsNotificationsStateSaving({required this.enabled});
  

 final  bool enabled;

/// Create a copy of SettingsNotificationsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsNotificationsStateSavingCopyWith<SettingsNotificationsStateSaving> get copyWith => _$SettingsNotificationsStateSavingCopyWithImpl<SettingsNotificationsStateSaving>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsNotificationsStateSaving&&(identical(other.enabled, enabled) || other.enabled == enabled));
}


@override
int get hashCode => Object.hash(runtimeType,enabled);

@override
String toString() {
  return 'SettingsNotificationsState.saving(enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class $SettingsNotificationsStateSavingCopyWith<$Res> implements $SettingsNotificationsStateCopyWith<$Res> {
  factory $SettingsNotificationsStateSavingCopyWith(SettingsNotificationsStateSaving value, $Res Function(SettingsNotificationsStateSaving) _then) = _$SettingsNotificationsStateSavingCopyWithImpl;
@useResult
$Res call({
 bool enabled
});




}
/// @nodoc
class _$SettingsNotificationsStateSavingCopyWithImpl<$Res>
    implements $SettingsNotificationsStateSavingCopyWith<$Res> {
  _$SettingsNotificationsStateSavingCopyWithImpl(this._self, this._then);

  final SettingsNotificationsStateSaving _self;
  final $Res Function(SettingsNotificationsStateSaving) _then;

/// Create a copy of SettingsNotificationsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? enabled = null,}) {
  return _then(SettingsNotificationsStateSaving(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class SettingsNotificationsStatePermissionDenied implements SettingsNotificationsState {
  const SettingsNotificationsStatePermissionDenied({required this.enabled});
  

 final  bool enabled;

/// Create a copy of SettingsNotificationsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsNotificationsStatePermissionDeniedCopyWith<SettingsNotificationsStatePermissionDenied> get copyWith => _$SettingsNotificationsStatePermissionDeniedCopyWithImpl<SettingsNotificationsStatePermissionDenied>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsNotificationsStatePermissionDenied&&(identical(other.enabled, enabled) || other.enabled == enabled));
}


@override
int get hashCode => Object.hash(runtimeType,enabled);

@override
String toString() {
  return 'SettingsNotificationsState.permissionDenied(enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class $SettingsNotificationsStatePermissionDeniedCopyWith<$Res> implements $SettingsNotificationsStateCopyWith<$Res> {
  factory $SettingsNotificationsStatePermissionDeniedCopyWith(SettingsNotificationsStatePermissionDenied value, $Res Function(SettingsNotificationsStatePermissionDenied) _then) = _$SettingsNotificationsStatePermissionDeniedCopyWithImpl;
@useResult
$Res call({
 bool enabled
});




}
/// @nodoc
class _$SettingsNotificationsStatePermissionDeniedCopyWithImpl<$Res>
    implements $SettingsNotificationsStatePermissionDeniedCopyWith<$Res> {
  _$SettingsNotificationsStatePermissionDeniedCopyWithImpl(this._self, this._then);

  final SettingsNotificationsStatePermissionDenied _self;
  final $Res Function(SettingsNotificationsStatePermissionDenied) _then;

/// Create a copy of SettingsNotificationsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? enabled = null,}) {
  return _then(SettingsNotificationsStatePermissionDenied(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class SettingsNotificationsStateSuccess implements SettingsNotificationsState {
  const SettingsNotificationsStateSuccess({required this.enabled});
  

 final  bool enabled;

/// Create a copy of SettingsNotificationsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsNotificationsStateSuccessCopyWith<SettingsNotificationsStateSuccess> get copyWith => _$SettingsNotificationsStateSuccessCopyWithImpl<SettingsNotificationsStateSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsNotificationsStateSuccess&&(identical(other.enabled, enabled) || other.enabled == enabled));
}


@override
int get hashCode => Object.hash(runtimeType,enabled);

@override
String toString() {
  return 'SettingsNotificationsState.success(enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class $SettingsNotificationsStateSuccessCopyWith<$Res> implements $SettingsNotificationsStateCopyWith<$Res> {
  factory $SettingsNotificationsStateSuccessCopyWith(SettingsNotificationsStateSuccess value, $Res Function(SettingsNotificationsStateSuccess) _then) = _$SettingsNotificationsStateSuccessCopyWithImpl;
@useResult
$Res call({
 bool enabled
});




}
/// @nodoc
class _$SettingsNotificationsStateSuccessCopyWithImpl<$Res>
    implements $SettingsNotificationsStateSuccessCopyWith<$Res> {
  _$SettingsNotificationsStateSuccessCopyWithImpl(this._self, this._then);

  final SettingsNotificationsStateSuccess _self;
  final $Res Function(SettingsNotificationsStateSuccess) _then;

/// Create a copy of SettingsNotificationsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? enabled = null,}) {
  return _then(SettingsNotificationsStateSuccess(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class SettingsNotificationsStateError implements SettingsNotificationsState {
  const SettingsNotificationsStateError({required this.enabled, required this.message});
  

 final  bool enabled;
 final  String message;

/// Create a copy of SettingsNotificationsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsNotificationsStateErrorCopyWith<SettingsNotificationsStateError> get copyWith => _$SettingsNotificationsStateErrorCopyWithImpl<SettingsNotificationsStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsNotificationsStateError&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,enabled,message);

@override
String toString() {
  return 'SettingsNotificationsState.error(enabled: $enabled, message: $message)';
}


}

/// @nodoc
abstract mixin class $SettingsNotificationsStateErrorCopyWith<$Res> implements $SettingsNotificationsStateCopyWith<$Res> {
  factory $SettingsNotificationsStateErrorCopyWith(SettingsNotificationsStateError value, $Res Function(SettingsNotificationsStateError) _then) = _$SettingsNotificationsStateErrorCopyWithImpl;
@useResult
$Res call({
 bool enabled, String message
});




}
/// @nodoc
class _$SettingsNotificationsStateErrorCopyWithImpl<$Res>
    implements $SettingsNotificationsStateErrorCopyWith<$Res> {
  _$SettingsNotificationsStateErrorCopyWithImpl(this._self, this._then);

  final SettingsNotificationsStateError _self;
  final $Res Function(SettingsNotificationsStateError) _then;

/// Create a copy of SettingsNotificationsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? message = null,}) {
  return _then(SettingsNotificationsStateError(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
