import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/_config.dart';
import '../../../../core/_core.dart';
import '../../../../resources/assets.gen.dart';
import '../../../app/app.dart';
import '../../../paywall/paywall.dart';
import '../widgets/_widgets.dart';

class AuthOptionsView extends StatefulWidget {
  const AuthOptionsView({super.key});

  @override
  State<AuthOptionsView> createState() => _AuthOptionsViewState();
}

class _AuthOptionsViewState extends State<AuthOptionsView> {
  bool _restoring = false;

  Future<void> _restorePurchases() async {
    if (_restoring) return;
    final subscription = getIt<SubscriptionCubit>();
    final identity = subscription.identityRevision;
    setState(() => _restoring = true);
    try {
      final result = await context.read<PaywallCubit>().restore();
      if (!mounted || result.outcome == BillingOutcome.cancelled) return;
      if (result.outcome != BillingOutcome.success) {
        if (result.message != null) AppWidgets.showInfoSnackBar(context, result.message!);
        return;
      }
      await subscription.refresh();
      if (!mounted) return;
      bool verified() =>
          !subscription.isClosed &&
          subscription.identityRevision == identity &&
          !subscription.state.isLoading &&
          subscription.state.errorText == null &&
          subscription.hasAccess();
      if (!verified()) {
        AppWidgets.showErrorSnackBar(context, context.l10n.authContinueError);
        return;
      }
      final session = getIt<AppSession>();
      var destination = AppFlowResolver.afterWelcomeRestore(
        features: session.config.features,
        onboardingCompleted: session.onboardingCompleted,
      );
      if (destination == AppRouter.homeRoute) destination = await AppFlowResolver.resolve();
      if (!mounted) return;
      if (!verified()) {
        AppWidgets.showErrorSnackBar(context, context.l10n.authContinueError);
        return;
      }
      AppWidgets.showSuccessSnackBar(context, context.l10n.restoreSuccessBody);
      context.go(AppFlowResolver.takeLocation(destination));
    } catch (error, stack) {
      AppLogger.logError(error, stackTrace: stack);
      if (mounted) AppWidgets.showErrorSnackBar(context, context.l10n.authContinueError);
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.themeData.dimensionsData;
    return Scaffold(
      appBar: MaterialAppBar(leading: context.canPop() ? null : const SizedBox.shrink()),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: context.themeData.edgeInsetsData.pagePadding.copyWith(top: 0),
          child: PaywallFooterLinks(isBusy: _restoring, onRestore: _restorePurchases),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: context.themeData.edgeInsetsData.pagePadding,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Gap(24),
                          Center(child: AppAssets.images.appIcon.image(height: 100)),
                          Gap(spacing.largeSpacing),
                          Text(
                            context.l10n.signInTitle,
                            textAlign: TextAlign.center,
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Gap(spacing.smallSpacing),
                          Text(
                            context.l10n.authOptionsDescription(getIt<AppConfig>().appName),
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Gap(32),
                          const SocialSignInWidget(),
                          const Gap(24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
