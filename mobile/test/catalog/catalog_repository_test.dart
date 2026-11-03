import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/storage/data_storage.dart';
import '../../lib/src/features/catalog/data/data_sources/catalog_local_source.dart';
import '../../lib/src/features/catalog/data/data_sources/catalog_remote_source.dart';
import '../../lib/src/features/catalog/data/data_sources/services/catalog_api_service.dart';
import '../../lib/src/features/catalog/data/models/catalog_model.dart';
import '../../lib/src/features/catalog/data/repositories/catalog_repository.dart';
import '../../lib/src/features/catalog/domain/entities/catalog_entity.dart';

class MemoryStorage implements DataStorage {
  final values = <String, Object>{};
  bool fail = false;
  @override
  Future<Object?> read(String key) async => values[key];
  @override
  Future<bool?> write(String key, Object data) async {
    if (fail) return false;
    values[key] = data;
    return true;
  }

  @override
  Future<bool?> remove(String key) async {
    values.remove(key);
    return true;
  }

  @override
  Future<bool?> removeAll() async {
    values.clear();
    return true;
  }
}

class FakeApi implements CatalogApiService {
  int calls = 0;
  bool miss = false;
  @override
  Future<Map<String, dynamic>> lookup(String barcode, String requestId) async {
    calls++;
    if (miss) return {'status': 'not_found'};
    return {
      'status': 'ready',
      'product': {
        'barcode': barcode,
        'name': 'PRIVATE',
        'summary': 'PRIVATE',
        'nutrition': {'raw': 'PRIVATE', 'basis': 'per_100g', 'nutrients': []},
        'ingredients': {
          'raw': 'PRIVATE',
          'items': ['oats'],
          'declared_allergens': null,
        },
        'findings': [],
      },
    };
  }
}

String code(int n) {
  final base = '29${n.toString().padLeft(10, '0')}';
  var sum = 0;
  for (var i = 0; i < 12; i++) {
    sum += int.parse(base[11 - i]) * (i.isEven ? 3 : 1);
  }
  return normalizeGtin('$base${(10 - sum % 10) % 10}');
}

