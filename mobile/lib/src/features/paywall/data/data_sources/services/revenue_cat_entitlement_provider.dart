import 'dart:async';

import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../../config/app_config.dart';
import '../../../domain/entitlements/entitlement_provider.dart';
import 'revenue_cat_service.dart';

/// Store payloads remain in the data layer, bound to their immutable access snapshot.
class RevenueCatEntitlementSnapshot extends EntitlementSnapshot {
  RevenueCatEntitlementSnapshot({
    required this.customerInfo,
    required super.subjectId,
    required super.checkedAt,
    required super.grants,
  }) : super(source: EntitlementSource.revenueCat);

  final CustomerInfo customerInfo;
}

/// Converts store information into SDK-independent access snapshots.
class RevenueCatEntitlementProvider implements EntitlementProvider {
  RevenueCatEntitlementProvider(this._billing, this._config);

  final BillingClient _billing;
  final AppConfig _config;
  final _updates = StreamController<EntitlementSnapshot>.broadcast(sync: true);
  String? _userId;
  bool _listening = false;
  bool _disposed = false;
  bool _changingIdentity = false;

  @override
  Stream<EntitlementSnapshot> get updates => _updates.stream;

  Future<void> _initialize(String? userId) async {
    if (_disposed) throw StateError('Entitlement provider disposed');
    if (!_billing.isInitialized) {
      await _billing.init(apiKey: _config.revenueCatApiKeyForCurrentPlatform, userId: userId);
    }
    if (!_listening && !_disposed) {
      _billing.addCustomerInfoUpdateListener(_onInfo);
      _listening = true;
    }
  }

  @override
  Future<EntitlementSnapshot> refresh({required String? userId}) async {
    _userId = userId;
    await _initialize(userId);
    return snapshot(await _billing.getCustomerInfo(), userId);
  }

  @override
  Future<EntitlementSnapshot> changeIdentity(String? userId) async {
    _changingIdentity = true;
    try {
      await _initialize(userId);
      final info = userId == null ? await _billing.logout() : await _billing.login(userId);
      final result = snapshot(info, userId);
      _userId = userId;
      return result;
    } finally {
      _changingIdentity = false;
    }
  }

  EntitlementSnapshot acceptPurchase(CustomerInfo info, String? userId) => snapshot(info, userId);

  void _onInfo(CustomerInfo info) {
    if (_disposed || _changingIdentity) return;
    try {
      _updates.add(snapshot(info, _userId));
    } on EntitlementVerificationException catch (error, stack) {
      _updates.addError(error, stack);
    }
  }

  static EntitlementSnapshot snapshot(CustomerInfo info, String? userId) {
    if (info.entitlements.verification == VerificationResult.failed ||
        info.entitlements.all.values.any(
          (grant) => grant.verification == VerificationResult.failed,
        )) {
      throw const EntitlementVerificationException();
    }
    final nonSubscriptionProducts = info.nonSubscriptionTransactions
        .map((transaction) => transaction.productIdentifier)
        .toSet();
    return RevenueCatEntitlementSnapshot(
      customerInfo: info,
      subjectId: userId,
      checkedAt: DateTime.now(),
      grants: {
        for (final entry in info.entitlements.all.entries)
          entry.key: EntitlementGrant(
            id: entry.key,
            isActive: entry.value.isActive,
            // Missing/malformed subscription expiry must not imply lifetime access.
            isNonExpiring:
                entry.value.expirationDate == null &&
                !entry.value.willRenew &&
                (nonSubscriptionProducts.contains(entry.value.productIdentifier) ||
                    entry.value.store == Store.promotional),
            expiresAt: DateTime.tryParse(entry.value.expirationDate ?? ''),
            isTrial: entry.value.periodType == PeriodType.trial,
          ),
      },
    );
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    if (_listening) _billing.removeCustomerInfoUpdateListener(_onInfo);
    await _updates.close();
  }
}
