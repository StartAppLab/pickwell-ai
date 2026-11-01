import 'dart:io';

import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

enum BillingOutcome { success, cancelled, pending, noAccess, failed }

class BillingResult {
  const BillingResult(this.outcome, {this.customerInfo, this.message});
  final BillingOutcome outcome;
  final CustomerInfo? customerInfo;
  final String? message;
}

/// An injectable boundary so billing behavior can be tested without a store.
abstract class BillingClient {
  bool get isInitialized;
  Future<void> init({required String apiKey, String? userId});
  Future<CustomerInfo> login(String userId);
  Future<CustomerInfo> logout();
  Future<Offerings> getOfferings();
  Future<BillingResult> purchasePackage(Package package);
  Future<BillingResult> restorePurchases();
  Future<CustomerInfo> getCustomerInfo();
  Future<void> invalidateCustomerInfoCache();
  void addCustomerInfoUpdateListener(void Function(CustomerInfo) listener);
  void removeCustomerInfoUpdateListener(void Function(CustomerInfo) listener);
}

class RevenueCatService implements BillingClient {
  RevenueCatService._();
  static final RevenueCatService instance = RevenueCatService._();
  bool _isInitialized = false;
  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> init({required String apiKey, String? userId}) async {
    if (_isInitialized) return;
    if (!(Platform.isIOS || Platform.isAndroid)) {
      throw UnsupportedError('RevenueCat billing requires iOS or Android.');
    }
    if (apiKey.trim().isEmpty || apiKey.contains('{{')) {
      throw ArgumentError('Set the RevenueCat public SDK key for this platform.');
    }
    await Purchases.setLogLevel(LogLevel.warn);
    await Purchases.configure(PurchasesConfiguration(apiKey)..appUserID = userId);
    _isInitialized = true;
  }

  @override
  Future<CustomerInfo> login(String userId) async => (await Purchases.logIn(userId)).customerInfo;

  @override
  Future<CustomerInfo> logout() async =>
      await Purchases.isAnonymous ? Purchases.getCustomerInfo() : Purchases.logOut();

  @override
  Future<Offerings> getOfferings() => Purchases.getOfferings();

  @override
  Future<BillingResult> purchasePackage(Package package) async {
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      return BillingResult(BillingOutcome.success, customerInfo: result.customerInfo);
    } on PlatformException catch (error) {
      final code = PurchasesErrorHelper.getErrorCode(error);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        return const BillingResult(BillingOutcome.cancelled);
      }
      if (code == PurchasesErrorCode.paymentPendingError) {
        return const BillingResult(
          BillingOutcome.pending,
          message: 'Your purchase is pending approval. Access will update when it completes.',
        );
      }
      return const BillingResult(
        BillingOutcome.failed,
        message: 'Unable to complete purchase. Please try again.',
      );
    } catch (_) {
      return const BillingResult(
        BillingOutcome.failed,
        message: 'Unable to complete purchase. Please try again.',
      );
    }
  }

  @override
  Future<BillingResult> restorePurchases() async {
    try {
      return BillingResult(
        BillingOutcome.success,
        customerInfo: await Purchases.restorePurchases(),
      );
    } catch (_) {
      return const BillingResult(
        BillingOutcome.failed,
        message: 'Unable to restore purchases. Please try again.',
      );
    }
  }

  @override
  Future<CustomerInfo> getCustomerInfo() => Purchases.getCustomerInfo();

  @override
  Future<void> invalidateCustomerInfoCache() => Purchases.invalidateCustomerInfoCache();

  @override
  void addCustomerInfoUpdateListener(void Function(CustomerInfo) listener) =>
      Purchases.addCustomerInfoUpdateListener(listener);

  @override
  void removeCustomerInfoUpdateListener(void Function(CustomerInfo) listener) =>
      Purchases.removeCustomerInfoUpdateListener(listener);
}
