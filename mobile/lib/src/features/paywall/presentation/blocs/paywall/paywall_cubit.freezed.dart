// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paywall_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaywallState {

 int get slideIndex; String get selectedPlan; bool get isLoading; DataError? get error; bool get isSuccess; bool get isPurchaseSuccess; String? get errorText; Offerings? get offerings; Offering? get offering;
/// Create a copy of PaywallState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaywallStateCopyWith<PaywallState> get copyWith => _$PaywallStateCopyWithImpl<PaywallState>(this as PaywallState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaywallState&&(identical(other.slideIndex, slideIndex) || other.slideIndex == slideIndex)&&(identical(other.selectedPlan, selectedPlan) || other.selectedPlan == selectedPlan)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error)&&(identical(other.isSuccess, isSuccess) || other.isSuccess == isSuccess)&&(identical(other.isPurchaseSuccess, isPurchaseSuccess) || other.isPurchaseSuccess == isPurchaseSuccess)&&(identical(other.errorText, errorText) || other.errorText == errorText)&&(identical(other.offerings, offerings) || other.offerings == offerings)&&(identical(other.offering, offering) || other.offering == offering));
}


@override
int get hashCode => Object.hash(runtimeType,slideIndex,selectedPlan,isLoading,error,isSuccess,isPurchaseSuccess,errorText,offerings,offering);

@override
String toString() {
  return 'PaywallState(slideIndex: $slideIndex, selectedPlan: $selectedPlan, isLoading: $isLoading, error: $error, isSuccess: $isSuccess, isPurchaseSuccess: $isPurchaseSuccess, errorText: $errorText, offerings: $offerings, offering: $offering)';
}


}

/// @nodoc
abstract mixin class $PaywallStateCopyWith<$Res>  {
  factory $PaywallStateCopyWith(PaywallState value, $Res Function(PaywallState) _then) = _$PaywallStateCopyWithImpl;
@useResult
$Res call({
 int slideIndex, String selectedPlan, bool isLoading, DataError? error, bool isSuccess, bool isPurchaseSuccess, String? errorText, Offerings? offerings, Offering? offering
});




}
/// @nodoc
class _$PaywallStateCopyWithImpl<$Res>
    implements $PaywallStateCopyWith<$Res> {
  _$PaywallStateCopyWithImpl(this._self, this._then);

  final PaywallState _self;
  final $Res Function(PaywallState) _then;

/// Create a copy of PaywallState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slideIndex = null,Object? selectedPlan = null,Object? isLoading = null,Object? error = freezed,Object? isSuccess = null,Object? isPurchaseSuccess = null,Object? errorText = freezed,Object? offerings = freezed,Object? offering = freezed,}) {
  return _then(_self.copyWith(
slideIndex: null == slideIndex ? _self.slideIndex : slideIndex // ignore: cast_nullable_to_non_nullable
as int,selectedPlan: null == selectedPlan ? _self.selectedPlan : selectedPlan // ignore: cast_nullable_to_non_nullable
as String,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as DataError?,isSuccess: null == isSuccess ? _self.isSuccess : isSuccess // ignore: cast_nullable_to_non_nullable
as bool,isPurchaseSuccess: null == isPurchaseSuccess ? _self.isPurchaseSuccess : isPurchaseSuccess // ignore: cast_nullable_to_non_nullable
as bool,errorText: freezed == errorText ? _self.errorText : errorText // ignore: cast_nullable_to_non_nullable
as String?,offerings: freezed == offerings ? _self.offerings : offerings // ignore: cast_nullable_to_non_nullable
as Offerings?,offering: freezed == offering ? _self.offering : offering // ignore: cast_nullable_to_non_nullable
as Offering?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaywallState].
extension PaywallStatePatterns on PaywallState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _PaywallStateIdle value)?  idle,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaywallStateIdle() when idle != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _PaywallStateIdle value)  idle,}){
final _that = this;
switch (_that) {
case _PaywallStateIdle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _PaywallStateIdle value)?  idle,}){
final _that = this;
switch (_that) {
case _PaywallStateIdle() when idle != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int slideIndex,  String selectedPlan,  bool isLoading,  DataError? error,  bool isSuccess,  bool isPurchaseSuccess,  String? errorText,  Offerings? offerings,  Offering? offering)?  idle,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaywallStateIdle() when idle != null:
return idle(_that.slideIndex,_that.selectedPlan,_that.isLoading,_that.error,_that.isSuccess,_that.isPurchaseSuccess,_that.errorText,_that.offerings,_that.offering);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int slideIndex,  String selectedPlan,  bool isLoading,  DataError? error,  bool isSuccess,  bool isPurchaseSuccess,  String? errorText,  Offerings? offerings,  Offering? offering)  idle,}) {final _that = this;
switch (_that) {
case _PaywallStateIdle():
return idle(_that.slideIndex,_that.selectedPlan,_that.isLoading,_that.error,_that.isSuccess,_that.isPurchaseSuccess,_that.errorText,_that.offerings,_that.offering);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int slideIndex,  String selectedPlan,  bool isLoading,  DataError? error,  bool isSuccess,  bool isPurchaseSuccess,  String? errorText,  Offerings? offerings,  Offering? offering)?  idle,}) {final _that = this;
switch (_that) {
case _PaywallStateIdle() when idle != null:
return idle(_that.slideIndex,_that.selectedPlan,_that.isLoading,_that.error,_that.isSuccess,_that.isPurchaseSuccess,_that.errorText,_that.offerings,_that.offering);case _:
  return null;

}
}

}

