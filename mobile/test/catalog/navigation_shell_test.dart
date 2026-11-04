import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import '../../lib/src/config/app_config.dart';
import '../../lib/src/config/injection_container.dart';
import '../../lib/src/config/theme/_theme.dart';
import '../../lib/src/features/root/presentation/blocs/root/root_cubit.dart';
import '../../lib/src/features/root/presentation/views/root_view.dart';
import '../../lib/src/localization/l10n/app_localizations.dart';
import 'home_widget_test.dart' show config;

void main() {
  setUp(() => getIt.registerSingleton<AppConfig>(config()));
  tearDown(() => getIt.reset());

  testWidgets('hidden dock keeps the guest scan action on Home only', (tester) async {
    final root = RootCubit();
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        ShellRoute(
          builder: (context, state, child) => BlocProvider.value(
            value: root,
            child: RootView(currentPath: state.uri.path, showNavigation: false, child: child),
          ),
          routes: [
            GoRoute(
              path: '/home',
              builder: (_, _) => const Scaffold(body: Text('Home fixture')),
            ),
            GoRoute(
              path: '/settings',
              builder: (_, _) => const Scaffold(body: Text('Settings fixture')),
            ),
          ],
        ),
        GoRoute(
          path: '/scan',
          builder: (_, _) => const Scaffold(body: Text('Scanner opened')),
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
    expect(find.text('Home fixture'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
    expect(find.text('Settings'), findsNothing);
    expect(find.byKey(const ValueKey('navigation-selector')), findsNothing);
    final scan = find.byTooltip('Scan barcode');
    expect(scan.hitTestable(), findsOneWidget);
    expect(tester.getCenter(scan).dx, greaterThan(tester.getSize(find.byType(RootView)).width / 2));
    await tester.tap(scan);
    await tester.pumpAndSettle();
    expect(find.text('Scanner opened'), findsOneWidget);
    expect(find.byType(RootView), findsNothing);
    router.go('/settings');
    await tester.pumpAndSettle();
    expect(find.text('Settings fixture'), findsOneWidget);
    expect(scan, findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
    await root.close();
  });

  for (final reducedMotion in [false, true]) {
    testWidgets(
      'selector remains edge-aligned and moves across shell routes; reduced motion=$reducedMotion',
      (tester) async {
        final root = RootCubit();
        final router = GoRouter(
          initialLocation: '/home',
          routes: [
            ShellRoute(
              builder: (context, state, child) => BlocProvider.value(
                value: root,
                child: RootView(key: state.pageKey, currentPath: state.uri.path, child: child),
              ),
              routes: [
                GoRoute(
                  name: '/home',
                  path: '/home',
                  builder: (_, _) => const Scaffold(body: Text('Home content fixture')),
                ),
                GoRoute(
                  name: '/settings',
                  path: '/settings',
                  builder: (_, _) => const Scaffold(body: Text('Settings content fixture')),
                ),
              ],
            ),
          ],
        );
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.lightTheme(AppColorScheme.lightColorScheme),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: reducedMotion),
              child: child!,
            ),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        );
        await tester.pumpAndSettle();
        final selector = find.byKey(const ValueKey('navigation-selector'));
        final shell = find.ancestor(of: selector, matching: find.byType(ClipRRect)).first;
        final start = tester.getRect(selector), bounds = tester.getRect(shell);
        expect(start.top - bounds.top, closeTo(0.5, 0.1));
        expect(start.left - bounds.left, closeTo(0.5, 0.1));
        expect(bounds.bottom - start.bottom, closeTo(0.5, 0.1));
        final shellState = tester.state(find.byType(RootView));
        await tester.tap(find.text('Settings'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        final during = tester.getRect(selector);
        if (reducedMotion) {
          expect(during.left, closeTo(start.left + start.width, 0.1));
        } else {
          expect(during.left, greaterThan(start.left));
          expect(during.left, lessThan(start.left + start.width));
        }
        await tester.pumpAndSettle();
        expect(tester.state(find.byType(RootView)), same(shellState));
        final end = tester.getRect(selector);
        expect(end.left, closeTo(start.left + start.width, 0.1));
        expect(bounds.right - end.right, closeTo(0.5, 0.1));
        expect(find.text('Settings content fixture'), findsOneWidget);
        await tester.tap(find.text('Home'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        if (!reducedMotion) {
          expect(tester.getRect(selector).left, inExclusiveRange(start.left, end.left));
        }
        await tester.pumpAndSettle();
        expect(tester.getRect(selector).left, closeTo(start.left, 0.1));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        router.dispose();
        await root.close();
      },
    );
  }

  for (final brightness in [Brightness.light, Brightness.dark]) {
    testWidgets(
      'navigation stays transparent with/without AppBar and after keyboard recovery: $brightness',
      (tester) async {
        final theme = brightness == Brightness.light
            ? AppTheme.lightTheme(AppColorScheme.lightColorScheme)
            : AppTheme.darkTheme(AppColorScheme.darkColorScheme);
        final style = AppTheme.systemOverlayStyle(brightness);
        for (final appBar in [true, false, true, false]) {
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
                value: AppTheme.systemOverlayStyle(Theme.of(context).brightness),
                child: child!,
              ),
              home: Scaffold(
                appBar: appBar ? AppBar(title: const Text('Nested page fixture')) : null,
                body: const TextField(),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.showKeyboard(find.byType(TextField));
          await tester.pump();
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pumpAndSettle();
          final emitted = SystemChrome.latestStyle!;
          expect(emitted.systemNavigationBarColor, Colors.transparent);
          expect(emitted.systemNavigationBarDividerColor, Colors.transparent);
          expect(emitted.systemNavigationBarContrastEnforced, false);
          expect(
            emitted.systemNavigationBarIconBrightness,
            brightness == Brightness.light ? Brightness.dark : Brightness.light,
          );
          expect(emitted.statusBarColor, Colors.transparent);
          expect(theme.appBarTheme.systemOverlayStyle, style);
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
