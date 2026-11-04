import '../../lib/src/features/catalog/presentation/views/product_detail_view.dart';
import '../../lib/src/features/catalog/presentation/blocs/catalog/catalog_cubit.dart';
import '../../lib/src/config/app_config.dart';
import '../../lib/src/features/catalog/data/data_sources/catalog_local_source.dart';
import '../../lib/src/features/catalog/data/data_sources/catalog_remote_source.dart';
import '../../lib/src/features/catalog/data/repositories/analysis_repository.dart';
import '../../lib/src/features/catalog/data/repositories/catalog_repository.dart';
import 'analysis_submission_test.dart' show ApiFixture;
import 'catalog_repository_test.dart' show MemoryStorage, FakeApi;
import 'email_otp_sdk_test.dart' show config;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import '../../lib/src/config/app_session.dart';
import '../../lib/src/config/injection_container.dart';
import '../../lib/src/core/errors/_errors.dart';
import '../../lib/src/features/catalog/domain/_domain.dart';
import '../../lib/src/features/catalog/presentation/blocs/catalog/label_capture_cubit.dart';
import '../../lib/src/features/catalog/presentation/blocs/catalog/private_product_card_cubit.dart';
import '../../lib/src/features/catalog/presentation/widgets/pending_capture_card.dart';
import '../../lib/src/features/catalog/presentation/widgets/catalog_widget.dart';
import '../../lib/src/features/home/presentation/views/home_view.dart';
import '../../lib/src/features/home/presentation/blocs/home/home_cubit.dart';
import 'analysis_fixtures.dart';
import 'catalog_cubit_test.dart' show FakeCatalog;
import 'label_capture_test.dart' show DraftMedia, photo;
import 'pending_capture_test.dart' show MemoryDraft;
import 'private_analysis_test.dart' show PrivateSession, privateResult, owner, job;
import 'product_results_test.dart' show host;

class CardAnalysis extends FakeAnalysis {
  int reads = 0;
  Completer<Either<Failure, AnalysisResult>>? wait;
  @override
  Future<Either<Failure, AnalysisResult>> privateResult(String id, String barcode) async {
    reads++;
    return wait?.future ?? Right(result);
  }
}

class DelayedRecents extends FakeCatalog {
  final first = Completer<Either<Failure, List<RecentProduct>>>();
  int reads = 0;
  @override
  Future<Either<Failure, List<RecentProduct>>> recents() async =>
      ++reads == 1 ? first.future : Right(recentItems);
}

