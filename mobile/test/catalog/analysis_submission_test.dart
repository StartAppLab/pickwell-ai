import 'dart:io';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import '../../lib/src/features/catalog/domain/_domain.dart';
import '../../lib/src/features/catalog/presentation/blocs/catalog/label_capture_cubit.dart';
import '../../lib/src/features/catalog/presentation/blocs/catalog/analysis_submission_cubit.dart';
import '../../lib/src/features/catalog/data/models/analysis_model.dart';
import '../../lib/src/features/catalog/data/models/catalog_model.dart';
import '../../lib/src/features/catalog/data/repositories/analysis_repository.dart';
import '../../lib/src/features/catalog/data/data_sources/services/analysis_api_service.dart';
import '../../lib/src/features/catalog/data/data_sources/catalog_local_source.dart';
import 'analysis_fixtures.dart';
import 'label_capture_test.dart' show DraftMedia, photo;
import 'catalog_repository_test.dart' show MemoryStorage, FakeApi;

class ApiFixture extends AnalysisApiService {
  Map<String, dynamic> value = {};
  @override
  Future<Map<String, dynamic>> submit(AnalysisRequest request) async => value;
}

class FileDraftMedia extends DraftMedia {
  @override
  Future<void> discard(LabelPhoto photo) async {
    final file = File(photo.path);
    if (await file.exists()) await file.delete();
    await super.discard(photo);
  }
}

