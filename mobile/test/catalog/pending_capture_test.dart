import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../lib/src/config/theme/_theme.dart';
import '../../lib/src/features/catalog/data/data_sources/services/scanner_media_service.dart';
import '../../lib/src/features/catalog/data/repositories/pending_capture_repository.dart';
import '../../lib/src/features/catalog/domain/_domain.dart';
import '../../lib/src/features/catalog/presentation/blocs/catalog/label_capture_cubit.dart';
import '../../lib/src/features/catalog/presentation/widgets/pending_capture_card.dart';
import '../../lib/src/features/catalog/data/models/analysis_model.dart';
import '../../lib/src/localization/l10n/app_localizations.dart';
import 'catalog_repository_test.dart' show code;
import 'label_capture_test.dart' show DraftMedia, photo, pngFixture;

class MemoryDraft implements PendingCaptureRepository {
  final values = <String, PendingCapture>{};
  PendingCapture? get value => values.isEmpty ? null : values.values.first;
  bool fail = false, failClear = false, failLoad = false;
  @override
  Future<PendingCapture?> load([String? barcode]) async =>
      barcode == null ? value : values[barcode];
  @override
  Future<List<PendingCapture>> loadAll() async {
    if (failLoad) throw const FileSystemException('fixture');
    return values.values.toList();
  }

  @override
  Future<void> save(PendingCapture draft) async {
    if (fail) throw StateError('disk');
    values[draft.barcode] = draft;
  }

