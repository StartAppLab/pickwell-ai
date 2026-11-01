// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_account_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsAccountState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsAccountState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SettingsAccountState()';
}


}

/// @nodoc
class $SettingsAccountStateCopyWith<$Res>  {
$SettingsAccountStateCopyWith(SettingsAccountState _, $Res Function(SettingsAccountState) __);
}


/// Adds pattern-matching-related methods to [SettingsAccountState].
extension SettingsAccountStatePatterns on SettingsAccountState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SettingsAccountStateIdle value)?  idle,TResult Function( SettingsAccountStateLoading value)?  loading,TResult Function( SettingsAccountStateSuccess value)?  success,TResult Function( SettingsAccountStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SettingsAccountStateIdle() when idle != null:
return idle(_that);case SettingsAccountStateLoading() when loading != null:
return loading(_that);case SettingsAccountStateSuccess() when success != null:
return success(_that);case SettingsAccountStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SettingsAccountStateIdle value)  idle,required TResult Function( SettingsAccountStateLoading value)  loading,required TResult Function( SettingsAccountStateSuccess value)  success,required TResult Function( SettingsAccountStateError value)  error,}){
final _that = this;
switch (_that) {
case SettingsAccountStateIdle():
return idle(_that);case SettingsAccountStateLoading():
return loading(_that);case SettingsAccountStateSuccess():
return success(_that);case SettingsAccountStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SettingsAccountStateIdle value)?  idle,TResult? Function( SettingsAccountStateLoading value)?  loading,TResult? Function( SettingsAccountStateSuccess value)?  success,TResult? Function( SettingsAccountStateError value)?  error,}){
final _that = this;
switch (_that) {
case SettingsAccountStateIdle() when idle != null:
return idle(_that);case SettingsAccountStateLoading() when loading != null:
return loading(_that);case SettingsAccountStateSuccess() when success != null:
return success(_that);case SettingsAccountStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  loading,TResult Function( String message)?  success,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SettingsAccountStateIdle() when idle != null:
return idle();case SettingsAccountStateLoading() when loading != null:
return loading();case SettingsAccountStateSuccess() when success != null:
return success(_that.message);case SettingsAccountStateError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  loading,required TResult Function( String message)  success,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case SettingsAccountStateIdle():
return idle();case SettingsAccountStateLoading():
return loading();case SettingsAccountStateSuccess():
return success(_that.message);case SettingsAccountStateError():
return error(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  loading,TResult? Function( String message)?  success,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case SettingsAccountStateIdle() when idle != null:
return idle();case SettingsAccountStateLoading() when loading != null:
return loading();case SettingsAccountStateSuccess() when success != null:
return success(_that.message);case SettingsAccountStateError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class SettingsAccountStateIdle implements SettingsAccountState {
  const SettingsAccountStateIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsAccountStateIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SettingsAccountState.idle()';
}


}




/// @nodoc


class SettingsAccountStateLoading implements SettingsAccountState {
  const SettingsAccountStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsAccountStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SettingsAccountState.loading()';
}


}




/// @nodoc


class SettingsAccountStateSuccess implements SettingsAccountState {
  const SettingsAccountStateSuccess({required this.message});
  

 final  String message;

/// Create a copy of SettingsAccountState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsAccountStateSuccessCopyWith<SettingsAccountStateSuccess> get copyWith => _$SettingsAccountStateSuccessCopyWithImpl<SettingsAccountStateSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsAccountStateSuccess&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'SettingsAccountState.success(message: $message)';
}


}

/// @nodoc
abstract mixin class $SettingsAccountStateSuccessCopyWith<$Res> implements $SettingsAccountStateCopyWith<$Res> {
  factory $SettingsAccountStateSuccessCopyWith(SettingsAccountStateSuccess value, $Res Function(SettingsAccountStateSuccess) _then) = _$SettingsAccountStateSuccessCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$SettingsAccountStateSuccessCopyWithImpl<$Res>
    implements $SettingsAccountStateSuccessCopyWith<$Res> {
  _$SettingsAccountStateSuccessCopyWithImpl(this._self, this._then);

  final SettingsAccountStateSuccess _self;
  final $Res Function(SettingsAccountStateSuccess) _then;

/// Create a copy of SettingsAccountState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(SettingsAccountStateSuccess(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SettingsAccountStateError implements SettingsAccountState {
  const SettingsAccountStateError({required this.message});
  

 final  String message;

/// Create a copy of SettingsAccountState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsAccountStateErrorCopyWith<SettingsAccountStateError> get copyWith => _$SettingsAccountStateErrorCopyWithImpl<SettingsAccountStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsAccountStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'SettingsAccountState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $SettingsAccountStateErrorCopyWith<$Res> implements $SettingsAccountStateCopyWith<$Res> {
  factory $SettingsAccountStateErrorCopyWith(SettingsAccountStateError value, $Res Function(SettingsAccountStateError) _then) = _$SettingsAccountStateErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$SettingsAccountStateErrorCopyWithImpl<$Res>
    implements $SettingsAccountStateErrorCopyWith<$Res> {
  _$SettingsAccountStateErrorCopyWithImpl(this._self, this._then);

  final SettingsAccountStateError _self;
  final $Res Function(SettingsAccountStateError) _then;

/// Create a copy of SettingsAccountState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(SettingsAccountStateError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
