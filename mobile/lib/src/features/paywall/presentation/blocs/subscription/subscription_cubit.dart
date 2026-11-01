import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../../config/_config.dart';
import '../../../../../core/_core.dart';
import '../../../../notification/notification.dart';
import '../../../data/_data.dart';
import '../../../domain/entitlements/entitlement_provider.dart';

part 'subscription_cubit.freezed.dart';
part 'subscription_state.dart';

@lazySingleton
class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit(AppConfig config, BillingClient billing)
    : this.withProvider(config, RevenueCatEntitlementProvider(billing, config));

  SubscriptionCubit.withProvider(this._config, this._provider, {DateTime Function()? now})
    : _now = now ?? DateTime.now,
      super(const SubscriptionState.idle());

  final AppConfig _config;
  final EntitlementProvider _provider;
  final DateTime Function() _now;
  StreamSubscription<EntitlementSnapshot>? _updates;
  Timer? _expirationTimer;
  Future<void>? _initialization;
  int _revision = 0;
  int _identityRevision = 0;

  /// Binds asynchronous purchase/restore results to the identity that requested them.
  int get identityRevision => _identityRevision;
  bool _changingIdentity = false;
  int _pendingIdentityChanges = 0;
  String? _userId;
  String? _desiredUserId;
  bool _identityFailed = false;
  Future<void> _identityQueue = Future.value();
  Future<void> _reminderQueue = Future.value();

  String? offeringFor(String? featureKey) => _config.features.featureOfferings[featureKey];

  Set<String> get _configuredEntitlementIds => {
    _config.revenueCatEntitlementId,
    ..._config.features.featureEntitlements.values.whereType<String>(),
  };

  String? entitlementFor(String? featureKey, {String? entitlementId}) {
    if (entitlementId != null) return entitlementId;
    if (featureKey != null && _config.features.featureEntitlements.containsKey(featureKey)) {
      return _config.features.featureEntitlements[featureKey];
    }
    return _config.revenueCatEntitlementId;
  }

  bool isUnavailable({String? featureKey, String? entitlementId}) =>
      (entitlementId != null && entitlementId.trim().isEmpty) ||
      (entitlementId == null &&
          featureKey != null &&
          !_config.features.featureEntitlements.containsKey(featureKey)) ||
      (!_config.features.billingEnabled &&
          entitlementFor(featureKey, entitlementId: entitlementId) != null);

  bool hasAccess({String? featureKey, String? entitlementId}) {
    if (isUnavailable(featureKey: featureKey, entitlementId: entitlementId)) return false;
    final entitlement = entitlementFor(featureKey, entitlementId: entitlementId);
    if (entitlement == null) return true;
    if (_identityFailed || _changingIdentity || _pendingIdentityChanges > 0) return false;
    final snapshot = state.entitlementSnapshot;
    if (snapshot == null || snapshot.subjectId != _desiredUserId) return false;
    return snapshot.grants[entitlement]?.allowsAt(_now()) == true;
  }

  Future<void> init({String? userId}) => _initialization ??= _initialize(userId);

  Future<void> _initialize(String? userId) async {
    _userId = userId;
    _desiredUserId = userId;
    if (!_config.features.billingEnabled) {
      emit(state.copyWith(isInitialized: true));
      return;
    }
    await refresh();
    if (isClosed) return;
    emit(state.copyWith(isInitialized: true));
  }

  Future<void> refresh() async {
    if (isClosed || !_config.features.billingEnabled) return;
    if (_changingIdentity || _pendingIdentityChanges > 0) {
      await _identityQueue;
      return;
    }
    if (_identityFailed) {
      await _queueIdentity(_desiredUserId);
      return;
    }
    final revision = ++_revision;
    emit(state.copyWith(isLoading: true, errorText: null));
    try {
      _attachListener();
      final info = await _provider.refresh(userId: _desiredUserId);
      if (isClosed || revision != _revision) return;
      if (info.subjectId != _desiredUserId) throw const EntitlementVerificationException();
      _emitInfo(info);
    } catch (error, stackTrace) {
      AppLogger.logError(error, stackTrace: stackTrace);
      if (isClosed || revision != _revision) return;
      _handleProviderError(error);
    }
  }

  /// Called only for an actual identity change; startup guests keep their RC ID.
  Future<void> onSignedIn(String userId) => _queueIdentity(userId);
  Future<void> onSignedOut() => _queueIdentity(null);

  Future<void> _queueIdentity(String? userId) {
    if (isClosed ||
        !_config.features.billingEnabled ||
        (_userId == userId && !_identityFailed && _pendingIdentityChanges == 0)) {
      return Future.value();
    }
    ++_identityRevision;
    ++_pendingIdentityChanges;
    _expirationTimer?.cancel();
    emit(const SubscriptionState.idle(isInitialized: true, isLoading: true));
    final result = _identityQueue.then((_) async {
      try {
        if (isClosed) return;
        _desiredUserId = userId;
        await _changeIdentity(userId);
      } finally {
        --_pendingIdentityChanges;
        if (!isClosed && _pendingIdentityChanges == 0) {
          emit(state.copyWith(isLoading: false));
        }
      }
    });
    _identityQueue = result.then<void>((_) {}, onError: (Object error, StackTrace stack) {});
    return result;
  }

  void _attachListener() {
    _updates ??= _provider.updates.listen(
      _onSnapshot,
      onError: (Object error, StackTrace stack) {
        AppLogger.logError(error, stackTrace: stack);
        if (!isClosed && _pendingIdentityChanges == 0 && !_identityFailed) {
          ++_revision;
          _handleProviderError(error);
        }
      },
    );
  }

  void _handleProviderError(Object error) {
    if (error is EntitlementVerificationException) {
      _expirationTimer?.cancel();
      emit(
        const SubscriptionState.idle(
          isInitialized: true,
          errorText: 'Unable to verify access. Please try again.',
        ),
      );
      if (_config.features.notificationsEnabled) _queueReminder(null);
    } else {
      // Same-identity transport failures retain access only within known validity.
      emit(
        state.copyWith(isLoading: false, errorText: 'Unable to refresh access. Please try again.'),
      );
    }
  }

  Future<void> _changeIdentity(String? userId) async {
    ++_revision;
    _changingIdentity = true;
    emit(const SubscriptionState.idle(isInitialized: true, isLoading: true));
    // Clear the previous account's reminder even if the identity switch fails.
    if (_config.features.notificationsEnabled) _queueReminder(null);
    try {
      _expirationTimer?.cancel();
      final info = await _provider.changeIdentity(userId);
      if (isClosed) return;
      if (info.subjectId != userId) throw const EntitlementVerificationException();
      _userId = userId;
      _identityFailed = false;
      _emitInfo(info);
    } catch (error, stackTrace) {
      AppLogger.logError(error, stackTrace: stackTrace);
      _identityFailed = true;
      if (!isClosed) {
        emit(
          state.copyWith(
            isLoading: false,
            errorText: 'Unable to switch billing account. Please try again.',
          ),
        );
      }
    } finally {
      _changingIdentity = false;
    }
  }

  void _onSnapshot(EntitlementSnapshot snapshot) {
    if (_changingIdentity ||
        _pendingIdentityChanges > 0 ||
        _identityFailed ||
        isClosed ||
        snapshot.subjectId != _desiredUserId) {
      return;
    }
    ++_revision;
    _emitInfo(snapshot);
  }

  void acceptPurchaseInfo(CustomerInfo info) {
    if (!_config.features.billingEnabled ||
        _changingIdentity ||
        _pendingIdentityChanges > 0 ||
        _identityFailed ||
        isClosed) {
      return;
    }
    final provider = _provider;
    if (provider is RevenueCatEntitlementProvider) {
      ++_revision;
      try {
        _emitInfo(provider.acceptPurchase(info, _desiredUserId));
      } on EntitlementVerificationException catch (error) {
        _handleProviderError(error);
      }
    } else {
      // A purchase result cannot grant access through a server provider.
      unawaited(refresh());
    }
  }

  void _emitInfo(EntitlementSnapshot snapshot, {bool clearError = true}) {
    if (isClosed || snapshot.subjectId != _desiredUserId) return;
    final allActive = snapshot.grants.values.where((grant) => grant.allowsAt(_now())).toList();
    final configured = _configuredEntitlementIds;
    final active = allActive.where((grant) => configured.contains(grant.id)).toList();
    final trial = active.where((grant) => grant.isTrial).firstOrNull;
    emit(
      state.copyWith(
        isLoading: _pendingIdentityChanges > 0,
        isPremium: active.isNotEmpty,
        isTrialActive: trial != null,
        customerInfo: snapshot is RevenueCatEntitlementSnapshot ? snapshot.customerInfo : null,
        entitlementSnapshot: snapshot,
        activeEntitlementIds: allActive.map((grant) => grant.id).toSet(),
        lastRefreshedAt: snapshot.checkedAt,
        errorText: clearError ? null : state.errorText,
      ),
    );
    _expirationTimer?.cancel();
    // Explicit entitlement overrides also need a UI rebuild at expiration.
    final expirations = allActive.map((grant) => grant.expiresAt).whereType<DateTime>().toList()
      ..sort();
    if (expirations.isNotEmpty) {
      _expirationTimer = Timer(expirations.first.difference(_now()), () {
        if (!isClosed &&
            !_changingIdentity &&
            !_identityFailed &&
            identical(state.entitlementSnapshot, snapshot)) {
          _emitInfo(snapshot, clearError: false);
        }
      });
    }
    if (_config.features.notificationsEnabled) _queueReminder(trial);
  }

  void _queueReminder(EntitlementGrant? entitlement) {
    _reminderQueue = _reminderQueue.then((_) => _syncReminder(entitlement)).catchError((
      Object error,
      StackTrace stack,
    ) {
      AppLogger.logError(error, stackTrace: stack);
    });
  }

  Future<void> _syncReminder(EntitlementGrant? entitlement) async {
    final end = entitlement?.expiresAt;
    if (entitlement?.isTrial != true || end == null) {
      await NotificationManager.cancelTrialEndingReminder();
      return;
    }
    final reminder = end.subtract(const Duration(days: 1));
    if (reminder.isAfter(DateTime.now())) {
      await NotificationManager.scheduleTrialEndingReminder(reminderAt: reminder);
    } else {
      await NotificationManager.cancelTrialEndingReminder();
    }
  }

  @override
  Future<void> close() async {
    ++_revision;
    _expirationTimer?.cancel();
    final closing = super.close();
    await _updates?.cancel();
    await _provider.dispose();
    return closing;
  }
}
