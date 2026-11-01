// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SubscriptionState {

 bool get isInitialized; bool get isLoading; bool get isPremium; bool get isTrialActive; CustomerInfo? get customerInfo; EntitlementSnapshot? get entitlementSnapshot; Set<String> get activeEntitlementIds; DateTime? get lastRefreshedAt; String? get errorText;
/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionStateCopyWith<SubscriptionState> get copyWith => _$SubscriptionStateCopyWithImpl<SubscriptionState>(this as SubscriptionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionState&&(identical(other.isInitialized, isInitialized) || other.isInitialized == isInitialized)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.isTrialActive, isTrialActive) || other.isTrialActive == isTrialActive)&&(identical(other.customerInfo, customerInfo) || other.customerInfo == customerInfo)&&(identical(other.entitlementSnapshot, entitlementSnapshot) || other.entitlementSnapshot == entitlementSnapshot)&&const DeepCollectionEquality().equals(other.activeEntitlementIds, activeEntitlementIds)&&(identical(other.lastRefreshedAt, lastRefreshedAt) || other.lastRefreshedAt == lastRefreshedAt)&&(identical(other.errorText, errorText) || other.errorText == errorText));
}


@override
int get hashCode => Object.hash(runtimeType,isInitialized,isLoading,isPremium,isTrialActive,customerInfo,entitlementSnapshot,const DeepCollectionEquality().hash(activeEntitlementIds),lastRefreshedAt,errorText);

@override
String toString() {
  return 'SubscriptionState(isInitialized: $isInitialized, isLoading: $isLoading, isPremium: $isPremium, isTrialActive: $isTrialActive, customerInfo: $customerInfo, entitlementSnapshot: $entitlementSnapshot, activeEntitlementIds: $activeEntitlementIds, lastRefreshedAt: $lastRefreshedAt, errorText: $errorText)';
}


}

/// @nodoc
abstract mixin class $SubscriptionStateCopyWith<$Res>  {
  factory $SubscriptionStateCopyWith(SubscriptionState value, $Res Function(SubscriptionState) _then) = _$SubscriptionStateCopyWithImpl;
@useResult
$Res call({
 bool isInitialized, bool isLoading, bool isPremium, bool isTrialActive, CustomerInfo? customerInfo, EntitlementSnapshot? entitlementSnapshot, Set<String> activeEntitlementIds, DateTime? lastRefreshedAt, String? errorText
});




}
/// @nodoc
class _$SubscriptionStateCopyWithImpl<$Res>
    implements $SubscriptionStateCopyWith<$Res> {
  _$SubscriptionStateCopyWithImpl(this._self, this._then);

  final SubscriptionState _self;
  final $Res Function(SubscriptionState) _then;

/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isInitialized = null,Object? isLoading = null,Object? isPremium = null,Object? isTrialActive = null,Object? customerInfo = freezed,Object? entitlementSnapshot = freezed,Object? activeEntitlementIds = null,Object? lastRefreshedAt = freezed,Object? errorText = freezed,}) {
  return _then(_self.copyWith(
isInitialized: null == isInitialized ? _self.isInitialized : isInitialized // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,isTrialActive: null == isTrialActive ? _self.isTrialActive : isTrialActive // ignore: cast_nullable_to_non_nullable
as bool,customerInfo: freezed == customerInfo ? _self.customerInfo : customerInfo // ignore: cast_nullable_to_non_nullable
as CustomerInfo?,entitlementSnapshot: freezed == entitlementSnapshot ? _self.entitlementSnapshot : entitlementSnapshot // ignore: cast_nullable_to_non_nullable
as EntitlementSnapshot?,activeEntitlementIds: null == activeEntitlementIds ? _self.activeEntitlementIds : activeEntitlementIds // ignore: cast_nullable_to_non_nullable
as Set<String>,lastRefreshedAt: freezed == lastRefreshedAt ? _self.lastRefreshedAt : lastRefreshedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,errorText: freezed == errorText ? _self.errorText : errorText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionState].
extension SubscriptionStatePatterns on SubscriptionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _SubscriptionStateIdle value)?  idle,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionStateIdle() when idle != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _SubscriptionStateIdle value)  idle,}){
final _that = this;
switch (_that) {
case _SubscriptionStateIdle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _SubscriptionStateIdle value)?  idle,}){
final _that = this;
switch (_that) {
case _SubscriptionStateIdle() when idle != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( bool isInitialized,  bool isLoading,  bool isPremium,  bool isTrialActive,  CustomerInfo? customerInfo,  EntitlementSnapshot? entitlementSnapshot,  Set<String> activeEntitlementIds,  DateTime? lastRefreshedAt,  String? errorText)?  idle,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionStateIdle() when idle != null:
return idle(_that.isInitialized,_that.isLoading,_that.isPremium,_that.isTrialActive,_that.customerInfo,_that.entitlementSnapshot,_that.activeEntitlementIds,_that.lastRefreshedAt,_that.errorText);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( bool isInitialized,  bool isLoading,  bool isPremium,  bool isTrialActive,  CustomerInfo? customerInfo,  EntitlementSnapshot? entitlementSnapshot,  Set<String> activeEntitlementIds,  DateTime? lastRefreshedAt,  String? errorText)  idle,}) {final _that = this;
switch (_that) {
case _SubscriptionStateIdle():
return idle(_that.isInitialized,_that.isLoading,_that.isPremium,_that.isTrialActive,_that.customerInfo,_that.entitlementSnapshot,_that.activeEntitlementIds,_that.lastRefreshedAt,_that.errorText);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( bool isInitialized,  bool isLoading,  bool isPremium,  bool isTrialActive,  CustomerInfo? customerInfo,  EntitlementSnapshot? entitlementSnapshot,  Set<String> activeEntitlementIds,  DateTime? lastRefreshedAt,  String? errorText)?  idle,}) {final _that = this;
switch (_that) {
case _SubscriptionStateIdle() when idle != null:
return idle(_that.isInitialized,_that.isLoading,_that.isPremium,_that.isTrialActive,_that.customerInfo,_that.entitlementSnapshot,_that.activeEntitlementIds,_that.lastRefreshedAt,_that.errorText);case _:
  return null;

}
}

}

