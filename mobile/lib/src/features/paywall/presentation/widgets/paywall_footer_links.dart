import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/_config.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../../data/data_sources/services/revenue_cat_service.dart';
import '../blocs/_blocs.dart';

class PaywallFooterLinks extends StatelessWidget {
  const PaywallFooterLinks({
    super.key,
    this.showRestore = true,
    this.onRestore,
    this.isBusy = false,
  });
  final bool showRestore;
  final bool isBusy;
  final Future<void> Function()? onRestore;

  @override
  Widget build(BuildContext context) {
    final config = getIt<AppConfig>();
    final isLoading = context.select<PaywallCubit, bool>((cubit) => cubit.state.isLoading);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (config.termsUrl.isNotEmpty)
          TextButton(
            onPressed: () => _open(context, config.termsUrl),
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
            child: Text(
              'Terms',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (config.privacyUrl.isNotEmpty)
          TextButton(
            onPressed: () => _open(context, config.privacyUrl),
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
            child: Text(
              'Privacy',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (showRestore && config.features.billingEnabled)
          TextButton(
            onPressed: isLoading || isBusy
                ? null
                : () async {
                    if (onRestore != null) {
                      await onRestore!();
                      return;
                    }
                    final result = await context.read<PaywallCubit>().restore();
                    if (result.outcome == BillingOutcome.success) {
                      await getIt<SubscriptionCubit>().refresh();
                    }
                    if (context.mounted && result.message != null) {
                      AppWidgets.showInfoSnackBar(context, result.message!);
                    }
                  },
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
            child: Text(
              'Restore',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _open(BuildContext context, String value) async {
    if (!await launchUrl(Uri.parse(value), mode: LaunchMode.externalApplication) &&
        context.mounted) {
      AppWidgets.showErrorSnackBar(context, 'Unable to open link.');
    }
  }
}
