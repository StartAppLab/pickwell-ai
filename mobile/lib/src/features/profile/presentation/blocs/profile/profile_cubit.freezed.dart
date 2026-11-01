// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileState {

 String? get firstName;
/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileStateCopyWith<ProfileState> get copyWith => _$ProfileStateCopyWithImpl<ProfileState>(this as ProfileState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileState&&(identical(other.firstName, firstName) || other.firstName == firstName));
}


@override
int get hashCode => Object.hash(runtimeType,firstName);

@override
String toString() {
  return 'ProfileState(firstName: $firstName)';
}


}

/// @nodoc
abstract mixin class $ProfileStateCopyWith<$Res>  {
  factory $ProfileStateCopyWith(ProfileState value, $Res Function(ProfileState) _then) = _$ProfileStateCopyWithImpl;
@useResult
$Res call({
 String? firstName
});




}
/// @nodoc
class _$ProfileStateCopyWithImpl<$Res>
    implements $ProfileStateCopyWith<$Res> {
  _$ProfileStateCopyWithImpl(this._self, this._then);

  final ProfileState _self;
  final $Res Function(ProfileState) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? firstName = freezed,}) {
  return _then(_self.copyWith(
firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileState].
extension ProfileStatePatterns on ProfileState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ProfileStateIdle value)?  idle,TResult Function( _ProfileStateLoading value)?  loading,TResult Function( _ProfileStateSuccess value)?  success,TResult Function( _ProfileStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileStateIdle() when idle != null:
return idle(_that);case _ProfileStateLoading() when loading != null:
return loading(_that);case _ProfileStateSuccess() when success != null:
return success(_that);case _ProfileStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ProfileStateIdle value)  idle,required TResult Function( _ProfileStateLoading value)  loading,required TResult Function( _ProfileStateSuccess value)  success,required TResult Function( _ProfileStateError value)  error,}){
final _that = this;
switch (_that) {
case _ProfileStateIdle():
return idle(_that);case _ProfileStateLoading():
return loading(_that);case _ProfileStateSuccess():
return success(_that);case _ProfileStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ProfileStateIdle value)?  idle,TResult? Function( _ProfileStateLoading value)?  loading,TResult? Function( _ProfileStateSuccess value)?  success,TResult? Function( _ProfileStateError value)?  error,}){
final _that = this;
switch (_that) {
case _ProfileStateIdle() when idle != null:
return idle(_that);case _ProfileStateLoading() when loading != null:
return loading(_that);case _ProfileStateSuccess() when success != null:
return success(_that);case _ProfileStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( ProfileEntity entity,  String? firstName)?  idle,TResult Function( String? firstName)?  loading,TResult Function( String? firstName)?  success,TResult Function( DataError error,  String? firstName)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileStateIdle() when idle != null:
return idle(_that.entity,_that.firstName);case _ProfileStateLoading() when loading != null:
return loading(_that.firstName);case _ProfileStateSuccess() when success != null:
return success(_that.firstName);case _ProfileStateError() when error != null:
return error(_that.error,_that.firstName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( ProfileEntity entity,  String? firstName)  idle,required TResult Function( String? firstName)  loading,required TResult Function( String? firstName)  success,required TResult Function( DataError error,  String? firstName)  error,}) {final _that = this;
switch (_that) {
case _ProfileStateIdle():
return idle(_that.entity,_that.firstName);case _ProfileStateLoading():
return loading(_that.firstName);case _ProfileStateSuccess():
return success(_that.firstName);case _ProfileStateError():
return error(_that.error,_that.firstName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( ProfileEntity entity,  String? firstName)?  idle,TResult? Function( String? firstName)?  loading,TResult? Function( String? firstName)?  success,TResult? Function( DataError error,  String? firstName)?  error,}) {final _that = this;
switch (_that) {
case _ProfileStateIdle() when idle != null:
return idle(_that.entity,_that.firstName);case _ProfileStateLoading() when loading != null:
return loading(_that.firstName);case _ProfileStateSuccess() when success != null:
return success(_that.firstName);case _ProfileStateError() when error != null:
return error(_that.error,_that.firstName);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileStateIdle implements ProfileState {
  const _ProfileStateIdle({required this.entity, this.firstName});
  

 final  ProfileEntity entity;
@override final  String? firstName;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileStateIdleCopyWith<_ProfileStateIdle> get copyWith => __$ProfileStateIdleCopyWithImpl<_ProfileStateIdle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileStateIdle&&(identical(other.entity, entity) || other.entity == entity)&&(identical(other.firstName, firstName) || other.firstName == firstName));
}


@override
int get hashCode => Object.hash(runtimeType,entity,firstName);

@override
String toString() {
  return 'ProfileState.idle(entity: $entity, firstName: $firstName)';
}


}

/// @nodoc
abstract mixin class _$ProfileStateIdleCopyWith<$Res> implements $ProfileStateCopyWith<$Res> {
  factory _$ProfileStateIdleCopyWith(_ProfileStateIdle value, $Res Function(_ProfileStateIdle) _then) = __$ProfileStateIdleCopyWithImpl;
@override @useResult
$Res call({
 ProfileEntity entity, String? firstName
});


$ProfileEntityCopyWith<$Res> get entity;

}
/// @nodoc
class __$ProfileStateIdleCopyWithImpl<$Res>
    implements _$ProfileStateIdleCopyWith<$Res> {
  __$ProfileStateIdleCopyWithImpl(this._self, this._then);

  final _ProfileStateIdle _self;
  final $Res Function(_ProfileStateIdle) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entity = null,Object? firstName = freezed,}) {
  return _then(_ProfileStateIdle(
entity: null == entity ? _self.entity : entity // ignore: cast_nullable_to_non_nullable
as ProfileEntity,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileEntityCopyWith<$Res> get entity {
  
  return $ProfileEntityCopyWith<$Res>(_self.entity, (value) {
    return _then(_self.copyWith(entity: value));
  });
}
}

/// @nodoc


class _ProfileStateLoading implements ProfileState {
  const _ProfileStateLoading({this.firstName});
  

@override final  String? firstName;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileStateLoadingCopyWith<_ProfileStateLoading> get copyWith => __$ProfileStateLoadingCopyWithImpl<_ProfileStateLoading>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileStateLoading&&(identical(other.firstName, firstName) || other.firstName == firstName));
}


@override
int get hashCode => Object.hash(runtimeType,firstName);

@override
String toString() {
  return 'ProfileState.loading(firstName: $firstName)';
}


}

/// @nodoc
abstract mixin class _$ProfileStateLoadingCopyWith<$Res> implements $ProfileStateCopyWith<$Res> {
  factory _$ProfileStateLoadingCopyWith(_ProfileStateLoading value, $Res Function(_ProfileStateLoading) _then) = __$ProfileStateLoadingCopyWithImpl;
@override @useResult
$Res call({
 String? firstName
});




}
/// @nodoc
class __$ProfileStateLoadingCopyWithImpl<$Res>
    implements _$ProfileStateLoadingCopyWith<$Res> {
  __$ProfileStateLoadingCopyWithImpl(this._self, this._then);

  final _ProfileStateLoading _self;
  final $Res Function(_ProfileStateLoading) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? firstName = freezed,}) {
  return _then(_ProfileStateLoading(
firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _ProfileStateSuccess implements ProfileState {
  const _ProfileStateSuccess({this.firstName});
  

@override final  String? firstName;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileStateSuccessCopyWith<_ProfileStateSuccess> get copyWith => __$ProfileStateSuccessCopyWithImpl<_ProfileStateSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileStateSuccess&&(identical(other.firstName, firstName) || other.firstName == firstName));
}


@override
int get hashCode => Object.hash(runtimeType,firstName);

@override
String toString() {
  return 'ProfileState.success(firstName: $firstName)';
}


}

/// @nodoc
abstract mixin class _$ProfileStateSuccessCopyWith<$Res> implements $ProfileStateCopyWith<$Res> {
  factory _$ProfileStateSuccessCopyWith(_ProfileStateSuccess value, $Res Function(_ProfileStateSuccess) _then) = __$ProfileStateSuccessCopyWithImpl;
@override @useResult
$Res call({
 String? firstName
});




}
/// @nodoc
class __$ProfileStateSuccessCopyWithImpl<$Res>
    implements _$ProfileStateSuccessCopyWith<$Res> {
  __$ProfileStateSuccessCopyWithImpl(this._self, this._then);

  final _ProfileStateSuccess _self;
  final $Res Function(_ProfileStateSuccess) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? firstName = freezed,}) {
  return _then(_ProfileStateSuccess(
firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _ProfileStateError implements ProfileState {
  const _ProfileStateError({required this.error, this.firstName});
  

 final  DataError error;
@override final  String? firstName;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileStateErrorCopyWith<_ProfileStateError> get copyWith => __$ProfileStateErrorCopyWithImpl<_ProfileStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileStateError&&(identical(other.error, error) || other.error == error)&&(identical(other.firstName, firstName) || other.firstName == firstName));
}


@override
int get hashCode => Object.hash(runtimeType,error,firstName);

@override
String toString() {
  return 'ProfileState.error(error: $error, firstName: $firstName)';
}


}

/// @nodoc
abstract mixin class _$ProfileStateErrorCopyWith<$Res> implements $ProfileStateCopyWith<$Res> {
  factory _$ProfileStateErrorCopyWith(_ProfileStateError value, $Res Function(_ProfileStateError) _then) = __$ProfileStateErrorCopyWithImpl;
@override @useResult
$Res call({
 DataError error, String? firstName
});




}
/// @nodoc
class __$ProfileStateErrorCopyWithImpl<$Res>
    implements _$ProfileStateErrorCopyWith<$Res> {
  __$ProfileStateErrorCopyWithImpl(this._self, this._then);

  final _ProfileStateError _self;
  final $Res Function(_ProfileStateError) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? error = null,Object? firstName = freezed,}) {
  return _then(_ProfileStateError(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as DataError,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
