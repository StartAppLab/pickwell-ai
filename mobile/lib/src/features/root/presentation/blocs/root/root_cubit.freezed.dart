// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'root_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RootState {

 int get selectedIndex;
/// Create a copy of RootState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RootStateCopyWith<RootState> get copyWith => _$RootStateCopyWithImpl<RootState>(this as RootState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RootState&&(identical(other.selectedIndex, selectedIndex) || other.selectedIndex == selectedIndex));
}


@override
int get hashCode => Object.hash(runtimeType,selectedIndex);

@override
String toString() {
  return 'RootState(selectedIndex: $selectedIndex)';
}


}

/// @nodoc
abstract mixin class $RootStateCopyWith<$Res>  {
  factory $RootStateCopyWith(RootState value, $Res Function(RootState) _then) = _$RootStateCopyWithImpl;
@useResult
$Res call({
 int selectedIndex
});




}
/// @nodoc
class _$RootStateCopyWithImpl<$Res>
    implements $RootStateCopyWith<$Res> {
  _$RootStateCopyWithImpl(this._self, this._then);

  final RootState _self;
  final $Res Function(RootState) _then;

/// Create a copy of RootState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedIndex = null,}) {
  return _then(_self.copyWith(
selectedIndex: null == selectedIndex ? _self.selectedIndex : selectedIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RootState].
extension RootStatePatterns on RootState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _RootStateIdle value)?  idle,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RootStateIdle() when idle != null:
return idle(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _RootStateIdle value)  idle,}){
final _that = this;
switch (_that) {
case _RootStateIdle():
return idle(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _RootStateIdle value)?  idle,}){
final _that = this;
switch (_that) {
case _RootStateIdle() when idle != null:
return idle(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int selectedIndex)?  idle,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RootStateIdle() when idle != null:
return idle(_that.selectedIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int selectedIndex)  idle,}) {final _that = this;
switch (_that) {
case _RootStateIdle():
return idle(_that.selectedIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int selectedIndex)?  idle,}) {final _that = this;
switch (_that) {
case _RootStateIdle() when idle != null:
return idle(_that.selectedIndex);case _:
  return null;

}
}

}

/// @nodoc


class _RootStateIdle implements RootState {
  const _RootStateIdle({this.selectedIndex = 0});
  

@override@JsonKey() final  int selectedIndex;

/// Create a copy of RootState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RootStateIdleCopyWith<_RootStateIdle> get copyWith => __$RootStateIdleCopyWithImpl<_RootStateIdle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RootStateIdle&&(identical(other.selectedIndex, selectedIndex) || other.selectedIndex == selectedIndex));
}


@override
int get hashCode => Object.hash(runtimeType,selectedIndex);

@override
String toString() {
  return 'RootState.idle(selectedIndex: $selectedIndex)';
}


}

/// @nodoc
abstract mixin class _$RootStateIdleCopyWith<$Res> implements $RootStateCopyWith<$Res> {
  factory _$RootStateIdleCopyWith(_RootStateIdle value, $Res Function(_RootStateIdle) _then) = __$RootStateIdleCopyWithImpl;
@override @useResult
$Res call({
 int selectedIndex
});




}
/// @nodoc
class __$RootStateIdleCopyWithImpl<$Res>
    implements _$RootStateIdleCopyWith<$Res> {
  __$RootStateIdleCopyWithImpl(this._self, this._then);

  final _RootStateIdle _self;
  final $Res Function(_RootStateIdle) _then;

/// Create a copy of RootState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedIndex = null,}) {
  return _then(_RootStateIdle(
selectedIndex: null == selectedIndex ? _self.selectedIndex : selectedIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
