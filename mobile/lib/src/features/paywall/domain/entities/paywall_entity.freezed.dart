// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paywall_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaywallEntity {

 int get id; String get message;
/// Create a copy of PaywallEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaywallEntityCopyWith<PaywallEntity> get copyWith => _$PaywallEntityCopyWithImpl<PaywallEntity>(this as PaywallEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaywallEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,id,message);

@override
String toString() {
  return 'PaywallEntity(id: $id, message: $message)';
}


}

/// @nodoc
abstract mixin class $PaywallEntityCopyWith<$Res>  {
  factory $PaywallEntityCopyWith(PaywallEntity value, $Res Function(PaywallEntity) _then) = _$PaywallEntityCopyWithImpl;
@useResult
$Res call({
 int id, String message
});




}
/// @nodoc
class _$PaywallEntityCopyWithImpl<$Res>
    implements $PaywallEntityCopyWith<$Res> {
  _$PaywallEntityCopyWithImpl(this._self, this._then);

  final PaywallEntity _self;
  final $Res Function(PaywallEntity) _then;

/// Create a copy of PaywallEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? message = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PaywallEntity].
extension PaywallEntityPatterns on PaywallEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaywallEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaywallEntity() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaywallEntity value)  $default,){
final _that = this;
switch (_that) {
case _PaywallEntity():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaywallEntity value)?  $default,){
final _that = this;
switch (_that) {
case _PaywallEntity() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaywallEntity() when $default != null:
return $default(_that.id,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String message)  $default,) {final _that = this;
switch (_that) {
case _PaywallEntity():
return $default(_that.id,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String message)?  $default,) {final _that = this;
switch (_that) {
case _PaywallEntity() when $default != null:
return $default(_that.id,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _PaywallEntity implements PaywallEntity {
  const _PaywallEntity({required this.id, required this.message});
  

@override final  int id;
@override final  String message;

/// Create a copy of PaywallEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaywallEntityCopyWith<_PaywallEntity> get copyWith => __$PaywallEntityCopyWithImpl<_PaywallEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaywallEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,id,message);

@override
String toString() {
  return 'PaywallEntity(id: $id, message: $message)';
}


}

/// @nodoc
abstract mixin class _$PaywallEntityCopyWith<$Res> implements $PaywallEntityCopyWith<$Res> {
  factory _$PaywallEntityCopyWith(_PaywallEntity value, $Res Function(_PaywallEntity) _then) = __$PaywallEntityCopyWithImpl;
@override @useResult
$Res call({
 int id, String message
});




}
/// @nodoc
class __$PaywallEntityCopyWithImpl<$Res>
    implements _$PaywallEntityCopyWith<$Res> {
  __$PaywallEntityCopyWithImpl(this._self, this._then);

  final _PaywallEntity _self;
  final $Res Function(_PaywallEntity) _then;

/// Create a copy of PaywallEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? message = null,}) {
  return _then(_PaywallEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