void main() {
  late LabelCaptureCubit draft;
  late PendingCapture item;
  late MemoryDraft store;
  late DraftMedia media;
  late CardAnalysis api;
  late FakeCatalog catalog;
  late bool authorized;
  setUp(() async {
    getIt.registerSingleton<AppConfig>(config('https://fixture.invalid'));
    store = MemoryDraft();
    media = DraftMedia();
    draft = LabelCaptureCubit(CaptureLabelUseCase(media), store);
    await draft.begin('96385074');
    for (final kind in LabelKind.values) {
      media.next = photo(kind.name);
      await draft.capture(kind);
    }
    await draft.rememberPrivate(privateResult(), draft.requestId!);
    item = draft.state.pending.single;
    api = CardAnalysis()..result = privateResult();
    catalog = FakeCatalog();
    authorized = true;
  });
  tearDown(() async {
    await draft.close();
    await getIt.unregister<AppConfig>();
  });
  PrivateProductCardCubit make({Future<void> Function()? published}) => PrivateProductCardCubit(
    item: item,
    analyze: AnalyzeProductUseCase(api),
    lookup: GetCatalogUseCase(catalog),
    drafts: draft,
    authorized: () => authorized,
    onPublished: published,
  );
  test(
    'private card reads validated identity without submitting or entering published recents',
    () async {
      final c = make();
      await c.load();
      expect(c.state.product!.name, 'SYNTHETIC WIDGET FIXTURE');
      expect(c.state.published, false);
      expect(api.requests, isEmpty);
      expect(catalog.requests, isEmpty);
      expect(draft.state.pending.single.privateJobId, job);
      await c.close();
    },
  );
  test(
    'owner publication becomes normal recent opening and retires only the completed draft',
    () async {
      api.result = AnalysisResult(
        AnalysisPhase.privateReady,
        product: resultFixture(),
        canonicalProduct: resultFixture(),
        publicationStatus: 'published',
        ownerId: owner,
        jobId: job,
        privateExpiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      catalog.result = Right(
        CatalogEntity(status: LookupStatus.found, barcode: item.barcode, product: resultFixture()),
      );
      var refreshed = false;
      final c = make(
        published: () async {
          refreshed = true;
        },
      );
      await c.load();
      expect(c.state.published, true);
      expect(catalog.requests.single.$3, true);
      expect(refreshed, true);
      expect(store.values, isEmpty);
      expect(draft.state.pending, isEmpty);
      expect(media.deleted.length, 3);
      expect(api.requests, isEmpty);
      await c.close();
    },
  );
  test(
    'real repositories persist only canonical barcode reference with zero new lookup or analysis calls',
    () async {
      final remote = FakeApi(), store = MemoryStorage();
      final raw = await remote.lookup(item.barcode, 'fixture');
      remote.calls = 0;
      final sdk = ApiFixture()
        ..value = {
          ...raw,
          'status': 'private_ready',
          'barcode': item.barcode,
          'job_id': job,
          'request_id': item.requestId,
          '_quota_subject': owner,
          'private_expires_at': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
          'publication_status': 'published',
          'canonical_product': raw['product'],
        };
      final persisted = CatalogLocalSource(store);
      final c = PrivateProductCardCubit(
        item: item,
        analyze: AnalyzeProductUseCase(AnalysisRepositoryImpl(sdk, persisted)),
        lookup: GetCatalogUseCase(CatalogRepositoryImpl(persisted, CatalogRemoteSource(remote))),
        drafts: draft,
        authorized: () => true,
      );
      await c.load();
      expect(c.state.published, true);
      expect(remote.calls, 0);
      expect(draft.state.pending, isEmpty);
      final json = store.values.values.join();
      expect(json, contains(item.barcode));
      expect(json, isNot(contains('nutrition')));
      expect(json, isNot(contains('ingredients')));
      expect(json, isNot(contains('private_job')));
      await c.close();
    },
  );
  test('publication does not discard photos if recent-index persistence failed', () async {
    api.result = AnalysisResult(AnalysisPhase.ready, product: resultFixture());
    catalog.result = Right(
      CatalogEntity(
        status: LookupStatus.found,
        barcode: item.barcode,
        product: resultFixture(),
        recentSaved: false,
      ),
    );
    final c = make();
    await c.load();
    expect(c.state.published, true);
    expect(c.state.unavailable, true);
    expect(store.values.length, 1);
    expect(media.deleted, isEmpty);
    await c.close();
  });
  test('another contribution becoming canonical cannot erase this private result', () async {
    api.result = AnalysisResult(
      AnalysisPhase.privateReady,
      product: resultFixture(),
      canonicalProduct: resultFixture(),
      publicationStatus: 'cancelled',
      ownerId: owner,
      jobId: job,
      privateExpiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
    final c = make();
    await c.load();
    expect(c.state.published, false);
    expect(catalog.requests, isEmpty);
    expect(store.values.length, 1);
    await c.close();
  });
  test('late account switch or mismatched job cannot display or remove owner data', () async {
    api.wait = Completer();
    final c = make();
    final work = c.load();
    authorized = false;
    api.wait!.complete(Right(privateResult()));
    await work;
    expect(c.state.product, isNull);
    expect(store.values.length, 1);
    await c.close();
    authorized = true;
    api.wait = null;
    api.result = AnalysisResult(
      AnalysisPhase.privateReady,
      product: resultFixture(),
      ownerId: 'other',
      jobId: job,
      publicationStatus: 'pending',
      privateExpiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
    final other = make();
    await other.load();
    expect(other.state.product, isNull);
    expect(other.state.unavailable, true);
    await other.close();
  });
  test('late completion cannot remove a newer retake of the same barcode', () async {
    media.next = photo('new-front');
    await draft.capture(LabelKind.front);
    expect(await draft.discardExpected(item), false);
    expect(draft.state.front?.path, 'new-front');
  });
  test('late publication preserves a new retake started during Home refresh', () async {
    api.result = AnalysisResult(AnalysisPhase.ready, product: resultFixture());
    catalog.result = Right(
      CatalogEntity(status: LookupStatus.found, barcode: item.barcode, product: resultFixture()),
    );
    final c = make(
      published: () async {
        media.next = photo('new-retake');
        await draft.capture(LabelKind.front);
      },
    );
    await c.load();
    expect(draft.state.front?.path, 'new-retake');
    expect(store.values.length, 1);
    expect(draft.state.pending.single.privateJobId, isNull);
    await c.close();
  });
  test(
    'publication waits out an older Home refresh before loading its new recent reference',
    () async {
      final source = DelayedRecents()
        ..recentItems = [RecentProduct(item.barcode, DateTime.now(), product: resultFixture())];
      final home = HomeCubit(GetRecentProductsUseCase(source));
      final old = home.load();
      final refresh = home.reloadAfterCurrent();
      source.first.complete(const Right([]));
      await old;
      await refresh;
      expect(source.reads, 2);
      expect(
        home.state.maybeWhen(ready: (items) => items.single.barcode, orElse: () => ''),
        item.barcode,
      );
      await home.close();
    },
  );
  test('unexpected private-read failure preserves recovery state', () async {
    api.wait = Completer();
    final c = make();
    final work = c.load();
    api.wait!.completeError(StateError('fixture unavailable'));
    await work;
    expect(c.state.unavailable, true);
    expect(store.values.length, 1);
    await c.close();
  });
  test('photo-cleanup failure keeps a recoverable card and reports the local error', () async {
    api.result = AnalysisResult(AnalysisPhase.ready, product: resultFixture());
    catalog.result = Right(
      CatalogEntity(status: LookupStatus.found, barcode: item.barcode, product: resultFixture()),
    );
    store.failClear = true;
    final c = make();
    await c.load();
    expect(c.state.cleanupFailed, true);
    expect(store.values.length, 1);
    expect(media.deleted, isEmpty);
    await c.close();
  });
  testWidgets(
    'a successful ready lookup refreshes Home once without waiting for another navigation',
    (tester) async {
      catalog.result = Right(
        CatalogEntity(status: LookupStatus.found, barcode: item.barcode, product: resultFixture()),
      );
      final lookup = CatalogCubit(GetCatalogUseCase(catalog));
      var notifications = 0;
      await tester.pumpWidget(
        host(
          BlocProvider.value(
            value: lookup,
            child: ProductDetailView(
              onPublished: () async {
                notifications++;
              },
            ),
          ),
        ),
      );
      await lookup.check(item.barcode);
      await tester.pumpAndSettle();
      expect(notifications, 1);
      await tester.pump();
      expect(notifications, 1);
      await tester.pumpWidget(const SizedBox());
      await lookup.close();
    },
  );
  testWidgets(
    'completed contribution is a product card, not a draft action panel; another account cannot see it',
    (tester) async {
      final session = PrivateSession();
      getIt.registerSingleton<AppSession>(session);
      getIt.registerSingleton<AnalyzeProductUseCase>(AnalyzeProductUseCase(api));
      getIt.registerSingleton<GetCatalogUseCase>(GetCatalogUseCase(catalog));
      addTearDown(() async {
        await getIt.unregister<GetCatalogUseCase>();
        await getIt.unregister<AnalyzeProductUseCase>();
        await getIt.unregister<AppSession>();
        session.dispose();
      });
      await tester.pumpWidget(host(Scaffold(body: PendingCaptureCard(draft: draft))));
      await tester.pumpAndSettle();
      expect(find.byType(CatalogWidget), findsOneWidget);
      expect(find.text('SYNTHETIC WIDGET FIXTURE'), findsOneWidget);
      expect(find.text('Private analysis'), findsNothing);
      expect(find.text('View analysis'), findsNothing);
      expect(find.text('Delete saved draft'), findsNothing);
      expect(find.text(item.barcode), findsNothing);
      expect(api.reads, 1);
      await tester.pump();
      expect(api.reads, 1);
      session.switchTo('30000000-0000-4000-8000-000000000003');
      await tester.pumpAndSettle();
      expect(find.byType(CatalogWidget), findsNothing);
      expect(find.text('SYNTHETIC WIDGET FIXTURE'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('manual refresh reloads metadata once without resubmitting analysis', (tester) async {
    final session = PrivateSession();
    getIt.registerSingleton<AppSession>(session);
    getIt.registerSingleton<AnalyzeProductUseCase>(AnalyzeProductUseCase(api));
    getIt.registerSingleton<GetCatalogUseCase>(GetCatalogUseCase(catalog));
    addTearDown(() async {
      await getIt.unregister<GetCatalogUseCase>();
      await getIt.unregister<AnalyzeProductUseCase>();
      await getIt.unregister<AppSession>();
      session.dispose();
    });
    await tester.pumpWidget(host(Scaffold(body: PendingCaptureCard(draft: draft))));
    await tester.pumpAndSettle();
    expect(api.reads, 1);
    await tester.pumpWidget(
      host(Scaffold(body: PendingCaptureCard(draft: draft, refreshRevision: 1))),
    );
    await tester.pumpAndSettle();
    expect(api.reads, 2);
    expect(api.requests, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('Home does not claim empty recents while an owner-private card exists', (
    tester,
  ) async {
    final session = PrivateSession();
    getIt.registerSingleton<AppSession>(session);
    getIt.registerSingleton<AnalyzeProductUseCase>(AnalyzeProductUseCase(api));
    getIt.registerSingleton<GetCatalogUseCase>(GetCatalogUseCase(catalog));
    addTearDown(() async {
      await getIt.unregister<GetCatalogUseCase>();
      await getIt.unregister<AnalyzeProductUseCase>();
      await getIt.unregister<AppSession>();
      session.dispose();
    });
    final home = HomeCubit(GetRecentProductsUseCase(catalog));
    await tester.pumpWidget(
      host(
        BlocProvider.value(
          value: home,
          child: HomeView(drafts: draft),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CatalogWidget), findsOneWidget);
    expect(find.text('Scan your first product'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await home.close();
  });
}
