// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sign_up_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SignUpState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignUpState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SignUpState()';
}


}

/// @nodoc
class $SignUpStateCopyWith<$Res>  {
$SignUpStateCopyWith(SignUpState _, $Res Function(SignUpState) __);
}


/// Adds pattern-matching-related methods to [SignUpState].
extension SignUpStatePatterns on SignUpState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SignUpStateIdle value)?  idle,TResult Function( _SignUpStateLoading value)?  loading,TResult Function( _SignUpStateSuccess value)?  success,TResult Function( _SignUpStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SignUpStateIdle() when idle != null:
return idle(_that);case _SignUpStateLoading() when loading != null:
return loading(_that);case _SignUpStateSuccess() when success != null:
return success(_that);case _SignUpStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SignUpStateIdle value)  idle,required TResult Function( _SignUpStateLoading value)  loading,required TResult Function( _SignUpStateSuccess value)  success,required TResult Function( _SignUpStateError value)  error,}){
final _that = this;
switch (_that) {
case SignUpStateIdle():
return idle(_that);case _SignUpStateLoading():
return loading(_that);case _SignUpStateSuccess():
return success(_that);case _SignUpStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SignUpStateIdle value)?  idle,TResult? Function( _SignUpStateLoading value)?  loading,TResult? Function( _SignUpStateSuccess value)?  success,TResult? Function( _SignUpStateError value)?  error,}){
final _that = this;
switch (_that) {
case SignUpStateIdle() when idle != null:
return idle(_that);case _SignUpStateLoading() when loading != null:
return loading(_that);case _SignUpStateSuccess() when success != null:
return success(_that);case _SignUpStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( ValidatedString email,  ValidatedString password,  ValidatedString confirmPassword,  ValidatedString firstName,  ValidatedString lastName,  bool obscurePassword,  bool obscureConfirmPassword,  String? errorText)?  idle,TResult Function()?  loading,TResult Function()?  success,TResult Function( DataError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SignUpStateIdle() when idle != null:
return idle(_that.email,_that.password,_that.confirmPassword,_that.firstName,_that.lastName,_that.obscurePassword,_that.obscureConfirmPassword,_that.errorText);case _SignUpStateLoading() when loading != null:
return loading();case _SignUpStateSuccess() when success != null:
return success();case _SignUpStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( ValidatedString email,  ValidatedString password,  ValidatedString confirmPassword,  ValidatedString firstName,  ValidatedString lastName,  bool obscurePassword,  bool obscureConfirmPassword,  String? errorText)  idle,required TResult Function()  loading,required TResult Function()  success,required TResult Function( DataError error)  error,}) {final _that = this;
switch (_that) {
case SignUpStateIdle():
return idle(_that.email,_that.password,_that.confirmPassword,_that.firstName,_that.lastName,_that.obscurePassword,_that.obscureConfirmPassword,_that.errorText);case _SignUpStateLoading():
return loading();case _SignUpStateSuccess():
return success();case _SignUpStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( ValidatedString email,  ValidatedString password,  ValidatedString confirmPassword,  ValidatedString firstName,  ValidatedString lastName,  bool obscurePassword,  bool obscureConfirmPassword,  String? errorText)?  idle,TResult? Function()?  loading,TResult? Function()?  success,TResult? Function( DataError error)?  error,}) {final _that = this;
switch (_that) {
case SignUpStateIdle() when idle != null:
return idle(_that.email,_that.password,_that.confirmPassword,_that.firstName,_that.lastName,_that.obscurePassword,_that.obscureConfirmPassword,_that.errorText);case _SignUpStateLoading() when loading != null:
return loading();case _SignUpStateSuccess() when success != null:
return success();case _SignUpStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class SignUpStateIdle extends SignUpState {
  const SignUpStateIdle({this.email = ValidatedString.empty, this.password = ValidatedString.empty, this.confirmPassword = ValidatedString.empty, this.firstName = ValidatedString.empty, this.lastName = ValidatedString.empty, this.obscurePassword = true, this.obscureConfirmPassword = true, this.errorText}): super._();
  

@JsonKey() final  ValidatedString email;
@JsonKey() final  ValidatedString password;
@JsonKey() final  ValidatedString confirmPassword;
@JsonKey() final  ValidatedString firstName;
@JsonKey() final  ValidatedString lastName;
@JsonKey() final  bool obscurePassword;
@JsonKey() final  bool obscureConfirmPassword;
 final  String? errorText;

/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignUpStateIdleCopyWith<SignUpStateIdle> get copyWith => _$SignUpStateIdleCopyWithImpl<SignUpStateIdle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignUpStateIdle&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.confirmPassword, confirmPassword) || other.confirmPassword == confirmPassword)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.obscurePassword, obscurePassword) || other.obscurePassword == obscurePassword)&&(identical(other.obscureConfirmPassword, obscureConfirmPassword) || other.obscureConfirmPassword == obscureConfirmPassword)&&(identical(other.errorText, errorText) || other.errorText == errorText));
}