/// @nodoc


class _PaywallStateIdle implements PaywallState {
  const _PaywallStateIdle({this.slideIndex = 0, this.selectedPlan = '', this.isLoading = false, this.error, this.isSuccess = false, this.isPurchaseSuccess = false, this.errorText, this.offerings, this.offering});
  

@override@JsonKey() final  int slideIndex;
@override@JsonKey() final  String selectedPlan;
@override@JsonKey() final  bool isLoading;
@override final  DataError? error;
@override@JsonKey() final  bool isSuccess;
@override@JsonKey() final  bool isPurchaseSuccess;
@override final  String? errorText;
@override final  Offerings? offerings;
@override final  Offering? offering;

/// Create a copy of PaywallState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaywallStateIdleCopyWith<_PaywallStateIdle> get copyWith => __$PaywallStateIdleCopyWithImpl<_PaywallStateIdle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaywallStateIdle&&(identical(other.slideIndex, slideIndex) || other.slideIndex == slideIndex)&&(identical(other.selectedPlan, selectedPlan) || other.selectedPlan == selectedPlan)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error)&&(identical(other.isSuccess, isSuccess) || other.isSuccess == isSuccess)&&(identical(other.isPurchaseSuccess, isPurchaseSuccess) || other.isPurchaseSuccess == isPurchaseSuccess)&&(identical(other.errorText, errorText) || other.errorText == errorText)&&(identical(other.offerings, offerings) || other.offerings == offerings)&&(identical(other.offering, offering) || other.offering == offering));
}


@override
int get hashCode => Object.hash(runtimeType,slideIndex,selectedPlan,isLoading,error,isSuccess,isPurchaseSuccess,errorText,offerings,offering);

@override
String toString() {
  return 'PaywallState.idle(slideIndex: $slideIndex, selectedPlan: $selectedPlan, isLoading: $isLoading, error: $error, isSuccess: $isSuccess, isPurchaseSuccess: $isPurchaseSuccess, errorText: $errorText, offerings: $offerings, offering: $offering)';
}


}

/// @nodoc
abstract mixin class _$PaywallStateIdleCopyWith<$Res> implements $PaywallStateCopyWith<$Res> {
  factory _$PaywallStateIdleCopyWith(_PaywallStateIdle value, $Res Function(_PaywallStateIdle) _then) = __$PaywallStateIdleCopyWithImpl;
@override @useResult
$Res call({
 int slideIndex, String selectedPlan, bool isLoading, DataError? error, bool isSuccess, bool isPurchaseSuccess, String? errorText, Offerings? offerings, Offering? offering
});




}
/// @nodoc
class __$PaywallStateIdleCopyWithImpl<$Res>
    implements _$PaywallStateIdleCopyWith<$Res> {
  __$PaywallStateIdleCopyWithImpl(this._self, this._then);

  final _PaywallStateIdle _self;
  final $Res Function(_PaywallStateIdle) _then;

/// Create a copy of PaywallState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slideIndex = null,Object? selectedPlan = null,Object? isLoading = null,Object? error = freezed,Object? isSuccess = null,Object? isPurchaseSuccess = null,Object? errorText = freezed,Object? offerings = freezed,Object? offering = freezed,}) {
  return _then(_PaywallStateIdle(
slideIndex: null == slideIndex ? _self.slideIndex : slideIndex // ignore: cast_nullable_to_non_nullable
as int,selectedPlan: null == selectedPlan ? _self.selectedPlan : selectedPlan // ignore: cast_nullable_to_non_nullable
as String,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as DataError?,isSuccess: null == isSuccess ? _self.isSuccess : isSuccess // ignore: cast_nullable_to_non_nullable
as bool,isPurchaseSuccess: null == isPurchaseSuccess ? _self.isPurchaseSuccess : isPurchaseSuccess // ignore: cast_nullable_to_non_nullable
as bool,errorText: freezed == errorText ? _self.errorText : errorText // ignore: cast_nullable_to_non_nullable
as String?,offerings: freezed == offerings ? _self.offerings : offerings // ignore: cast_nullable_to_non_nullable
as Offerings?,offering: freezed == offering ? _self.offering : offering // ignore: cast_nullable_to_non_nullable
as Offering?,
  ));
}


}

// dart format on
