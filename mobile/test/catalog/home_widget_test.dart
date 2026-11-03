import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import '../../lib/src/config/app_config.dart';
import '../../lib/src/config/app_features.dart';
import '../../lib/src/config/router/consumer_route_policy.dart';
import '../../lib/src/config/injection_container.dart';
import '../../lib/src/config/theme/_theme.dart';
import '../../lib/src/features/catalog/domain/_domain.dart';
import '../../lib/src/features/catalog/presentation/blocs/catalog/catalog_cubit.dart';
import '../../lib/src/features/catalog/presentation/views/catalog_view.dart';
import 'package:fpdart/fpdart.dart';
import '../../lib/src/features/catalog/presentation/widgets/lookup_notice.dart';
import '../../lib/src/features/home/presentation/blocs/home/home_cubit.dart';
import '../../lib/src/features/home/presentation/views/home_view.dart';
import '../../lib/src/features/root/presentation/blocs/root/root_cubit.dart';
import '../../lib/src/features/root/presentation/views/root_view.dart';
import '../../lib/src/localization/l10n/app_localizations.dart';
import 'catalog_cubit_test.dart' show FakeCatalog;

AppConfig config() => const AppConfig(
  baseUrl: '',
  apiKey: '',
  sentryDsn: '',
  postHogApiKey: '',
  postHogHost: '',
  revenueCatAndroidApiKey: '',
  revenueCatiOSApiKey: '',
  revenueCatEntitlementId: '',
);
void main() {
  setUp(() {
    getIt.registerSingleton<AppConfig>(config());
  });
  tearDown(() async {
    await getIt.reset();
  });
  testWidgets(
    'guest empty Home has search/chips and separate far-right Scan; nested route hides dock',
    (tester) async {
      final home = HomeCubit(GetRecentProductsUseCase(FakeCatalog())), root = RootCubit();
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          ShellRoute(
            builder: (context, state, child) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: home),
                BlocProvider.value(value: root),
              ],
              child: RootView(currentPath: state.uri.path, child: child),
            ),
            routes: [
              GoRoute(path: '/home', builder: (_, _) => const HomeView()),
              GoRoute(path: '/settings', builder: (_, _) => const Scaffold()),
            ],
          ),
          GoRoute(
            path: '/scan',
            builder: (_, _) => const Scaffold(body: Text('CAMERA ROUTE')),
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.lightTheme(AppColorScheme.lightColorScheme),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Your next food find starts here'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Newest'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Chat'), findsNothing);
      expect(find.text('Recently scanned'), findsNothing);
      await tester.tap(find.byTooltip('Search your products'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      await tester.tap(find.byTooltip('Close search'));
      await tester.pumpAndSettle();
      final scan = find.byTooltip('Scan barcode');
      expect(tester.getCenter(scan).dx, greaterThan(tester.getCenter(find.text('Settings')).dx));
      await tester.tap(scan);
      await tester.pumpAndSettle();
      expect(find.text('CAMERA ROUTE'), findsOneWidget);
      expect(find.text('Settings'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
      await home.close();
      await root.close();
    },
  );
  testWidgets('local ready-product cards search only loaded records', (tester) async {
    final semantics = tester.ensureSemantics();
    final repo = FakeCatalog()
      ..recentItems = [
        RecentProduct(
          '00000096385074',
          DateTime.utc(2026),
          product: const ProductRecord(
            barcode: '00000096385074',
            name: 'Fixture cereal',
            brand: 'Fixture brand',
            summary: 'Synthetic',
            nutrition: {},
            ingredients: {},
            findings: [],
          ),
        ),
      ];
    final home = HomeCubit(GetRecentProductsUseCase(repo));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme(AppColorScheme.lightColorScheme),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider.value(value: home, child: const HomeView()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Fixture cereal'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Product photo unavailable')), findsOneWidget);
    await tester.tap(find.byTooltip('Search your products'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'unrelated');
    await tester.pumpAndSettle();
    expect(find.text('No matching products'), findsOneWidget);
    expect(repo.requests, isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
    await home.close();
    semantics.dispose();
  });
  testWidgets(
    'unavailable recents stay truthful; Food filters unknown references and refresh retries',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = FakeCatalog()
        ..recentItems = [
          RecentProduct('00000096385074', DateTime.utc(2026, 2)),
          RecentProduct(
            '00036000291452',
            DateTime.utc(2026, 1),
            product: const ProductRecord(
              barcode: '00036000291452',
              name: 'Loaded cereal',
              summary: 'Fixture only',
              nutrition: {},
              ingredients: {},
              findings: [],
            ),
          ),
        ];
      final home = HomeCubit(GetRecentProductsUseCase(repo));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme(AppColorScheme.lightColorScheme),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider.value(value: home, child: const HomeView()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('00000096385074'), findsOneWidget);
      expect(find.textContaining('Check your connection'), findsOneWidget);
      expect(find.text('Loaded cereal'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('00000096385074')).dy,
        lessThan(tester.getTopLeft(find.text('Loaded cereal')).dy),
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image != const AssetImage('assets/images/pickwell_lemon.png'),
        ),
        findsNothing,
        reason: 'Only supplied brand art is allowed; no invented product images',
      );
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();
      expect(find.text('00000096385074'), findsNothing);
      expect(find.text('Loaded cereal'), findsOneWidget);
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      expect(find.text('00000096385074'), findsOneWidget);
      repo.recentItems = [];
      final refresh = tester.state<RefreshIndicatorState>(find.byType(RefreshIndicator));
      final pending = refresh.show();
      await tester.pumpAndSettle();
      await pending;
      expect(find.text('Your next food find starts here'), findsOneWidget);
      expect(repo.requests, isEmpty, reason: 'Search/filter widgets never issue a lookup');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await home.close();
    },
  );
  testWidgets('camera permission notice exposes recovery and keeps readable text', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme(AppColorScheme.lightColorScheme),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LookupNotice(
            status: LookupStatus.denied,
            error: 'camera',
            retry: () => retried = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Allow camera access'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(retried, true);
  });
  test('optional-auth policy leaves scanner, details and capture guest-capable', () {
    for (final path in ['/home', '/scan', '/product/00000096385074', '/capture/00000096385074']) {
      expect(
        ConsumerRoutePolicy.redirect(
          features: const AppFeatures(authMode: AuthMode.optional),
          isAuthenticated: false,
          recoveringPassword: false,
          onboardingCompleted: true,
          path: path,
        ),
        isNull,
      );
    }
  });
  for (final status in [LookupStatus.found, LookupStatus.miss]) {
    testWidgets('scanner navigates $status to the correct nested destination', (tester) async {
      final repo = FakeCatalog()
        ..result = Right(CatalogEntity(status: status, barcode: '00000096385074'));
      final cubit = CatalogCubit(GetCatalogUseCase(repo));
      final router = GoRouter(
        initialLocation: '/scan',
        routes: [
          GoRoute(
            path: '/scan',
            builder: (_, _) => BlocProvider.value(value: cubit, child: const CatalogView()),
          ),
          GoRoute(
            path: '/product/:barcode',
            builder: (_, _) => const Scaffold(body: Text('PRODUCT DESTINATION')),
          ),
          GoRoute(
            path: '/capture/:barcode',
            builder: (_, _) => const Scaffold(body: Text('CAPTURE DESTINATION')),
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.lightTheme(AppColorScheme.lightColorScheme),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
      await tester.pumpAndSettle();
      await cubit.check('96385074');
      await tester.pumpAndSettle();
      expect(
        find.text(status == LookupStatus.found ? 'PRODUCT DESTINATION' : 'CAPTURE DESTINATION'),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
      await cubit.close();
    });
  }
  testWidgets('compact Home handles large text in light and dark themes', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final home = HomeCubit(GetRecentProductsUseCase(FakeCatalog()));
    for (final theme in [
      AppTheme.lightTheme(AppColorScheme.lightColorScheme),
      AppTheme.darkTheme(AppColorScheme.darkColorScheme),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: BlocProvider.value(value: home, child: const HomeView()),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await home.close();
  });
}
