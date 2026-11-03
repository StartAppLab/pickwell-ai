import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/_config.dart';
import '../../core/_core.dart';
import '../../features/_features.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;
  static const String splashRoute = '/';
  static const String welcomeRoute = '/welcome';
  static const String onboardingRoute = '/onboarding';
  static const String onboardingPaywallRoute = '/onboarding-paywall';
  static const String authOptionsRoute = '/auth-options';
  static const String signInRoute = '/sign-in';
  static const String signUpRoute = '/sign-up';
  static const String otpRoute = '/otp';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String changePasswordRoute = '/change-password';
  static const String homeRoute = '/home';
  static const String settingsRoute = '/settings';
  static const String notificationRoute = '/notification';
  static const String paywallRoute = '/paywall';
  static const String profileRoute = '/profile';
  static const String termsOfUseRoute = '/terms-of-use';
  static const String privacyPolicyRoute = '/privacy-policy';

  static const String settingsChangelogRoute = '/settings-changelog';
  static const String settingsAccountRoute = '/settings-account';
  static const String settingsNotificationsRoute = '/settings-notifications';
  static const String settingsLanguageRoute = '/settings-language';
  static const String settingsThemeRoute = '/settings-theme';
  static const String settingsDarkModeRoute = '/settings-dark-mode';
  static const String settingsSubscriptionDebugRoute = '/settings-subscription-debug';

  static final routerConfig = GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: !const bool.fromEnvironment('dart.vm.product'),
    initialLocation: splashRoute,
    refreshListenable: getIt<AppSession>(),
    routes: [
      GoRoute(
        name: splashRoute,
        path: splashRoute,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        name: welcomeRoute,
        path: welcomeRoute,
        builder: (context, state) => const WelcomeView(),
      ),
      GoRoute(
        name: onboardingRoute,
        path: onboardingRoute,
        builder: (context, state) =>
            BlocProvider.value(value: getIt<OnboardingCubit>(), child: const OnboardingView()),
      ),
      GoRoute(
        name: onboardingPaywallRoute,
        path: onboardingPaywallRoute,
        builder: (context, state) =>
            BlocProvider(create: (_) => getIt<PaywallCubit>(), child: const PaywallView()),
      ),
      GoRoute(
        name: authOptionsRoute,
        path: authOptionsRoute,
        builder: (context, state) =>
            BlocProvider(create: (_) => getIt<PaywallCubit>(), child: const AuthOptionsView()),
      ),
      GoRoute(
        name: signInRoute,
        path: signInRoute,
        builder: (context, state) => BlocProvider.value(
          value: getIt<SignInCubit>(),
          child: SignInView(
            showCreateAccount: state.uri.queryParameters['showCreateAccount'] != 'false',
          ),
        ),
      ),
      GoRoute(
        name: signUpRoute,
        path: signUpRoute,
        builder: (context, state) =>
            BlocProvider.value(value: getIt<SignUpCubit>(), child: const SignUpView()),
      ),
      GoRoute(
        name: otpRoute,
        path: otpRoute,
        builder: (context, state) => BlocProvider.value(
          value: getIt<OtpCubit>(),
          child: OtpView(fromRoute: state.extra is String ? state.extra as String : signUpRoute),
        ),
      ),
      GoRoute(
        name: forgotPasswordRoute,
        path: forgotPasswordRoute,
        builder: (context, state) => BlocProvider.value(
          value: getIt<ForgotPasswordCubit>(),
          child: const ForgotPasswordView(),
        ),
      ),
      GoRoute(
        name: changePasswordRoute,
        path: changePasswordRoute,
        builder: (context, state) => BlocProvider.value(
          value: getIt<ChangePasswordCubit>(),
          child: ChangePasswordView(
            code: state.uri.queryParameters['code'],
            tokenHash: state.uri.queryParameters['token_hash'],
          ),
        ),
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<CatalogCubit>(),
          child: CatalogView(session: getIt<AppSession>()),
        ),
      ),
      GoRoute(
        path: '/product/:barcode',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<CatalogCubit>()
            ..check(
              state.pathParameters['barcode'] ?? '',
              local: true,
              entryQuota: state.extra is QuotaSnapshot ? state.extra as QuotaSnapshot : null,
            ),
          child: ProductDetailView(
            session: getIt<AppSession>(),
            drafts: getIt<LabelCaptureCubit>(),
          ),
        ),
      ),
      GoRoute(
        path: '/capture-auth/:barcode',
        redirect: (context, state) {
          try {
            final code = normalizeGtin(state.pathParameters['barcode'] ?? '');
            final draft = getIt<LabelCaptureCubit>().state;
            if (draft.barcode != code || !draft.ready) return '/capture/$code';
          } catch (_) {
            return '/scan';
          }
          return null;
        },
        builder: (context, state) {
          if (!getIt<AppConfig>().features.authEnabled) {
            return Scaffold(
              appBar: AppBar(),
              body: SafeArea(child: Center(child: Text(context.l10n.pkOtpUnavailable))),
            );
          }
          return BlocProvider(
            create: (_) => getIt<EmailOtpCubit>()..check(),
            child: EmailOtpGateView(barcode: normalizeGtin(state.pathParameters['barcode']!)),
          );
        },
      ),
      GoRoute(
        path: '/capture/:barcode',
        redirect: (context, state) async {
          final draft = getIt<LabelCaptureCubit>();
          try {
            final code = normalizeGtin(state.pathParameters['barcode'] ?? '');
            await draft.begin(code);
            if (draft.state.barcode != code) return '/home';
          } catch (_) {
            return '/scan';
          }
          return null;
        },
        builder: (context, state) {
          try {
            final barcode = normalizeGtin(state.pathParameters['barcode'] ?? '');
            final draft = getIt<LabelCaptureCubit>();
            unawaited(draft.begin(barcode));
            return MultiBlocProvider(
              providers: [
                BlocProvider.value(value: draft),
                BlocProvider.value(value: getIt<AnalysisSubmissionCubit>()),
              ],
              child: CaptureEntryView(
                barcode: barcode,
                session: getIt<AppSession>(),
                entryQuota: state.extra is QuotaSnapshot ? state.extra as QuotaSnapshot : null,
              ),
            );
          } catch (_) {
            return BlocProvider(
              create: (_) => getIt<CatalogCubit>(),
              child: CatalogView(session: getIt<AppSession>()),
            );
          }
        },
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) =>
            RootView(key: state.pageKey, currentPath: state.uri.path, child: child),
        routes: [
          GoRoute(
            name: homeRoute,
            path: homeRoute,
            parentNavigatorKey: _shellNavigatorKey,
            pageBuilder: (context, state) => NoTransitionPage(
              child: BlocProvider.value(
                value: getIt<HomeCubit>(),
                child: HomeView(drafts: getIt<LabelCaptureCubit>()),
              ),
            ),
          ),
          GoRoute(
            name: settingsRoute,
            path: settingsRoute,
            parentNavigatorKey: _shellNavigatorKey,
            pageBuilder: (context, state) => NoTransitionPage(
              child: ListenableBuilder(
                listenable: getIt<AppSession>(),
                builder: (context, _) {
                  final authEnabled = getIt<AppConfig>().features.authEnabled;
                  final session = getIt<AppSession>();
                  final view = SettingsView(
                    key: ValueKey((session.userId, session.hasAuthenticatedUi)),
                    supabaseClient: authEnabled ? getIt<SupabaseClient>() : null,
                  );
                  return authEnabled
                      ? BlocProvider.value(value: getIt<SignOutCubit>(), child: view)
                      : view;
                },
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        name: notificationRoute,
        path: notificationRoute,
        builder: (context, state) =>
            BlocProvider.value(value: getIt<NotificationCubit>(), child: const NotificationView()),
      ),
      GoRoute(
        name: paywallRoute,
        path: paywallRoute,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<PaywallCubit>(),
          child: PaywallView(
            isOnboarding: false,
            showBackButton: false,
            entitlementId: state.uri.queryParameters['entitlement'],
            offeringId: state.uri.queryParameters['offering'],
          ),
        ),
      ),
      GoRoute(
        name: profileRoute,
        path: profileRoute,
        builder: (context, state) => BlocProvider.value(
          value: getIt<ProfileCubit>(),
          child: ProfileView(supabaseClient: getIt<SupabaseClient>()),
        ),
      ),
      GoRoute(
        name: termsOfUseRoute,
        path: termsOfUseRoute,
        builder: (context, state) => const SettingsTermsOfUseView(),
      ),
      GoRoute(
        name: privacyPolicyRoute,
        path: privacyPolicyRoute,
        builder: (context, state) => const SettingsPrivacyPolicyView(),
      ),
      GoRoute(
        name: settingsChangelogRoute,
        path: settingsChangelogRoute,
        builder: (context, state) => const SettingsChangelogView(),
      ),
      GoRoute(
        name: settingsAccountRoute,
        path: settingsAccountRoute,
        builder: (context, state) => BlocProvider.value(
          value: getIt<SettingsAccountCubit>(),
          child: const SettingsAccountView(),
        ),
      ),
      GoRoute(
        name: settingsNotificationsRoute,
        path: settingsNotificationsRoute,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<SettingsNotificationsCubit>()..load(),
          child: const SettingsNotificationsView(),
        ),
      ),
      GoRoute(
        name: settingsLanguageRoute,
        path: settingsLanguageRoute,
        builder: (context, state) => const SettingsLanguageView(),
      ),
      GoRoute(
        name: settingsThemeRoute,
        path: settingsThemeRoute,
        builder: (context, state) => const SettingsThemeView(),
      ),
      GoRoute(
        name: settingsDarkModeRoute,
        path: settingsDarkModeRoute,
        builder: (context, state) => const SettingsDarkModeView(),
      ),
      GoRoute(
        name: settingsSubscriptionDebugRoute,
        path: settingsSubscriptionDebugRoute,
        builder: (context, state) => const SettingsSubscriptionDebugView(),
      ),
    ],
    redirect: (context, state) {
      final session = getIt<AppSession>();
      final features = getIt<AppConfig>().features;
      final path = state.uri.path;
      final target = ConsumerRoutePolicy.redirect(
        features: features,
        isAuthenticated: session.isAuthenticated,
        debugGuestMode: session.debugGuestMode,
        recoveringPassword: session.recoveringPassword,
        onboardingCompleted: session.onboardingCompleted,
        path: path,
      );
      if (target == signInRoute) {
        AppFlowResolver.rememberRequestedLocation(state.uri);
      }
      if (path == otpRoute && state.extra is! String && !session.isAuthenticated) {
        return signUpRoute;
      }
      return target;
    },
  );
}
