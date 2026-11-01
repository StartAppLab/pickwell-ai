// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'validated_string.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ValidatedString {

 String get value; IsValid? get isValid;
/// Create a copy of ValidatedString
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValidatedStringCopyWith<ValidatedString> get copyWith => _$ValidatedStringCopyWithImpl<ValidatedString>(this as ValidatedString, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ValidatedString&&(identical(other.value, value) || other.value == value)&&(identical(other.isValid, isValid) || other.isValid == isValid));
}


@override
int get hashCode => Object.hash(runtimeType,value,isValid);

@override
String toString() {
  return 'ValidatedString(value: $value, isValid: $isValid)';
}


}

/// @nodoc
abstract mixin class $ValidatedStringCopyWith<$Res>  {
  factory $ValidatedStringCopyWith(ValidatedString value, $Res Function(ValidatedString) _then) = _$ValidatedStringCopyWithImpl;
@useResult
$Res call({
 String value, IsValid? isValid
});




}
/// @nodoc
class _$ValidatedStringCopyWithImpl<$Res>
    implements $ValidatedStringCopyWith<$Res> {
  _$ValidatedStringCopyWithImpl(this._self, this._then);

  final ValidatedString _self;
  final $Res Function(ValidatedString) _then;

/// Create a copy of ValidatedString
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? isValid = freezed,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,isValid: freezed == isValid ? _self.isValid : isValid // ignore: cast_nullable_to_non_nullable
as IsValid?,
  ));
}

}


/// Adds pattern-matching-related methods to [ValidatedString].
extension ValidatedStringPatterns on ValidatedString {
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value,  IsValid? isValid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ValidatedString() when $default != null:
return $default(_that.value,_that.isValid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value,  IsValid? isValid)  $default,) {final _that = this;
switch (_that) {
case _ValidatedString():
return $default(_that.value,_that.isValid);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value,  IsValid? isValid)?  $default,) {final _that = this;
switch (_that) {
case _ValidatedString() when $default != null:
return $default(_that.value,_that.isValid);case _:
  return null;

}
}

}

/// @nodoc


class _ValidatedString extends ValidatedString {
  const _ValidatedString({this.value = '', this.isValid = null}): super._();
  

@override@JsonKey() final  String value;
@override@JsonKey() final  IsValid? isValid;

/// Create a copy of ValidatedString
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ValidatedStringCopyWith<_ValidatedString> get copyWith => __$ValidatedStringCopyWithImpl<_ValidatedString>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ValidatedString&&(identical(other.value, value) || other.value == value)&&(identical(other.isValid, isValid) || other.isValid == isValid));
}


@override
int get hashCode => Object.hash(runtimeType,value,isValid);

@override
String toString() {
  return 'ValidatedString(value: $value, isValid: $isValid)';
}


}

/// @nodoc
abstract mixin class _$ValidatedStringCopyWith<$Res> implements $ValidatedStringCopyWith<$Res> {
  factory _$ValidatedStringCopyWith(_ValidatedString value, $Res Function(_ValidatedString) _then) = __$ValidatedStringCopyWithImpl;
@override @useResult
$Res call({
 String value, IsValid? isValid
});




}
/// @nodoc
class __$ValidatedStringCopyWithImpl<$Res>
    implements _$ValidatedStringCopyWith<$Res> {
  __$ValidatedStringCopyWithImpl(this._self, this._then);

  final _ValidatedString _self;
  final $Res Function(_ValidatedString) _then;

/// Create a copy of ValidatedString
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? isValid = freezed,}) {
  return _then(_ValidatedString(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,isValid: freezed == isValid ? _self.isValid : isValid // ignore: cast_nullable_to_non_nullable
as IsValid?,
  ));
}


}

// dart format on
