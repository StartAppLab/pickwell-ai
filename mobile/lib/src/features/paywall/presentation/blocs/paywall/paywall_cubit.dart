import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../../config/_config.dart';
import '../../../../../core/_core.dart';
import '../../../data/_data.dart';
import '../subscription/subscription_cubit.dart';

part 'paywall_state.dart';
part 'paywall_cubit.freezed.dart';

@injectable
class PaywallCubit extends Cubit<PaywallState> {
  PaywallCubit(this._billing, this._config, this._subscription) : super(const PaywallState.idle());
  final BillingClient _billing;
  final AppConfig _config;
  final SubscriptionCubit _subscription;
  String? _entitlementId;

  Future<void> loadOfferings({String? entitlementId, String? offeringId}) async {
    if (state.isLoading) return;
    _entitlementId = entitlementId ?? _config.revenueCatEntitlementId;
    emit(state.copyWith(isLoading: true, errorText: null));
    try {
      await _subscription.init();
      await _subscription.refresh();
      if (_subscription.state.entitlementSnapshot == null) {
        throw StateError('Billing is unavailable');
      }
      final offerings = await _billing.getOfferings();
      if (isClosed) return;
      final offering = offeringId == null ? offerings.current : offerings.all[offeringId];
      final packages = offering?.availablePackages ?? <Package>[];
      emit(
        state.copyWith(
          isLoading: false,
          offerings: offerings,
          offering: offering,
          selectedPlan: packages.isEmpty ? '' : packages.first.identifier,
          errorText: packages.isEmpty ? 'No plans are available. Please try again later.' : null,
        ),
      );
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(isLoading: false, errorText: 'Unable to load plans. Please try again.'),
        );
      }
    }
  }

  Future<BillingResult> purchase() async {
    if (state.isLoading) return const BillingResult(BillingOutcome.pending);
    final packages = state.offering?.availablePackages ?? <Package>[];
    final package = packages.where((p) => p.identifier == state.selectedPlan).firstOrNull;
    if (package == null) {
      return _applyResult(
        const BillingResult(BillingOutcome.failed, message: 'Select an available plan.'),
      );
    }
    emit(state.copyWith(isLoading: true, errorText: null));
    try {
      await _subscription.refresh();
      if (_subscription.state.entitlementSnapshot == null || _subscription.state.isLoading) {
        return _applyResult(
          const BillingResult(
            BillingOutcome.failed,
            message: 'Unable to verify your billing account. Please try again.',
          ),
        );
      }
      final identity = _subscription.identityRevision;
      return _applyResult(await _billing.purchasePackage(package), identityRevision: identity);
    } catch (_) {
      return _applyResult(
        const BillingResult(
          BillingOutcome.failed,
          message: 'Unable to complete purchase. Please try again.',
        ),
      );
    }
  }

  Future<BillingResult> restore() async {
    if (state.isLoading) return const BillingResult(BillingOutcome.pending);
    emit(state.copyWith(isLoading: true, errorText: null));
    try {
      await _subscription.init();
      await _subscription.refresh();
      if (_subscription.state.entitlementSnapshot == null || _subscription.state.isLoading) {
        return _applyResult(
          const BillingResult(
            BillingOutcome.failed,
            message: 'Unable to verify your billing account. Please try again.',
          ),
        );
      }
      final identity = _subscription.identityRevision;
      return _applyResult(await _billing.restorePurchases(), identityRevision: identity);
    } catch (_) {
      return _applyResult(
        const BillingResult(
          BillingOutcome.failed,
          message: 'Unable to restore purchases. Please try again.',
        ),
      );
    }
  }

  BillingResult _applyResult(BillingResult result, {int? identityRevision}) {
    if (identityRevision != null && identityRevision != _subscription.identityRevision) {
      result = const BillingResult(
        BillingOutcome.failed,
        message: 'Your account changed. Restore purchases for the current account.',
      );
    }
    if (result.customerInfo != null && result.outcome == BillingOutcome.success) {
      _subscription.acceptPurchaseInfo(result.customerInfo!);
    }

    if (result.outcome == BillingOutcome.success &&
        !_subscription.hasAccess(
          entitlementId: _entitlementId ?? _config.revenueCatEntitlementId,
        )) {
      result = const BillingResult(
        BillingOutcome.noAccess,
        message:
            'No active access was found for this feature. Contact support if you have already paid.',
      );
    }
    if (!isClosed) {
      emit(
        state.copyWith(
          isLoading: false,
          isPurchaseSuccess: result.outcome == BillingOutcome.success,
          errorText: result.message,
        ),
      );
    }
    return result;
  }

  void setSelectedPlan(String identifier) {
    if (!state.isLoading) emit(state.copyWith(selectedPlan: identifier));
  }

  void setSlideIndex(int index) => emit(state.copyWith(slideIndex: index));
  void setErrorText(String? text) => emit(state.copyWith(errorText: text));
  void reset() => emit(const PaywallState.idle());
}
