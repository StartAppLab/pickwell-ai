import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/config/app_session.dart';
import '../../lib/src/features/catalog/domain/_domain.dart';
import '../../lib/src/features/catalog/data/data_sources/catalog_local_source.dart';
import '../../lib/src/features/catalog/data/repositories/analysis_repository.dart';
import '../../lib/src/features/catalog/data/models/analysis_model.dart';
import '../../lib/src/features/catalog/presentation/blocs/catalog/analysis_submission_cubit.dart';
import '../../lib/src/features/catalog/presentation/blocs/catalog/label_capture_cubit.dart';
import '../../lib/src/features/catalog/presentation/views/private_analysis_view.dart';
import 'analysis_fixtures.dart';
import 'analysis_submission_test.dart' show ApiFixture;
import 'catalog_repository_test.dart' show FakeApi, MemoryStorage;
import 'email_otp_sdk_test.dart' show config;
import 'label_capture_test.dart' show DraftMedia, photo;
import 'pending_capture_test.dart' show MemoryDraft;
import 'product_results_test.dart' show host;

const owner = '10000000-0000-4000-8000-000000000001', job = '20000000-0000-4000-8000-000000000002';
AnalysisResult privateResult({String publication = 'pending'}) => AnalysisResult(
  AnalysisPhase.privateReady,
  product: resultFixture(),
  ownerId: owner,
  jobId: job,
  publicationStatus: publication,
  privateExpiresAt: DateTime.now().add(const Duration(hours: 23)),
);

class PrivateSession extends AppSession {
  String? identity = owner;
  PrivateSession() : super(config('https://fixture.invalid'), MemoryStorage());
  @override
  String? get userId => identity;
  void switchTo(String? id) {
    identity = id;
    notifyListeners();
  }
}

void main() {
  test('private response requires owner and job binding and never enters shared recents', () async {
    final api = ApiFixture()
      ..value = {
        ...await FakeApi().lookup('00000096385074', 'fixture'),
        'status': 'private_ready',
        'barcode': '00000096385074',
        'job_id': job,
        'request_id': job,
        '_quota_subject': owner,
        'private_expires_at': DateTime.now().add(const Duration(hours: 23)).toIso8601String(),
        'publication_status': 'pending',
      };
    expect(AnalysisModel.parse(api.value, '00000096385074').phase, AnalysisPhase.privateReady);
    expect(
      () => AnalysisModel.parse({...api.value, '_quota_subject': null}, '00000096385074'),
      throwsFormatException,
    );
    final store = MemoryStorage(),
        local = CatalogLocalSource(store),
        repo = AnalysisRepositoryImpl(api, local);
    final p = photo('private');
    expect(
      (await repo.submit(
        AnalysisRequest(
          barcode: '00000096385074',
          requestId: job,
          front: p,
          nutrition: p,
          ingredients: p,
        ),
      )).isRight(),
      true,
    );
    expect(local.products, isEmpty);
    expect(await local.load(), isEmpty);
    expect((await repo.privateResult(job, '')).isRight(), true);
    expect(local.products, isEmpty);
  });
  test(
    'successful private handoff keeps bounded photos and persists only owner-bound result reference',
    () async {
      final media = DraftMedia()..next = photo('front'),
          store = MemoryDraft(),
          draft = LabelCaptureCubit(CaptureLabelUseCase(media), store);
      await draft.begin('96385074');
      for (final kind in LabelKind.values) {
        media.next = photo(kind.name);
        await draft.capture(kind);
      }
      final fake = FakeAnalysis()..result = privateResult(),
          sender = AnalysisSubmissionCubit(AnalyzeProductUseCase(fake), draft);
      expect(sender.beginAuthorization(), true);
      await sender.finishAuthorization(true);
      expect(sender.state.phase, AnalysisPhase.privateReady);
      expect(draft.state.count, 3);
      expect(media.deleted, isEmpty);
      expect(store.value!.privateOwnerId, owner);
      expect(store.value!.privateJobId, job);
      expect(store.value!.expiresAt.difference(DateTime.now()) <= const Duration(hours: 24), true);
      final restored = LabelCaptureCubit(CaptureLabelUseCase(media), store);
      await restored.restore();
      expect(restored.state.pending.single.privateJobId, job);
      await draft.discardBarcode('00000096385074');
      media.next = photo('new-front');
      await draft.capture(LabelKind.front);
      expect(store.value?.privateJobId, isNull);
      expect(store.value?.privateOwnerId, isNull);
      await sender.close();
      await draft.close();
      await restored.close();
    },
  );
  for (final status in ['pending', 'rejected', 'cancelled', 'expired']) {
    testWidgets('private $status result is readable with fallback and a nonblocking notice', (
      tester,
    ) async {
      final session = PrivateSession(),
          fake = FakeAnalysis()..result = privateResult(publication: status),
          draft = LabelCaptureCubit(CaptureLabelUseCase(DraftMedia()), MemoryDraft());
      await tester.pumpWidget(
        host(
          PrivateAnalysisView(
            jobId: job,
            barcode: '00000096385074',
            session: session,
            analyze: AnalyzeProductUseCase(fake),
            drafts: draft,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Analysis ready'), findsOneWidget);
      expect(
        find.text("This product hasn't been approved for the shared catalog yet."),
        findsOneWidget,
      );
      expect(find.text('SYNTHETIC WIDGET FIXTURE'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
      expect(tester.takeException(), null);
      session.switchTo(null);
      await tester.pumpAndSettle();
      expect(find.text('SYNTHETIC WIDGET FIXTURE'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await draft.close();
      session.dispose();
    });
  }
  testWidgets('transient publication-check failure preserves a valid owner result', (tester) async {
    final session = PrivateSession(),
        fake = FakeAnalysis()..result = privateResult(),
        draft = LabelCaptureCubit(CaptureLabelUseCase(DraftMedia()), MemoryDraft());
    await tester.pumpWidget(
      host(
        PrivateAnalysisView(
          jobId: job,
          barcode: '00000096385074',
          session: session,
          analyze: AnalyzeProductUseCase(fake),
          drafts: draft,
        ),
      ),
    );
    await tester.pumpAndSettle();
    fake.transportError = true;
    await tester.ensureVisible(find.text('Check shared publication'));
    await tester.tap(find.text('Check shared publication'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, 1200));
    await tester.pumpAndSettle();
    expect(find.text('SYNTHETIC WIDGET FIXTURE'), findsOneWidget);
    expect(find.text('Analysis ready'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await draft.close();
    session.dispose();
  });
  testWidgets('switching accounts cannot reuse the previous owner result', (tester) async {
    final session = PrivateSession(),
        fake = FakeAnalysis(),
        draft = LabelCaptureCubit(CaptureLabelUseCase(DraftMedia()), MemoryDraft());
    fake.result = privateResult();
    await tester.pumpWidget(
      host(
        PrivateAnalysisView(
          jobId: job,
          barcode: '00000096385074',
          session: session,
          analyze: AnalyzeProductUseCase(fake),
          drafts: draft,
        ),
      ),
    );
    await tester.pumpAndSettle();
    session.switchTo('30000000-0000-4000-8000-000000000003');
    await tester.pumpAndSettle();
    expect(find.text('SYNTHETIC WIDGET FIXTURE'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await draft.close();
    session.dispose();
  });
}
