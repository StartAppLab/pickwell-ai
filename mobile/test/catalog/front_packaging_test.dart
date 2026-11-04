import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import '../../lib/src/features/catalog/domain/_domain.dart';
import '../../lib/src/features/catalog/data/models/analysis_model.dart';
import '../../lib/src/features/catalog/data/repositories/pending_capture_repository.dart';
import '../../lib/src/features/catalog/data/data_sources/services/scanner_media_service.dart';
import '../../lib/src/features/catalog/presentation/blocs/catalog/label_capture_cubit.dart';
import '../../lib/src/features/catalog/presentation/blocs/catalog/analysis_submission_cubit.dart';
import 'label_capture_test.dart' show DraftMedia, photo, pngFixture;
import 'pending_capture_test.dart' show MemoryDraft;
import 'analysis_fixtures.dart' show FakeAnalysis, resultFixture;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'front is mandatory; full capture and OTP cancellation/resume retain exact three photos',
    () async {
      final media = DraftMedia(), store = MemoryDraft();
      final draft = LabelCaptureCubit(CaptureLabelUseCase(media), store);
      final repo = FakeAnalysis();
      final sender = AnalysisSubmissionCubit(AnalyzeProductUseCase(repo), draft);
      await draft.begin('96385074');
      await draft.capture(LabelKind.nutrition);
      await draft.capture(LabelKind.ingredients);
      expect(media.calls, 0);
      expect(sender.beginAuthorization(), false);
      for (final kind in LabelKind.values) {
        media.next = photo(kind.name);
        await draft.capture(kind);
      }
      expect(draft.state.ready, true);
      expect(draft.state.count, 3);
      final before = draft.state, key = draft.requestId;
      sender.beginAuthorization();
      await sender.finishAuthorization(false);
      expect(repo.requests, isEmpty);
      expect(draft.state.front, same(before.front));
      // Simulate leaving the route and recreating the app-owned capture Cubit.
      await sender.close();
      await draft.close();
      final resumed = LabelCaptureCubit(CaptureLabelUseCase(media), store);
      await resumed.begin('96385074');
      expect(resumed.requestId, key);
      expect(resumed.state.front, same(before.front));
      expect(resumed.state.nutrition, same(before.nutrition));
      expect(resumed.state.ingredients, same(before.ingredients));
      final next = AnalysisSubmissionCubit(AnalyzeProductUseCase(repo), resumed);
      next.beginAuthorization();
      await next.finishAuthorization(true);
      expect(repo.requests.single.front, same(before.front));
      expect(repo.requests.single.requestId, key);
      await next.close();
      await resumed.close();
    },
  );
  test(
    'front retake preserves labels and invalidates old request; late success cannot delete new front',
    () async {
      final media = DraftMedia();
      final draft = LabelCaptureCubit(CaptureLabelUseCase(media));
      await draft.begin('96385074');
      for (final kind in LabelKind.values) {
        media.next = photo(kind.name);
        await draft.capture(kind);
      }
      final n = draft.state.nutrition,
          i = draft.state.ingredients,
          old = draft.state.front,
          key = draft.requestId;
      final repo = FakeAnalysis()..pending = Completer();
      final sender = AnalysisSubmissionCubit(AnalyzeProductUseCase(repo), draft);
      sender.beginAuthorization();
      final pending = sender.finishAuthorization(true);
      await Future<void>.delayed(Duration.zero);
      media.next = photo('new front');
      await draft.capture(LabelKind.front);
      expect(draft.requestId, isNot(key));
      expect(draft.state.nutrition, same(n));
      expect(draft.state.ingredients, same(i));
      expect(media.deleted, contains(old));
      repo.pending!.complete(Right(AnalysisResult(AnalysisPhase.ready, product: resultFixture())));
      await pending;
      expect(draft.state.front!.path, 'new front');
      expect(draft.state.nutrition, same(n));
      expect(draft.state.ingredients, same(i));
      expect(media.deleted.any((p) => p.path == 'new front'), false);
      await sender.close();
      await draft.close();
    },
  );
  test(
    'front survives real disk roundtrip; legacy two-photo draft retains labels but cannot submit',
    () async {
      final root = await Directory.systemTemp.createTemp('front_pending_');
      final media = ScannerMediaService.withPicker(ImagePicker(), root);
      try {
        final input = await pngFixture(root);
        final front = await media.validateAndStoreLabel(XFile(input.path));
        final nutrition = await media.validateAndStoreLabel(XFile(input.path));
        final ingredients = await media.validateAndStoreLabel(XFile(input.path));
        final repository = PendingCaptureRepositoryImpl.testing(media, root);
        await repository.save(
          PendingCapture(
            barcode: '00000096385074',
            requestId: '11111111-1111-4111-8111-111111111111',
            expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
            front: front,
            nutrition: nutrition,
            ingredients: ingredients,
          ),
        );
        final saved = (await repository.load())!;
        expect(saved.front, isNotNull);
        expect(await File(saved.front!.path).exists(), true);
        final manifest = File(
          '${root.path}/pickwell_pending_analysis_v1/00000096385074/manifest.json',
        );
        final json = jsonDecode(await manifest.readAsString()) as Map<String, dynamic>;
        json['v'] = 1;
        json.remove('front');
        await manifest.writeAsString(jsonEncode(json));
        final legacy = (await repository.load())!;
        expect(legacy.front, isNull);
        expect(legacy.nutrition, isNotNull);
        expect(legacy.ingredients, isNotNull);
        final store = MemoryDraft();
        await store.save(legacy);
        final capture = LabelCaptureCubit(CaptureLabelUseCase(DraftMedia()), store);
        await capture.begin(legacy.barcode);
        expect(capture.state.ready, false);
        await capture.close();
        await repository.clear();
        expect(
          await Directory('${root.path}/pickwell_pending_analysis_v1/00000096385074').exists(),
          false,
        );
      } finally {
        await root.delete(recursive: true);
      }
    },
  );
  test('front and exact pair retake targets parse without changing legacy results', () {
    for (final photos in [
      ['front'],
      ['front', 'nutrition'],
      ['nutrition', 'ingredients'],
    ]) {
      final result = AnalysisModel.parse({
        'status': 'needs_retake',
        'retake': photos,
      }, '00000096385074');
      expect(result.retake.map((p) => p.name), photos);
    }
  });
}
