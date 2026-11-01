// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'otp_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OtpState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtpState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OtpState()';
}


}

/// @nodoc
class $OtpStateCopyWith<$Res>  {
$OtpStateCopyWith(OtpState _, $Res Function(OtpState) __);
}


/// Adds pattern-matching-related methods to [OtpState].
extension OtpStatePatterns on OtpState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( OtpStateIdle value)?  idle,TResult Function( _OtpStateLoading value)?  loading,TResult Function( _OtpStateSuccess value)?  success,TResult Function( _OtpStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case OtpStateIdle() when idle != null:
return idle(_that);case _OtpStateLoading() when loading != null:
return loading(_that);case _OtpStateSuccess() when success != null:
return success(_that);case _OtpStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( OtpStateIdle value)  idle,required TResult Function( _OtpStateLoading value)  loading,required TResult Function( _OtpStateSuccess value)  success,required TResult Function( _OtpStateError value)  error,}){
final _that = this;
switch (_that) {
case OtpStateIdle():
return idle(_that);case _OtpStateLoading():
return loading(_that);case _OtpStateSuccess():
return success(_that);case _OtpStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( OtpStateIdle value)?  idle,TResult? Function( _OtpStateLoading value)?  loading,TResult? Function( _OtpStateSuccess value)?  success,TResult? Function( _OtpStateError value)?  error,}){
final _that = this;
switch (_that) {
case OtpStateIdle() when idle != null:
return idle(_that);case _OtpStateLoading() when loading != null:
return loading(_that);case _OtpStateSuccess() when success != null:
return success(_that);case _OtpStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( ValidatedString token,  String? email,  String? errorText,  bool? canResend)?  idle,TResult Function()?  loading,TResult Function()?  success,TResult Function( DataError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case OtpStateIdle() when idle != null:
return idle(_that.token,_that.email,_that.errorText,_that.canResend);case _OtpStateLoading() when loading != null:
return loading();case _OtpStateSuccess() when success != null:
return success();case _OtpStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( ValidatedString token,  String? email,  String? errorText,  bool? canResend)  idle,required TResult Function()  loading,required TResult Function()  success,required TResult Function( DataError error)  error,}) {final _that = this;
switch (_that) {
case OtpStateIdle():
return idle(_that.token,_that.email,_that.errorText,_that.canResend);case _OtpStateLoading():
return loading();case _OtpStateSuccess():
return success();case _OtpStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( ValidatedString token,  String? email,  String? errorText,  bool? canResend)?  idle,TResult? Function()?  loading,TResult? Function()?  success,TResult? Function( DataError error)?  error,}) {final _that = this;
switch (_that) {
case OtpStateIdle() when idle != null:
return idle(_that.token,_that.email,_that.errorText,_that.canResend);case _OtpStateLoading() when loading != null:
return loading();case _OtpStateSuccess() when success != null:
return success();case _OtpStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class OtpStateIdle extends OtpState {
  const OtpStateIdle({this.token = ValidatedString.empty, this.email, this.errorText, this.canResend}): super._();
  

@JsonKey() final  ValidatedString token;
 final  String? email;
 final  String? errorText;
 final  bool? canResend;

/// Create a copy of OtpState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OtpStateIdleCopyWith<OtpStateIdle> get copyWith => _$OtpStateIdleCopyWithImpl<OtpStateIdle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtpStateIdle&&(identical(other.token, token) || other.token == token)&&(identical(other.email, email) || other.email == email)&&(identical(other.errorText, errorText) || other.errorText == errorText)&&(identical(other.canResend, canResend) || other.canResend == canResend));
}


@override
int get hashCode => Object.hash(runtimeType,token,email,errorText,canResend);

@override
String toString() {
  return 'OtpState.idle(token: $token, email: $email, errorText: $errorText, canResend: $canResend)';
}


}

/// @nodoc
abstract mixin class $OtpStateIdleCopyWith<$Res> implements $OtpStateCopyWith<$Res> {
  factory $OtpStateIdleCopyWith(OtpStateIdle value, $Res Function(OtpStateIdle) _then) = _$OtpStateIdleCopyWithImpl;
@useResult
$Res call({
 ValidatedString token, String? email, String? errorText, bool? canResend
});


$ValidatedStringCopyWith<$Res> get token;

}
/// @nodoc
class _$OtpStateIdleCopyWithImpl<$Res>
    implements $OtpStateIdleCopyWith<$Res> {
  _$OtpStateIdleCopyWithImpl(this._self, this._then);

  final OtpStateIdle _self;
  final $Res Function(OtpStateIdle) _then;

/// Create a copy of OtpState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? token = null,Object? email = freezed,Object? errorText = freezed,Object? canResend = freezed,}) {
  return _then(OtpStateIdle(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as ValidatedString,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,errorText: freezed == errorText ? _self.errorText : errorText // ignore: cast_nullable_to_non_nullable
as String?,canResend: freezed == canResend ? _self.canResend : canResend // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

/// Create a copy of OtpState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ValidatedStringCopyWith<$Res> get token {
  
  return $ValidatedStringCopyWith<$Res>(_self.token, (value) {
    return _then(_self.copyWith(token: value));
  });
}
}

/// @nodoc


class _OtpStateLoading extends OtpState {
  const _OtpStateLoading(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtpStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OtpState.loading()';
}


}




/// @nodoc


class _OtpStateSuccess extends OtpState {
  const _OtpStateSuccess(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtpStateSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OtpState.success()';
}


}




/// @nodoc


class _OtpStateError extends OtpState {
  const _OtpStateError({required this.error}): super._();
  

 final  DataError error;

/// Create a copy of OtpState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OtpStateErrorCopyWith<_OtpStateError> get copyWith => __$OtpStateErrorCopyWithImpl<_OtpStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtpStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'OtpState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$OtpStateErrorCopyWith<$Res> implements $OtpStateCopyWith<$Res> {
  factory _$OtpStateErrorCopyWith(_OtpStateError value, $Res Function(_OtpStateError) _then) = __$OtpStateErrorCopyWithImpl;
@useResult
$Res call({
 DataError error
});




}
/// @nodoc
class __$OtpStateErrorCopyWithImpl<$Res>
    implements _$OtpStateErrorCopyWith<$Res> {
  __$OtpStateErrorCopyWithImpl(this._self, this._then);

  final _OtpStateError _self;
  final $Res Function(_OtpStateError) _then;

/// Create a copy of OtpState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_OtpStateError(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as DataError,
  ));
}


}

// dart format on
