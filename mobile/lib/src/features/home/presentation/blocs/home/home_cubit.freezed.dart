// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HomeState()';
}


}

/// @nodoc
class $HomeStateCopyWith<$Res>  {
$HomeStateCopyWith(HomeState _, $Res Function(HomeState) __);
}


/// Adds pattern-matching-related methods to [HomeState].
extension HomeStatePatterns on HomeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _HomeStateIdle value)?  idle,TResult Function( _HomeStateLoading value)?  loading,TResult Function( _HomeStateSuccess value)?  success,TResult Function( _HomeStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeStateIdle() when idle != null:
return idle(_that);case _HomeStateLoading() when loading != null:
return loading(_that);case _HomeStateSuccess() when success != null:
return success(_that);case _HomeStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _HomeStateIdle value)  idle,required TResult Function( _HomeStateLoading value)  loading,required TResult Function( _HomeStateSuccess value)  success,required TResult Function( _HomeStateError value)  error,}){
final _that = this;
switch (_that) {
case _HomeStateIdle():
return idle(_that);case _HomeStateLoading():
return loading(_that);case _HomeStateSuccess():
return success(_that);case _HomeStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _HomeStateIdle value)?  idle,TResult? Function( _HomeStateLoading value)?  loading,TResult? Function( _HomeStateSuccess value)?  success,TResult? Function( _HomeStateError value)?  error,}){
final _that = this;
switch (_that) {
case _HomeStateIdle() when idle != null:
return idle(_that);case _HomeStateLoading() when loading != null:
return loading(_that);case _HomeStateSuccess() when success != null:
return success(_that);case _HomeStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  loading,TResult Function()?  success,TResult Function( DataError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeStateIdle() when idle != null:
return idle();case _HomeStateLoading() when loading != null:
return loading();case _HomeStateSuccess() when success != null:
return success();case _HomeStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  loading,required TResult Function()  success,required TResult Function( DataError error)  error,}) {final _that = this;
switch (_that) {
case _HomeStateIdle():
return idle();case _HomeStateLoading():
return loading();case _HomeStateSuccess():
return success();case _HomeStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  loading,TResult? Function()?  success,TResult? Function( DataError error)?  error,}) {final _that = this;
switch (_that) {
case _HomeStateIdle() when idle != null:
return idle();case _HomeStateLoading() when loading != null:
return loading();case _HomeStateSuccess() when success != null:
return success();case _HomeStateError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _HomeStateIdle implements HomeState {
  const _HomeStateIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeStateIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HomeState.idle()';
}


}




/// @nodoc


class _HomeStateLoading implements HomeState {
  const _HomeStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HomeState.loading()';
}


}




/// @nodoc


class _HomeStateSuccess implements HomeState {
  const _HomeStateSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeStateSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HomeState.success()';
}


}




/// @nodoc


class _HomeStateError implements HomeState {
  const _HomeStateError({required this.error});
  

 final  DataError error;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeStateErrorCopyWith<_HomeStateError> get copyWith => __$HomeStateErrorCopyWithImpl<_HomeStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeStateError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'HomeState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$HomeStateErrorCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory _$HomeStateErrorCopyWith(_HomeStateError value, $Res Function(_HomeStateError) _then) = __$HomeStateErrorCopyWithImpl;
@useResult
$Res call({
 DataError error
});




}
/// @nodoc
class __$HomeStateErrorCopyWithImpl<$Res>
    implements _$HomeStateErrorCopyWith<$Res> {
  __$HomeStateErrorCopyWithImpl(this._self, this._then);

  final _HomeStateError _self;
  final $Res Function(_HomeStateError) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_HomeStateError(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as DataError,
  ));
}


}

// dart format on
