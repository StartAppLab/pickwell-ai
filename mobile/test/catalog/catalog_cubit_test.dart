import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import '../../lib/src/core/errors/_errors.dart';
import '../../lib/src/features/catalog/domain/_domain.dart';
import '../../lib/src/features/catalog/presentation/blocs/catalog/catalog_cubit.dart';

class FakeCatalog extends CatalogRepository {
  final requests = <(String, String, bool)>[];
  Either<Failure, CatalogEntity> result = const Right(
    CatalogEntity(status: LookupStatus.miss, barcode: '00000096385074'),
  );
  Completer<Either<Failure, CatalogEntity>>? pending;
  List<RecentProduct> recentItems = [];
  @override
  Future<Either<Failure, CatalogEntity>> getCatalog({
    required String barcode,
    required String requestId,
    bool useMemory = false,
  }) {
    requests.add((barcode, requestId, useMemory));
    return pending?.future ?? Future.value(result);
  }

  @override
  ProductRecord? cached(String barcode) => null;
  @override
  Future<Either<Failure, List<RecentProduct>>> recents() async => Right(recentItems);
}

void main() {
  test('EAN/UPC aliases, EAN8 and explicit UPC-E expansion retain check-digit validation', () {
    expect(normalizeGtin('036000291452'), '00036000291452');
    expect(normalizeGtin('0036000291452'), '00036000291452');
    expect(normalizeGtin('96385074'), '00000096385074');
    expect(normalizeGtin('04252614', upce: true), '00042100005264');
    for (final raw in ['96385075', '12', 'ABC12345', '00042100005265']) {
      expect(() => normalizeGtin(raw), throwsFormatException);
    }
  });
  test('camera denial is recoverable and idle/scanning states are explicit', () async {
    final c = CatalogCubit(GetCatalogUseCase(FakeCatalog()));
    expect(c.state.status, LookupStatus.idle);
    c.scanning();
    expect(c.state.status, LookupStatus.scanning);
    c.cameraDenied();
    expect(c.state.error, 'camera');
    expect(c.state.status, LookupStatus.denied);
    c.scanning();
    expect(c.state.status, LookupStatus.scanning);
    await c.close();
  });
  for (final status in [
    LookupStatus.found,
    LookupStatus.miss,
    LookupStatus.processing,
    LookupStatus.denied,
    LookupStatus.error,
  ]) {
    test('lookup transitions checking to $status without auth gate', () async {
      final repo = FakeCatalog()
        ..result = Right(CatalogEntity(status: status, barcode: '00000096385074'));
      final c = CatalogCubit(GetCatalogUseCase(repo));
      final states = <LookupStatus>[];
      final sub = c.stream.listen((s) => states.add(s.status));
      await c.check('96385074');
      await Future<void>.delayed(Duration.zero);
      expect(states, [LookupStatus.checking, status]);
      expect(repo.requests.single.$1, '00000096385074');
      expect(repo.requests.single.$3, false);
      await sub.cancel();
      await c.close();
    });
  }
  test(
    'invalid barcode does not access backend; duplicate frames while checking are suppressed',
    () async {
      final repo = FakeCatalog()..pending = Completer();
      final c = CatalogCubit(GetCatalogUseCase(repo));
      await c.check('bad');
      expect(repo.requests, isEmpty);
      final first = c.check('96385074');
      await c.check('96385074');
      expect(repo.requests.length, 1);
      repo.pending!.complete(repo.result);
      await first;
      await c.close();
    },
  );
  test('network retry reuses its key, processing refresh gets a fresh key', () async {
    final repo = FakeCatalog()
      ..result = Left(
        ServerFailure(
          error: const DataError(stackTrace: 'fixture', statusCode: 'unavailable'),
        ),
      );
    final c = CatalogCubit(GetCatalogUseCase(repo));
    await c.check('96385074');
    await c.retry();
    expect(repo.requests[0].$2, repo.requests[1].$2);
    repo.result = const Right(
      CatalogEntity(status: LookupStatus.processing, barcode: '00000096385074'),
    );
    await c.retry();
    await c.retry();
    expect(repo.requests[2].$2, isNot(repo.requests[3].$2));
    await c.close();
  });
  test('closed route discards stale responses', () async {
    final repo = FakeCatalog()..pending = Completer();
    final c = CatalogCubit(GetCatalogUseCase(repo));
    final request = c.check('96385074');
    await c.close();
    repo.pending!.complete(repo.result);
    await request;
    expect(c.isClosed, true);
  });
}
