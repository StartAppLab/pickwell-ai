import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../config/_config.dart';
import '../../../../core/_core.dart';
import '../../../_features.dart';

enum _CompletionSource { purchase, restore }

class PaywallView extends StatefulWidget {
  const PaywallView({
    super.key,
    this.isOnboarding = true,
    this.showBackButton = true,
    this.entitlementId,
    this.offeringId,
  });

  final bool isOnboarding;
  final bool showBackButton;
  final String? entitlementId;
  final String? offeringId;

  @override
  State<PaywallView> createState() => _PaywallViewState();
}

class _PaywallViewState extends State<PaywallView> {
  late final PageController _pageController;
  static const int _totalSteps = 3;
  bool _isCompletingPurchase = false;
  ({int identityRevision, _CompletionSource source})? _retryCompletion;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.isOnboarding ? 0 : _totalSteps - 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<PaywallCubit>();
      cubit.loadOfferings(entitlementId: widget.entitlementId, offeringId: widget.offeringId);
      if (!widget.isOnboarding) cubit.setSlideIndex(_totalSteps - 1);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<PaywallCubit, PaywallState>(
    builder: (context, state) {
      final slideIndex = state.slideIndex;
      final isLoading = state.isLoading || _isCompletingPurchase;
      final packages = state.offering?.availablePackages ?? <Package>[];
      final selectedPackage = packages
          .where((package) => package.identifier == state.selectedPlan)
          .firstOrNull;

      return PopScope(
        canPop: widget.showBackButton || !widget.isOnboarding,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop || !widget.showBackButton) return;
          if (widget.isOnboarding && slideIndex > 0) {
            await _prev();
          } else if (context.canPop()) {
            context.pop();
          }
        },
        child: Scaffold(
          appBar: MaterialAppBar(
            leading: !widget.showBackButton || (widget.isOnboarding && slideIndex == 0)
                ? const SizedBox.shrink()
                : null,
            onIconPressed: () async {
              if (widget.isOnboarding && slideIndex > 0) {
                await _prev();
              } else {
                await _close();
              }
            },
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: slideIndex == _totalSteps - 1
                    ? IconButton(
                        onPressed: isLoading ? null : _close,
                        icon: AppIcon(
                          icon: HugeIcons.strokeRoundedCancel01,
                          color: context.colorScheme.onSurface,
                          size: 24,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: context.colorScheme.surfaceContainer,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      )
                    : TextButton(
                        onPressed: isLoading ? null : _restore,
                        child: Text('Restore', style: context.textTheme.labelLarge),
                      ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: widget.isOnboarding
                      ? ExpandablePageView(
                          controller: _pageController,
                          scrollPhysics: const NeverScrollableScrollPhysics(),
                          itemCount: _totalSteps,
                          onPageChanged: context.read<PaywallCubit>().setSlideIndex,
                          itemBuilder: (context, index) => switch (index) {
                            0 => const PaywallStep1Widget(),
                            1 => PaywallStep2Widget(
                              hasFreeTrial:
                                  selectedPackage != null && _hasFreeTrial(selectedPackage),
                            ),
                            2 =>
                              selectedPackage != null && _hasFreeTrial(selectedPackage)
                                  ? PaywallStep3Widget(
                                      trialDuration: _freeTrialLengthLabel(
                                        selectedPackage,
                                      )?.toLowerCase(),
                                      trialDays: _freeTrialDays(selectedPackage),
                                    )
                                  : const PaywallDefaultWidget(),
                            _ => const SizedBox.shrink(),
                          },
                        )
                      : const PaywallDefaultWidget(),
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: context.themeData.edgeInsetsData.pagePadding.copyWith(top: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (slideIndex == _totalSteps - 1) ...[
                    for (final package in packages) ...[
                      PaywallPlanCard(
                        title: package.storeProduct.title,
                        price: package.storeProduct.priceString,
                        period: _period(package.packageType),
                        isPopular: package.packageType == PackageType.annual,
                        isSelected: state.selectedPlan == package.identifier,
                        onSelect: isLoading || _retryCompletion != null
                            ? () {}
                            : () =>
                                  context.read<PaywallCubit>().setSelectedPlan(package.identifier),
                      ),
                      if (package != packages.last)
                        Gap(context.themeData.dimensionsData.smallSpacing),
                    ],
                    if (packages.isEmpty && !isLoading)
                      Text('No products available', style: context.textTheme.bodyMedium),
                    Gap(context.themeData.dimensionsData.smallSpacing),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppIcon(
                        icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                        color: context.colorScheme.primary,
                        size: 24,
                      ),
                      const Gap(4),
                      Flexible(
                        child: Text(
                          slideIndex == _totalSteps - 1
                              ? 'No Commitment  •  Cancel Anytime'
                              : 'No Payment Due Now',
                          textAlign: TextAlign.center,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(context.themeData.dimensionsData.smallSpacing),
                  ElevatedButton(
                    onPressed: isLoading || (state.offering == null && _retryCompletion == null)
                        ? null
                        : _next,
                    child: Text(
                      _retryCompletion != null
                          ? context.l10n.retryButton
                          : slideIndex == _totalSteps - 1
                          ? _finalStepButtonLabel(selectedPackage)
                          : 'Continue',
                    ),
                  ),
                  Gap(context.themeData.dimensionsData.smallSpacing),
                  if (slideIndex == _totalSteps - 1)
                    PaywallFooterLinks(onRestore: _restore)
                  else
                    _buildPriceFooter(context, packages, selectedPackage),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  Future<void> _prev() => _pageController.previousPage(
    duration: const Duration(milliseconds: 200),
    curve: Curves.linear,
  );

  String _period(PackageType type) => switch (type) {
    PackageType.weekly => 'Billed weekly',
    PackageType.monthly => 'Billed monthly',
    PackageType.twoMonth => 'Billed every two months',
    PackageType.threeMonth => 'Billed every three months',
    PackageType.sixMonth => 'Billed every six months',
    PackageType.annual => 'Billed yearly',
    PackageType.lifetime => 'One-time purchase',
    _ => 'See billing details in store confirmation',
  };

  String _finalStepButtonLabel(Package? package) {
    if (package == null || !_hasFreeTrial(package)) return 'Unlock Now';
    final length = _freeTrialLengthLabel(package);
    return length == null ? 'Start Free Trial' : 'Start My $length Free Trial';
  }

  bool _hasFreeTrial(Package package) {
    final introductoryPrice = package.storeProduct.introductoryPrice;
    return (introductoryPrice != null && introductoryPrice.price == 0) ||
        _freeTrialPhase(package) != null;
  }

  String? _freeTrialLengthLabel(Package package) {
    final introductoryPrice = package.storeProduct.introductoryPrice;
    if (introductoryPrice != null && introductoryPrice.price == 0) {
      return _trialLengthLabel(
        introductoryPrice.periodUnit,
        introductoryPrice.periodNumberOfUnits * introductoryPrice.cycles,
      );
    }

    final freePhase = _freeTrialPhase(package);
    if (freePhase == null) return null;

    final period = freePhase.billingPeriod;
    final length = period == null
        ? null
        : _trialLengthLabel(period.unit, period.value * (freePhase.billingCycleCount ?? 1));
    return length;
  }

  int? _freeTrialDays(Package package) {
    final introductoryPrice = package.storeProduct.introductoryPrice;
    if (introductoryPrice != null && introductoryPrice.price == 0) {
      return _trialDurationDays(
        introductoryPrice.periodUnit,
        introductoryPrice.periodNumberOfUnits * introductoryPrice.cycles,
      );
    }

    final freePhase = _freeTrialPhase(package)!;
    final period = freePhase.billingPeriod;
    if (period == null) return null;
    return _trialDurationDays(period.unit, period.value * (freePhase.billingCycleCount ?? 1));
  }

  int? _trialDurationDays(PeriodUnit unit, int count) {
    if (count <= 0) return null;
    return switch (unit) {
      PeriodUnit.day => count,
      PeriodUnit.week => count * 7,
      PeriodUnit.month => count * 30,
      PeriodUnit.year => count * 365,
      PeriodUnit.unknown => null,
    };
  }

  PricingPhase? _freeTrialPhase(Package package) {
    final product = package.storeProduct;
    final options = [
      if (product.defaultOption != null) product.defaultOption!,
      ...?product.subscriptionOptions,
    ];
    for (final option in options) {
      final phase = option.freePhase;
      if (phase != null && phase.price.amountMicros == 0) return phase;
    }
    return null;
  }

  String? _trialLengthLabel(PeriodUnit unit, int count) {
    if (count <= 0) return null;
    return switch (unit) {
      PeriodUnit.day => '$count-Day',
      PeriodUnit.week => '${count * 7}-Day',
      PeriodUnit.month => '$count-Month',
      PeriodUnit.year => '$count-Year',
      PeriodUnit.unknown => null,
    };
  }

  Widget _buildPriceFooter(BuildContext context, List<Package> packages, Package? selectedPackage) {
    final baseStyle = context.textTheme.bodySmall?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
    );

    if (selectedPackage?.packageType == PackageType.lifetime) {
      return Text(
        '${selectedPackage!.storeProduct.priceString} ${_period(selectedPackage.packageType).toLowerCase()}',
        style: baseStyle,
        textAlign: TextAlign.center,
      );
    }

    Package? highestRecurringPackage;
    for (final package in packages) {
      if (package.packageType == PackageType.lifetime || _periodDetails(package) == null) {
        continue;
      }
      if (highestRecurringPackage == null ||
          package.storeProduct.price > highestRecurringPackage.storeProduct.price) {
        highestRecurringPackage = package;
      }
    }

    if (highestRecurringPackage == null) {
      return Text(
        selectedPackage == null
            ? ''
            : '${selectedPackage.storeProduct.priceString} ${_period(selectedPackage.packageType).toLowerCase()}',
        style: baseStyle,
        textAlign: TextAlign.center,
      );
    }

    final details = _periodDetails(highestRecurringPackage)!;
    final isWeekly = highestRecurringPackage.packageType == PackageType.weekly;
    final equivalent = highestRecurringPackage.storeProduct.price / (isWeekly ? 7 : details.weeks);
    final currencySymbol = _currencySymbolFromPriceString(
      highestRecurringPackage.storeProduct.priceString,
    );
    final equivalentPrice = NumberFormat.currency(
      locale: Localizations.localeOf(context).toString(),
      name: highestRecurringPackage.storeProduct.currencyCode,
      symbol: currencySymbol.isEmpty ? null : currencySymbol,
    ).format(equivalent);
    final equivalentPeriod = isWeekly ? 'day' : 'week';

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Just ${highestRecurringPackage.storeProduct.priceString} per ${details.label} ',
          ),
          TextSpan(
            text: '($equivalentPrice per $equivalentPeriod)',
            style: baseStyle?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
      style: baseStyle,
      textAlign: TextAlign.center,
    );
  }

  ({String label, double weeks})? _periodDetails(Package package) => switch (package.packageType) {
    PackageType.weekly => (label: 'week', weeks: 1),
    PackageType.monthly => (label: 'month', weeks: 365.2425 / 12 / 7),
    PackageType.twoMonth => (label: 'two months', weeks: 365.2425 / 6 / 7),
    PackageType.threeMonth => (label: 'three months', weeks: 365.2425 / 4 / 7),
    PackageType.sixMonth => (label: 'six months', weeks: 365.2425 / 2 / 7),
    PackageType.annual => (label: 'year', weeks: 365.2425 / 7),
    PackageType.custom || PackageType.unknown => _customPeriodDetails(package),
    PackageType.lifetime => null,
  };

  ({String label, double weeks})? _customPeriodDetails(Package package) {
    final match = RegExp(
      r'^P(\d+)([DWMY])$',
    ).firstMatch(package.storeProduct.subscriptionPeriod ?? '');
    if (match == null) return null;

    final count = int.parse(match.group(1)!);
    return switch (match.group(2)) {
      'D' => (label: count == 1 ? 'day' : '$count days', weeks: count / 7),
      'W' => (label: count == 1 ? 'week' : '$count weeks', weeks: count.toDouble()),
      'M' => (
        label: count == 1 ? 'month' : '$count months',
        weeks: count.toDouble() * 365.2425 / 12 / 7,
      ),
      'Y' => (label: count == 1 ? 'year' : '$count years', weeks: count.toDouble() * 365.2425 / 7),
      _ => null,
    };
  }

  String _currencySymbolFromPriceString(String priceString) {
    final amount = RegExp(r'[0-9٠-٩۰-۹][0-9٠-٩۰-۹.,٬٫\s]*').firstMatch(priceString);
    if (amount == null) return '';

    final prefix = priceString.substring(0, amount.start).trim();
    final suffix = priceString.substring(amount.end).trim();
    return '$prefix$suffix';
  }

  Future<void> _next() async {
    if (_isCompletingPurchase) return;
    final retry = _retryCompletion;
    if (retry != null) {
      await _completePurchase(identityRevision: retry.identityRevision, source: retry.source);
      return;
    }
    if (context.read<PaywallCubit>().state.slideIndex < _totalSteps - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.linear,
      );
      return;
    }
    final identityRevision = context.read<SubscriptionCubit>().identityRevision;
    await _handle(
      await context.read<PaywallCubit>().purchase(),
      identityRevision: identityRevision,
      source: _CompletionSource.purchase,
    );
  }

  Future<void> _close() async {
    if (_isCompletingPurchase) return;
    final retry = _retryCompletion;
    if (retry != null) {
      await _completePurchase(identityRevision: retry.identityRevision, source: retry.source);
      return;
    }
    await _leavePaywall();
  }

  Future<void> _leavePaywall() async {
    if (widget.isOnboarding) {
      final session = getIt<AppSession>();
      if (!session.onboardingPaywallCompleted) {
        try {
          await session.completeOnboardingPaywall();
        } catch (_) {
          if (mounted) {
            AppWidgets.showErrorSnackBar(
              context,
              'Unable to save paywall progress. Please try again.',
            );
          }
          return;
        }
      }
      if (!mounted) return;
      context.go(AppFlowResolver.takeLocation(AppRouter.homeRoute));
    } else if (!context.canPop()) {
      context.goNamed(AppRouter.homeRoute);
    } else {
      context.pop();
    }
  }

  Future<void> _restore() async {
    if (_isCompletingPurchase) return;
    final retry = _retryCompletion;
    if (retry != null) {
      await _completePurchase(identityRevision: retry.identityRevision, source: retry.source);
      return;
    }
    final identityRevision = context.read<SubscriptionCubit>().identityRevision;
    await _handle(
      await context.read<PaywallCubit>().restore(),
      identityRevision: identityRevision,
      source: _CompletionSource.restore,
    );
  }

  Future<void> _handle(
    BillingResult result, {
    required int identityRevision,
    required _CompletionSource source,
  }) async {
    if (!mounted || _isCompletingPurchase) return;
    if (result.outcome != BillingOutcome.success) {
      if (result.outcome != BillingOutcome.cancelled && result.message != null) {
        AppWidgets.showInfoSnackBar(context, result.message!);
      }
      return;
    }
    await _completePurchase(identityRevision: identityRevision, source: source);
  }

  Future<void> _completePurchase({
    required int identityRevision,
    required _CompletionSource source,
  }) async {
    if (!mounted || _isCompletingPurchase) return;
    final subscription = context.read<SubscriptionCubit>();
    final entitlementId = widget.entitlementId ?? getIt<AppConfig>().revenueCatEntitlementId;
    bool hasVerifiedAccess() =>
        !subscription.isClosed &&
        subscription.identityRevision == identityRevision &&
        subscription.hasAccess(entitlementId: entitlementId);

    setState(() => _isCompletingPurchase = true);
    try {
      await subscription.refresh();
      if (!mounted) return;
      if (!hasVerifiedAccess()) {
        if (subscription.isClosed || subscription.identityRevision != identityRevision) {
          _retryCompletion = null;
        }
        AppWidgets.showErrorSnackBar(context, context.l10n.authContinueError);
        return;
      }
      if (widget.isOnboarding) {
        final session = getIt<AppSession>();
        if (!session.onboardingPaywallCompleted) {
          try {
            await session.completeOnboardingPaywall();
          } catch (_) {
            _retryCompletion = (identityRevision: identityRevision, source: source);
            rethrow;
          }
        }
        if (!mounted) return;
        if (!hasVerifiedAccess()) {
          _retryCompletion = null;
          AppWidgets.showErrorSnackBar(context, context.l10n.authContinueError);
          return;
        }
        _retryCompletion = null;
      }
      if (source == _CompletionSource.purchase) {
        await CongratulationsView.show(context);
      } else if (widget.isOnboarding) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            final colorScheme = dialogContext.colorScheme;
            final textTheme = dialogContext.textTheme;
            final dimensions = dialogContext.themeData.dimensionsData;
            final insets = dialogContext.themeData.edgeInsetsData;
            return PopScope(
              canPop: false,
              child: AlertDialog(
                scrollable: true,
                elevation: 0,
                backgroundColor: colorScheme.surface,
                clipBehavior: Clip.antiAlias,
                constraints: BoxConstraints(maxWidth: dimensions.maxWidth),
                insetPadding: insets.dialogPadding,
                titlePadding: insets.pagePadding.copyWith(bottom: dimensions.smallSpacing),
                contentPadding: insets.pagePadding.copyWith(
                  top: 0,
                  bottom: dimensions.mediumSpacing,
                ),
                actionsPadding: insets.pagePadding.copyWith(top: 0),
                title: Text(
                  dialogContext.l10n.restoreSuccessTitle,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                content: SizedBox(
                  width: dimensions.maxWidth,
                  child: Text(
                    dialogContext.l10n.restoreSuccessBody,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge,
                  ),
                ),
                actions: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(dialogContext.l10n.continueButton, textAlign: TextAlign.center),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
      if (!mounted) return;
      // Identity or access may change while the confirmation is open.
      if (!hasVerifiedAccess()) {
        AppWidgets.showErrorSnackBar(context, context.l10n.authContinueError);
        return;
      }
      await _leavePaywall();
    } catch (error, stackTrace) {
      AppLogger.logError(error, stackTrace: stackTrace);
      if (mounted) AppWidgets.showErrorSnackBar(context, context.l10n.authContinueError);
    } finally {
      if (mounted) setState(() => _isCompletingPurchase = false);
    }
  }
}