void main() {
  late DraftMedia media;
  late LabelCaptureCubit draft;
  late FakeAnalysis repository;
  late AnalysisSubmissionCubit sender;
  Future<void> capture() async {
    await draft.begin('96385074');
    media.next = photo('front');
    await draft.capture(LabelKind.front);
    media.next = photo('nutrition');
    await draft.capture(LabelKind.nutrition);
    media.next = photo('ingredients');
    await draft.capture(LabelKind.ingredients);
  }

  setUp(() async {
    media = DraftMedia();
    draft = LabelCaptureCubit(CaptureLabelUseCase(media));
    repository = FakeAnalysis();
    sender = AnalysisSubmissionCubit(AnalyzeProductUseCase(repository), draft);
    await capture();
  });
  test('definitive no-provider denial renews key; uncertain retries preserve it', () async {
    final original = draft.requestId;
    repository.result = const AnalysisResult(
      AnalysisPhase.denied,
      error: 'service_budget_exceeded',
      retryable: true,
      restartAllowed: true,
    );
    expect(sender.beginAuthorization(), true);
    await sender.finishAuthorization(true);
    expect(sender.retryAvailable, true);
    expect(draft.requestId, isNot(original));
    expect(draft.attempts, 0);
    final next = draft.requestId;
    repository.transportError = true;
    await sender.retry();
    expect(repository.requests.last.requestId, next);
    expect(draft.requestId, next);
    await sender.retry();
    expect(repository.requests.last.requestId, next);
  });
  test(
    'legacy diagnostic reanalysis explicitly reuses saved photos with one fresh persisted key',
    () async {
      repository.result = const AnalysisResult(
        AnalysisPhase.retake,
        retake: {LabelKind.nutrition},
        canReanalyzeSaved: true,
      );
      sender.beginAuthorization();
      await sender.finishAuthorization(true);
      final previous = repository.requests.single, photos = media.calls;
      repository.result = const AnalysisResult(AnalysisPhase.retake, retake: {LabelKind.nutrition});
      await sender.reanalyzeSaved();
      expect(repository.requests.length, 2);
      expect(repository.requests.last.requestId, isNot(previous.requestId));
      expect(repository.requests.last.nutrition, same(previous.nutrition));
      expect(repository.requests.last.ingredients, same(previous.ingredients));
      expect(media.calls, photos);
      expect(media.deleted, isEmpty);
      await sender.reanalyzeSaved();
      expect(
        repository.requests.length,
        2,
        reason: 'Modern result does not permit another diagnostic restart',
      );
    },
  );
  tearDown(() async {
    await sender.close();
    await draft.close();
  });
  test('confirmed success removes real temporary files before reporting ready', () async {
    final directory = await Directory.systemTemp.createTemp('published_cleanup_');
    final nutrition = await File('${directory.path}/nutrition').writeAsBytes([1, 2, 3]);
    final ingredients = await File('${directory.path}/ingredients').writeAsBytes([4, 5, 6]);
    final files = FileDraftMedia();
    final current = LabelCaptureCubit(CaptureLabelUseCase(files));
    final endpoint = FakeAnalysis()
      ..result = AnalysisResult(AnalysisPhase.ready, product: resultFixture());
    final sending = AnalysisSubmissionCubit(AnalyzeProductUseCase(endpoint), current);
    try {
      await current.begin('96385074');
      final front = await File('${directory.path}/front').writeAsBytes([7, 8, 9]);
      files.next = photo(front.path);
      await current.capture(LabelKind.front);
      files.next = photo(nutrition.path);
      await current.capture(LabelKind.nutrition);
      files.next = photo(ingredients.path);
      await current.capture(LabelKind.ingredients);
      sending.beginAuthorization();
      await sending.finishAuthorization(true);
      expect(sending.state.phase, AnalysisPhase.ready);
      expect(await front.exists(), false);
      expect(await nutrition.exists(), false);
      expect(await ingredients.exists(), false);
      expect(endpoint.requests.length, 1);
    } finally {
      await sending.close();
      await current.close();
      await directory.delete(recursive: true);
    }
  });
  test('auth cancellation preserves exact photos and makes no upload', () async {
    final before = draft.state;
    expect(sender.beginAuthorization(), true);
    expect(sender.beginAuthorization(), false);
    await sender.finishAuthorization(false);
    expect(draft.state.barcode, before.barcode);
    expect(draft.state.nutrition, same(before.nutrition));
    expect(draft.state.ingredients, same(before.ingredients));
    expect(repository.requests, isEmpty);
  });
  test(
    'success waits for cleanup, clears both photo references and returns the published product',
    () async {
      repository.result = AnalysisResult(AnalysisPhase.ready, product: resultFixture());
      sender.beginAuthorization();
      await sender.finishAuthorization(true);
      expect(sender.state.phase, AnalysisPhase.ready);
      expect(sender.state.result!.product!.barcode, draft.state.barcode);
      expect(draft.state.count, 0);
      expect(media.deleted.map((p) => p.path), containsAll(['nutrition', 'ingredients']));
      expect(repository.requests.length, 1);
    },
  );
  test(
    'double press is suppressed; transport and processing retry reuse the key and same photos',
    () async {
      repository.pending = Completer();
      sender.beginAuthorization();
      final sending = sender.finishAuthorization(true);
      await Future<void>.delayed(Duration.zero);
      await sender.submit();
      expect(repository.requests.length, 1);
      repository.pending!.complete(
        const Right(AnalysisResult(AnalysisPhase.processing, retryable: true)),
      );
      await sending;
      repository.pending = null;
      repository.result = const AnalysisResult(AnalysisPhase.processing, retryable: true);
      await sender.retry();
      expect(repository.requests[0].requestId, repository.requests[1].requestId);
      expect(draft.state.ready, true);
      repository.transportError = true;
      await sender.retry();
      expect(sender.state.canRetry, false);
      await sender.retry();
      expect(repository.requests.length, 3);
    },
  );
  test('only a changed photo gets a new request key after precise retake', () async {
    sender.beginAuthorization();
    await sender.finishAuthorization(true);
    final first = repository.requests.single;
    expect(sender.state.result!.retake, {LabelKind.ingredients});
    expect(sender.canStart, false);
    media.next = photo('replacement');
    await draft.capture(LabelKind.ingredients);
    expect(identical(draft.state.nutrition, first.nutrition), true);
    expect(sender.beginAuthorization(), true);
    await sender.finishAuthorization(true);
    expect(repository.requests.last.requestId, isNot(first.requestId));
  });
  test('cleanup failure is surfaced; retry deletes pending files without another upload', () async {
    repository.result = AnalysisResult(AnalysisPhase.ready, product: resultFixture());
    media.deletionFails = true;
    sender.beginAuthorization();
    await sender.finishAuthorization(true);
    expect(sender.state.phase, AnalysisPhase.cleanupFailed);
    media.deletionFails = false;
    await sender.retryCleanup();
    expect(sender.state.phase, AnalysisPhase.ready);
    expect(repository.requests.length, 1);
    expect(media.deleted.length, 3);
  });
  test('late accepted response never deletes a newer unrelated draft', () async {
    repository.pending = Completer();
    sender.beginAuthorization();
    final sending = sender.finishAuthorization(true);
    await Future<void>.delayed(Duration.zero);
    await draft.begin('4006381333931');
    media.next = photo('new-product');
    await draft.capture(LabelKind.nutrition);
    final current = draft.state.nutrition;
    repository.pending!.complete(
      Right(AnalysisResult(AnalysisPhase.ready, product: resultFixture())),
    );
    await sending;
    expect(identical(draft.state.nutrition, current), true);
    expect(media.deleted.any((p) => p.path == 'new-product'), false);
  });
  test('blocked reconciliation, denied and expired session never discard captures', () async {
    for (final result in [
      const AnalysisResult(AnalysisPhase.blocked),
      const AnalysisResult(AnalysisPhase.denied),
      const AnalysisResult(AnalysisPhase.authRequired),
    ]) {
      await capture();
      media.next = photo('new-${result.phase}');
      await draft.capture(LabelKind.ingredients);
      repository.result = result;
      sender.beginAuthorization();
      final before = draft.state;
      await sender.finishAuthorization(true);
      expect(draft.state.barcode, before.barcode);
      expect(draft.state.nutrition, same(before.nutrition));
      expect(draft.state.ingredients, same(before.ingredients));
      expect(sender.state.phase, result.phase);
    }
  });
  test(
    'typed model rejects malformed retake, mismatched products and private arbitrary statuses',
    () {
      expect(
        () => AnalysisModel.parse({
          'status': 'needs_retake',
          'retake': ['arbitrary'],
        }, '00000096385074'),
        throwsFormatException,
      );
      expect(
        () => AnalysisModel.parse({
          'status': 'ready',
          'product': {'barcode': '00000000000000'},
        }, '00000096385074'),
        throwsFormatException,
      );
      expect(
        AnalysisModel.parse({'status': 'processing', 'retryable': false}, '00000096385074').phase,
        AnalysisPhase.blocked,
      );
      expect(
        AnalysisModel.parse({
          'status': 'error',
          'error': 'inference_disabled',
        }, '00000096385074').phase,
        AnalysisPhase.blocked,
      );
    },
  );
  test(
    'published record stays usable when optional recents write fails; payload never persists',
    () async {
      final api = ApiFixture()..value = await FakeApi().lookup('00000096385074', 'fixture');
      api.value['status'] = 'already_exists';
      final store = MemoryStorage()..fail = true, local = CatalogLocalSource(MemoryStorage());
      final actualLocal = CatalogLocalSource(store),
          repo = AnalysisRepositoryImpl(api, actualLocal);
      final request = AnalysisRequest(
        barcode: '00000096385074',
        requestId: createCatalogRequestId(),
        front: draft.state.nutrition!,
        nutrition: draft.state.nutrition!,
        ingredients: draft.state.ingredients!,
      );
      final result = await repo.submit(request);
      expect(result.isRight(), true);
      expect(actualLocal.products[request.barcode], isNotNull);
      expect(store.values, isEmpty);
      expect(local.products, isEmpty);
    },
  );
  test(
    'disabled inference can be checked later with the same photo key without recapturing',
    () async {
      final paused = AnalysisModel.parse({
        'status': 'error',
        'error': 'inference_disabled',
      }, '00000096385074');
      expect(paused.retryable, true);
      repository.result = paused;
      sender.beginAuthorization();
      await sender.finishAuthorization(true);
      final key = repository.requests.single.requestId;
      expect(draft.state.ready, true);
      expect(sender.retryAvailable, true);
      repository.result = AnalysisResult(AnalysisPhase.ready, product: resultFixture());
      await sender.retry();
      expect(repository.requests.last.requestId, key);
      expect(sender.state.phase, AnalysisPhase.ready);
      expect(draft.state.count, 0);
    },
  );
  test('malformed finding evidence is rejected before result widgets or photo disposal', () async {
    final json = await FakeApi().lookup('00000096385074', 'fixture');
    (json['product'] as Map)['findings'] = [
      {
        'severity': 'green',
        'title': 'Unsupported',
        'explanation': 'No source',
        'source_details': 17,
      },
    ];
    expect(() => CatalogModel.parse(json, '00000096385074'), throwsFormatException);
    final api = ApiFixture()..value = json;
    final repo = AnalysisRepositoryImpl(api, CatalogLocalSource(MemoryStorage()));
    final result = await repo.submit(
      AnalysisRequest(
        barcode: '00000096385074',
        requestId: createCatalogRequestId(),
        front: draft.state.nutrition!,
        nutrition: draft.state.nutrition!,
        ingredients: draft.state.ingredients!,
      ),
    );
    expect(result.isLeft(), true);
    expect(draft.state.ready, true);
  });
  test(
    'cached and newly published response preserve identical evidence and unknown fields',
    () async {
      final json = await FakeApi().lookup('00000096385074', 'fixture');
      final p = json['product'] as Map;
      p['explanations'] = [
        {'photo': 'ingredients', 'source': 'oats', 'text': 'The ingredient label states: oats'},
      ];
      p['missing_information'] = ['Unknown serving context'];
      p['analyzed_at'] = '2026-11-03T00:00:00Z';
      final cached = CatalogModel.parse(json, '00000096385074').product!,
          fresh = AnalysisModel.parse({
            ...json,
            'status': 'already_exists',
          }, '00000096385074').product!;
      expect(cached.explanations, fresh.explanations);
      expect(fresh.analyzedAt, DateTime.utc(2026, 11, 3));
      expect(fresh.missingInformation, ['Unknown serving context']);
    },
  );
}
