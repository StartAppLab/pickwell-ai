import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/config/app_config.dart';
import '../../lib/src/config/app_features.dart';
import '../../lib/src/config/injection_container.dart';
import '../../lib/src/features/catalog/data/models/catalog_model.dart';
import '../../lib/src/features/catalog/domain/entities/catalog_entity.dart';
import '../../lib/src/features/catalog/domain/entities/product_thumbnail.dart';
import '../../lib/src/features/catalog/presentation/widgets/product_card_thumbnail.dart';
import '../../lib/src/features/catalog/presentation/widgets/product_thumbnail_placeholder.dart';
import '../../lib/src/features/catalog/presentation/widgets/product_result_content.dart';
import 'analysis_fixtures.dart';
import 'product_results_test.dart' show host;

const media = ProductThumbnail(
  id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  digest: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
  width: 120,
  height: 80,
);
ProductRecord parse(Object? thumbnail) {
  final p = resultFixture();
  return CatalogModel.parse({
    'status': 'ready',
    'product': {
      'barcode': p.barcode,
      'summary': p.summary,
      'name': p.name,
      'nutrition': p.nutrition,
      'ingredients': p.ingredients,
      'findings': p.findings,
      'thumbnail': thumbnail,
    },
  }, p.barcode).product!;
}

Map<String, Object> metadata() => {
  'id': media.id,
  'digest': media.digest,
  'width': 120,
  'height': 80,
};
void main() {
  setUp(() {
    getIt.registerSingleton<AppConfig>(
      AppConfig(
        features: const AppFeatures(authMode: AuthMode.optional, backendEnabled: true),
        baseUrl: 'https://fixture.supabase.co',
        apiKey: 'public-fixture',
        sentryDsn: '',
        postHogApiKey: '',
        postHogHost: '',
        revenueCatAndroidApiKey: '',
        revenueCatiOSApiKey: '',
        revenueCatEntitlementId: '',
      ),
    );
  });
  tearDown(() async {
    await getIt.unregister<AppConfig>();
  });
  test('legacy and malformed media keep a valid product without an image', () {
    for (final value in [
      null,
      {},
      {...metadata(), 'width': 385},
      {...metadata(), 'digest': 'private/path.jpg'},
    ]) {
      expect(parse(value).thumbnail, isNull);
    }
    expect(parse(metadata()).thumbnail!.id, media.id);
  });
  test('configured public endpoint is used; server URLs cannot become image origins', () {
    final product = parse({...metadata(), 'url': 'https://attacker.invalid/private'});
    final url = Uri.parse(product.thumbnail!.url('https://project.supabase.co')!);
    expect(url.host, 'project.supabase.co');
    expect(url.path, '/functions/v1/get-product-thumbnail');
    expect(url.queryParameters, {'id': media.id, 'v': media.digest});
    expect(media.url('file:///private/photo.jpg'), isNull);
    expect(
      media.url(
        Uri(scheme: 'https', host: 'project.supabase.co', userInfo: 'fixture:fixture').toString(),
      ),
      isNull,
    );
  });
  testWidgets('legacy fallback retains 5:4 layout at large text size', (tester) async {
    await tester.pumpWidget(
      host(const Scaffold(body: Center(child: ProductCardThumbnail())), scale: 2),
    );
    expect(find.byType(Image), findsNothing);
    expect(tester.getSize(find.byType(ProductCardThumbnail)), const Size(100, 80));
    expect(find.byType(ProductThumbnailPlaceholder), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('public network failure never changes card size or exposes private imagery', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const Scaffold(
          body: Center(child: ProductCardThumbnail(thumbnail: media)),
        ),
      ),
    );
    final before = tester.getSize(find.byType(ProductCardThumbnail));
    expect(find.byType(Image), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(ProductThumbnailPlaceholder), findsOneWidget);
    expect(tester.getSize(find.byType(ProductCardThumbnail)), before);
    expect(tester.takeException(), isNull);
  });
  testWidgets('details use the same derivative fallback in an enlarged square hero', (
    tester,
  ) async {
    await tester.pumpWidget(host(Scaffold(body: ProductResultContent(product: parse(metadata())))));
    await tester.pumpAndSettle();
    expect(find.byType(ProductCardThumbnail), findsOneWidget);
    expect(tester.getSize(find.byType(ProductCardThumbnail)), const Size(184, 184));
    expect(find.byType(ProductThumbnailPlaceholder), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
