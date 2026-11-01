// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'forgot_password_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ForgotPasswordState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ForgotPasswordState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ForgotPasswordState()';
}


}

/// @nodoc
class $ForgotPasswordStateCopyWith<$Res>  {
$ForgotPasswordStateCopyWith(ForgotPasswordState _, $Res Function(ForgotPasswordState) __);
}


/// Adds pattern-matching-related methods to [ForgotPasswordState].
extension ForgotPasswordStatePatterns on ForgotPasswordState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ForgotPasswordStateIdle value)?  idle,TResult Function( _ForgotPasswordStateLoading value)?  loading,TResult Function( _ForgotPasswordStateSuccess value)?  success,TResult Function( _ForgotPasswordStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ForgotPasswordStateIdle() when idle != null:
return idle(_that);case _ForgotPasswordStateLoading() when loading != null:
return loading(_that);case _ForgotPasswordStateSuccess() when success != null:
return success(_that);case _ForgotPasswordStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ForgotPasswordStateIdle value)  idle,required TResult Function( _ForgotPasswordStateLoading value)  loading,required TResult Function( _ForgotPasswordStateSuccess value)  success,required TResult Function( _ForgotPasswordStateError value)  error,}){
final _that = this;
switch (_that) {
case ForgotPasswordStateIdle():
return idle(_that);case _ForgotPasswordStateLoading():
return loading(_that);case _ForgotPasswordStateSuccess():
return success(_that);case _ForgotPasswordStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ForgotPasswordStateIdle value)?  idle,TResult? Function( _ForgotPasswordStateLoading value)?  loading,TResult? Function( _ForgotPasswordStateSuccess value)?  success,TResult? Function( _ForgotPasswordStateError value)?  error,}){
final _that = this;
switch (_that) {
case ForgotPasswordStateIdle() when idle != null:
return idle(_that);case _ForgotPasswordStateLoading() when loading != null:
return loading(_that);case _ForgotPasswordStateSuccess() when success != null:
return success(_that);case _ForgotPasswordStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( ValidatedString email,  String? errorText)?  idle,TResult Function()?  loading,TResult Function()?  success,TResult Function( DataError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ForgotPasswordStateIdle() when idle != null:
return idle(_that.email,_that.errorText);case _ForgotPasswordStateLoading() when loading != null:
return loading();case _ForgotPasswordStateSuccess() when success != null:
return success();case _ForgotPasswordStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( ValidatedString email,  String? errorText)  idle,required TResult Function()  loading,required TResult Function()  success,required TResult Function( DataError error)  error,}) {final _that = this;
switch (_that) {
case ForgotPasswordStateIdle():
return idle(_that.email,_that.errorText);case _ForgotPasswordStateLoading():
return loading();case _ForgotPasswordStateSuccess():
return success();case _ForgotPasswordStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( ValidatedString email,  String? errorText)?  idle,TResult? Function()?  loading,TResult? Function()?  success,TResult? Function( DataError error)?  error,}) {final _that = this;
switch (_that) {
case ForgotPasswordStateIdle() when idle != null:
return idle(_that.email,_that.errorText);case _ForgotPasswordStateLoading() when loading != null:
return loading();case _ForgotPasswordStateSuccess() when success != null:
return success();case _ForgotPasswordStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class ForgotPasswordStateIdle extends ForgotPasswordState {
  const ForgotPasswordStateIdle({this.email = ValidatedString.empty, this.errorText}): super._();
  

@JsonKey() final  ValidatedString email;
 final  String? errorText;

/// Create a copy of ForgotPasswordState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForgotPasswordStateIdleCopyWith<ForgotPasswordStateIdle> get copyWith => _$ForgotPasswordStateIdleCopyWithImpl<ForgotPasswordStateIdle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ForgotPasswordStateIdle&&(identical(other.email, email) || other.email == email)&&(identical(other.errorText, errorText) || other.errorText == errorText));
}


@override
int get hashCode => Object.hash(runtimeType,email,errorText);

@override
String toString() {
  return 'ForgotPasswordState.idle(email: $email, errorText: $errorText)';
}


}

/// @nodoc
abstract mixin class $ForgotPasswordStateIdleCopyWith<$Res> implements $ForgotPasswordStateCopyWith<$Res> {
  factory $ForgotPasswordStateIdleCopyWith(ForgotPasswordStateIdle value, $Res Function(ForgotPasswordStateIdle) _then) = _$ForgotPasswordStateIdleCopyWithImpl;
@useResult
$Res call({
 ValidatedString email, String? errorText
});


$ValidatedStringCopyWith<$Res> get email;

}
/// @nodoc
class _$ForgotPasswordStateIdleCopyWithImpl<$Res>
    implements $ForgotPasswordStateIdleCopyWith<$Res> {
  _$ForgotPasswordStateIdleCopyWithImpl(this._self, this._then);

  final ForgotPasswordStateIdle _self;
  final $Res Function(ForgotPasswordStateIdle) _then;

/// Create a copy of ForgotPasswordState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,Object? errorText = freezed,}) {
  return _then(ForgotPasswordStateIdle(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as ValidatedString,errorText: freezed == errorText ? _self.errorText : errorText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ForgotPasswordState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ValidatedStringCopyWith<$Res> get email {
  
  return $ValidatedStringCopyWith<$Res>(_self.email, (value) {
    return _then(_self.copyWith(email: value));
  });
}
}

/// @nodoc


class _ForgotPasswordStateLoading extends ForgotPasswordState {
  const _ForgotPasswordStateLoading(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ForgotPasswordStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ForgotPasswordState.loading()';
}


}




/// @nodoc


class _ForgotPasswordStateSuccess extends ForgotPasswordState {
  const _ForgotPasswordStateSuccess(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ForgotPasswordStateSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ForgotPasswordState.success()';
}


}




/// @nodoc


class _ForgotPasswordStateError extends ForgotPasswordState {
  const _ForgotPasswordStateError({required this.error}): super._();
  

 final  DataError error;

/// Create a copy of ForgotPasswordState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ForgotPasswordStateErrorCopyWith<_ForgotPasswordStateError> get copyWith => __$ForgotPasswordStateErrorCopyWithImpl<_ForgotPasswordStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ForgotPasswordStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'ForgotPasswordState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$ForgotPasswordStateErrorCopyWith<$Res> implements $ForgotPasswordStateCopyWith<$Res> {
  factory _$ForgotPasswordStateErrorCopyWith(_ForgotPasswordStateError value, $Res Function(_ForgotPasswordStateError) _then) = __$ForgotPasswordStateErrorCopyWithImpl;
@useResult
$Res call({
 DataError error
});




}
/// @nodoc
class __$ForgotPasswordStateErrorCopyWithImpl<$Res>
    implements _$ForgotPasswordStateErrorCopyWith<$Res> {
  __$ForgotPasswordStateErrorCopyWithImpl(this._self, this._then);

  final _ForgotPasswordStateError _self;
  final $Res Function(_ForgotPasswordStateError) _then;

/// Create a copy of ForgotPasswordState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_ForgotPasswordStateError(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as DataError,
  ));
}


}

// dart format on
