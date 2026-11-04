import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import '../../lib/src/config/app_session.dart';
import '../../lib/src/features/catalog/domain/_domain.dart';
import '../../lib/src/features/catalog/data/models/quota_model.dart';
import '../../lib/src/features/catalog/data/models/catalog_model.dart';
import '../../lib/src/features/catalog/data/models/analysis_model.dart';
import '../../lib/src/features/catalog/presentation/blocs/catalog/catalog_cubit.dart';
import '../../lib/src/features/catalog/presentation/blocs/catalog/analysis_submission_cubit.dart';
import '../../lib/src/features/catalog/presentation/blocs/catalog/label_capture_cubit.dart';
import '../../lib/src/features/catalog/presentation/widgets/quota_status.dart';
import '../../lib/src/features/catalog/presentation/views/product_detail_view.dart';
import 'catalog_repository_test.dart' show MemoryStorage, FakeApi;
import 'catalog_cubit_test.dart' show FakeCatalog;
import 'home_widget_test.dart' show config;
import 'product_results_test.dart' show host;
import 'analysis_fixtures.dart';
import 'label_capture_test.dart' show DraftMedia, photo;

class QuotaSession extends AppSession {
  String? identity;
  QuotaSession(this.identity) : super(config(), MemoryStorage());
  @override
  String? get userId => identity;
  void change(String? value) {
    identity = value;
    notifyListeners();
  }
}

DateTime nextReset() {
  final now = DateTime.now().toUtc();
  return DateTime.utc(now.year, now.month, now.day + 1);
}

