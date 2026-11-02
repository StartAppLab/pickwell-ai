import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../lib/src/config/theme/_theme.dart';
import '../../lib/src/core/errors/_errors.dart';
import '../../lib/src/features/catalog/domain/_domain.dart';
import '../../lib/src/features/catalog/data/data_sources/services/scanner_media_service.dart';
import '../../lib/src/features/catalog/presentation/blocs/catalog/label_capture_cubit.dart';
import '../../lib/src/features/catalog/presentation/views/capture_entry_view.dart';
import '../../lib/src/localization/l10n/app_localizations.dart';

class DraftMedia extends LabelCaptureRepository {
  final deleted = <LabelPhoto>[];
  LabelPhoto? next;
  String? failure;
  bool deletionFails = false;
  int calls = 0;
  Completer<Either<Failure, LabelPhoto?>>? pending;
  @override
  Future<Either<Failure, LabelPhoto?>> capture() async {
    calls++;
    if (pending != null) return pending!.future;
    if (failure != null) {
      return Left(
        ServerFailure(
          error: DataError(stackTrace: 'fixture', statusCode: failure!),
        ),
      );
    }
    return Right(next);
  }

  @override
  Future<void> discard(LabelPhoto photo) async {
    if (deletionFails) throw StateError('fixture cleanup');
    deleted.add(photo);
  }

  @override
  Future<void> prepare() async {}
}

class CameraPicker extends ImagePicker {
  XFile? next;
  bool fail = false;
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    expect(source, ImageSource.camera);
    expect(maxWidth, 2400);
    expect(maxHeight, 2400);
    expect(imageQuality, 90);
    expect(requestFullMetadata, false);
    if (fail) throw StateError('camera fixture');
    return next;
  }
}

LabelPhoto photo(String path) => LabelPhoto(
  path: path,
  mimeType: 'image/png',
  byteLength: 20,
  width: 10,
  height: 10,
  capturedAt: DateTime.utc(2026),
);

