import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/config/app_config.dart';
import '../../lib/src/config/injection_container.dart';
import '../../lib/src/config/theme/_theme.dart';
import '../../lib/src/features/catalog/domain/_domain.dart';
import '../../lib/src/features/home/presentation/blocs/home/home_cubit.dart';
import '../../lib/src/features/home/presentation/views/home_view.dart';
import '../../lib/src/features/home/presentation/widgets/home_filter_bar.dart';
import '../../lib/src/localization/l10n/app_localizations.dart';
import 'catalog_cubit_test.dart' show FakeCatalog;
import 'home_widget_test.dart' show config;

RecentProduct entry(String barcode, String name, int day) => RecentProduct(
  barcode,
  DateTime.utc(2026, 11, day),
  product: ProductRecord(
    barcode: barcode,
    name: name,
    summary: 'Synthetic sorting fixture',
    nutrition: const {},
    ingredients: const {},
    findings: const [],
  ),
);

Widget host(
  Widget child, {
  Locale locale = const Locale('en'),
  double scale = 1,
  bool dark = false,
}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: dark
      ? AppTheme.darkTheme(AppColorScheme.darkColorScheme)
      : AppTheme.lightTheme(AppColorScheme.lightColorScheme),
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, content) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: content!,
  ),
  home: child,
);
void main() {
  setUp(() => getIt.registerSingleton<AppConfig>(config()));
  tearDown(() => getIt.reset());
  final records = [
    entry('banana', 'Banana', 2),
    entry('apple', ' apple ', 1),
    entry('berry', 'banana', 3),
    RecentProduct('unknown', DateTime.utc(2026, 11, 4)),
  ];
  for (final pair in [
    (RecentProductSort.newest, ['unknown', 'berry', 'banana', 'apple']),
    (RecentProductSort.oldest, ['apple', 'banana', 'berry', 'unknown']),
    (RecentProductSort.nameAscending, ['apple', 'berry', 'banana', 'unknown']),
    (RecentProductSort.nameDescending, ['berry', 'banana', 'apple', 'unknown']),
  ]) {
    test('${pair.$1} sorts references deterministically without mutating the index', () {
      final original = records.map((e) => e.barcode).toList();
      expect(filterRecentProducts(records, sort: pair.$1).map((e) => e.barcode), pair.$2);
      expect(records.map((e) => e.barcode), original);
    });
  }
  test('query and Food filtering compose with ordering; ties use barcode', () {
    expect(
      filterRecentProducts(
        records,
        foodOnly: true,
        sort: RecentProductSort.oldest,
      ).map((e) => e.barcode),
      ['apple', 'banana', 'berry'],
    );
    expect(
      filterRecentProducts(
        records,
        query: 'BANANA',
        sort: RecentProductSort.oldest,
      ).map((e) => e.barcode),
      ['banana', 'berry'],
    );
    final ties = [entry('b', 'same', 1), entry('a', 'same', 1)];
    for (final sort in RecentProductSort.values) {
      expect(filterRecentProducts(ties, sort: sort).map((e) => e.barcode), ['a', 'b']);
    }
  });
  testWidgets(
    'sort menu changes real Home ordering; search, filters and refresh preserve selection without lookups',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = FakeCatalog()
        ..recentItems = [
          entry('00036000291452', 'Banana fixture', 2),
          entry('00000096385074', 'Apple fixture', 1),
        ];
      final home = HomeCubit(GetRecentProductsUseCase(repo));
      await tester.pumpWidget(host(BlocProvider.value(value: home, child: const HomeView())));
      await tester.pumpAndSettle();
      double y(String label) => tester.getTopLeft(find.text(label)).dy;
      expect(y('Banana fixture'), lessThan(y('Apple fixture')));
      for (final option in ['Oldest', 'Name A–Z', 'Name Z–A', 'Newest']) {
        await tester.tap(find.byTooltip('Sort products'));
        await tester.pumpAndSettle();
        final selected = {
          'Oldest': RecentProductSort.oldest,
          'Name A–Z': RecentProductSort.nameAscending,
          'Name Z–A': RecentProductSort.nameDescending,
          'Newest': RecentProductSort.newest,
        }[option]!;
        await tester.tap(find.byKey(ValueKey('sort-option-${selected.name}')));
        await tester.pumpAndSettle();
        final appleFirst = option == 'Oldest' || option == 'Name A–Z';
        expect(
          y(appleFirst ? 'Apple fixture' : 'Banana fixture'),
          lessThan(y(appleFirst ? 'Banana fixture' : 'Apple fixture')),
        );
      }
      await tester.tap(find.byTooltip('Sort products'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('sort-option-oldest')));
      await tester.pumpAndSettle();
      await home.load();
      await tester.pumpAndSettle();
      expect(find.text('Oldest'), findsOneWidget);
      await tester.tap(find.byTooltip('Sort products'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 900));
      await tester.pumpAndSettle();
      expect(find.text('Oldest'), findsOneWidget, reason: 'Dismissing sort preserves selection');
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();
      expect(y('Apple fixture'), lessThan(y('Banana fixture')));
      await tester.tap(find.byTooltip('Search your products'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'banana');
      await tester.pumpAndSettle();
      expect(find.text('Apple fixture'), findsNothing);
      expect(find.text('Banana fixture'), findsOneWidget);
      await tester.tap(find.byTooltip('Close search'));
      await tester.pumpAndSettle();
      expect(y('Apple fixture'), lessThan(y('Banana fixture')));
      expect(repo.requests, isEmpty, reason: 'Sort/search/filter must never spend lookup quota');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await home.close();
    },
  );
  testWidgets('filter capsules and sort remain tappable at large text in dark and RTL layouts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 690);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final locale in [const Locale('en'), const Locale('ar'), const Locale('de')]) {
      var food = false;
      var sort = RecentProductSort.newest;
      await tester.pumpWidget(
        host(
          Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: StatefulBuilder(
                  builder: (context, setState) => HomeFilterBar(
                    foodOnly: food,
                    onFoodChanged: (value) => setState(() => food = value),
                    sort: sort,
                    onSortChanged: (value) => setState(() => sort = value),
                  ),
                ),
              ),
            ),
          ),
          locale: locale,
          dark: true,
          scale: 1.6,
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(HomeFilterBar));
      final l = AppLocalizations.of(context)!;
      await tester.tap(find.text(l.pkFood));
      await tester.pumpAndSettle();
      expect(food, true);
      final menu = find.byTooltip(l.pkSortProducts);
      expect(tester.getSize(menu).height, greaterThanOrEqualTo(48));
      await tester.tap(menu);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('sort-option-oldest')));
      await tester.pumpAndSettle();
      expect(sort, RecentProductSort.oldest);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}
