// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sign_in_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SignInState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignInState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SignInState()';
}


}

/// @nodoc
class $SignInStateCopyWith<$Res>  {
$SignInStateCopyWith(SignInState _, $Res Function(SignInState) __);
}


/// Adds pattern-matching-related methods to [SignInState].
extension SignInStatePatterns on SignInState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SignInStateIdle value)?  idle,TResult Function( _SignInStateLoading value)?  loading,TResult Function( _SignInStateSuccess value)?  success,TResult Function( _SignInStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SignInStateIdle() when idle != null:
return idle(_that);case _SignInStateLoading() when loading != null:
return loading(_that);case _SignInStateSuccess() when success != null:
return success(_that);case _SignInStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SignInStateIdle value)  idle,required TResult Function( _SignInStateLoading value)  loading,required TResult Function( _SignInStateSuccess value)  success,required TResult Function( _SignInStateError value)  error,}){
final _that = this;
switch (_that) {
case SignInStateIdle():
return idle(_that);case _SignInStateLoading():
return loading(_that);case _SignInStateSuccess():
return success(_that);case _SignInStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SignInStateIdle value)?  idle,TResult? Function( _SignInStateLoading value)?  loading,TResult? Function( _SignInStateSuccess value)?  success,TResult? Function( _SignInStateError value)?  error,}){
final _that = this;
switch (_that) {
case SignInStateIdle() when idle != null:
return idle(_that);case _SignInStateLoading() when loading != null:
return loading(_that);case _SignInStateSuccess() when success != null:
return success(_that);case _SignInStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( ValidatedString email,  ValidatedString password,  bool obscurePassword,  bool socialLoading,  String? errorText)?  idle,TResult Function()?  loading,TResult Function()?  success,TResult Function( DataError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SignInStateIdle() when idle != null:
return idle(_that.email,_that.password,_that.obscurePassword,_that.socialLoading,_that.errorText);case _SignInStateLoading() when loading != null:
return loading();case _SignInStateSuccess() when success != null:
return success();case _SignInStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( ValidatedString email,  ValidatedString password,  bool obscurePassword,  bool socialLoading,  String? errorText)  idle,required TResult Function()  loading,required TResult Function()  success,required TResult Function( DataError error)  error,}) {final _that = this;
switch (_that) {
case SignInStateIdle():
return idle(_that.email,_that.password,_that.obscurePassword,_that.socialLoading,_that.errorText);case _SignInStateLoading():
return loading();case _SignInStateSuccess():
return success();case _SignInStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( ValidatedString email,  ValidatedString password,  bool obscurePassword,  bool socialLoading,  String? errorText)?  idle,TResult? Function()?  loading,TResult? Function()?  success,TResult? Function( DataError error)?  error,}) {final _that = this;
switch (_that) {
case SignInStateIdle() when idle != null:
return idle(_that.email,_that.password,_that.obscurePassword,_that.socialLoading,_that.errorText);case _SignInStateLoading() when loading != null:
return loading();case _SignInStateSuccess() when success != null:
return success();case _SignInStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class SignInStateIdle extends SignInState {
  const SignInStateIdle({this.email = ValidatedString.empty, this.password = ValidatedString.empty, this.obscurePassword = true, this.socialLoading = false, this.errorText}): super._();
  

@JsonKey() final  ValidatedString email;
@JsonKey() final  ValidatedString password;
@JsonKey() final  bool obscurePassword;
@JsonKey() final  bool socialLoading;
 final  String? errorText;

/// Create a copy of SignInState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignInStateIdleCopyWith<SignInStateIdle> get copyWith => _$SignInStateIdleCopyWithImpl<SignInStateIdle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignInStateIdle&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.obscurePassword, obscurePassword) || other.obscurePassword == obscurePassword)&&(identical(other.socialLoading, socialLoading) || other.socialLoading == socialLoading)&&(identical(other.errorText, errorText) || other.errorText == errorText));
}


@override
int get hashCode => Object.hash(runtimeType,email,password,obscurePassword,socialLoading,errorText);

@override
String toString() {
  return 'SignInState.idle(email: $email, password: $password, obscurePassword: $obscurePassword, socialLoading: $socialLoading, errorText: $errorText)';
}


}

/// @nodoc
abstract mixin class $SignInStateIdleCopyWith<$Res> implements $SignInStateCopyWith<$Res> {
  factory $SignInStateIdleCopyWith(SignInStateIdle value, $Res Function(SignInStateIdle) _then) = _$SignInStateIdleCopyWithImpl;
@useResult
$Res call({
 ValidatedString email, ValidatedString password, bool obscurePassword, bool socialLoading, String? errorText
});


$ValidatedStringCopyWith<$Res> get email;$ValidatedStringCopyWith<$Res> get password;

}
/// @nodoc
class _$SignInStateIdleCopyWithImpl<$Res>
    implements $SignInStateIdleCopyWith<$Res> {
  _$SignInStateIdleCopyWithImpl(this._self, this._then);

  final SignInStateIdle _self;
  final $Res Function(SignInStateIdle) _then;

/// Create a copy of SignInState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,Object? obscurePassword = null,Object? socialLoading = null,Object? errorText = freezed,}) {
  return _then(SignInStateIdle(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as ValidatedString,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as ValidatedString,obscurePassword: null == obscurePassword ? _self.obscurePassword : obscurePassword // ignore: cast_nullable_to_non_nullable
as bool,socialLoading: null == socialLoading ? _self.socialLoading : socialLoading // ignore: cast_nullable_to_non_nullable
as bool,errorText: freezed == errorText ? _self.errorText : errorText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of SignInState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ValidatedStringCopyWith<$Res> get email {
  
  return $ValidatedStringCopyWith<$Res>(_self.email, (value) {
    return _then(_self.copyWith(email: value));
  });
}/// Create a copy of SignInState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ValidatedStringCopyWith<$Res> get password {
  
  return $ValidatedStringCopyWith<$Res>(_self.password, (value) {
    return _then(_self.copyWith(password: value));
  });
}
}

/// @nodoc


class _SignInStateLoading extends SignInState {
  const _SignInStateLoading(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignInStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SignInState.loading()';
}


}




/// @nodoc


class _SignInStateSuccess extends SignInState {
  const _SignInStateSuccess(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignInStateSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SignInState.success()';
}


}




/// @nodoc


class _SignInStateError extends SignInState {
  const _SignInStateError({required this.error}): super._();
  

 final  DataError error;

/// Create a copy of SignInState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignInStateErrorCopyWith<_SignInStateError> get copyWith => __$SignInStateErrorCopyWithImpl<_SignInStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignInStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'SignInState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$SignInStateErrorCopyWith<$Res> implements $SignInStateCopyWith<$Res> {
  factory _$SignInStateErrorCopyWith(_SignInStateError value, $Res Function(_SignInStateError) _then) = __$SignInStateErrorCopyWithImpl;
@useResult
$Res call({
 DataError error
});




}
/// @nodoc
class __$SignInStateErrorCopyWithImpl<$Res>
    implements _$SignInStateErrorCopyWith<$Res> {
  __$SignInStateErrorCopyWithImpl(this._self, this._then);

  final _SignInStateError _self;
  final $Res Function(_SignInStateError) _then;

/// Create a copy of SignInState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_SignInStateError(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as DataError,
  ));
}


}

// dart format on
