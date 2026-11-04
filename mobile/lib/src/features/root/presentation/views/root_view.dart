import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../config/_config.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../../../settings/domain/entities/app_release.dart';
import '../../../home/home.dart';
import '../blocs/_blocs.dart';
import '../widgets/_widgets.dart';

class RootTab {
  final String routeName;
  final String label;
  final dynamic icon;

  const RootTab({required this.routeName, required this.label, required this.icon});
}

class RootView extends StatefulWidget {
  final Widget? child;
  final Widget? actionButton;
  final List<RootTab>? tabs;
  final String? currentPath;
  final bool showNavigation;

  const RootView({
    super.key,
    this.child,
    this.actionButton,
    this.tabs,
    this.currentPath,
    this.showNavigation = true,
  });

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  bool _isShowingHomeSheets = false;
  bool _didCheckHomeSheets = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Route visibility changes also resume deferred sheets when returning Home.
    if (_isHome) _scheduleHomeSheets();
  }

  @override
  void didUpdateWidget(covariant RootView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPath != widget.currentPath) _scheduleHomeSheets();
  }

  void _scheduleHomeSheets() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _showHomeSheets());
  }

  bool get _isHome =>
      mounted &&
      widget.currentPath == AppRouter.homeRoute &&
      ModalRoute.isCurrentOf(context) == true;

  Future<void> _showHomeSheets() async {
    if (!getIt<AppConfig>().features.onboardingEnabled) return;
    if (!_isHome || _isShowingHomeSheets || _didCheckHomeSheets) return;
    _isShowingHomeSheets = true;
    final storage = getIt<DataStorage>();
    try {
      final hasSeenWelcome = await storage.read(DataStorageKeys.hasSeenWelcomeSheet) == true;
      if (!mounted || !_isHome) return;
      if (!hasSeenWelcome) {
        await WelcomeSheet.show(
          context,
          onContinue: () async {
            if (await storage.write(DataStorageKeys.hasSeenWelcomeSheet, true) != true) {
              throw StateError('Unable to save welcome progress.');
            }
          },
        );
      }
      if (!mounted || !_isHome) return;
      final packageInfo = await getIt.getAsync<PackageInfo>();
      final currentVersion = packageInfo.version.trim();
      if (currentVersion.isEmpty) return;
      final storedVersion = await storage.read(DataStorageKeys.lastSeenAppVersion);
      final previousVersion = storedVersion is String ? storedVersion.trim() : '';
      if (!mounted || !_isHome) return;

      final shouldShowRelease =
          previousVersion.isEmpty || _compareVersions(previousVersion, currentVersion) < 0;
      if (shouldShowRelease) {
        AppRelease? release;
        for (final candidate in AppRelease.releases) {
          if (candidate.version == currentVersion) {
            release = candidate;
            break;
          }
        }
        if (release != null) await WhatsNewSheet.show(context, release: release);
        if (await storage.write(DataStorageKeys.lastSeenAppVersion, currentVersion) != true) {
          throw StateError('Unable to save release notes progress.');
        }
      }
      _didCheckHomeSheets = true;
    } catch (error, stackTrace) {
      AppLogger.logError(error, stackTrace: stackTrace);
    } finally {
      _isShowingHomeSheets = false;
    }
  }

  int _compareVersions(String left, String right) {
    final leftParts = _versionParts(left);
    final rightParts = _versionParts(right);
    final length = leftParts.length > rightParts.length ? leftParts.length : rightParts.length;

    for (var index = 0; index < length; index++) {
      final leftPart = index < leftParts.length ? leftParts[index] : 0;
      final rightPart = index < rightParts.length ? rightParts[index] : 0;
      if (leftPart != rightPart) return leftPart.compareTo(rightPart);
    }
    return 0;
  }

  List<int> _versionParts(String version) => version
      .split('+')
      .first
      .split('.')
      .map((part) => int.tryParse(part.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final tabs = widget.tabs?.isNotEmpty == true ? widget.tabs! : _defaultTabs(context);
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(child: widget.child ?? const SizedBox.shrink()),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: const EdgeBlur(height: 20, position: EdgeBlurPosition.top),
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: const EdgeBlur(height: 90)),
        ],
      ),
      bottomNavigationBar: BlocSelector<RootCubit, RootState, int>(
        selector: (state) => state.selectedIndex,
        builder: (context, selectedIndex) {
          if (MediaQuery.viewInsetsOf(context).bottom > 0 ||
              (!widget.showNavigation && widget.currentPath != AppRouter.homeRoute)) {
            return const SizedBox.shrink();
          }
          final d = context.themeData.dimensionsData;
          final routeSelectedIndex = tabs.indexWhere((tab) => tab.routeName == widget.currentPath);
          final safeSelectedIndex = (routeSelectedIndex >= 0 ? routeSelectedIndex : selectedIndex)
              .clamp(0, tabs.length - 1);
          final navShell = widget.showNavigation
              ? _buildNavShell(context, safeSelectedIndex, tabs)
              : null;
          return SafeArea(
            bottom: true,
            maintainBottomViewPadding: true,
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: d.maxWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.themeData.edgeInsetsData.pagePadding.left,
                    vertical: d.paddingXs,
                  ),
                  child: Row(
                    children: [
                      if (navShell != null) ...[
                        Expanded(child: navShell),
                        Gap(d.spacingSm),
                      ] else
                        const Spacer(),
                      ...[
                        widget.actionButton ??
                            IconButton.filled(
                              tooltip: context.l10n.pkScan,
                              style: IconButton.styleFrom(minimumSize: const Size(64, 64)),
                              onPressed: () async {
                                await context.push('/scan');
                                if (context.mounted) await getIt<HomeCubit>().load();
                              },
                              icon: const AppIcon(icon: HugeIcons.strokeRoundedBarcodeScan),
                            ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<RootTab> _defaultTabs(BuildContext context) => [
    RootTab(
      routeName: AppRouter.homeRoute,
      icon: HugeIcons.strokeRoundedHome01,
      label: context.l10n.home,
    ),
    RootTab(
      routeName: AppRouter.settingsRoute,
      icon: HugeIcons.strokeRoundedSettings01,
      label: context.l10n.settings,
    ),
  ];

  Widget _buildNavShell(BuildContext context, int selectedIndex, List<RootTab> tabs) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: Theme.of(context).platform == TargetPlatform.android ? 0 : 12,
          sigmaY: Theme.of(context).platform == TargetPlatform.android ? 0 : 12,
        ),
        child: Container(
          height: (44 + MediaQuery.textScalerOf(context).scale(12) * 1.6).clamp(
            64.0,
            double.infinity,
          ),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerLowest.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: context.colorScheme.outlineVariant, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: context.colorScheme.shadow.withValues(alpha: 0.08),
                offset: const Offset(0, 10),
                blurRadius: 20,
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / tabs.length;
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    left: selectedIndex * itemWidth,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      key: const ValueKey('navigation-selector'),
                      width: itemWidth,
                      decoration: BoxDecoration(
                        color: context.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var index = 0; index < tabs.length; index++)
                        Expanded(
                          child: NavItem(
                            index: index,
                            selectedIndex: selectedIndex,
                            icon: tabs[index].icon,
                            label: tabs[index].label,
                            onTap: () => _changeTab(index, tabs),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _changeTab(int selectedIndex, List<RootTab> tabs) {
    context.read<RootCubit>().setSelectedIndex(selectedIndex);
    context.goNamed(tabs[selectedIndex].routeName);
  }
}
