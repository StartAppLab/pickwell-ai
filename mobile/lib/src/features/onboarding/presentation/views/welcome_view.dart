import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/_config.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../../../paywall/paywall.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  late final PaywallCubit _paywallCubit;

  @override
  void initState() {
    super.initState();
    _paywallCubit = getIt<PaywallCubit>();
  }

  @override
  void dispose() {
    _paywallCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = getIt<AppConfig>();
    final spacing = context.themeData.dimensionsData;

    return BlocProvider.value(
      value: _paywallCubit,
      child: Scaffold(
        backgroundColor: context.colorScheme.surface,
        resizeToAvoidBottomInset: false,
        appBar: EmptyAppBar(),
        body: SafeArea(
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    Padding(
                      padding: context.themeData.edgeInsetsData.pagePadding,
                      child: AspectRatio(
                        aspectRatio: 1.15,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: context.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 56,
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: context.themeData.edgeInsetsData.pagePadding,
                      child: Column(
                        children: [
                          Text(
                            context.l10n.welcomeTitle(config.appName),
                            textAlign: TextAlign.center,
                            style: context.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                          Gap(spacing.smallSpacing),
                          Text(
                            context.l10n.welcomeDesc,
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Gap(180),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: context.themeData.edgeInsetsData.pagePadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (kDebugMode && config.features.billingEnabled) ...[
                OutlinedButton(
                  onPressed: () => _skipToPaywall(context),
                  child: Text(
                    '[DEV] Skip to Paywall',
                    style: context.themeData.textStyleData.buttonTextStyle.copyWith(
                      color: context.colorScheme.primary,
                    ),
                  ),
                ),
                Gap(spacing.smallSpacing),
                OutlinedButton(
                  onPressed: () => _skipToHome(context),
                  child: Text(
                    '[DEV] Skip to Home',
                    style: context.themeData.textStyleData.buttonTextStyle.copyWith(
                      color: context.colorScheme.primary,
                    ),
                  ),
                ),
                Gap(spacing.smallSpacing),
              ],
              ElevatedButton(
                onPressed: () => _getStarted(context),
                child: Text(
                  context.l10n.getStarted,
                  style: context.themeData.textStyleData.buttonTextStyle.copyWith(
                    color: context.colorScheme.onPrimary,
                  ),
                ),
              ),
              if (config.features.authEnabled) ...[
                Gap(spacing.smallSpacing),
                GestureDetector(
                  onTap: () => _openSignIn(context, config),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text.rich(
                      TextSpan(
                        text: context.l10n.alreadyHaveAnAccount,
                        children: [
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: context.l10n.signIn,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ] else if (config.features.billingEnabled) ...[
                Gap(spacing.smallSpacing),
                BlocBuilder<PaywallCubit, PaywallState>(
                  builder: (context, state) => GestureDetector(
                    onTap: state.isLoading ? null : _restorePurchases,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text.rich(
                        TextSpan(
                          text: 'Already have a subscription? ',
                          children: [
                            TextSpan(
                              text: state.isLoading ? 'Restoring…' : 'Restore',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _getStarted(BuildContext context) {
    context.pushNamed(AppRouter.onboardingRoute);
  }

  void _openSignIn(BuildContext context, AppConfig config) {
    final features = config.features;
    if (features.googleSignInEnabled || features.appleSignInEnabled) {
      context.pushNamed(AppRouter.authOptionsRoute);
      return;
    }

    context.pushNamed(AppRouter.signInRoute, queryParameters: const {'showCreateAccount': 'false'});
  }

  Future<void> _restorePurchases() async {
    final result = await _paywallCubit.restore();
    if (!mounted) return;
    if (result.outcome == BillingOutcome.success) {
      final session = getIt<AppSession>();
      AppWidgets.showSuccessSnackBar(context, 'Purchases restored successfully');
      context.goNamed(
        AppFlowResolver.afterWelcomeRestore(
          features: session.config.features,
          onboardingCompleted: session.onboardingCompleted,
        ),
      );
    } else if (result.outcome != BillingOutcome.cancelled) {
      AppWidgets.showInfoSnackBar(context, result.message ?? 'No purchases were found to restore.');
    }
  }

  Future<void> _skipToHome(BuildContext context) async {
    await getIt<AppSession>().completeOnboarding();
    if (!context.mounted) return;
    context.goNamed(AppRouter.homeRoute);
  }

  Future<void> _skipToPaywall(BuildContext context) async {
    try {
      await getIt<AppSession>().completeOnboarding();
    } catch (_) {
      if (context.mounted) {
        AppWidgets.showErrorSnackBar(context, 'Unable to save progress. Please try again.');
      }
      return;
    }
    if (!context.mounted) return;
    context.pushNamed(AppRouter.onboardingPaywallRoute);
  }
}
