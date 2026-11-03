import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/config/_config.dart';
import 'src/core/_core.dart';
import 'src/features/_features.dart';
import 'src/localization/_localization.dart';
import 'src/resources/_resources.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  void fail(Object error, StackTrace stackTrace) {
    AppLogger.logError(error, stackTrace: stackTrace);
    FlutterNativeSplash.remove();
    runApp(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  kDebugMode
                      ? 'Unable to start the app. Check configuration and restart.\n${AppLogger.sanitize(error.toString())}'
                      : 'Unable to start the app. Please restart and try again.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> launch() async {
    try {
      // Keep both system bars visible while rendering behind them on Android,
      // including devices older than Android 15's edge-to-edge default.
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      await _bootstrapApplication();
      runApp(const PickwellApp());
    } catch (error, stackTrace) {
      fail(error, stackTrace);
    }
  }

  try {
    AppFlavor.config = setupFlavorConfig();
    AppFlavor.config.validate();
    if (AppFlavor.config.features.crashReportingEnabled) {
      await SentryFlutter.init((options) {
        options.dsn = AppFlavor.config.sentryDsn;
        options.environment = AppFlavor.config.flavor.name;
        options.sendDefaultPii = false;
        options.tracesSampleRate = AppFlavor.config.flavor == Flavor.prod ? 0.1 : 1.0;
      }, appRunner: launch);
    } else {
      await launch();
    }
  } catch (error, stackTrace) {
    fail(error, stackTrace);
  }
}

Future<void> _bootstrapApplication() async {
  final config = AppFlavor.config;
  config.validate();
  if (config.features.backendEnabled) {
    await Supabase.initialize(
      url: config.baseUrl,
      publishableKey: config.apiKey,
      authOptions: FlutterAuthClientOptions(
        persistSession: config.features.authEnabled,
        detectSessionInUri: config.features.authEnabled,
        autoRefreshToken: config.features.authEnabled,
      ),
      storageOptions: const StorageClientOptions(retryAttempts: 3),
    );
  }
  await configureDependencies();
  try {
    // Sweep previous-process label drafts even when this launch only opens Home.
    await getIt<CaptureLabelUseCase>().prepare();
  } catch (_) {
    // Capture retries initialization and fails closed with a local cleanup error.
    // A temporary cache failure must not block public cached-product browsing.
  }
  await getIt<AppSession>().init(config.features.backendEnabled ? getIt<SupabaseClient>() : null);
  if (config.features.analyticsEnabled) {
    final posthog = PostHogConfig(config.postHogApiKey)
      ..host = config.postHogHost
      ..debug = config.flavor != Flavor.prod
      ..captureApplicationLifecycleEvents = config.flavor == Flavor.prod;
    await Posthog().setup(posthog);
  }
  if (config.features.billingEnabled) {
    try {
      await getIt<BillingClient>().init(
        apiKey: config.revenueCatApiKeyForCurrentPlatform,
        userId: getIt<AppSession>().userId,
      );
    } catch (error, stackTrace) {
      // The app remains usable while billing is unavailable; paid actions show retry.
      AppLogger.logError(error, stackTrace: stackTrace);
    }
  }
  await Future.wait([
    getIt<SettingsCubit>().init(),
    if (config.features.onboardingEnabled) getIt<OnboardingCubit>().init(),
    NotificationManager.init(enabled: config.features.notificationsEnabled),
  ]);
  // Subscription updates can schedule reminders and must wait for notification setup.
  await getIt<SubscriptionCubit>().init(userId: getIt<AppSession>().userId);
}

AppFlavor setupFlavorConfig() {
  final flavor = const String.fromEnvironment('APP_ENVIRONMENT', defaultValue: 'dev').toLowerCase();
  switch (flavor) {
    case 'dev':
      return const AppFlavor.dev();
    case 'stg':
      return const AppFlavor.stg();
    case 'prod':
      return const AppFlavor.prod();
    default:
      throw Exception('Unknown flavor: $flavor');
  }
}

class PickwellApp extends StatefulWidget {
  const PickwellApp({super.key});

  @override
  State<PickwellApp> createState() => _PickwellAppState();
}

class _PickwellAppState extends State<PickwellApp> with WidgetsBindingObserver {
  StreamSubscription<AuthState>? _authStateSubscription;
  bool _didPrecache = false;
  Timer? _splashTimer;
  Future<void> _authQueue = Future.value();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initSubscriptionHandling();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecache) return;
    _didPrecache = true;
    unawaited(_prepareInitialAssets());
  }

  Future<void> _prepareInitialAssets() async {
    try {
      await _precacheInitialAssets(context);
    } catch (error, stackTrace) {
      AppLogger.logError(error, stackTrace: stackTrace);
    } finally {
      if (mounted) {
        _splashTimer = Timer(const Duration(milliseconds: 100), FlutterNativeSplash.remove);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _splashTimer?.cancel();
    unawaited(_authStateSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<SubscriptionCubit>()),
        BlocProvider.value(value: getIt<SettingsCubit>()),
        BlocProvider.value(value: getIt<RootCubit>()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (previous, current) =>
            previous.localeState != current.localeState ||
            previous.themeState != current.themeState ||
            previous.themeMode != current.themeMode,
        builder: (context, state) {
          final defaultLightTheme = ThemeState.themes.first.lightTheme;
          final defaultDarkTheme = ThemeState.themes.first.darkTheme;
          const defaultThemeMode = ThemeMode.system;
          return MaterialApp.router(
            title: getIt<AppConfig>().appName,
            debugShowCheckedModeBanner: false, // AppFlavor.config.flavor != Flavor.prod,
            localizationsDelegates: AppLocale.localizationsDelegates,
            supportedLocales: AppLocale.supportedLocales,
            locale: state.localeState?.locale,
            theme: state.themeState?.lightTheme ?? defaultLightTheme,
            darkTheme: state.themeState?.darkTheme ?? defaultDarkTheme,
            themeMode: state.themeMode ?? defaultThemeMode,
            builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
              value: AppTheme.systemOverlayStyle(Theme.of(context).brightness),
              child: child ?? const SizedBox.shrink(),
            ),
            routerConfig: AppRouter.routerConfig,
          );
        },
      ),
    );
  }

  Future<void> _precacheInitialAssets(BuildContext context) async {
    final svgCache = getIt<SvgCache>();
    await Future.wait([
      AssetImage(AppAssets.images.appIcon.path).precache(context),
      svgCache.precache(AppAssets.icons.icApple.path, context),
      svgCache.precache(AppAssets.icons.icGoogle.path, context),
    ]);
  }

  void _initSubscriptionHandling() {
    if (!getIt<AppConfig>().features.authEnabled) return;
    final client = getIt<SupabaseClient>();
    _authStateSubscription = client.auth.onAuthStateChange.listen(
      (event) {
        if (event.event == AuthChangeEvent.signedIn) {
          _queueAuthUpdate(event.session?.user.id);
        } else if (event.event == AuthChangeEvent.signedOut) {
          _queueAuthUpdate(null);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        AppLogger.logError(error, stackTrace: stackTrace);
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(getIt<SubscriptionCubit>().refresh());
  }

  void _queueAuthUpdate(String? userId) {
    _authQueue = _authQueue
        .then((_) async {
          if (!mounted) return;
          final cubit = getIt<SubscriptionCubit>();
          if (userId == null) {
            await cubit.onSignedOut();
          } else {
            await cubit.onSignedIn(userId);
          }
        })
        .catchError((Object error, StackTrace stackTrace) {
          AppLogger.logError(error, stackTrace: stackTrace);
        });
  }
}
