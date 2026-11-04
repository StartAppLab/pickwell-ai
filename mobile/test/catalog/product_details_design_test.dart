import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import '../../lib/src/features/catalog/presentation/widgets/product_result_header.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import '../../lib/src/features/catalog/domain/_domain.dart';
import '../../lib/src/features/catalog/presentation/views/product_detail_view.dart';
import '../../lib/src/features/catalog/presentation/blocs/catalog/catalog_cubit.dart';
import 'catalog_cubit_test.dart' show FakeCatalog;
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/features/catalog/presentation/widgets/product_result_content.dart';
import '../../lib/src/features/catalog/presentation/widgets/product_nutrition_panel.dart';
import '../../lib/src/features/catalog/presentation/widgets/product_section.dart';
import 'product_results_test.dart' show host;

// Explicit layout fixture only, never saved to a catalog or used as product evidence.
ProductRecord fixture({bool addedOnly = false}) => ProductRecord(
  barcode: '00000096385074',
  name: 'Layout fixture',
  brand: 'Example brand',
  isDemo: true,
  summary: 'Synthetic display fixture for label information. Not a real product analysis.',
  ingredients: {
    'raw': 'Oats, milk.',
    'items': ['Oats', 'Milk'],
    'declared_allergens': 'Contains milk.',
  },
  nutrition: {
    'raw': 'Synthetic nutrition fixture',
    'basis': 'per_serving',
    'serving_size': '170 g',
    'nutrients': [
      {'name': 'Energy', 'value': 120, 'unit': 'kcal'},
      {'name': addedOnly ? 'Added sugars' : 'Total sugars', 'value': 6, 'unit': 'g'},
      {'name': 'Sodium', 'value': 55, 'unit': 'mg'},
      {'name': 'Protein', 'value': 12, 'unit': 'g'},
      {'name': 'Vitamin D', 'value': 80, 'unit': 'IU'},
    ],
  },
  findings: [],
  modelVersion: 'fixture:model',
  rulesVersion: 'fixture:rules',
);
void main() {
  setUpAll(() async {
    await (FontLoader(
      'Manrope',
    )..addFont(rootBundle.load('assets/fonts/Manrope/Manrope-Regular.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    await (FontLoader(
      'packages/cupertino_icons/CupertinoIcons',
    )..addFont(rootBundle.load('packages/cupertino_icons/assets/CupertinoIcons.ttf'))).load();
  });
  testWidgets(
    'reference hierarchy shows larger photo and rounded cards with technical detail hidden',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final boundary = GlobalKey();
      final repo = FakeCatalog()
        ..result = Right(
          CatalogEntity(status: LookupStatus.found, barcode: fixture().barcode, product: fixture()),
        );
      final cubit = CatalogCubit(GetCatalogUseCase(repo));
      await cubit.check(fixture().barcode, local: true);
      addTearDown(cubit.close);
      await tester.pumpWidget(
        host(
          RepaintBoundary(
            key: boundary,
            child: BlocProvider.value(value: cubit, child: const ProductDetailView()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Layout fixture'), findsOneWidget);
      expect(find.text('fixture:model'), findsNothing);
      expect(find.text('00000096385074'), findsNothing);
      expect(find.text('92/100'), findsNothing);
      expect(find.text('Add to List'), findsNothing);
      final card = tester.widget<Card>(
        find.descendant(of: find.byType(ProductSection).first, matching: find.byType(Card)),
      );
      expect(card.shape, isA<RoundedRectangleBorder>());
      final image = boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final rendered = await image.toImage(pixelRatio: 2);
        final bytes = await rendered.toByteData(format: ui.ImageByteFormat.png);
        await File('../.secrets/product-details-ui.png').writeAsBytes(bytes!.buffer.asUint8List());
        rendered.dispose();
      });
    },
  );
  testWidgets('edge-to-edge results clear system insets and scroll beneath usable controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = FakeCatalog()
      ..result = Right(
        CatalogEntity(status: LookupStatus.found, barcode: fixture().barcode, product: fixture()),
      );
    final cubit = CatalogCubit(GetCatalogUseCase(repo));
    addTearDown(cubit.close);
    await cubit.check(fixture().barcode, local: true);
    await tester.pumpWidget(
      host(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(390, 844),
            padding: EdgeInsets.only(top: 24, bottom: 34),
            viewPadding: EdgeInsets.only(top: 24, bottom: 34),
          ),
          child: BlocProvider.value(value: cubit, child: const ProductDetailView()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final viewport = find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable));
    expect(tester.getRect(viewport).top, 0);
    expect(tester.getRect(viewport).bottom, 844);
    expect(tester.getTopLeft(find.byType(ProductResultHeader)).dy, greaterThanOrEqualTo(80));
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.systemOverlayStyle!.systemNavigationBarColor, Colors.transparent);
    expect(appBar.systemOverlayStyle!.systemNavigationBarContrastEnforced, false);
    final back = find.ancestor(
      of: find.byIcon(CupertinoIcons.chevron_back),
      matching: find.byType(IconButton),
    );
    expect(tester.getRect(back).left, 16);
    expect(tester.getRect(back).top, greaterThanOrEqualTo(32));
    expect(tester.getSize(back).width, greaterThanOrEqualTo(48));
    expect(tester.getSize(back).height, greaterThanOrEqualTo(48));
    await tester.drag(find.byType(ListView), const Offset(0, -160));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byType(ProductResultHeader)).dy, lessThan(80));
    await tester.tap(find.byIcon(CupertinoIcons.ellipsis));
    await tester.pumpAndSettle();
    expect(find.text('Copy barcode').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'compact highlights preserve printed units and keep micronutrients available on expansion',
    (tester) async {
      final p = fixture();
      await tester.pumpWidget(
        host(
          Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ProductNutritionPanel(nutrition: p.nutrition, explanations: const []),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final text in ['120 kcal', '6 g', '55 mg', '12 g']) {
        expect(find.text(text), findsOneWidget);
      }
      expect(find.text('Vitamin D'), findsNothing);
      await tester.tap(find.text('All nutrition facts'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Vitamin D'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('80 IU'), findsOneWidget);
    },
  );
  testWidgets('added sugar is never substituted for missing total sugar', (tester) async {
    await tester.pumpWidget(
      host(
        Scaffold(
          body: ProductNutritionPanel(
            nutrition: fixture(addedOnly: true).nutrition,
            explanations: const [],
          ),
        ),
      ),
    );
    expect(find.text('Unknown'), findsOneWidget);
    expect(find.text('6 g'), findsNothing);
  });
  for (final dark in [false, true]) {
    testWidgets('compact screen and large text keep findings and allergens readable dark=$dark', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        host(
          Scaffold(body: ProductResultContent(product: fixture())),
          dark: dark,
          scale: 2,
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Contains milk.'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.text('All nutrition facts'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