@override
int get hashCode => Object.hash(runtimeType,email,password,confirmPassword,firstName,lastName,obscurePassword,obscureConfirmPassword,errorText);

@override
String toString() {
  return 'SignUpState.idle(email: $email, password: $password, confirmPassword: $confirmPassword, firstName: $firstName, lastName: $lastName, obscurePassword: $obscurePassword, obscureConfirmPassword: $obscureConfirmPassword, errorText: $errorText)';
}


}

/// @nodoc
abstract mixin class $SignUpStateIdleCopyWith<$Res> implements $SignUpStateCopyWith<$Res> {
  factory $SignUpStateIdleCopyWith(SignUpStateIdle value, $Res Function(SignUpStateIdle) _then) = _$SignUpStateIdleCopyWithImpl;
@useResult
$Res call({
 ValidatedString email, ValidatedString password, ValidatedString confirmPassword, ValidatedString firstName, ValidatedString lastName, bool obscurePassword, bool obscureConfirmPassword, String? errorText
});


$ValidatedStringCopyWith<$Res> get email;$ValidatedStringCopyWith<$Res> get password;$ValidatedStringCopyWith<$Res> get confirmPassword;$ValidatedStringCopyWith<$Res> get firstName;$ValidatedStringCopyWith<$Res> get lastName;

}
/// @nodoc
class _$SignUpStateIdleCopyWithImpl<$Res>
    implements $SignUpStateIdleCopyWith<$Res> {
  _$SignUpStateIdleCopyWithImpl(this._self, this._then);

  final SignUpStateIdle _self;
  final $Res Function(SignUpStateIdle) _then;

/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,Object? confirmPassword = null,Object? firstName = null,Object? lastName = null,Object? obscurePassword = null,Object? obscureConfirmPassword = null,Object? errorText = freezed,}) {
  return _then(SignUpStateIdle(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as ValidatedString,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as ValidatedString,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as ValidatedString,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as ValidatedString,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as ValidatedString,obscurePassword: null == obscurePassword ? _self.obscurePassword : obscurePassword // ignore: cast_nullable_to_non_nullable
as bool,obscureConfirmPassword: null == obscureConfirmPassword ? _self.obscureConfirmPassword : obscureConfirmPassword // ignore: cast_nullable_to_non_nullable
as bool,errorText: freezed == errorText ? _self.errorText : errorText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ValidatedStringCopyWith<$Res> get email {
  
  return $ValidatedStringCopyWith<$Res>(_self.email, (value) {
    return _then(_self.copyWith(email: value));
  });
}/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ValidatedStringCopyWith<$Res> get password {
  
  return $ValidatedStringCopyWith<$Res>(_self.password, (value) {
    return _then(_self.copyWith(password: value));
  });
}/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ValidatedStringCopyWith<$Res> get confirmPassword {
  
  return $ValidatedStringCopyWith<$Res>(_self.confirmPassword, (value) {
    return _then(_self.copyWith(confirmPassword: value));
  });
}/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ValidatedStringCopyWith<$Res> get firstName {
  
  return $ValidatedStringCopyWith<$Res>(_self.firstName, (value) {
    return _then(_self.copyWith(firstName: value));
  });
}/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ValidatedStringCopyWith<$Res> get lastName {
  
  return $ValidatedStringCopyWith<$Res>(_self.lastName, (value) {
    return _then(_self.copyWith(lastName: value));
  });
}
}

/// @nodoc


class _SignUpStateLoading extends SignUpState {
  const _SignUpStateLoading(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignUpStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SignUpState.loading()';
}


}




/// @nodoc


class _SignUpStateSuccess extends SignUpState {
  const _SignUpStateSuccess(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignUpStateSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SignUpState.success()';
}


}




/// @nodoc


class _SignUpStateError extends SignUpState {
  const _SignUpStateError({required this.error}): super._();
  

 final  DataError error;

/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignUpStateErrorCopyWith<_SignUpStateError> get copyWith => __$SignUpStateErrorCopyWithImpl<_SignUpStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignUpStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'SignUpState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$SignUpStateErrorCopyWith<$Res> implements $SignUpStateCopyWith<$Res> {
  factory _$SignUpStateErrorCopyWith(_SignUpStateError value, $Res Function(_SignUpStateError) _then) = __$SignUpStateErrorCopyWithImpl;
@useResult
$Res call({
 DataError error
});




}
/// @nodoc
class __$SignUpStateErrorCopyWithImpl<$Res>
    implements _$SignUpStateErrorCopyWith<$Res> {
  __$SignUpStateErrorCopyWithImpl(this._self, this._then);

  final _SignUpStateError _self;
  final $Res Function(_SignUpStateError) _then;

/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_SignUpStateError(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as DataError,
  ));
}


}

// dart format on