ProductRecord product(String barcode) => ProductRecord(
  barcode: barcode,
  summary: 'PRIVATE',
  nutrition: const {},
  ingredients: const {},
  findings: const [],
);
void main() {
  test(
    'local index is bounded/deduplicated and persists references only under concurrent writes',
    () async {
      final storage = MemoryStorage(), local = CatalogLocalSource(MemoryStorage());
      final source = CatalogLocalSource(storage);
      await Future.wait(List.generate(35, (n) => source.remember(product(code(n)))));
      expect((await source.load()).length, 30);
      expect(source.products.length, 30);
      await source.remember(product(code(34)));
      expect((await source.load()).length, 30);
      final raw = storage.values[DataStorageKeys.recentProducts] as String;
      expect(raw, isNot(contains('PRIVATE')));
      for (final row in jsonDecode(raw) as List) {
        expect((row as Map).keys.toSet(), {'barcode', 'opened_at'});
      }
      expect(await local.load(), isEmpty);
    },
  );
  test('malformed stored data recovers to empty and malformed entries are ignored', () async {
    final s = MemoryStorage();
    final local = CatalogLocalSource(s);
    s.values[DataStorageKeys.recentProducts] = 'broken';
    expect(await local.load(), isEmpty);
    s.values[DataStorageKeys.recentProducts] = jsonEncode([
      {'barcode': 'bad', 'opened_at': 'bad'},
    ]);
    expect(await local.load(), isEmpty);
  });
  test(
    'new scan always calls backend; explicitly reopening current result avoids a lookup',
    () async {
      final storage = MemoryStorage(), api = FakeApi();
      final repo = CatalogRepositoryImpl(CatalogLocalSource(storage), CatalogRemoteSource(api));
      await repo.getCatalog(barcode: '96385074', requestId: 'first');
      await repo.getCatalog(barcode: '96385074', requestId: 'second');
      expect(api.calls, 2);
      final cached = await repo.getCatalog(
        barcode: '96385074',
        requestId: 'third',
        useMemory: true,
      );
      expect(cached.isRight(), true);
      expect(api.calls, 2);
    },
  );
  test(
    'optional persistence failure preserves successful published result and is surfaced',
    () async {
      final storage = MemoryStorage()..fail = true;
      final repo = CatalogRepositoryImpl(
        CatalogLocalSource(storage),
        CatalogRemoteSource(FakeApi()),
      );
      final result = await repo.getCatalog(barcode: '96385074', requestId: 'fixture');
      expect(result.isRight(), true);
      expect(result.getOrElse((_) => throw StateError('unexpected')).recentSaved, false);
    },
  );
  test('readable nutrition with unknown basis and amounts remains displayable', () async {
    final json = await FakeApi().lookup('00000096385074', 'test');
    final product = json['product'] as Map<String, dynamic>;
    product['nutrition'] = {
      'raw': 'Nutrition facts Protein unclear',
      'basis': 'unknown',
      'serving_size': null,
      'nutrients': [
        {'name': 'Protein', 'value': null, 'unit': 'g', 'source': null},
      ],
    };
    final result = CatalogModel.parse(json, '00000096385074');
    expect(result.status, LookupStatus.found);
    expect(result.product!.nutrition['basis'], 'unknown');
    expect((result.product!.nutrition['nutrients'] as List).first['value'], isNull);
  });
  test('printed vitamin and daily-value units survive catalog parsing', () async {
    final json = await FakeApi().lookup('00000096385074', 'test');
    final nutrition = (json['product'] as Map)['nutrition'] as Map;
    for (final unit in ['IU', 'ug RAE', 'ug DFE', 'mg NE', 'mg α-TE', '%', '%DV']) {
      nutrition['nutrients'] = [
        {'name': 'Vitamin D', 'value': 71, 'unit': unit, 'source': 'Printed fixture'},
      ];
      final result = CatalogModel.parse(json, '00000096385074');
      final nutrient = (result.product!.nutrition['nutrients'] as List).single;
      expect(nutrient['value'], 71);
      expect(nutrient['unit'], unit);
    }
  });
  test('interpretation metadata parses while malformed reference URLs are rejected', () async {
    final json = await FakeApi().lookup('00000096385074', 'test');
    final product = json['product'] as Map;
    product['explanations'] = [
      {
        'photo': 'ingredients',
        'source': 'Lecithin',
        'text': 'Keeps ingredients mixed.',
        'ingredient': 'Lecithin',
        'kind': 'background',
        'references': [
          {'id': 'fda-ingredients', 'title': 'FDA reference', 'url': 'https://www.fda.gov/food/'},
        ],
      },
    ];
    product['provenance'] = {'interpretation_version': 'evidence-composition-v1'};
    final parsed = CatalogModel.parse(json, '00000096385074');
    expect(parsed.product!.explanations.single['kind'], 'background');
    expect(parsed.product!.provenance['interpretation_version'], 'evidence-composition-v1');
    ((product['explanations'] as List).single['references'] as List).single['url'] =
        'javascript:bad';
    expect(() => CatalogModel.parse(json, '00000096385074'), throwsFormatException);
  });
  test('DTO parser rejects unknown/mismatched products and preserves denial/reset metadata', () {
    expect(
      () => CatalogModel.parse({'status': 'invented'}, '00000096385074'),
      throwsFormatException,
    );
    expect(
      () => CatalogModel.parse({
        'status': 'ready',
        'product': {'barcode': 'other'},
      }, '00000096385074'),
      throwsFormatException,
    );
    final result = CatalogModel.parse({
      'status': 'quota_exceeded',
      'quota': {
        'limit': 20,
        'remaining': 0,
        'used': 25,
        'reserved': 0,
        'version': 2,
        'reset_at': '2026-11-03T00:00:00Z',
      },
    }, '00000096385074');
    expect(result.status, LookupStatus.denied);
    expect(result.quota!.limit, 20);
  });
  test('a fresh miss evicts a previously loaded published result', () async {
    final api = FakeApi(), local = CatalogLocalSource(MemoryStorage());
    final repo = CatalogRepositoryImpl(local, CatalogRemoteSource(api));
    await repo.getCatalog(barcode: '96385074', requestId: 'ready');
    expect(repo.cached('00000096385074'), isNotNull);
    api.miss = true;
    await repo.getCatalog(barcode: '96385074', requestId: 'fresh');
    expect(repo.cached('00000096385074'), isNull);
  });
}