Future<File> pngFixture(Directory dir, {int width = 16}) async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawColor(const Color(0xffeeeeee), BlendMode.src);
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, 16);
  final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  image.dispose();
  picture.dispose();
  return File('${dir.path}/fixture-$width.png').writeAsBytes(bytes);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'barcode-first sequence and independent retakes retain the other label; cancellation is harmless',
    () async {
      final media = DraftMedia();
      final cubit = LabelCaptureCubit(CaptureLabelUseCase(media));
      await cubit.begin('96385074');
      expect(cubit.state.barcode, '00000096385074');
      await cubit.capture(LabelKind.ingredients);
      expect(media.calls, 0);
      media.next = photo('nutrition1');
      await cubit.capture(LabelKind.nutrition);
      final nutrition = cubit.state.nutrition;
      media.next = photo('ingredients1');
      await cubit.capture(LabelKind.ingredients);
      final ingredients = cubit.state.ingredients;
      expect(cubit.state.ready, true);
      media.next = photo('nutrition2');
      await cubit.capture(LabelKind.nutrition);
      expect(cubit.state.ingredients, same(ingredients));
      expect(media.deleted, contains(nutrition));
      final replaced = cubit.state.nutrition;
      media.next = null;
      await cubit.capture(LabelKind.ingredients);
      expect(cubit.state.ingredients, same(ingredients));
      media.next = photo('ingredients2');
      await cubit.capture(LabelKind.ingredients);
      expect(cubit.state.nutrition, same(replaced));
      expect(media.deleted, contains(ingredients));
      expect(cubit.state.count, 2);
      await cubit.close();
    },
  );

  test(
    'camera/validation errors preserve accepted photos and discard removes all references',
    () async {
      final media = DraftMedia()..next = photo('nutrition');
      final cubit = LabelCaptureCubit(CaptureLabelUseCase(media));
      await cubit.begin('96385074');
      await cubit.capture(LabelKind.nutrition);
      for (final failure in ['camera', 'image_format', 'image_size', 'image_dimensions']) {
        media.failure = failure;
        await cubit.capture(LabelKind.ingredients);
        expect(cubit.state.error, failure);
        expect(cubit.state.nutrition!.path, 'nutrition');
        expect(cubit.state.ingredients, isNull);
      }
      await cubit.discard();
      expect(cubit.state.count, 0);
      expect(media.deleted.single.path, 'nutrition');
      await cubit.close();
    },
  );

  test(
    'same-barcode route return keeps draft; a different barcode removes prior captures',
    () async {
      final media = DraftMedia()..next = photo('nutrition');
      final cubit = LabelCaptureCubit(CaptureLabelUseCase(media));
      await cubit.begin('96385074');
      await cubit.capture(LabelKind.nutrition);
      final original = cubit.state;
      await cubit.begin('00000096385074');
      expect(cubit.state, same(original));
      await cubit.begin('036000291452');
      expect(cubit.state.count, 0);
      expect(cubit.state.barcode, '00036000291452');
      expect(media.deleted.single.path, 'nutrition');
      await cubit.close();
    },
  );

  test(
    'duplicate actions are suppressed and late camera result after discard is deleted',
    () async {
      final media = DraftMedia()..pending = Completer();
      final cubit = LabelCaptureCubit(CaptureLabelUseCase(media));
      await cubit.begin('96385074');
      final capture = cubit.capture(LabelKind.nutrition);
      await Future<void>.delayed(Duration.zero);
      await cubit.capture(LabelKind.nutrition);
      expect(media.calls, 1);
      await cubit.discard();
      media.pending!.complete(Right(photo('late')));
      await capture;
      expect(cubit.state.count, 0);
      expect(media.deleted.single.path, 'late');
      await cubit.close();
    },
  );

  test('failed deletion blocks more capture until cleanup can be retried', () async {
    final media = DraftMedia()..next = photo('old');
    final cubit = LabelCaptureCubit(CaptureLabelUseCase(media));
    await cubit.begin('96385074');
    await cubit.capture(LabelKind.nutrition);
    media.deletionFails = true;
    await cubit.discard();
    await cubit.capture(LabelKind.nutrition);
    expect(cubit.state.error, 'cleanup');
    expect(media.calls, 1);
    media.deletionFails = false;
    media.next = photo('new');
    await cubit.capture(LabelKind.nutrition);
    expect(cubit.state.nutrition!.path, 'new');
    expect(media.deleted.single.path, 'old');
    await cubit.close();
  });

  test('closed draft disposes late camera results without emitting', () async {
    final media = DraftMedia()..pending = Completer();
    final cubit = LabelCaptureCubit(CaptureLabelUseCase(media));
    await cubit.begin('96385074');
    final capture = cubit.capture(LabelKind.nutrition);
    await Future<void>.delayed(Duration.zero);
    await cubit.close();
    media.pending!.complete(Right(photo('closed-late')));
    await capture;
    expect(media.deleted.single.path, 'closed-late');
  });

  test(
    'camera adapter requests bounded compression and deletes picker output on success and rejection',
    () async {
      final dir = await Directory.systemTemp.createTemp('capture_adapter_test_');
      final picker = CameraPicker();
      final media = ScannerMediaService.withPicker(picker);
      try {
        expect(await media.captureLabel(), isNull, reason: 'Cancellation creates no photo');
        final input = await pngFixture(dir);
        picker.next = XFile(input.path);
        final captured = (await media.captureLabel())!;
        expect(await input.exists(), false);
        expect(await File(captured.path).exists(), true);
        await media.discardLabel(captured);
        final bad = await File('${dir.path}/bad.jpg').writeAsString('invalid photo fixture');
        picker.next = XFile(bad.path);
        await expectLater(media.captureLabel(), throwsA(isA<LabelMediaException>()));
        expect(await bad.exists(), false);
        picker.fail = true;
        await expectLater(media.captureLabel(), throwsStateError);
      } finally {
        await dir.delete(recursive: true);
      }
    },
  );

  testWidgets('one-hour draft expiry removes references and files', (tester) async {
    final media = DraftMedia()..next = photo('expired');
    final cubit = LabelCaptureCubit(CaptureLabelUseCase(media));
    await cubit.begin('96385074');
    await cubit.capture(LabelKind.nutrition);
    await tester.pump(LabelCaptureCubit.draftLifetime);
    expect(cubit.state.error, 'draft_expired');
    expect(cubit.state.count, 0);
    expect(media.deleted.single.path, 'expired');
    await cubit.close();
  });

  test(
    'real file boundary checks signature, decodability, byte/dimension limits and owned deletion',
    () async {
      final dir = await Directory.systemTemp.createTemp('capture_test_');
      final media = ScannerMediaService();
      try {
        final valid = await pngFixture(dir);
        final stored = await media.validateAndStoreLabel(XFile(valid.path, mimeType: 'image/jpeg'));
        expect(stored.mimeType, 'image/png');
        expect(stored.width, 16);
        expect(await File(stored.path).exists(), true);
        expect(await valid.exists(), true, reason: 'Validation never deletes caller-owned fixture');
        final unsupported = await File('${dir.path}/bad.jpg').writeAsString('not an image');
        await expectLater(
          media.validateAndStoreLabel(XFile(unsupported.path)),
          throwsA(isA<LabelMediaException>().having((e) => e.code, 'code', 'image_format')),
        );
        final corrupt = await File(
          '${dir.path}/truncated.jpg',
        ).writeAsBytes([255, 216, 255, 0, 1, 2]);
        await expectLater(
          media.validateAndStoreLabel(XFile(corrupt.path)),
          throwsA(isA<LabelMediaException>().having((e) => e.code, 'code', 'image_decode')),
        );
        final large = File('${dir.path}/oversize.png');
        final handle = await large.open(mode: FileMode.write);
        await handle.truncate(ScannerMediaService.maxLabelBytes + 1);
        await handle.close();
        await expectLater(
          media.validateAndStoreLabel(XFile(large.path)),
          throwsA(isA<LabelMediaException>().having((e) => e.code, 'code', 'image_size')),
        );
        final empty = await File('${dir.path}/empty.png').create();
        await expectLater(
          media.validateAndStoreLabel(XFile(empty.path)),
          throwsA(isA<LabelMediaException>().having((e) => e.code, 'code', 'image_size')),
        );
        final wide = await pngFixture(dir, width: 2401);
        await expectLater(
          media.validateAndStoreLabel(XFile(wide.path)),
          throwsA(isA<LabelMediaException>().having((e) => e.code, 'code', 'image_dimensions')),
        );
        await media.discardLabel(photo(valid.path));
        expect(await valid.exists(), true, reason: 'Cannot delete outside private draft directory');
        await media.discardLabel(stored);
        expect(await File(stored.path).exists(), false);
        final orphan = await media.validateAndStoreLabel(XFile(valid.path));
        await ScannerMediaService().prepareLabels();
        expect(
          await File(orphan.path).exists(),
          false,
          reason: 'Next process session sweeps prior drafts',
        );
      } finally {
        await dir.delete(recursive: true);
      }
    },
  );

  testWidgets(
    'three-step wizard previews/retakes and preserves draft across replaced OTP handoff route',
    (tester) async {
      final dir = await tester.runAsync(() => Directory.systemTemp.createTemp('capture_widget_'));
      final file = (await tester.runAsync(() => pngFixture(dir!)))!;
      final media = DraftMedia()..next = photo(file.path);
      final cubit = LabelCaptureCubit(CaptureLabelUseCase(media));
      final router = GoRouter(
        initialLocation: '/capture',
        routes: [
          GoRoute(
            path: '/capture',
            builder: (_, _) {
              unawaited(cubit.begin('96385074'));
              return BlocProvider.value(
                value: cubit,
                child: const CaptureEntryView(barcode: '00000096385074'),
              );
            },
          ),
          // Route test fixture only: production OTP remains T04.2.
          GoRoute(
            path: '/otp-fixture',
            builder: (_, _) => const Scaffold(body: Text('OTP HANDOFF FIXTURE')),
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
      await tester.pumpAndSettle();
      expect(find.text('Step 1 · Barcode ✓'), findsOneWidget);
      expect(find.text('Step 2 · Nutrition'), findsOneWidget);
      expect(find.text('Step 3 · Ingredients'), findsOneWidget);
      await tester.tap(find.text('Take photo: Nutrition'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Take photo: Ingredients'), 180);
      await tester.tap(find.text('Take photo: Ingredients'));
      await tester.pumpAndSettle();
      expect(cubit.state.ready, true);
      await tester.scrollUntilVisible(find.text('Retake photo: Nutrition'), -120);
      expect(find.text('Retake photo: Nutrition'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Retake photo: Ingredients'), 120);
      expect(find.text('Retake photo: Ingredients'), findsOneWidget);
      final nutrition = cubit.state.nutrition, ingredients = cubit.state.ingredients;
      router.go('/otp-fixture');
      await tester.pumpAndSettle();
      expect(cubit.isClosed, false);
      router.go('/capture');
      await tester.pumpAndSettle();
      expect(cubit.state.nutrition, same(nutrition));
      expect(cubit.state.ingredients, same(ingredients));
      expect(cubit.state.barcode, '00000096385074');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
      await cubit.close();
      await tester.runAsync(() => dir!.delete(recursive: true));
    },
  );
}