  @override
  Future<void> clear([String? barcode]) async {
    if (failClear) throw StateError('disk');
    if (barcode == null) {
      values.clear();
    } else {
      values.remove(barcode);
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'photos, expiry and exact request key survive recreation; switching barcodes preserves the saved draft',
    () async {
      final store = MemoryDraft(), media = DraftMedia()..next = photo('nutrition');
      var c = LabelCaptureCubit(CaptureLabelUseCase(media), store);
      await c.begin('96385074');
      await c.capture(LabelKind.nutrition);
      media.next = photo('ingredients');
      await c.capture(LabelKind.ingredients);
      final key = c.requestId, expiry = c.expiresAt;
      await c.recordAttempts(2);
      await c.close();
      expect(store.value, isNotNull);
      expect(media.deleted, isEmpty);
      c = LabelCaptureCubit(CaptureLabelUseCase(media), store);
      await c.restore();
      expect(c.state.ready, true);
      expect(c.requestId, key);
      expect(c.attempts, 2);
      expect(c.expiresAt, expiry);
      await c.begin('2900000000018');
      expect(c.state.barcode, '02900000000018');
      expect(c.state.ready, false);
      expect(c.state.pending.single.barcode, '00000096385074');
      await c.discardBarcode('00000096385074');
      expect(store.value, isNull);
      expect(c.state.count, 0);
      media.next = photo('new');
      await c.capture(LabelKind.nutrition);
      expect(store.value?.nutrition?.path, 'new');
      await c.close();
    },
  );
  test('persist failure retains open photos and blocks recording an unsafe transmission', () async {
    final store = MemoryDraft()..fail = true, media = DraftMedia()..next = photo('kept');
    final c = LabelCaptureCubit(CaptureLabelUseCase(media), store);
    await c.begin('96385074');
    await c.capture(LabelKind.nutrition);
    expect(c.state.nutrition?.path, 'kept');
    expect(c.state.error, 'draft_save');
    expect(await c.recordAttempts(1), false);
    store.fail = false;
    expect(await c.recordAttempts(1), true);
    await c.discard();
    await c.close();
  });
  test(
    'real disk roundtrip validates files; expiry, path traversal and orphan files are safely removed',
    () async {
      final root = await Directory.systemTemp.createTemp('pending-test-');
      try {
        final media = ScannerMediaService.withPicker(ImagePicker(), root),
            input = await pngFixture(root);
        final label = await media.validateAndStoreLabel(XFile(input.path));
        final repository = PendingCaptureRepositoryImpl.testing(media, root);
        await repository.save(
          PendingCapture(
            barcode: '00000096385074',
            requestId: createCatalogRequestId(),
            expiresAt: DateTime.now().toUtc().add(const Duration(hours: 23)),
            nutrition: label,
            ingredients: label,
            attempts: 2,
          ),
        );
        final restored = await repository.load();
        expect(restored?.attempts, 2);
        expect(restored?.nutrition?.byteLength, label.byteLength);
        expect(await File(restored!.ingredients!.path).exists(), true);
        final manifest = File(
          '${root.path}/pickwell_pending_analysis_v1/00000096385074/manifest.json',
        );
        final json = jsonDecode(await manifest.readAsString()) as Map<String, dynamic>;
        json['nutrition'] = {
          'file': '../../fixture-16.png',
          'captured_at': DateTime.now().toIso8601String(),
        };
        await manifest.writeAsString(jsonEncode(json));
        expect(await repository.load(), isNull);
        expect(await input.exists(), true);
        await repository.save(
          PendingCapture(
            barcode: '00000096385074',
            requestId: createCatalogRequestId(),
            expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
            nutrition: label,
          ),
        );
        final expired = jsonDecode(await manifest.readAsString()) as Map<String, dynamic>;
        expired['expires_at'] = '2000-01-01T00:00:00Z';
        await manifest.writeAsString(jsonEncode(expired));
        expect(await repository.load(), isNull);
        expect(await manifest.exists(), false);
        await manifest.parent.create(recursive: true);
        final orphan = await File('${manifest.parent.path}/orphan.jpg').writeAsString('private');
        await repository.load();
        expect(await orphan.exists(), false);
      } finally {
        await root.delete(recursive: true);
      }
    },
  );
  test(
    'successful submission must clear saved copies; cleanup failure retains recoverable draft',
    () async {
      final store = MemoryDraft(), media = DraftMedia()..next = photo('nutrition');
      final c = LabelCaptureCubit(CaptureLabelUseCase(media), store);
      await c.begin('96385074');
      await c.capture(LabelKind.nutrition);
      media.next = photo('ingredients');
      await c.capture(LabelKind.ingredients);
      final submitted = c.state;
      store.failClear = true;
      expect(await c.discardSubmitted(submitted), false);
      expect(c.state.ready, true);
      expect(store.value, isNotNull);
      store.failClear = false;
      expect(await c.discardSubmitted(submitted), true);
      expect(store.value, isNull);
      expect(c.state.count, 0);
      expect(media.deleted.length, 2);
      await c.close();
    },
  );
  test('service daily limit carries a real retry time and remains manually retryable', () {
    final r = AnalysisModel.parse({
      'status': 'error',
      'error': 'service_budget_exceeded',
      'retry_at': '2026-11-04T00:00:00Z',
      'retry_after_seconds': 300,
    }, '00000096385074');
    expect(r.phase, AnalysisPhase.denied);
    expect(r.retryable, true);
    expect(r.retryAt, DateTime.utc(2026, 11, 4));
    expect(r.retryAfterSeconds, 300);
  });
  testWidgets(
    'pending warning card resumes saved capture outside scanner and offers explicit delete',
    (tester) async {
      final media = DraftMedia()..next = photo('kept'), store = MemoryDraft();
      final draft = LabelCaptureCubit(CaptureLabelUseCase(media), store);
      await draft.begin('96385074');
      await draft.capture(LabelKind.nutrition);
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => Scaffold(body: PendingCaptureCard(draft: draft)),
          ),
          GoRoute(
            path: '/capture/:barcode',
            builder: (_, s) => Scaffold(body: Text('RESUMED ${s.pathParameters['barcode']}')),
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.lightTheme(AppColorScheme.lightColorScheme),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
      expect(find.text('Needs analysis'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      await tester.tap(find.text('Continue analysis'));
      await tester.pumpAndSettle();
      expect(find.text('RESUMED 00000096385074'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();
      expect(draft.state.count, 1);
      await tester.tap(find.text('Delete saved draft'));
      await tester.pumpAndSettle();
      expect(draft.state.count, 0);
      expect(store.value, isNull);
      await tester.pumpWidget(const SizedBox());
      router.dispose();
      await draft.close();
    },
  );
  test(
    'five independent drafts deduplicate barcodes and restore request keys without eviction',
    () async {
      final store = MemoryDraft(),
          media = DraftMedia(),
          c = LabelCaptureCubit(CaptureLabelUseCase(media), store);
      final keys = <String, String>{};
      for (var n = 1; n <= 5; n++) {
        await c.begin(code(n));
        media.next = photo('nutrition-$n');
        await c.capture(LabelKind.nutrition);
        media.next = photo('ingredients-$n');
        await c.capture(LabelKind.ingredients);
        await c.recordAttempts(n % 3);
        keys[code(n)] = c.requestId!;
      }
      expect(c.state.pending.length, 5);
      final calls = media.calls;
      await c.begin(code(1));
      expect(c.state.nutrition?.path, 'nutrition-1');
      expect(c.requestId, keys[code(1)]);
      expect(c.attempts, 1);
      await c.begin(code(1));
      expect(c.state.pending.length, 5);
      expect(media.calls, calls);
      await c.begin(code(6));
      expect(c.state.error, 'draft_limit');
      expect(c.state.barcode, code(1));
      expect(store.values.length, 5);
      await c.discardBarcode(code(3));
      expect(store.values.length, 4);
      expect(store.values.containsKey(code(1)), true);
      await c.begin(code(6));
      media.next = photo('six');
      await c.capture(LabelKind.nutrition);
      expect(store.values.length, 5);
      await c.close();
      final restored = LabelCaptureCubit(CaptureLabelUseCase(media), store);
      await restored.restore();
      expect(restored.state.pending.length, 5);
      await restored.begin(code(2));
      expect(restored.requestId, keys[code(2)]);
      expect(restored.attempts, 2);
      await restored.close();
    },
  );
  test(
    'late publication clears only the completed product while another draft stays active',
    () async {
      final store = MemoryDraft(),
          media = DraftMedia(),
          c = LabelCaptureCubit(CaptureLabelUseCase(media), store);
      await c.begin(code(1));
      media.next = photo('a-n');
      await c.capture(LabelKind.nutrition);
      media.next = photo('a-i');
      await c.capture(LabelKind.ingredients);
      final submitted = c.state;
      await c.begin(code(2));
      media.next = photo('b-n');
      await c.capture(LabelKind.nutrition);
      final key = c.requestId;
      expect(await c.discardSubmitted(submitted), true);
      expect(c.state.barcode, code(2));
      expect(c.state.nutrition?.path, 'b-n');
      expect(c.requestId, key);
      expect(c.state.pending.single.barcode, code(2));
      expect(store.values.containsKey(code(1)), false);
      expect(store.values.containsKey(code(2)), true);
      await c.close();
    },
  );
  testWidgets('expiry removes only its own draft', (tester) async {
    final store = MemoryDraft(),
        media = DraftMedia(),
        c = LabelCaptureCubit(CaptureLabelUseCase(media), store);
    await c.begin(code(1));
    media.next = photo('first');
    await c.capture(LabelKind.nutrition);
    await tester.pump(const Duration(hours: 1));
    await c.begin(code(2));
    media.next = photo('later');
    await c.capture(LabelKind.nutrition);
    await tester.pump(const Duration(hours: 23));
    expect(c.state.pending.single.barcode, code(2));
    expect(c.state.nutrition?.path, 'later');
    await c.close();
  });
  test(
    'legacy single draft migrates; disk capacity and per-product removal preserve other records',
    () async {
      final root = await Directory.systemTemp.createTemp('multi-draft-test-');
      try {
        final media = ScannerMediaService.withPicker(ImagePicker(), root),
            input = await pngFixture(root);
        final photo = await media.validateAndStoreLabel(XFile(input.path));
        final repo = PendingCaptureRepositoryImpl.testing(media, root),
            key = createCatalogRequestId();
        PendingCapture item(int n) => PendingCapture(
          barcode: code(n),
          requestId: n == 1 ? key : createCatalogRequestId(),
          expiresAt: DateTime.now().toUtc().add(const Duration(hours: 23)),
          nutrition: photo,
          attempts: n % 3,
        );
        await repo.save(item(1));
        final base = Directory('${root.path}/pickwell_pending_analysis_v1'),
            dir = Directory('${base.path}/${code(1)}');
        await for (final file in dir.list()) {
          if (file is File) await file.copy('${base.path}/${file.uri.pathSegments.last}');
        }
        await dir.delete(recursive: true);
        final migrated = await repo.loadAll();
        expect(migrated.single.requestId, key);
        expect(await File('${base.path}/manifest.json').exists(), false);
        expect(await File('${dir.path}/manifest.json').exists(), true);
        for (var n = 2; n <= 5; n++) {
          await repo.save(item(n));
        }
        await expectLater(repo.save(item(6)), throwsStateError);
        expect((await repo.loadAll()).length, 5);
        await repo.save(item(1));
        expect((await repo.loadAll()).length, 5);
        await repo.clear(code(3));
        expect((await repo.loadAll()).length, 4);
        expect((await repo.load(code(1)))?.requestId, key);
        await repo.save(item(6));
        expect((await repo.loadAll()).length, 5);
        final manifest = File('${base.path}/${code(2)}/manifest.json');
        final j = jsonDecode(await manifest.readAsString()) as Map;
        j['expires_at'] = '2000-01-01T00:00:00Z';
        await manifest.writeAsString(jsonEncode(j));
        final all = await repo.loadAll();
        expect(all.length, 4);
        expect(all.any((d) => d.barcode == code(2)), false);
        expect(all.any((d) => d.barcode == code(6)), true);
      } finally {
        await root.delete(recursive: true);
      }
    },
  );
  test('transient restore failure preserves the stored queue and can be retried', () async {
    final store = MemoryDraft(), media = DraftMedia()..next = photo('kept');
    var c = LabelCaptureCubit(CaptureLabelUseCase(media), store);
    await c.begin(code(1));
    await c.capture(LabelKind.nutrition);
    await c.close();
    store.failLoad = true;
    c = LabelCaptureCubit(CaptureLabelUseCase(media), store);
    await c.restore();
    expect(c.state.error, 'draft_load');
    await c.begin(code(2));
    expect(c.state.barcode, isNull);
    expect(store.values.length, 1);
    store.failLoad = false;
    await c.retryRestore();
    expect(c.state.pending.single.barcode, code(1));
    expect(c.state.nutrition?.path, 'kept');
    await c.close();
  });
  testWidgets('multiple pending cards resume and delete independently', (tester) async {
    final store = MemoryDraft(),
        media = DraftMedia(),
        draft = LabelCaptureCubit(CaptureLabelUseCase(media), store);
    await draft.begin(code(1));
    media.next = photo('first');
    await draft.capture(LabelKind.nutrition);
    final firstKey = draft.requestId;
    await draft.begin(code(2));
    media.next = photo('second');
    await draft.capture(LabelKind.nutrition);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: SingleChildScrollView(child: PendingCaptureCard(draft: draft)),
          ),
        ),
        GoRoute(
          path: '/capture/:barcode',
          redirect: (_, s) async {
            await draft.begin(s.pathParameters['barcode']!);
            return null;
          },
          builder: (_, _) => Scaffold(body: Text('ACTIVE ${draft.state.nutrition?.path}')),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.lightTheme(AppColorScheme.lightColorScheme),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    expect(find.text('Needs analysis'), findsNWidgets(2));
    final resume = find.descendant(
      of: find.byKey(ValueKey('pending-${code(1)}')),
      matching: find.text('Continue analysis'),
    );
    await tester.ensureVisible(resume);
    await tester.tap(resume);
    await tester.pumpAndSettle();
    expect(find.text('ACTIVE first'), findsOneWidget);
    expect(draft.requestId, firstKey);
    router.pop();
    await tester.pumpAndSettle();
    final remove = find.descendant(
      of: find.byKey(ValueKey('pending-${code(2)}')),
      matching: find.text('Delete saved draft'),
    );
    await tester.ensureVisible(remove);
    await tester.tap(remove);
    await tester.pumpAndSettle();
    expect(draft.state.pending.single.barcode, code(1));
    expect(find.text('Needs analysis'), findsOneWidget);
    expect(media.calls, 2);
    await tester.pumpWidget(const SizedBox());
    router.dispose();
    await draft.close();
  });
}