Map<String, dynamic> response({
  int limit = 30,
  int used = 0,
  int reserved = 0,
  int version = 1,
  DateTime? reset,
  String owner = 'owner',
}) => {
  '_quota_subject': owner,
  'quota': {
    'limit': limit,
    'used': used,
    'reserved': reserved,
    'remaining': (limit - used - reserved).clamp(0, limit),
    'version': version,
    'reset_at': (reset ?? nextReset()).toIso8601String(),
  },
};
QuotaSnapshot snapshot({
  int limit = 30,
  int used = 0,
  int reserved = 0,
  QuotaMetric metric = QuotaMetric.barcodeLookup,
  String owner = 'owner',
  DateTime? reset,
}) => QuotaModel.parse(
  response(limit: limit, used: used, reserved: reserved, owner: owner, reset: reset),
  metric,
)!;
void main() {
  test(
    'server 30/31 and 3/4 boundaries and lowering limit to 20 remain exact without client refill',
    () {
      for (final metric in QuotaMetric.values) {
        final limit = metric == QuotaMetric.barcodeLookup ? 30 : 3;
        expect(snapshot(limit: limit, used: limit - 1, metric: metric).remaining, 1);
        expect(snapshot(limit: limit, used: limit, metric: metric).remaining, 0);
      }
      final lowered = snapshot(limit: 20, used: 25);
      expect(lowered.limit, 20);
      expect(lowered.used, 25);
      expect(lowered.remaining, 0);
      expect(snapshot(limit: 3, used: 2, reserved: 1, metric: QuotaMetric.aiAnalysis).remaining, 0);
    },
  );
  test(
    'invalid/missing/negative metadata is unavailable and never turns a valid product into an error',
    () async {
      for (final mutate in <void Function(Map)>[
        (q) => q['remaining'] = -1,
        (q) => q['used'] = -1,
        (q) => q['remaining'] = 31,
        (q) => q['version'] = 0,
        (q) => q['used'] = 0.5,
        (q) => q['reset_at'] = '2026-11-04T00:00:00',
        (q) => q['reset_at'] = '2026-11-04T01:00:00Z',
      ]) {
        final json = response();
        mutate(json['quota'] as Map);
        expect(QuotaModel.parse(json, QuotaMetric.barcodeLookup), isNull);
      }
      final ready = await FakeApi().lookup('00000096385074', 'fixture');
      ready['quota'] = {'used': -1};
      final parsed = CatalogModel.parse(ready, '00000096385074');
      expect(parsed.status, LookupStatus.found);
      expect(parsed.quota, isNull);
    },
  );
  test('reset uses the actual UTC instant even when response supplies an offset', () {
    final json = response();
    (json['quota'] as Map)['reset_at'] = '2026-11-04T08:00:00+08:00';
    final q = QuotaModel.parse(json, QuotaMetric.aiAnalysis)!;
    expect(q.resetAt, DateTime.utc(2026, 11, 4));
    expect(q.expired(DateTime.utc(2026, 11, 3, 23, 59, 59)), false);
    expect(q.expired(DateTime.utc(2026, 11, 4)), true);
  });
  testWidgets(
    'authenticated exact counts, reserved slots and mutable 20 limit come only from snapshots',
    (tester) async {
      final session = QuotaSession('owner');
      await tester.pumpWidget(
        host(
          Scaffold(
            body: QuotaStatus(snapshot: snapshot(used: 29), session: session),
          ),
        ),
      );
      expect(find.text('1 of 30 remaining'), findsOneWidget);
      expect(find.textContaining('(your local time)'), findsOneWidget);
      final local = nextReset().toLocal(),
          material = MaterialLocalizations.of(tester.element(find.byType(QuotaStatus)));
      expect(find.textContaining(material.formatMediumDate(local)), findsOneWidget);
      expect(find.textContaining(local.timeZoneName), findsWidgets);
      await tester.pumpWidget(
        host(
          Scaffold(
            body: QuotaStatus(
              snapshot: snapshot(limit: 20, used: 25),
              session: session,
              loadedResult: true,
            ),
          ),
        ),
      );
      expect(find.text('0 of 20 remaining'), findsOneWidget);
      expect(find.textContaining('Already loaded product'), findsOneWidget);
      expect(find.textContaining('Buy'), findsNothing);
      expect(find.textContaining('Upgrade'), findsNothing);
      await tester.pumpWidget(
        host(
          Scaffold(
            body: QuotaStatus(
              snapshot: snapshot(limit: 3, used: 2, reserved: 1, metric: QuotaMetric.aiAnalysis),
              session: session,
            ),
          ),
        ),
      );
      expect(find.text('0 of 3 remaining'), findsOneWidget);
      expect(find.text('1 currently reserved for processing'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      session.dispose();
    },
  );
  testWidgets(
    'guest throttle is not a daily personal allowance; sign-out/account switch hides private counts',
    (tester) async {
      final session = QuotaSession('owner'), q = snapshot(used: 29);
      await tester.pumpWidget(
        host(
          Scaffold(
            body: QuotaStatus(snapshot: q, session: session),
          ),
        ),
      );
      expect(find.text('1 of 30 remaining'), findsOneWidget);
      session.change('other');
      await tester.pump();
      expect(find.text('1 of 30 remaining'), findsNothing);
      expect(find.textContaining('Usage is unavailable'), findsOneWidget);
      session.change(null);
      await tester.pump();
      expect(find.textContaining('Guests do not have a guaranteed personal'), findsOneWidget);
      expect(find.textContaining('remaining'), findsNothing);
      await tester.pumpWidget(
        host(
          Scaffold(
            body: QuotaStatus(snapshot: q, session: session, rateLimited: true),
          ),
        ),
      );
      expect(find.textContaining('not a personal daily allowance'), findsOneWidget);
      expect(find.textContaining('Resets at'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      session.dispose();
    },
  );
  testWidgets(
    'expired/offline snapshot is not refilled locally and rebuilding does not request usage',
    (tester) async {
      final session = QuotaSession('owner');
      await tester.pumpWidget(
        host(
          Scaffold(
            body: QuotaStatus(
              snapshot: snapshot(reset: DateTime.utc(2000), used: 30),
              session: session,
            ),
          ),
        ),
      );
      expect(find.textContaining('previous report has passed its reset'), findsOneWidget);
      expect(find.text('30 of 30 remaining'), findsNothing);
      await tester.pumpWidget(
        host(
          Scaffold(
            body: QuotaStatus(snapshot: snapshot(used: 29), session: session, unavailable: true),
          ),
        ),
      );
      expect(find.textContaining('Usage is unavailable'), findsOneWidget);
      expect(find.textContaining('remaining'), findsNothing);
      for (var n = 0; n < 5; n++) {
        session.notifyListeners();
        await tester.pump();
      }
      expect(find.byType(FilledButton), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      session.dispose();
    },
  );
  testWidgets('display expiry hides old counts instead of locally refilling at reset', (
    tester,
  ) async {
    final session = QuotaSession('owner');
    final q = QuotaSnapshot(
      metric: QuotaMetric.barcodeLookup,
      limit: 30,
      used: 29,
      reserved: 0,
      remaining: 1,
      version: 1,
      ownerId: 'owner',
      receivedAt: DateTime.now().toUtc(),
      resetAt: DateTime.now().toUtc().add(const Duration(seconds: 10)),
    );
    await tester.pumpWidget(
      host(
        Scaffold(
          body: QuotaStatus(snapshot: q, session: session),
        ),
      ),
    );
    expect(find.text('1 of 30 remaining'), findsOneWidget);
    await tester.pump(const Duration(seconds: 11));
    expect(find.text('1 of 30 remaining'), findsNothing);
    expect(find.textContaining('previous report has passed its reset'), findsOneWidget);
    expect(q.remaining, 1);
    await tester.pumpWidget(const SizedBox.shrink());
    session.dispose();
  });
  testWidgets('compact dark quota card supports large text without overflow', (tester) async {
    tester.view.physicalSize = const Size(640, 1280);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final session = QuotaSession('owner');
    await tester.pumpWidget(
      host(
        Scaffold(
          body: SingleChildScrollView(
            child: QuotaStatus(
              snapshot: snapshot(limit: 3, used: 3, metric: QuotaMetric.aiAnalysis),
              session: session,
              loadedResult: true,
            ),
          ),
        ),
        dark: true,
        scale: 2,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('0 of 3 remaining'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    session.dispose();
  });
  test(
    'optional route quota survives a local-only result opening without another lookup',
    () async {
      final repo = FakeCatalog()
        ..result = Right(
          CatalogEntity(
            status: LookupStatus.found,
            barcode: '00000096385074',
            product: resultFixture(),
          ),
        );
      final cubit = CatalogCubit(GetCatalogUseCase(repo)),
          q = snapshot(limit: 3, used: 1, metric: QuotaMetric.aiAnalysis);
      await cubit.check('96385074', local: true, entryQuota: q);
      expect(identical(cubit.state.quota, q), true);
      expect(repo.requests.single.$3, true);
      await cubit.close();
    },
  );
  test(
    'denial/offline preserves an already loaded same-barcode result; genuine miss clears it',
    () async {
      final repo = FakeCatalog()
        ..result = Right(
          CatalogEntity(
            status: LookupStatus.found,
            barcode: '00000096385074',
            product: resultFixture(),
          ),
        );
      final cubit = CatalogCubit(GetCatalogUseCase(repo));
      await cubit.check('96385074');
      final loaded = cubit.state.product;
      repo.result = Right(
        CatalogEntity(
          status: LookupStatus.denied,
          barcode: '00000096385074',
          quota: snapshot(used: 30),
          errorCode: 'quota_exceeded',
        ),
      );
      await cubit.retry();
      expect(identical(cubit.state.product, loaded), true);
      expect(cubit.state.quota!.remaining, 0);
      repo.result = const Right(
        CatalogEntity(
          status: LookupStatus.error,
          barcode: '00000096385074',
          errorCode: 'unavailable',
        ),
      );
      await cubit.retry();
      expect(identical(cubit.state.product, loaded), true);
      expect(cubit.state.quota, isNull);
      repo.result = const Right(
        CatalogEntity(status: LookupStatus.miss, barcode: '00000096385074'),
      );
      await cubit.retry();
      expect(cubit.state.product, isNull);
      await cubit.close();
    },
  );
  testWidgets('exhausted quota still renders loaded product, without a paywall or rebuild fetch', (
    tester,
  ) async {
    final session = QuotaSession('owner'),
        repo = FakeCatalog()
          ..result = Right(
            CatalogEntity(
              status: LookupStatus.found,
              barcode: '00000096385074',
              product: resultFixture(),
            ),
          );
    final cubit = CatalogCubit(GetCatalogUseCase(repo));
    await cubit.check('96385074');
    repo.result = Right(
      CatalogEntity(
        status: LookupStatus.denied,
        barcode: '00000096385074',
        quota: snapshot(used: 30),
        errorCode: 'quota_exceeded',
      ),
    );
    await cubit.retry();
    final calls = repo.requests.length;
    await tester.pumpWidget(
      host(
        BlocProvider.value(
          value: cubit,
          child: ProductDetailView(session: session),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('SYNTHETIC WIDGET FIXTURE'), findsOneWidget);
    expect(find.text('0 of 30 remaining'), findsOneWidget);
    expect(find.textContaining('Already loaded product'), findsOneWidget);
    for (var n = 0; n < 3; n++) {
      session.notifyListeners();
      await tester.pump();
    }
    expect(repo.requests.length, calls);
    expect(find.text('Upgrade'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await cubit.close();
    session.dispose();
  });
  test(
    'known quota rejection can recheck server config/reset with the same key and retained photos',
    () async {
      final media = DraftMedia();
      final current = LabelCaptureCubit(CaptureLabelUseCase(media));
      await current.begin('96385074');
      media.next = photo('nutrition');
      final previousPhoto = media.next;
      media.next = photo('front');
      await current.capture(LabelKind.front);
      media.next = previousPhoto;
      await current.capture(LabelKind.nutrition);
      media.next = photo('ingredients');
      await current.capture(LabelKind.ingredients);
      final repo = FakeAnalysis()
        ..result = AnalysisModel.parse({
          'status': 'quota_exceeded',
          ...response(limit: 3, used: 3),
        }, '00000096385074');
      final sender = AnalysisSubmissionCubit(AnalyzeProductUseCase(repo), current);
      sender.beginAuthorization();
      await sender.finishAuthorization(true);
      final key = repo.requests.single.requestId;
      expect(sender.retryAvailable, true);
      for (var n = 0; n < 3; n++) {
        await sender.retry();
        expect(repo.requests.last.requestId, key);
        expect(current.state.ready, true);
      }
      repo.result = AnalysisResult(
        AnalysisPhase.ready,
        product: resultFixture(),
        quota: snapshot(limit: 20, used: 4, metric: QuotaMetric.aiAnalysis),
      );
      await sender.retry();
      expect(sender.state.phase, AnalysisPhase.ready);
      expect(sender.state.result!.quota!.limit, 20);
      expect(repo.requests.last.requestId, key);
      await sender.close();
      await current.close();
    },
  );
}
