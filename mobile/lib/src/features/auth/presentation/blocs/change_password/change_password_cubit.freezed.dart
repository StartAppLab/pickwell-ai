// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'change_password_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChangePasswordState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangePasswordState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChangePasswordState()';
}


}

/// @nodoc
class $ChangePasswordStateCopyWith<$Res>  {
$ChangePasswordStateCopyWith(ChangePasswordState _, $Res Function(ChangePasswordState) __);
}


/// Adds pattern-matching-related methods to [ChangePasswordState].
extension ChangePasswordStatePatterns on ChangePasswordState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ChangePasswordStateIdle value)?  idle,TResult Function( _ChangePasswordStateLoading value)?  loading,TResult Function( _ChangePasswordStateSuccess value)?  success,TResult Function( _ChangePasswordStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ChangePasswordStateIdle() when idle != null:
return idle(_that);case _ChangePasswordStateLoading() when loading != null:
return loading(_that);case _ChangePasswordStateSuccess() when success != null:
return success(_that);case _ChangePasswordStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ChangePasswordStateIdle value)  idle,required TResult Function( _ChangePasswordStateLoading value)  loading,required TResult Function( _ChangePasswordStateSuccess value)  success,required TResult Function( _ChangePasswordStateError value)  error,}){
final _that = this;
switch (_that) {
case ChangePasswordStateIdle():
return idle(_that);case _ChangePasswordStateLoading():
return loading(_that);case _ChangePasswordStateSuccess():
return success(_that);case _ChangePasswordStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ChangePasswordStateIdle value)?  idle,TResult? Function( _ChangePasswordStateLoading value)?  loading,TResult? Function( _ChangePasswordStateSuccess value)?  success,TResult? Function( _ChangePasswordStateError value)?  error,}){
final _that = this;
switch (_that) {
case ChangePasswordStateIdle() when idle != null:
return idle(_that);case _ChangePasswordStateLoading() when loading != null:
return loading(_that);case _ChangePasswordStateSuccess() when success != null:
return success(_that);case _ChangePasswordStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( ValidatedString password,  ValidatedString confirmPassword,  bool obscurePassword,  bool obscureConfirmPassword,  String? errorText)?  idle,TResult Function()?  loading,TResult Function()?  success,TResult Function( DataError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ChangePasswordStateIdle() when idle != null:
return idle(_that.password,_that.confirmPassword,_that.obscurePassword,_that.obscureConfirmPassword,_that.errorText);case _ChangePasswordStateLoading() when loading != null:
return loading();case _ChangePasswordStateSuccess() when success != null:
return success();case _ChangePasswordStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( ValidatedString password,  ValidatedString confirmPassword,  bool obscurePassword,  bool obscureConfirmPassword,  String? errorText)  idle,required TResult Function()  loading,required TResult Function()  success,required TResult Function( DataError error)  error,}) {final _that = this;
switch (_that) {
case ChangePasswordStateIdle():
return idle(_that.password,_that.confirmPassword,_that.obscurePassword,_that.obscureConfirmPassword,_that.errorText);case _ChangePasswordStateLoading():
return loading();case _ChangePasswordStateSuccess():
return success();case _ChangePasswordStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( ValidatedString password,  ValidatedString confirmPassword,  bool obscurePassword,  bool obscureConfirmPassword,  String? errorText)?  idle,TResult? Function()?  loading,TResult? Function()?  success,TResult? Function( DataError error)?  error,}) {final _that = this;
switch (_that) {
case ChangePasswordStateIdle() when idle != null:
return idle(_that.password,_that.confirmPassword,_that.obscurePassword,_that.obscureConfirmPassword,_that.errorText);case _ChangePasswordStateLoading() when loading != null:
return loading();case _ChangePasswordStateSuccess() when success != null:
return success();case _ChangePasswordStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class ChangePasswordStateIdle extends ChangePasswordState {
  const ChangePasswordStateIdle({this.password = ValidatedString.empty, this.confirmPassword = ValidatedString.empty, this.obscurePassword = true, this.obscureConfirmPassword = true, this.errorText}): super._();
  

@JsonKey() final  ValidatedString password;
@JsonKey() final  ValidatedString confirmPassword;
@JsonKey() final  bool obscurePassword;
@JsonKey() final  bool obscureConfirmPassword;
 final  String? errorText;

/// Create a copy of ChangePasswordState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangePasswordStateIdleCopyWith<ChangePasswordStateIdle> get copyWith => _$ChangePasswordStateIdleCopyWithImpl<ChangePasswordStateIdle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangePasswordStateIdle&&(identical(other.password, password) || other.password == password)&&(identical(other.confirmPassword, confirmPassword) || other.confirmPassword == confirmPassword)&&(identical(other.obscurePassword, obscurePassword) || other.obscurePassword == obscurePassword)&&(identical(other.obscureConfirmPassword, obscureConfirmPassword) || other.obscureConfirmPassword == obscureConfirmPassword)&&(identical(other.errorText, errorText) || other.errorText == errorText));
}


@override
int get hashCode => Object.hash(runtimeType,password,confirmPassword,obscurePassword,obscureConfirmPassword,errorText);

@override
String toString() {
  return 'ChangePasswordState.idle(password: $password, confirmPassword: $confirmPassword, obscurePassword: $obscurePassword, obscureConfirmPassword: $obscureConfirmPassword, errorText: $errorText)';
}


}

/// @nodoc
abstract mixin class $ChangePasswordStateIdleCopyWith<$Res> implements $ChangePasswordStateCopyWith<$Res> {
  factory $ChangePasswordStateIdleCopyWith(ChangePasswordStateIdle value, $Res Function(ChangePasswordStateIdle) _then) = _$ChangePasswordStateIdleCopyWithImpl;
@useResult
$Res call({
 ValidatedString password, ValidatedString confirmPassword, bool obscurePassword, bool obscureConfirmPassword, String? errorText
});


$ValidatedStringCopyWith<$Res> get password;$ValidatedStringCopyWith<$Res> get confirmPassword;

}
/// @nodoc
class _$ChangePasswordStateIdleCopyWithImpl<$Res>
    implements $ChangePasswordStateIdleCopyWith<$Res> {
  _$ChangePasswordStateIdleCopyWithImpl(this._self, this._then);

  final ChangePasswordStateIdle _self;
  final $Res Function(ChangePasswordStateIdle) _then;

/// Create a copy of ChangePasswordState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? password = null,Object? confirmPassword = null,Object? obscurePassword = null,Object? obscureConfirmPassword = null,Object? errorText = freezed,}) {
  return _then(ChangePasswordStateIdle(
password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as ValidatedString,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as ValidatedString,obscurePassword: null == obscurePassword ? _self.obscurePassword : obscurePassword // ignore: cast_nullable_to_non_nullable
as bool,obscureConfirmPassword: null == obscureConfirmPassword ? _self.obscureConfirmPassword : obscureConfirmPassword // ignore: cast_nullable_to_non_nullable
as bool,errorText: freezed == errorText ? _self.errorText : errorText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ChangePasswordState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ValidatedStringCopyWith<$Res> get password {
  
  return $ValidatedStringCopyWith<$Res>(_self.password, (value) {
    return _then(_self.copyWith(password: value));
  });
}/// Create a copy of ChangePasswordState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ValidatedStringCopyWith<$Res> get confirmPassword {
  
  return $ValidatedStringCopyWith<$Res>(_self.confirmPassword, (value) {
    return _then(_self.copyWith(confirmPassword: value));
  });
}
}

/// @nodoc


class _ChangePasswordStateLoading extends ChangePasswordState {
  const _ChangePasswordStateLoading(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangePasswordStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChangePasswordState.loading()';
}


}




/// @nodoc


class _ChangePasswordStateSuccess extends ChangePasswordState {
  const _ChangePasswordStateSuccess(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangePasswordStateSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChangePasswordState.success()';
}


}




/// @nodoc


class _ChangePasswordStateError extends ChangePasswordState {
  const _ChangePasswordStateError({required this.error}): super._();
  

 final  DataError error;

/// Create a copy of ChangePasswordState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangePasswordStateErrorCopyWith<_ChangePasswordStateError> get copyWith => __$ChangePasswordStateErrorCopyWithImpl<_ChangePasswordStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangePasswordStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'ChangePasswordState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$ChangePasswordStateErrorCopyWith<$Res> implements $ChangePasswordStateCopyWith<$Res> {
  factory _$ChangePasswordStateErrorCopyWith(_ChangePasswordStateError value, $Res Function(_ChangePasswordStateError) _then) = __$ChangePasswordStateErrorCopyWithImpl;
@useResult
$Res call({
 DataError error
});




}
/// @nodoc
class __$ChangePasswordStateErrorCopyWithImpl<$Res>
    implements _$ChangePasswordStateErrorCopyWith<$Res> {
  __$ChangePasswordStateErrorCopyWithImpl(this._self, this._then);

  final _ChangePasswordStateError _self;
  final $Res Function(_ChangePasswordStateError) _then;

/// Create a copy of ChangePasswordState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_ChangePasswordStateError(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as DataError,
  ));
}


}

// dart format on
