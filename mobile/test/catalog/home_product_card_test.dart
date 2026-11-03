import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/config/app_config.dart';
import '../../lib/src/config/injection_container.dart';
import '../../lib/src/config/theme/_theme.dart';
import '../../lib/src/features/app/app.dart';
import '../../lib/src/features/catalog/domain/_domain.dart';
import '../../lib/src/features/catalog/presentation/widgets/catalog_widget.dart';
import '../../lib/src/features/catalog/presentation/widgets/product_card_thumbnail.dart';
import '../../lib/src/features/home/presentation/blocs/home/home_cubit.dart';
import '../../lib/src/features/home/presentation/views/home_view.dart';
import '../../lib/src/localization/l10n/app_localizations.dart';
import 'catalog_cubit_test.dart' show FakeCatalog;
import 'home_widget_test.dart' show config;

Widget host(Widget child, {double scale = 1}) => MaterialApp(
  theme: AppTheme.lightTheme(AppColorScheme.lightColorScheme),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, content) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: content!,
  ),
  home: Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(20), child: child),
      ),
    ),
  ),
);
ProductRecord product({String? name, String? brand, String? serving}) => ProductRecord(
  barcode: '00000096385074',
  name: name,
  brand: brand,
  summary: 'Synthetic test record',
  nutrition: {'serving_size': serving},
  ingredients: const {},
  findings: const [],
);
void main() {
  testWidgets('card always has title and labeled image area without barcode subtitles', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    for (final record in [product(name: '   '), product(name: 'Fixture oats', brand: ' '), null]) {
      await tester.pumpWidget(
        host(
          CatalogWidget(
            entry: RecentProduct('00000096385074', DateTime.utc(2026), product: record),
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(record?.name == 'Fixture oats' ? 'Fixture oats' : 'Food product'),
        findsOneWidget,
      );
      expect(find.byType(ProductCardThumbnail), findsOneWidget);
      final thumbnail = tester.getSize(find.byType(ProductCardThumbnail));
      expect(thumbnail.width / thumbnail.height, closeTo(5 / 4, .001));
      expect(find.bySemanticsLabel(RegExp('Product photo unavailable')), findsOneWidget);
      expect(find.text('No photo'), findsOneWidget);
      expect(find.text('00000096385074'), findsNothing);
      expect(find.text('Nutrition & ingredients'), findsNothing);
      expect(
        find.byType(Image),
        findsNothing,
        reason: 'No invented product photo or retained capture',
      );
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
    semantics.dispose();
  });
  testWidgets('card omits subtitles and the entire card remains tappable', (tester) async {
    var opened = 0;
    await tester.pumpWidget(
      host(
        CatalogWidget(
          entry: RecentProduct(
            '00000096385074',
            DateTime.utc(2026),
            product: product(name: 'Fixture oats', brand: 'Fixture brand', serving: '30 g'),
          ),
          onTap: () => opened++,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Fixture brand'), findsNothing);
    expect(find.textContaining('Serving size'), findsNothing);
    await tester.tap(find.byType(ProductCardThumbnail));
    expect(opened, 1);
    expect(tester.takeException(), isNull);
  });
  testWidgets('long titles and unknown metadata fit compact large-text cards', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 690);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      host(
        CatalogWidget(
          entry: RecentProduct(
            '00000096385074',
            DateTime.utc(2026),
            product: product(
              name: 'A very long packaged-food product name with additional descriptive words',
              brand: 'An equally long manufacturer description',
              serving: 'Two portions of 30 grams each',
            ),
          ),
          onTap: () {},
        ),
        scale: 1.6,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ProductCardThumbnail), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Home uses HugeIcons with the requested Cupertino product chevron', (tester) async {
    getIt.registerSingleton<AppConfig>(config());
    final repo = FakeCatalog()
      ..recentItems = [
        RecentProduct('00000096385074', DateTime.utc(2026), product: product(name: 'Fixture oats')),
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
    void expectHugeIcons() {
      for (final icon in tester.widgetList<Icon>(find.byType(Icon))) {
        expect(icon.icon, anyOf(CupertinoIcons.chevron_forward, CupertinoIcons.chevron_back));
      }
      for (final icon in tester.widgetList<AppIcon>(find.byType(AppIcon))) {
        if (icon.icon is IconData) {
          expect(icon.icon, anyOf(CupertinoIcons.chevron_forward, CupertinoIcons.chevron_back));
        } else {
          expect(icon.icon, isA<List<List<dynamic>>>());
        }
      }
    }

    expectHugeIcons();
    await tester.tap(find.byTooltip('Search your products'));
    await tester.pumpAndSettle();
    expectHugeIcons();
    await tester.tap(find.byTooltip('Close search'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Sort products'));
    await tester.pumpAndSettle();
    expectHugeIcons();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await home.close();
    await getIt.reset();
  });
}
