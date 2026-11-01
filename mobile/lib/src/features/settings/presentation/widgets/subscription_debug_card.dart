import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/_config.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../../../paywall/paywall.dart';

class SubscriptionDebugCard extends StatefulWidget {
  const SubscriptionDebugCard({super.key});

  @override
  State<SubscriptionDebugCard> createState() => _SubscriptionDebugCardState();
}

class _SubscriptionDebugCardState extends State<SubscriptionDebugCard> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action, String success) async {
    if (!kDebugMode || _busy) return;
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) AppWidgets.showInfoSnackBar(context, success);
    } catch (error, stack) {
      AppLogger.logError(error, stackTrace: stack);
      if (mounted) {
        AppWidgets.showErrorSnackBar(context, 'Operation failed. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _refresh() {
    final subscription = context.read<SubscriptionCubit>();
    return _run(() async {
      await subscription.init();
      await getIt<BillingClient>().invalidateCustomerInfoCache();
      await subscription.refresh();
      if (subscription.isClosed ||
          subscription.state.isLoading ||
          subscription.state.errorText != null ||
          subscription.state.entitlementSnapshot == null) {
        throw StateError('Unable to refresh subscription access');
      }
    }, 'Access refreshed');
  }

  Future<void> _resetCounters() => _run(
    () => getIt<PaywallGateService>().resetAllSoftPaywallTriggers(),
    'Paywall counters reset. Subscription access is unchanged.',
  );

  Future<void> _openTestingGuide() => _run(() async {
    final url = switch (defaultTargetPlatform) {
      TargetPlatform.iOS =>
        'https://developer.apple.com/documentation/storekit/testing-in-app-purchases-with-sandbox',
      TargetPlatform.android => 'https://developer.android.com/google/play/billing/test',
      _ => 'https://www.revenuecat.com/docs/test-and-launch/sandbox',
    };
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw StateError('Unable to open testing guide');
    }
  }, 'Testing guide opened');

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    final spacing = context.themeData.dimensionsData;
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      builder: (context, state) {
        final disabled = _busy || state.isLoading;
        final access = context.read<SubscriptionCubit>().hasAccess();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _panel(context, [
              if (disabled) ...[const LinearProgressIndicator(), Gap(spacing.mediumSpacing)],
              Text(
                state.isLoading
                    ? 'Checking access…'
                    : state.errorText != null || state.entitlementSnapshot == null
                    ? 'Access needs verification'
                    : access
                    ? 'Premium access active'
                    : 'No premium access',
                style: context.textTheme.titleLarge,
              ),
              Gap(spacing.mediumSpacing),
              _detail(context, 'Entitlement', getIt<AppConfig>().revenueCatEntitlementId),
              _detail(context, 'Trial', state.isTrialActive ? 'Active' : 'Inactive'),
              _detail(
                context,
                'Active entitlements',
                state.activeEntitlementIds.isEmpty ? 'None' : state.activeEntitlementIds.join(', '),
              ),
              _detail(
                context,
                'Last checked',
                state.lastRefreshedAt == null
                    ? 'Never'
                    : DateFormat(
                        'MMM d, yyyy • HH:mm',
                        'en',
                      ).format(state.lastRefreshedAt!.toLocal()),
              ),
              if (state.errorText != null)
                Text(
                  state.errorText!,
                  style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.error),
                ),
              Gap(spacing.smallSpacing),
              ElevatedButton(
                onPressed: disabled ? null : _refresh,
                child: const Text('Refresh access'),
              ),
            ]),
            Gap(spacing.mediumSpacing),
            _panel(context, [
              Text('Paywall counters', style: context.textTheme.titleMedium),
              Gap(spacing.smallSpacing),
              Text(
                'Reset how often soft paywalls appear. This does not remove purchases '
                'or change premium access.',
                style: context.textTheme.bodyMedium,
              ),
              Gap(spacing.mediumSpacing),
              OutlinedButton(
                onPressed: disabled ? null : _resetCounters,
                child: const Text('Reset paywall counters'),
              ),
            ]),
            Gap(spacing.mediumSpacing),
            _panel(context, [
              Text('Reset test purchases', style: context.textTheme.titleMedium),
              Gap(spacing.smallSpacing),
              Text(
                'Reset purchases in your test environment, then refresh access here. '
                'App resets do not erase store purchases.',
                style: context.textTheme.bodyMedium,
              ),
              Gap(spacing.smallSpacing),
              Text(
                defaultTargetPlatform == TargetPlatform.iOS
                    ? 'Apple Sandbox: clear the tester’s purchase history. For local StoreKit tests, reset transactions in Xcode.'
                    : 'Use your store’s test-purchase controls. For Google Play, manage the test order in Play Console.',
                style: context.textTheme.bodyMedium,
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: disabled ? null : _openTestingGuide,
                  child: const Text('Open testing guide'),
                ),
              ),
            ]),
          ],
        );
      },
    );
  }

  Widget _panel(BuildContext context, List<Widget> children) => Container(
    padding: context.themeData.edgeInsetsData.containerPadding,
    decoration: BoxDecoration(
      color: context.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(context.themeData.dimensionsData.cornerRadius),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
  );

  Widget _detail(BuildContext context, String label, String value) => Padding(
    padding: EdgeInsets.only(bottom: context.themeData.dimensionsData.smallSpacing),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textTheme.labelMedium),
        SelectableText(value, style: context.textTheme.bodyMedium),
      ],
    ),
  );
}
