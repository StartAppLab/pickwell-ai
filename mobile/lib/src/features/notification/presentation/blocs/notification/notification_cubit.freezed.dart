// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NotificationState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NotificationState()';
}


}

/// @nodoc
class $NotificationStateCopyWith<$Res>  {
$NotificationStateCopyWith(NotificationState _, $Res Function(NotificationState) __);
}


/// Adds pattern-matching-related methods to [NotificationState].
extension NotificationStatePatterns on NotificationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NotificationStateIdle value)?  idle,TResult Function( _NotificationStateLoading value)?  loading,TResult Function( _NotificationStateSuccess value)?  success,TResult Function( _NotificationStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NotificationStateIdle() when idle != null:
return idle(_that);case _NotificationStateLoading() when loading != null:
return loading(_that);case _NotificationStateSuccess() when success != null:
return success(_that);case _NotificationStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NotificationStateIdle value)  idle,required TResult Function( _NotificationStateLoading value)  loading,required TResult Function( _NotificationStateSuccess value)  success,required TResult Function( _NotificationStateError value)  error,}){
final _that = this;
switch (_that) {
case NotificationStateIdle():
return idle(_that);case _NotificationStateLoading():
return loading(_that);case _NotificationStateSuccess():
return success(_that);case _NotificationStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NotificationStateIdle value)?  idle,TResult? Function( _NotificationStateLoading value)?  loading,TResult? Function( _NotificationStateSuccess value)?  success,TResult? Function( _NotificationStateError value)?  error,}){
final _that = this;
switch (_that) {
case NotificationStateIdle() when idle != null:
return idle(_that);case _NotificationStateLoading() when loading != null:
return loading(_that);case _NotificationStateSuccess() when success != null:
return success(_that);case _NotificationStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String? errorText)?  idle,TResult Function()?  loading,TResult Function()?  success,TResult Function( DataError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NotificationStateIdle() when idle != null:
return idle(_that.errorText);case _NotificationStateLoading() when loading != null:
return loading();case _NotificationStateSuccess() when success != null:
return success();case _NotificationStateError() when error != null:
return error(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String? errorText)  idle,required TResult Function()  loading,required TResult Function()  success,required TResult Function( DataError error)  error,}) {final _that = this;
switch (_that) {
case NotificationStateIdle():
return idle(_that.errorText);case _NotificationStateLoading():
return loading();case _NotificationStateSuccess():
return success();case _NotificationStateError():
return error(_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String? errorText)?  idle,TResult? Function()?  loading,TResult? Function()?  success,TResult? Function( DataError error)?  error,}) {final _that = this;
switch (_that) {
case NotificationStateIdle() when idle != null:
return idle(_that.errorText);case _NotificationStateLoading() when loading != null:
return loading();case _NotificationStateSuccess() when success != null:
return success();case _NotificationStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class NotificationStateIdle implements NotificationState {
  const NotificationStateIdle({this.errorText});
  

 final  String? errorText;

/// Create a copy of NotificationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationStateIdleCopyWith<NotificationStateIdle> get copyWith => _$NotificationStateIdleCopyWithImpl<NotificationStateIdle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationStateIdle&&(identical(other.errorText, errorText) || other.errorText == errorText));
}


@override
int get hashCode => Object.hash(runtimeType,errorText);

@override
String toString() {
  return 'NotificationState.idle(errorText: $errorText)';
}


}

/// @nodoc
abstract mixin class $NotificationStateIdleCopyWith<$Res> implements $NotificationStateCopyWith<$Res> {
  factory $NotificationStateIdleCopyWith(NotificationStateIdle value, $Res Function(NotificationStateIdle) _then) = _$NotificationStateIdleCopyWithImpl;
@useResult
$Res call({
 String? errorText
});




}
/// @nodoc
class _$NotificationStateIdleCopyWithImpl<$Res>
    implements $NotificationStateIdleCopyWith<$Res> {
  _$NotificationStateIdleCopyWithImpl(this._self, this._then);

  final NotificationStateIdle _self;
  final $Res Function(NotificationStateIdle) _then;

/// Create a copy of NotificationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? errorText = freezed,}) {
  return _then(NotificationStateIdle(
errorText: freezed == errorText ? _self.errorText : errorText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _NotificationStateLoading implements NotificationState {
  const _NotificationStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NotificationState.loading()';
}


}




/// @nodoc


class _NotificationStateSuccess implements NotificationState {
  const _NotificationStateSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationStateSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NotificationState.success()';
}


}




/// @nodoc


class _NotificationStateError implements NotificationState {
  const _NotificationStateError({required this.error});
  

 final  DataError error;

/// Create a copy of NotificationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationStateErrorCopyWith<_NotificationStateError> get copyWith => __$NotificationStateErrorCopyWithImpl<_NotificationStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'NotificationState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$NotificationStateErrorCopyWith<$Res> implements $NotificationStateCopyWith<$Res> {
  factory _$NotificationStateErrorCopyWith(_NotificationStateError value, $Res Function(_NotificationStateError) _then) = __$NotificationStateErrorCopyWithImpl;
@useResult
$Res call({
 DataError error
});




}
/// @nodoc
class __$NotificationStateErrorCopyWithImpl<$Res>
    implements _$NotificationStateErrorCopyWith<$Res> {
  __$NotificationStateErrorCopyWithImpl(this._self, this._then);

  final _NotificationStateError _self;
  final $Res Function(_NotificationStateError) _then;

/// Create a copy of NotificationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_NotificationStateError(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as DataError,
  ));
}


}

// dart format on
