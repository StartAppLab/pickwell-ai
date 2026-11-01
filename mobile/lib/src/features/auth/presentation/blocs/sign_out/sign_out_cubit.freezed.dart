// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sign_out_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SignOutState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignOutState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SignOutState()';
}


}

/// @nodoc
class $SignOutStateCopyWith<$Res>  {
$SignOutStateCopyWith(SignOutState _, $Res Function(SignOutState) __);
}


/// Adds pattern-matching-related methods to [SignOutState].
extension SignOutStatePatterns on SignOutState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _SignOutStateIdle value)?  idle,TResult Function( _SignOutStateLoading value)?  loading,TResult Function( _SignOutStateSuccess value)?  success,TResult Function( _SignOutStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SignOutStateIdle() when idle != null:
return idle(_that);case _SignOutStateLoading() when loading != null:
return loading(_that);case _SignOutStateSuccess() when success != null:
return success(_that);case _SignOutStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _SignOutStateIdle value)  idle,required TResult Function( _SignOutStateLoading value)  loading,required TResult Function( _SignOutStateSuccess value)  success,required TResult Function( _SignOutStateError value)  error,}){
final _that = this;
switch (_that) {
case _SignOutStateIdle():
return idle(_that);case _SignOutStateLoading():
return loading(_that);case _SignOutStateSuccess():
return success(_that);case _SignOutStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _SignOutStateIdle value)?  idle,TResult? Function( _SignOutStateLoading value)?  loading,TResult? Function( _SignOutStateSuccess value)?  success,TResult? Function( _SignOutStateError value)?  error,}){
final _that = this;
switch (_that) {
case _SignOutStateIdle() when idle != null:
return idle(_that);case _SignOutStateLoading() when loading != null:
return loading(_that);case _SignOutStateSuccess() when success != null:
return success(_that);case _SignOutStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( ValidatedString email)?  idle,TResult Function()?  loading,TResult Function()?  success,TResult Function( DataError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SignOutStateIdle() when idle != null:
return idle(_that.email);case _SignOutStateLoading() when loading != null:
return loading();case _SignOutStateSuccess() when success != null:
return success();case _SignOutStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( ValidatedString email)  idle,required TResult Function()  loading,required TResult Function()  success,required TResult Function( DataError error)  error,}) {final _that = this;
switch (_that) {
case _SignOutStateIdle():
return idle(_that.email);case _SignOutStateLoading():
return loading();case _SignOutStateSuccess():
return success();case _SignOutStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( ValidatedString email)?  idle,TResult? Function()?  loading,TResult? Function()?  success,TResult? Function( DataError error)?  error,}) {final _that = this;
switch (_that) {
case _SignOutStateIdle() when idle != null:
return idle(_that.email);case _SignOutStateLoading() when loading != null:
return loading();case _SignOutStateSuccess() when success != null:
return success();case _SignOutStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _SignOutStateIdle extends SignOutState {
  const _SignOutStateIdle({this.email = ValidatedString.empty}): super._();
  

@JsonKey() final  ValidatedString email;

/// Create a copy of SignOutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignOutStateIdleCopyWith<_SignOutStateIdle> get copyWith => __$SignOutStateIdleCopyWithImpl<_SignOutStateIdle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignOutStateIdle&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode => Object.hash(runtimeType,email);

@override
String toString() {
  return 'SignOutState.idle(email: $email)';
}


}

/// @nodoc
abstract mixin class _$SignOutStateIdleCopyWith<$Res> implements $SignOutStateCopyWith<$Res> {
  factory _$SignOutStateIdleCopyWith(_SignOutStateIdle value, $Res Function(_SignOutStateIdle) _then) = __$SignOutStateIdleCopyWithImpl;
@useResult
$Res call({
 ValidatedString email
});


$ValidatedStringCopyWith<$Res> get email;

}
/// @nodoc
class __$SignOutStateIdleCopyWithImpl<$Res>
    implements _$SignOutStateIdleCopyWith<$Res> {
  __$SignOutStateIdleCopyWithImpl(this._self, this._then);

  final _SignOutStateIdle _self;
  final $Res Function(_SignOutStateIdle) _then;

/// Create a copy of SignOutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,}) {
  return _then(_SignOutStateIdle(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as ValidatedString,
  ));
}

/// Create a copy of SignOutState
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


class _SignOutStateLoading extends SignOutState {
  const _SignOutStateLoading(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignOutStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SignOutState.loading()';
}


}




/// @nodoc


class _SignOutStateSuccess extends SignOutState {
  const _SignOutStateSuccess(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignOutStateSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SignOutState.success()';
}


}




/// @nodoc


class _SignOutStateError extends SignOutState {
  const _SignOutStateError({required this.error}): super._();
  

 final  DataError error;

/// Create a copy of SignOutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignOutStateErrorCopyWith<_SignOutStateError> get copyWith => __$SignOutStateErrorCopyWithImpl<_SignOutStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignOutStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'SignOutState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$SignOutStateErrorCopyWith<$Res> implements $SignOutStateCopyWith<$Res> {
  factory _$SignOutStateErrorCopyWith(_SignOutStateError value, $Res Function(_SignOutStateError) _then) = __$SignOutStateErrorCopyWithImpl;
@useResult
$Res call({
 DataError error
});




}
/// @nodoc
class __$SignOutStateErrorCopyWithImpl<$Res>
    implements _$SignOutStateErrorCopyWith<$Res> {
  __$SignOutStateErrorCopyWithImpl(this._self, this._then);

  final _SignOutStateError _self;
  final $Res Function(_SignOutStateError) _then;

/// Create a copy of SignOutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_SignOutStateError(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as DataError,
  ));
}


}

// dart format on
