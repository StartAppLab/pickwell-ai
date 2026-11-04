import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/features/catalog/domain/entities/catalog_entity.dart';
import '../../lib/src/features/catalog/domain/entities/product_display_identity.dart';
import '../../lib/src/features/catalog/presentation/widgets/catalog_widget.dart';
import '../../lib/src/features/catalog/presentation/widgets/product_card_thumbnail.dart';
import '../../lib/src/features/catalog/presentation/widgets/product_identity_header.dart';
import '../../lib/src/features/catalog/presentation/widgets/product_result_content.dart';
import 'analysis_fixtures.dart';
import 'product_results_test.dart' show host;

ProductRecord record({
  String? brand = 'Lucky Me!',
  String? name = 'Pancit Canton',
  Object? front = const {'variant': 'Original Flavor', 'net_quantity': '60 g'},
}) {
  final fixture = resultFixture();
  return ProductRecord(
    barcode: fixture.barcode,
    brand: brand,
    name: name,
    summary: fixture.summary,
    nutrition: fixture.nutrition,
    ingredients: fixture.ingredients,
    findings: fixture.findings,
    provenance: {
      'identity': {'front': front},
    },
    explanations: fixture.explanations,
  );
}

void main() {
  test('subtitle joins only existing variant and package quantity with no dangling separators', () {
    for (final row in [
      [
        <String, Object?>{'variant': ' Original Flavor ', 'net_quantity': '60 g'},
        'Original Flavor · 60 g',
      ],
      [
        <String, Object?>{'variant': 'Original Flavor', 'net_quantity': null},
        'Original Flavor',
      ],
      [
        <String, Object?>{'variant': ' ', 'net_quantity': '60 g'},
        '60 g',
      ],
      [
        <String, Object?>{'variant': null, 'net_quantity': ' '},
        null,
      ],
    ]) {
      expect(ProductDisplayIdentity.fromProduct(record(front: row[0])).subtitle, row[1]);
    }
  });
  test('canonical identity wins; available front observations fill missing fields only', () {
    final complete = ProductDisplayIdentity.fromProduct(
      record(front: {'brand': 'Other observation', 'product_name': 'Other name'}),
    );
    expect(complete.brand, 'Lucky Me!');
    expect(complete.name, 'Pancit Canton');
    final fallback = ProductDisplayIdentity.fromProduct(
      record(
        brand: ' ',
        name: null,
        front: {'brand': ' Read brand ', 'product_name': ' Read product '},
      ),
    );
    expect(fallback.brand, 'Read brand');
    expect(fallback.name, 'Read product');
  });
  test('legacy/malformed identity never invents package quantity from nutrition serving size', () {
    for (final value in [
      null,
      'invalid',
      {},
      {
        'variant': 42,
        'net_quantity': {'value': 60},
      },
    ]) {
      final result = ProductDisplayIdentity.fromProduct(record(front: value));
      expect(result.subtitle, isNull);
      expect(result.name, 'Pancit Canton');
    }
    expect(ProductDisplayIdentity.fromProduct(null).subtitle, isNull);
  });
  for (final details in [false, true]) {
    testWidgets(
      'brand/name/subtitle ordering and thumbnail consistent in ${details ? 'Details' : 'recent product card'}',
      (tester) async {
        final p = record();
        final content = details
            ? ProductResultContent(product: p)
            : Center(
                child: CatalogWidget(
                  entry: RecentProduct(p.barcode, DateTime.utc(2026), product: p),
                  onTap: () {},
                ),
              );
        await tester.pumpWidget(host(Scaffold(body: content)));
        await tester.pumpAndSettle();
        expect(find.text('Lucky Me!'), findsOneWidget);
        expect(find.text('Pancit Canton'), findsOneWidget);
        expect(find.text('Original Flavor · 60 g'), findsOneWidget);
        expect(
          tester.getTopLeft(find.text('Lucky Me!')).dy,
          lessThan(tester.getTopLeft(find.text('Pancit Canton')).dy),
        );
        expect(
          tester.getTopLeft(find.text('Pancit Canton')).dy,
          lessThan(tester.getTopLeft(find.text('Original Flavor · 60 g')).dy),
        );
        final brand = tester.widget<Text>(find.text('Lucky Me!')),
            name = tester.widget<Text>(find.text('Pancit Canton'));
        expect(brand.style!.fontSize!, lessThan(name.style!.fontSize!));
        expect(find.byType(ProductCardThumbnail), findsOneWidget);
        expect(find.text(p.barcode), findsNothing);
        if (details) {
          await tester.scrollUntilVisible(
            find.text('About this analysis'),
            200,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.ensureVisible(find.text('About this analysis'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('About this analysis').hitTestable());
          await tester.pumpAndSettle();
          expect(
            find.byWidgetPredicate((w) => w is SelectableText && w.data == p.barcode),
            findsOneWidget,
          );
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('missing values are omitted and unresolved recent records retain honest fallback', (
    tester,
  ) async {
    for (final p in [record(brand: ' ', name: ' ', front: {}), null]) {
      await tester.pumpWidget(
        host(
          Scaffold(
            body: Center(child: ProductIdentityHeader(product: p, compact: true)),
          ),
        ),
      );
      expect(find.text('Food product'), findsOneWidget);
      expect(find.textContaining(' · '), findsNothing);
      expect(find.text('Lucky Me!'), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });
  testWidgets('long brand/name/variant/quantity wrap safely in compact scaled cards', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final p = record(
      brand: 'A very long actual brand with several descriptive terms',
      name: 'A very long product name with a detailed packaging description',
      front: {
        'variant': 'A very long original flavor description',
        'net_quantity': '12 individually wrapped packs · 720 g',
      },
    );
    await tester.pumpWidget(
      host(
        Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CatalogWidget(
                entry: RecentProduct(p.barcode, DateTime.utc(2026), product: p),
                onTap: () {},
              ),
            ),
          ),
        ),
        scale: 2,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(ProductCardThumbnail)), const Size(100, 80));
  });
}
