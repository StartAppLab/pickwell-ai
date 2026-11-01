import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/_config.dart';
import '../../../../core/_core.dart';
import '../blocs/_blocs.dart';

class PremiumGuard extends StatelessWidget {
  final Widget child;
  final Widget? lockedChild;
  final String? featureKey;
  final String? entitlementId;
  final String? offeringId;
  final Widget? loadingChild;
  final bool Function(SubscriptionState)? allowWhen;

  const PremiumGuard({
    super.key,
    required this.child,
    this.lockedChild,
    this.featureKey,
    this.entitlementId,
    this.offeringId,
    this.loadingChild,
    this.allowWhen,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      builder: (context, state) {
        final cubit = context.read<SubscriptionCubit>();
        if (cubit.hasAccess(featureKey: featureKey, entitlementId: entitlementId) ||
            allowWhen?.call(state) == true) {
          return child;
        }
        if (cubit.isUnavailable(featureKey: featureKey, entitlementId: entitlementId)) {
          return lockedChild ?? const Center(child: Text('This feature is currently unavailable.'));
        }
        if (!state.isInitialized || state.isLoading) {
          return loadingChild ?? const Center(child: CircularProgressIndicator());
        }
        if (state.errorText != null) {
          return Center(
            child: TextButton(onPressed: cubit.refresh, child: const Text('Retry access check')),
          );
        }
        return lockedChild ??
            _DefaultLockedState(
              entitlementId: cubit.entitlementFor(featureKey, entitlementId: entitlementId),
              offeringId: offeringId ?? cubit.offeringFor(featureKey),
            );
      },
    );
  }
}

class _DefaultLockedState extends StatelessWidget {
  const _DefaultLockedState({this.entitlementId, this.offeringId});
  final String? entitlementId;
  final String? offeringId;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.themeData.edgeInsetsData.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock, size: 40, color: context.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              'Premium feature',
              style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Unlock access with a subscription.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.pushNamed(
                AppRouter.paywallRoute,
                queryParameters: {'entitlement': entitlementId, 'offering': offeringId},
              ),
              child: const Text('View Plans'),
            ),
          ],
        ),
      ),
    );
  }
}
