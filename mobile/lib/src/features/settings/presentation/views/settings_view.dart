import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/_config.dart';
import '../../../../core/_core.dart';
import '../../../../localization/_localization.dart';
import '../../../app/app.dart';
import '../../../auth/auth.dart';
import '../../../notification/notification.dart';
import '../../../onboarding/onboarding.dart';
import '../../../paywall/paywall.dart';
import '../../../root/root.dart';

import '../../domain/entities/_entities.dart';
import '../blocs/_blocs.dart';
import '../widgets/_widgets.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key, this.supabaseClient});

  final SupabaseClient? supabaseClient;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  SupabaseClient? _supabaseClient;
  late final Future<PackageInfo> _packageInfo;
  String? _profilePictureUrl;
  String? _email;
  String? _firstName;
  String? _lastName;
  String? _fullName;
  bool _isResettingOnboarding = false;

  late List<SettingsEntity> _generalSettingsList;
  late List<SettingsEntity> _actionSettingsList;
  late List<SettingsEntity> _supportSettingsList;
  late List<SettingsEntity> _debugSettingsList;
  late SettingsEntity _signIn;
  late SettingsEntity _signOut;

  @override
  void initState() {
    super.initState();

    _supabaseClient = widget.supabaseClient;
    _packageInfo = getIt.getAsync<PackageInfo>();
    _readProfile();
  }

  void _readProfile() {
    final user = _supabaseClient?.auth.currentUser;
    _profilePictureUrl = user?.userMetadata?['avatar_url'];
    _email = user?.email;
    _firstName = user?.userMetadata?['first_name'];
    _lastName = user?.userMetadata?['last_name'];
    _fullName = [_firstName, _lastName].where((name) => name != null && name.isNotEmpty).join(' ');
  }

  @override
  void didUpdateWidget(covariant SettingsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _supabaseClient = widget.supabaseClient;
    _readProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final isAuthenticated = getIt<AppSession>().hasAuthenticatedUi;

    _generalSettingsList = [
      if (isAuthenticated) ...[
        SettingsEntity(
          icon: HugeIcons.strokeRoundedUser,
          title: context.l10n.account,
          onPressed: () => context.pushNamed(AppRouter.settingsAccountRoute),
        ),
      ],
    ];
    _actionSettingsList = [
      SettingsEntity(
        icon: HugeIcons.strokeRoundedThumbsUp,
        title: context.l10n.rateApp,
        onPressed: () => ReviewPromptDialog.show(context, onRateNow: _rateApp),
      ),
      SettingsEntity(
        icon: HugeIcons.strokeRoundedShare03,
        title: context.l10n.shareApp,
        onPressed: _shareApp,
      ),
    ];
    _supportSettingsList = [
      SettingsEntity(
        icon: HugeIcons.strokeRoundedReload,
        title: 'Changelog',
        onPressed: () => context.pushNamed(AppRouter.settingsChangelogRoute),
      ),
      SettingsEntity(
        icon: HugeIcons.strokeRoundedMessage02,
        title: context.l10n.contactUs,
        onPressed: () => _contactUs(context),
      ),
      SettingsEntity(
        icon: HugeIcons.strokeRoundedBook04,
        title: context.l10n.termsOfUse,
        onPressed: () => context.pushNamed(AppRouter.termsOfUseRoute),
      ),
      SettingsEntity(
        icon: HugeIcons.strokeRoundedSquareLock01,
        title: context.l10n.privacyPolicy,
        onPressed: () => context.pushNamed(AppRouter.privacyPolicyRoute),
      ),
    ];
    _debugSettingsList = [
      SettingsEntity(
        icon: HugeIcons.strokeRoundedGift,
        title: 'Show Welcome',
        onPressed: () => WelcomeSheet.show(context),
      ),
      SettingsEntity(
        icon: HugeIcons.strokeRoundedSparkles,
        title: "Show What's New",
        onPressed: _showWhatsNew,
      ),
      SettingsEntity(
        icon: HugeIcons.strokeRoundedParty,
        title: 'Show Congratulations',
        onPressed: () => CongratulationsView.show(context),
      ),
      SettingsEntity(
        icon: HugeIcons.strokeRoundedStarSquare,
        title: 'Show Review Prompt',
        onPressed: () => ReviewPromptDialog.show(context, onRateNow: _rateApp),
      ),
      if (getIt<AppConfig>().features.billingEnabled)
        SettingsEntity(
          icon: HugeIcons.strokeRoundedCrown,
          title: 'Test Subscription',
          onPressed: () => _openSubscriptionDebug(context),
        ),
      if (getIt<AppConfig>().features.notificationsEnabled)
        SettingsEntity(
          icon: HugeIcons.strokeRoundedNotification01,
          title: 'Test Notification',
          onPressed: _testNotification,
        ),
      if (getIt<AppConfig>().features.onboardingEnabled)
        SettingsEntity(
          icon: HugeIcons.strokeRoundedReload,
          title: 'Reset Onboarding',
          onPressed: _resetOnboarding,
        ),
    ];
    _signOut = SettingsEntity(
      icon: HugeIcons.strokeRoundedLogoutSquare01,
      title: context.l10n.signOut,
      onPressed: _showSignOutConfirmation,
    );
    _signIn = SettingsEntity(
      icon: HugeIcons.strokeRoundedLoginSquare01,
      title: context.l10n.signIn,
      onPressed: () => context.pushNamed(AppRouter.emailSignInRoute),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) => previous.errorText != current.errorText,
      listener: (context, state) {
        if (state.errorText != null) AppWidgets.showErrorSnackBar(context, state.errorText!);
      },
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: EmptyAppBar(
          enforceSystemUiContrast: false,
          themeModeAdaptive: false,
          systemOverlayStyle:
              (context.colorScheme.brightness == Brightness.light
                      ? SystemUiOverlayStyle.dark
                      : SystemUiOverlayStyle.light)
                  .copyWith(
                    statusBarColor: Colors.transparent,
                    systemNavigationBarColor: Colors.transparent,
                  ),
        ),
        backgroundColor: context.colorScheme.surface,
        body: SafeArea(
          top: false,
          bottom: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: context.themeData.edgeInsetsData.pagePadding.copyWith(
                top: context.themeData.edgeInsetsData.pagePadding.top + topInset,
                bottom: context.themeData.edgeInsetsData.pagePadding.bottom + bottomInset + 60,
              ),
              child: Column(
                children: [
                  // Page Title
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      context.l10n.settings,
                      textAlign: TextAlign.start,
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Gap(context.themeData.dimensionsData.mediumSpacing),
                  BlocSelector<SubscriptionCubit, SubscriptionState, bool>(
                    selector: (state) => state.isPremium,
                    builder: (context, isPremium) {
                      if (isPremium || !getIt<AppConfig>().features.billingEnabled) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        children: [
                          // Upgrade to Premium
                          ListItem(
                            onPressed: () => _showPaywall(context),
                            pressDelay: context.themeData.durationData.buttonPressDelay,
                            backgroundColor: context.colorScheme.secondaryContainer,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(
                                      context.themeData.dimensionsData.smallSpacing,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(
                                        context.themeData.dimensionsData.cornerRadius - 4,
                                      ),
                                    ),
                                    child: AppIcon(
                                      icon: HugeIcons.strokeRoundedCrown,
                                      size: 24,
                                      color: context.colorScheme.onPrimary,
                                    ),
                                  ),
                                  Gap(context.themeData.dimensionsData.smallSpacing),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Upgrade to Premium',
                                          style: context.textTheme.titleMedium?.copyWith(
                                            color: context.colorScheme.onSecondaryContainer,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Gap(context.themeData.dimensionsData.textSpacing),
                                        Text(
                                          'Experience all the exclusive features and contents of the app',
                                          style: context.textTheme.bodySmall?.copyWith(
                                            color: context.colorScheme.onSecondaryContainer
                                                .withValues(alpha: 0.9),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Gap(context.themeData.dimensionsData.mediumSpacing),
                        ],
                      );
                    },
                  ),
                  // Profile
                  if (getIt<AppSession>().hasAuthenticatedUi) ...[
                    ListItem(
                      onPressed: () => _navigateToProfile(context),
                      pressDelay: context.themeData.durationData.buttonPressDelay,
                      leading: _profilePictureUrl != null
                          ? CircleAvatar(
                              foregroundImage: CachedNetworkImageProvider(_profilePictureUrl!),
                              radius: 25,
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: context.colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  (_firstName?.isNotEmpty ?? false)
                                      ? _firstName![0]
                                      : context.l10n.appTitle[0],
                                  style: context.textTheme.titleLarge,
                                ),
                              ),
                            ),
                      trailing: AppIcon(
                        icon: HugeIcons.strokeRoundedArrowRight01,
                        color: context.colorScheme.primary,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fullName ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            _email ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gap(context.themeData.dimensionsData.mediumSpacing),
                  ],
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'General',
                      textAlign: TextAlign.start,
                      style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Gap(context.themeData.dimensionsData.smallSpacing),
                  // General Settings
                  Container(
                    decoration: BoxDecoration(
                      color: context.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(
                        context.themeData.dimensionsData.cornerRadius,
                      ),
                    ),
                    child: Column(
                      children: [
                        for (var settings in _generalSettingsList) ...{
                          ListSettingsItem(settings: settings),
                        },
                        _buildLanguageItem(),
                        _buildThemeItem(),
                        _buildDarkModeItem(),
                        if (getIt<AppConfig>().features.notificationsEnabled)
                          _buildNotificationsItem(),
                      ],
                    ),
                  ),
                  Gap(context.themeData.dimensionsData.mediumSpacing),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Actions',
                      textAlign: TextAlign.start,
                      style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Gap(context.themeData.dimensionsData.smallSpacing),
                  // Action Settings
                  Container(
                    decoration: BoxDecoration(
                      color: context.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(
                        context.themeData.dimensionsData.cornerRadius,
                      ),
                    ),
                    child: Column(
                      children: [
                        for (var settings in _actionSettingsList) ...{
                          ListSettingsItem(settings: settings),
                        },
                      ],
                    ),
                  ),
                  Gap(context.themeData.dimensionsData.mediumSpacing),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Support',
                      textAlign: TextAlign.start,
                      style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Gap(context.themeData.dimensionsData.smallSpacing),
                  // Support Settings
                  Container(
                    decoration: BoxDecoration(
                      color: context.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(
                        context.themeData.dimensionsData.cornerRadius,
                      ),
                    ),
                    child: Column(
                      children: [
                        for (var settings in _supportSettingsList) ...{
                          ListSettingsItem(settings: settings),
                        },
                      ],
                    ),
                  ),
                  if (kDebugMode && _debugSettingsList.isNotEmpty) ...[
                    Gap(context.themeData.dimensionsData.mediumSpacing),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Debug',
                        textAlign: TextAlign.start,
                        style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Gap(context.themeData.dimensionsData.smallSpacing),
                    Container(
                      decoration: BoxDecoration(
                        color: context.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(
                          context.themeData.dimensionsData.cornerRadius,
                        ),
                      ),
                      child: Column(
                        children: [
                          if (_isResettingOnboarding) const LinearProgressIndicator(),
                          for (var settings in _debugSettingsList) ...{
                            ListSettingsItem(settings: settings),
                          },
                        ],
                      ),
                    ),
                  ],
                  if (getIt<AppConfig>().features.authEnabled &&
                      !getIt<AppSession>().hasAuthenticatedUi)
                    Padding(
                      padding: EdgeInsets.only(top: context.themeData.dimensionsData.mediumSpacing),
                      child: ListSettingsItem(settings: _signIn, trailing: const SizedBox.shrink()),
                    ),
                  if (getIt<AppConfig>().features.billingEnabled &&
                      context.watch<SubscriptionCubit>().state.customerInfo?.managementURL != null)
                    ListTile(
                      title: const Text('Manage subscription'),
                      onTap: () => context.pushNamed(AppRouter.paywallRoute),
                    ),
                  // Sign Out
                  if (getIt<AppSession>().hasAuthenticatedUi) ...[
                    Gap(context.themeData.dimensionsData.mediumSpacing),
                    ListSettingsItem(
                      settings: _signOut,
                      trailing: const SizedBox.shrink(),
                      color: context.colorScheme.error,
                    ),
                  ],
                  Gap(context.themeData.dimensionsData.mediumSpacing),
                  // App Name, Version and Build Number
                  FutureBuilder<PackageInfo>(
                    future: _packageInfo,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.done:
                          if (snapshot.hasError || snapshot.data == null) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            children: [
                              Text(
                                snapshot.data!.appName,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Gap(context.themeData.dimensionsData.textSpacing),
                              Text(
                                context.l10n.appVersion(
                                  snapshot.data!.version,
                                  snapshot.data!.buildNumber,
                                ),
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          );
                        default:
                          return const SizedBox.shrink();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showPaywall(BuildContext context) async {
    context.pushNamed(AppRouter.paywallRoute);
  }

  Widget _buildLanguageItem() {
    return BlocSelector<SettingsCubit, SettingsState, int>(
      selector: (state) => state.selectedLanguage,
      builder: (context, selectedLanguage) {
        final locale = LocaleState.locales
            .where((locale) => locale.id == selectedLanguage)
            .firstOrNull;
        return ListSettingsItem(
          settings: SettingsEntity(
            icon: HugeIcons.strokeRoundedGlobe02,
            title: context.l10n.language,
            onPressed: () => context.pushNamed(AppRouter.settingsLanguageRoute),
          ),
          trailing: _SettingsTrailingLabel(label: locale?.title ?? 'System'),
        );
      },
    );
  }

  Widget _buildThemeItem() {
    return BlocSelector<SettingsCubit, SettingsState, int>(
      selector: (state) => state.selectedTheme,
      builder: (context, selectedTheme) {
        final theme = ThemeState.themes.firstWhere(
          (theme) => theme.id == selectedTheme,
          orElse: () => ThemeState.themes.first,
        );
        return ListSettingsItem(
          settings: SettingsEntity(
            icon: HugeIcons.strokeRoundedPaintBoard,
            title: context.l10n.theme,
            onPressed: () => context.pushNamed(AppRouter.settingsThemeRoute),
          ),
          trailing: _SettingsTrailingLabel(label: theme.title),
        );
      },
    );
  }

  Widget _buildDarkModeItem() {
    return BlocSelector<SettingsCubit, SettingsState, int>(
      selector: (state) => state.selectedDarkMode,
      builder: (context, selectedDarkMode) {
        final title = switch (selectedDarkMode) {
          0 => 'System',
          1 => 'Light',
          2 => 'Dark',
          _ => 'System',
        };
        return ListSettingsItem(
          settings: SettingsEntity(
            icon: HugeIcons.strokeRoundedMoon02,
            title: context.l10n.darkMode,
            onPressed: () => context.pushNamed(AppRouter.settingsDarkModeRoute),
          ),
          trailing: _SettingsTrailingLabel(label: title),
        );
      },
    );
  }

  Widget _buildNotificationsItem() {
    return ListSettingsItem(
      settings: SettingsEntity(
        icon: HugeIcons.strokeRoundedNotification01,
        title: context.l10n.notifications,
        onPressed: () => context.pushNamed(AppRouter.settingsNotificationsRoute),
      ),
    );
  }

  Future<void> _navigateToProfile(BuildContext context) async {
    await context.pushNamed(AppRouter.profileRoute);
  }

  Future<void> _rateApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    } else {
      await inAppReview.openStoreListing();
    }
  }

  Future<void> _shareApp() async {
    // TODO: Change share text
    final config = getIt<AppConfig>();
    final shareText = '${config.appName} ${config.storeUrlForCurrentPlatform}'.trim();
    await SharePlus.instance.share(ShareParams(text: shareText));
  }

  Future<void> _contactUs(BuildContext context) async {
    try {
      // TODO: Change contact link
      final contact = getIt<AppConfig>().supportUrl;
      if (contact.isEmpty) return;
      final uri = Uri.parse(contact);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      AppLogger.logError(e);
      if (context.mounted) {
        AppWidgets.showErrorSnackBar(context, 'Unable to open contact page');
      }
    }
  }

  Future<void> _showSignOutConfirmation() async {
    final signOutCubit = getIt<SignOutCubit>();

    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: signOutCubit,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                          color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    Padding(
                      padding: context.themeData.edgeInsetsData.pagePadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Are you sure you want to sign out?',
                            textAlign: TextAlign.center,
                            style: context.textTheme.titleMedium,
                          ),
                          Gap(context.themeData.dimensionsData.mediumSpacing),
                          BlocConsumer<SignOutCubit, SignOutState>(
                            listener: (context, state) {
                              state.whenOrNull(
                                success: () {
                                  getIt<AppSession>().disableDebugGuestMode();
                                  context.pop();
                                  if (getIt<AppConfig>().features.authMode == AuthMode.required) {
                                    context.goNamed(AppRouter.signInRoute);
                                  } else {
                                    context.goNamed(AppRouter.homeRoute);
                                  }
                                },
                                error: (error) {
                                  AppWidgets.showErrorSnackBar(
                                    context,
                                    error.message ?? 'Sign out failed',
                                  );
                                },
                              );
                            },
                            builder: (context, state) {
                              return state.maybeWhen(
                                loading: () => ListActionItem(
                                  text: 'Signing Out...',
                                  textColor: context.colorScheme.error,
                                  onPressed: null,
                                ),
                                orElse: () => ListActionItem(
                                  text: context.l10n.signOut,
                                  textColor: context.colorScheme.error,
                                  onPressed: () => context.read<SignOutCubit>().signOut(),
                                ),
                              );
                            },
                          ),
                          Gap(context.themeData.dimensionsData.smallSpacing),
                          ListActionItem(text: 'Cancel', onPressed: () => context.pop()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openSubscriptionDebug(BuildContext context) async {
    if (!kDebugMode) return;
    await context.pushNamed(AppRouter.settingsSubscriptionDebugRoute);
  }

  Future<void> _showWhatsNew() async {
    if (!kDebugMode || AppRelease.releases.isEmpty) return;
    await WhatsNewSheet.show(context, release: AppRelease.releases.first);
  }

  Future<void> _testNotification() async {
    if (!kDebugMode) return;
    final granted = await NotificationManager.ensurePermission();
    if (!granted) {
      if (mounted) {
        AppWidgets.showErrorSnackBar(context, 'Notification permission not granted');
      }
      return;
    }
    await NotificationManager.showNotification(
      title: 'Test Notification',
      body: 'This is a test notification from the Debug menu!',
    );
    if (mounted) {
      AppWidgets.showInfoSnackBar(context, 'Test notification sent');
    }
  }

  Future<void> _resetOnboarding() async {
    if (!kDebugMode || _isResettingOnboarding) return;
    setState(() => _isResettingOnboarding = true);
    try {
      final onboarding = getIt<OnboardingCubit>();
      onboarding.reset();
      // Flush earlier answer writes and require the cleared answers to persist.
      await onboarding.save();
      await getIt<AppSession>().resetOnboarding(resetHomeSheets: true);
      if (!mounted) return;
      context.read<RootCubit>().setSelectedIndex(0);
      context.goNamed(AppRouter.welcomeRoute);
    } catch (error, stackTrace) {
      AppLogger.logError(error, stackTrace: stackTrace);
      if (mounted) {
        AppWidgets.showErrorSnackBar(context, 'Unable to reset onboarding. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isResettingOnboarding = false);
    }
  }
}

class _SettingsTrailingLabel extends StatelessWidget {
  const _SettingsTrailingLabel({this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Text(
            label!,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        Gap(context.themeData.dimensionsData.smallSpacing),
        AppIcon(
          size: 22,
          icon: HugeIcons.strokeRoundedArrowRight01,
          color: context.colorScheme.primary,
        ),
      ],
    );
  }
}
