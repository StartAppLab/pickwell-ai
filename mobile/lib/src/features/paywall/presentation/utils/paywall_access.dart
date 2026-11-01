import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/_config.dart';
import '../../../app/app.dart';
import '../blocs/_blocs.dart';
import '../services/paywall_gate_service.dart';

class PaywallAccess {
  const PaywallAccess._();

  static bool isPremium(BuildContext context) => context.read<SubscriptionCubit>().state.isPremium;

  /// Refreshes access before deciding, then rechecks when the paywall closes.
  /// Named features can map to different entitlements, or null for free access.
  static Future<bool> requirePremium(
    BuildContext context, {
    String? featureKey,
    String? entitlementId,
    String? offeringId,
    bool Function(SubscriptionState)? allowWhen,
  }) async {
    final cubit = context.read<SubscriptionCubit>();
    await cubit.init();
    await cubit.refresh();
    if (!context.mounted) return false;
    if (cubit.hasAccess(featureKey: featureKey, entitlementId: entitlementId) ||
        allowWhen?.call(cubit.state) == true) {
      return true;
    }
    if (cubit.isUnavailable(featureKey: featureKey, entitlementId: entitlementId)) {
      AppWidgets.showErrorSnackBar(context, 'This feature is currently unavailable.');
      return false;
    }
    if (cubit.state.entitlementSnapshot == null ||
        cubit.state.errorText != null ||
        cubit.state.isLoading) {
      AppWidgets.showErrorSnackBar(
        context,
        cubit.state.errorText ?? 'Access is still loading. Please try again.',
      );
      return false;
    }
    await context.pushNamed(
      AppRouter.paywallRoute,
      queryParameters: {
        'entitlement': cubit.entitlementFor(featureKey, entitlementId: entitlementId),
        'offering': offeringId ?? cubit.offeringFor(featureKey),
      },
    );
    if (!context.mounted) return false;
    await cubit.refresh();
    return context.mounted &&
        (cubit.hasAccess(featureKey: featureKey, entitlementId: entitlementId) ||
            allowWhen?.call(cubit.state) == true);
  }

  static Future<bool> run(
    BuildContext context, {
    required Future<void> Function() action,
    String? featureKey,
    String? entitlementId,
    String? offeringId,
    bool Function(SubscriptionState)? allowWhen,
  }) async {
    if (!await requirePremium(
      context,
      featureKey: featureKey,
      entitlementId: entitlementId,
      offeringId: offeringId,
      allowWhen: allowWhen,
    )) {
      return false;
    }
    if (!context.mounted) return false;
    await action();
    return true;
  }

  /// A nudge only: the return value indicates whether a paywall was shown.
  static Future<bool> maybeShowSoftPaywall(
    BuildContext context, {
    required String featureKey,
    int showEvery = 3,
  }) async {
    final cubit = context.read<SubscriptionCubit>();
    await cubit.init();
    await cubit.refresh();
    if (cubit.isUnavailable(featureKey: featureKey) ||
        cubit.state.entitlementSnapshot == null ||
        cubit.state.errorText != null ||
        cubit.state.isLoading ||
        cubit.hasAccess(featureKey: featureKey)) {
      return false;
    }
    final shouldShow = await getIt<PaywallGateService>().shouldShowSoftPaywall(
      featureKey: featureKey,
      showEvery: showEvery,
    );
    if (!shouldShow || !context.mounted) return false;
    await context.pushNamed(
      AppRouter.paywallRoute,
      queryParameters: {
        'entitlement': cubit.entitlementFor(featureKey),
        'offering': cubit.offeringFor(featureKey),
      },
    );
    return true;
  }
}
