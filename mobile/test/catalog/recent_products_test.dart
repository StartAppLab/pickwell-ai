import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../lib/src/core/storage/data_storage.dart';
import '../../lib/src/features/catalog/data/data_sources/catalog_local_source.dart';
import '../../lib/src/features/catalog/data/data_sources/catalog_remote_source.dart';
import '../../lib/src/features/catalog/data/repositories/catalog_repository.dart';
import '../../lib/src/features/catalog/domain/_domain.dart';
import '../../lib/src/features/home/presentation/blocs/home/home_cubit.dart';
import 'catalog_repository_test.dart' show MemoryStorage, FakeApi, product, code;

class ControlledApi extends FakeApi {
  final requests = <(String, String)>[];
  String status = 'ready';
  bool offline = false;
  Completer<void>? pending;
  @override
  Future<Map<String, dynamic>> lookup(String barcode, String requestId) async {
    requests.add((barcode, requestId));
    if (pending != null) await pending!.future;
    if (offline) throw StateError('offline fixture');
    if (status != 'ready') return {'status': status};
    return super.lookup(barcode, requestId);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'ready result survives repository restart as references; online resolution preserves opened times',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = DataStorage(storage: prefs), api = ControlledApi();
      final first = CatalogRepositoryImpl(CatalogLocalSource(storage), CatalogRemoteSource(api));
      await first.getCatalog(barcode: code(1), requestId: createCatalogRequestId());
      await first.getCatalog(barcode: code(2), requestId: createCatalogRequestId());
      await first.getCatalog(
        barcode: code(1),
        requestId: createCatalogRequestId(),
        useMemory: true,
      );
      final saved = prefs.getString(DataStorageKeys.recentProducts)!;
      expect(jsonDecode(saved), hasLength(2));
      expect(saved, isNot(contains('PRIVATE')));
      final restarted = CatalogRepositoryImpl(
        CatalogLocalSource(DataStorage(storage: prefs)),
        CatalogRemoteSource(api),
      );
      expect(restarted.cached(code(1)), isNull);
      final before = api.requests.length;
      final rows = (await restarted.recents()).getOrElse((_) => throw StateError('failed'));
      expect(rows.map((r) => r.barcode), [code(1), code(2)]);
      expect(rows.every((r) => r.product != null), true);
      expect(api.requests.length - before, 2);
      expect(
        prefs.getString(DataStorageKeys.recentProducts),
        saved,
        reason: 'refresh is not opening',
      );
      await restarted.recents();
      expect(api.requests.length - before, 2, reason: 'loaded Home data is reused');
      await restarted.getCatalog(
        barcode: code(1),
        requestId: createCatalogRequestId(),
        useMemory: true,
      );
      expect(api.requests.length - before, 2, reason: 'local reopening uses no backend/model');
      expect((await restarted.recents()).getOrElse((_) => []).map((r) => r.barcode), [
        code(1),
        code(2),
      ]);
    },
  );

  test(
    'offline refresh keeps unavailable references, stops fan-out, and retries with same operation key',
    () async {
      final storage = MemoryStorage();
      final seed = CatalogLocalSource(storage);
      await seed.remember(product(code(1)));
      await seed.remember(product(code(2)));
      final api = ControlledApi()..offline = true;
      final repo = CatalogRepositoryImpl(CatalogLocalSource(storage), CatalogRemoteSource(api));
      final saved = storage.values[DataStorageKeys.recentProducts];
      final rows = (await repo.recents()).getOrElse((_) => []);
      expect(rows, hasLength(2));
      expect(rows.every((r) => r.product == null), true);
      expect(api.requests, hasLength(1));
      api.offline = false;
      final restored = (await repo.recents()).getOrElse((_) => []);
      expect(restored.every((r) => r.product != null), true);
      expect(api.requests[0], api.requests[1]);
      expect(storage.values[DataStorageKeys.recentProducts], saved);
    },
  );

  for (final state in ['rate_limited', 'quota_exceeded', 'error']) {
    test('$state stops refresh admission and preserves index without fake product data', () async {
      final storage = MemoryStorage();
      final local = CatalogLocalSource(storage);
      await local.remember(product(code(1)));
      await local.remember(product(code(2)));
      final api = ControlledApi()..status = state;
      final repo = CatalogRepositoryImpl(CatalogLocalSource(storage), CatalogRemoteSource(api));
      final result = (await repo.recents()).getOrElse((_) => []);
      expect(result, hasLength(2));
      expect(result.every((r) => r.product == null), true);
      expect(api.requests, hasLength(1));
    });
  }

  test(
    'miss and processing never create a published cache entry or rewrite last-opened history',
    () async {
      final storage = MemoryStorage();
      await CatalogLocalSource(storage).remember(product(code(1)));
      final saved = storage.values[DataStorageKeys.recentProducts];
      final api = ControlledApi()..status = 'not_found';
      final repo = CatalogRepositoryImpl(CatalogLocalSource(storage), CatalogRemoteSource(api));
      for (final status in ['not_found', 'processing']) {
        api.status = status;
        final result = (await repo.recents()).getOrElse((_) => []);
        expect(result.single.product, isNull);
        expect(repo.cached(code(1)), isNull);
        expect(storage.values[DataStorageKeys.recentProducts], saved);
      }
      await repo.getCatalog(barcode: code(2), requestId: createCatalogRequestId());
      expect(
        (jsonDecode(storage.values[DataStorageKeys.recentProducts] as String) as List),
        hasLength(1),
      );
    },
  );

  test(
    'search is trimmed/case insensitive and local; Food excludes unknown references; newest sorts',
    () {
      final old = RecentProduct(
        code(1),
        DateTime.utc(2026, 1),
        product: ProductRecord(
          barcode: code(1),
          name: 'Oat Cereal',
          brand: 'Fixture Brand',
          summary: '',
          nutrition: {},
          ingredients: {},
          findings: [],
        ),
      );
      final newest = RecentProduct(code(2), DateTime.utc(2026, 2));
      expect(filterRecentProducts([old, newest]), [newest, old]);
      expect(filterRecentProducts([old, newest], query: ' OAT '), [old]);
      expect(filterRecentProducts([old, newest], query: 'fixture BRAND'), [old]);
      expect(filterRecentProducts([old, newest], query: code(2)), [newest]);
      expect(filterRecentProducts([old, newest], foodOnly: true), [old]);
      expect(filterRecentProducts([old, newest], query: 'no match'), isEmpty);
    },
  );

  test(
    'concurrent Home reloads share one resolution request; closed Cubit ignores completion',
    () async {
      final storage = MemoryStorage();
      await CatalogLocalSource(storage).remember(product(code(1)));
      final api = ControlledApi()..pending = Completer();
      final repo = CatalogRepositoryImpl(CatalogLocalSource(storage), CatalogRemoteSource(api));
      final home = HomeCubit(GetRecentProductsUseCase(repo));
      final first = home.load(), second = home.load();
      await Future<void>.delayed(Duration.zero);
      expect(api.requests, hasLength(1));
      await home.close();
      api.pending!.complete();
      await Future.wait([first, second]);
    },
  );
}