/// @nodoc


class _SubscriptionStateIdle implements SubscriptionState {
  const _SubscriptionStateIdle({this.isInitialized = false, this.isLoading = false, this.isPremium = false, this.isTrialActive = false, this.customerInfo, this.entitlementSnapshot, final  Set<String> activeEntitlementIds = const <String>{}, this.lastRefreshedAt, this.errorText}): _activeEntitlementIds = activeEntitlementIds;
  

@override@JsonKey() final  bool isInitialized;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isPremium;
@override@JsonKey() final  bool isTrialActive;
@override final  CustomerInfo? customerInfo;
@override final  EntitlementSnapshot? entitlementSnapshot;
 final  Set<String> _activeEntitlementIds;
@override@JsonKey() Set<String> get activeEntitlementIds {
  if (_activeEntitlementIds is EqualUnmodifiableSetView) return _activeEntitlementIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_activeEntitlementIds);
}

@override final  DateTime? lastRefreshedAt;
@override final  String? errorText;

/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionStateIdleCopyWith<_SubscriptionStateIdle> get copyWith => __$SubscriptionStateIdleCopyWithImpl<_SubscriptionStateIdle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionStateIdle&&(identical(other.isInitialized, isInitialized) || other.isInitialized == isInitialized)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.isTrialActive, isTrialActive) || other.isTrialActive == isTrialActive)&&(identical(other.customerInfo, customerInfo) || other.customerInfo == customerInfo)&&(identical(other.entitlementSnapshot, entitlementSnapshot) || other.entitlementSnapshot == entitlementSnapshot)&&const DeepCollectionEquality().equals(other._activeEntitlementIds, _activeEntitlementIds)&&(identical(other.lastRefreshedAt, lastRefreshedAt) || other.lastRefreshedAt == lastRefreshedAt)&&(identical(other.errorText, errorText) || other.errorText == errorText));
}


@override
int get hashCode => Object.hash(runtimeType,isInitialized,isLoading,isPremium,isTrialActive,customerInfo,entitlementSnapshot,const DeepCollectionEquality().hash(_activeEntitlementIds),lastRefreshedAt,errorText);

@override
String toString() {
  return 'SubscriptionState.idle(isInitialized: $isInitialized, isLoading: $isLoading, isPremium: $isPremium, isTrialActive: $isTrialActive, customerInfo: $customerInfo, entitlementSnapshot: $entitlementSnapshot, activeEntitlementIds: $activeEntitlementIds, lastRefreshedAt: $lastRefreshedAt, errorText: $errorText)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionStateIdleCopyWith<$Res> implements $SubscriptionStateCopyWith<$Res> {
  factory _$SubscriptionStateIdleCopyWith(_SubscriptionStateIdle value, $Res Function(_SubscriptionStateIdle) _then) = __$SubscriptionStateIdleCopyWithImpl;
@override @useResult
$Res call({
 bool isInitialized, bool isLoading, bool isPremium, bool isTrialActive, CustomerInfo? customerInfo, EntitlementSnapshot? entitlementSnapshot, Set<String> activeEntitlementIds, DateTime? lastRefreshedAt, String? errorText
});




}
/// @nodoc
class __$SubscriptionStateIdleCopyWithImpl<$Res>
    implements _$SubscriptionStateIdleCopyWith<$Res> {
  __$SubscriptionStateIdleCopyWithImpl(this._self, this._then);

  final _SubscriptionStateIdle _self;
  final $Res Function(_SubscriptionStateIdle) _then;

/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isInitialized = null,Object? isLoading = null,Object? isPremium = null,Object? isTrialActive = null,Object? customerInfo = freezed,Object? entitlementSnapshot = freezed,Object? activeEntitlementIds = null,Object? lastRefreshedAt = freezed,Object? errorText = freezed,}) {
  return _then(_SubscriptionStateIdle(
isInitialized: null == isInitialized ? _self.isInitialized : isInitialized // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,isTrialActive: null == isTrialActive ? _self.isTrialActive : isTrialActive // ignore: cast_nullable_to_non_nullable
as bool,customerInfo: freezed == customerInfo ? _self.customerInfo : customerInfo // ignore: cast_nullable_to_non_nullable
as CustomerInfo?,entitlementSnapshot: freezed == entitlementSnapshot ? _self.entitlementSnapshot : entitlementSnapshot // ignore: cast_nullable_to_non_nullable
as EntitlementSnapshot?,activeEntitlementIds: null == activeEntitlementIds ? _self._activeEntitlementIds : activeEntitlementIds // ignore: cast_nullable_to_non_nullable
as Set<String>,lastRefreshedAt: freezed == lastRefreshedAt ? _self.lastRefreshedAt : lastRefreshedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,errorText: freezed == errorText ? _self.errorText : errorText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
