import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import '../../lib/src/core/errors/_errors.dart';
import '../../lib/src/features/catalog/domain/_domain.dart';
import '../../lib/src/features/catalog/presentation/blocs/catalog/label_capture_cubit.dart';
import '../../lib/src/features/catalog/presentation/blocs/catalog/analysis_submission_cubit.dart';
import '../../lib/src/features/catalog/presentation/views/capture_entry_view.dart';
import '../../lib/src/features/catalog/presentation/widgets/capture_analysis_loading.dart';
import '../../lib/src/features/catalog/presentation/widgets/capture_step_timeline.dart';
import '../../lib/src/features/catalog/presentation/widgets/analysis_submission_notice.dart';
import 'analysis_fixtures.dart';
import 'label_capture_test.dart' show DraftMedia, photo, pngFixture;
import 'product_results_test.dart' show host;

void main() {
  late DraftMedia media;
  late LabelCaptureCubit draft;
  late FakeAnalysis analysis;
  late AnalysisSubmissionCubit sender;
  late Directory directory;
  late File image;
  setUpAll(() async {
    await (FontLoader(
      'Manrope',
    )..addFont(rootBundle.load('assets/fonts/Manrope/Manrope-Regular.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    await (FontLoader(
      'packages/cupertino_icons/CupertinoIcons',
    )..addFont(rootBundle.load('packages/cupertino_icons/assets/CupertinoIcons.ttf'))).load();
  });
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('adding_ui_fixture_');
    image = await pngFixture(directory);
    media = DraftMedia()..next = photo(image.path);
    draft = LabelCaptureCubit(CaptureLabelUseCase(media));
    await draft.begin('96385074');
    analysis = FakeAnalysis();
    sender = AnalysisSubmissionCubit(AnalyzeProductUseCase(analysis), draft);
  });
  tearDown(() async {
    if (!sender.isClosed) await sender.close();
    if (!draft.isClosed) await draft.close();
    await directory.delete(recursive: true);
  });
  Widget capture({GlobalKey? boundary, bool dark = false, double scale = 1}) => host(
    RepaintBoundary(
      key: boundary,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: draft),
          BlocProvider.value(value: sender),
        ],
        child: const CaptureEntryView(barcode: '00000096385074'),
      ),
    ),
    dark: dark,
    scale: scale,
  );
  Future<void> render(WidgetTester tester, GlobalKey key, String name) async {
    await tester.runAsync(() async {
      final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final rendered = await boundary.toImage(pixelRatio: 2);
      final bytes = await rendered.toByteData(format: ui.ImageByteFormat.png);
      await File('../.secrets/$name.png').writeAsBytes(bytes!.buffer.asUint8List());
      rendered.dispose();
    });
  }

  Future<void> preparePhotos() async {
    for (final kind in LabelKind.values) {
      media.next = photo(image.path);
      await draft.capture(kind);
    }
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() async {
      await sender.close();
      await draft.close();
    });
  }

  testWidgets('not-found is a separate honest entry, with barcode and docked choices', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final key = GlobalKey();
    await tester.pumpWidget(capture(boundary: key));
    await tester.pumpAndSettle();
    expect(find.text('Product not found'), findsOneWidget);
    expect(find.text('00000096385074'), findsOneWidget);
    expect(find.text('Add this product').hitTestable(), findsOneWidget);
    expect(find.text('Scan another').hitTestable(), findsOneWidget);
    expect(find.byType(CaptureStepTimeline), findsNothing);
    expect(media.calls, 0);
    await render(tester, key, 'adding-product-not-found');
    await tester.tap(find.text('Add this product'));
    await tester.pumpAndSettle();
    expect(find.text('Product not found'), findsNothing);
    expect(find.byType(CaptureStepTimeline), findsOneWidget);
    expect(find.text('No photo yet'), findsOneWidget);
    expect(find.byKey(const ValueKey('capture-photo-action')).hitTestable(), findsOneWidget);
    expect(media.calls, 0, reason: 'Entering the wizard never opens a camera automatically');
    await render(tester, key, 'adding-product-front-empty');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('capture advances, revisiting stays put, and cancellation/failure never advances', (
    tester,
  ) async {
    await tester.pumpWidget(capture());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add this product'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('capture-photo-action')));
    await tester.pumpAndSettle();
    expect(find.text('Take a photo of the nutrition facts'), findsOneWidget);
    final front = draft.state.front;
    await tester.tap(find.byKey(const ValueKey('capture-step-0')));
    await tester.pumpAndSettle();
    expect(find.text('Take a photo of the front packaging'), findsOneWidget);
    await tester.pump();
    expect(find.text('Take a photo of the front packaging'), findsOneWidget);
    expect(media.calls, 1);
    media.next = photo(image.path); // A distinct captured object from the same synthetic image.
    await tester.tap(find.byKey(const ValueKey('capture-photo-action')));
    await tester.pumpAndSettle();
    expect(draft.state.front, isNot(same(front)));
    expect(find.text('Take a photo of the nutrition facts'), findsOneWidget);
    media.next = null;
    await tester.tap(find.byKey(const ValueKey('capture-photo-action')));
    await tester.pumpAndSettle();
    expect(find.text('Take a photo of the nutrition facts'), findsOneWidget);
    media.failure = 'image_size';
    await tester.tap(find.byKey(const ValueKey('capture-photo-action')));
    await tester.pumpAndSettle();
    expect(find.text('Take a photo of the nutrition facts'), findsOneWidget);
    expect(draft.state.nutrition, isNull);
    media.failure = null;
    media.next = photo(image.path);
    await tester.tap(find.byKey(const ValueKey('capture-photo-action')));
    await tester.pumpAndSettle();
    expect(find.text('Take a photo of the ingredients'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('capture-photo-action')));
    await tester.pumpAndSettle();
    expect(find.text('Review photos'), findsOneWidget);
    expect(draft.state.ready, true);
    expect(analysis.requests, isEmpty);
    await finish(tester);
  });

  testWidgets('future steps can be visited without bypassing capture prerequisites or submission', (
    tester,
  ) async {
    await tester.pumpWidget(capture());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add this product'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('capture-step-1')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<FilledButton>(find.byKey(const ValueKey('capture-photo-action'))).onPressed,
      isNull,
    );
    expect(find.text('Take the front packaging photo first.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('capture-step-3')));
    await tester.pumpAndSettle();
    expect(find.text('Review photos'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byKey(const ValueKey('capture-analyze-action'))).onPressed,
      isNull,
    );
    expect(media.calls, 0);
    expect(analysis.requests, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Scan another returns to scanner without capturing or submitting', (tester) async {
    final router = GoRouter(
      initialLocation: '/capture',
      routes: [
        GoRoute(
          path: '/capture',
          builder: (_, _) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: draft),
              BlocProvider.value(value: sender),
            ],
            child: const CaptureEntryView(barcode: '00000096385074'),
          ),
        ),
        GoRoute(
          path: '/scan',
          builder: (_, _) => const Scaffold(body: Text('Scanner destination')),
        ),
      ],
    );
    await tester.pumpWidget(host(Router.withConfig(config: router)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scan another'));
    await tester.pumpAndSettle();
    expect(find.text('Scanner destination'), findsOneWidget);
    expect(media.calls, 0);
    expect(analysis.requests, isEmpty);
    await finish(tester);
    router.dispose();
  });

  testWidgets('legacy saved-photo reanalysis and delete-draft action remain reachable on review', (
    tester,
  ) async {
    await preparePhotos();
    analysis.result = const AnalysisResult(
      AnalysisPhase.retake,
      retake: {LabelKind.nutrition},
      canReanalyzeSaved: true,
    );
    expect(sender.beginAuthorization(), true);
    await sender.finishAuthorization(true);
    await tester.pumpWidget(capture());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Reanalyze saved photos'), 200);
    expect(find.text('Reanalyze saved photos'), findsOneWidget);
    expect(draft.state.count, 3);
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('Delete saved draft').hitTestable(), findsOneWidget);
    expect(analysis.requests.length, 1);
    await finish(tester);
  });

  testWidgets(
    'saved review resumes, independent retake stays on review, discard remains available',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await preparePhotos();
      final nutrition = draft.state.nutrition, ingredients = draft.state.ingredients;
      final key = GlobalKey();
      await tester.pumpWidget(capture(boundary: key));
      await tester.pumpAndSettle();
      expect(find.text('Review photos'), findsOneWidget);
      expect(find.text('Product not found'), findsNothing);
      expect(find.text('Analyze Product').hitTestable(), findsOneWidget);
      await render(tester, key, 'adding-product-review');
      media.next = photo(image.path);
      await tester.tap(find.byTooltip('Retake photo: Front packaging'));
      await tester.pumpAndSettle();
      expect(find.text('Review photos'), findsOneWidget);
      expect(draft.state.nutrition, same(nutrition));
      expect(draft.state.ingredients, same(ingredients));
      await tester.tap(find.text('Discard photos'));
      await tester.pumpAndSettle();
      expect(draft.state.count, 0);
      expect(find.text('Take a photo of the front packaging'), findsOneWidget);
      expect(find.text('No photo yet'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('loading follows the real request and retains retry/error actions and photos', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await preparePhotos();
    analysis.pending = Completer<Either<Failure, AnalysisResult>>();
    final key = GlobalKey();
    await tester.pumpWidget(capture(boundary: key));
    await tester.pumpAndSettle();
    expect(sender.beginAuthorization(), true);
    final request = sender.finishAuthorization(true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(CaptureAnalysisLoading), findsOneWidget);
    expect(find.text('Analyzing your product…'), findsOneWidget);
    expect(find.byType(CaptureStepTimeline), findsNothing);
    expect(
      tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value,
      isNull,
    );
    await render(tester, key, 'adding-product-analyzing');
    analysis.pending!.complete(
      const Right(
        AnalysisResult(AnalysisPhase.error, error: 'transport_uncertain', retryable: true),
      ),
    );
    await request;
    await tester.pumpAndSettle();
    expect(find.byType(CaptureAnalysisLoading), findsNothing);
    expect(find.text('Review photos'), findsOneWidget);
    await tester.scrollUntilVisible(find.byType(AnalysisSubmissionNotice), 200);
    await tester.scrollUntilVisible(find.text('Check request again'), 200);
    expect(find.text('Check request again'), findsOneWidget);
    expect(draft.state.count, 3);
    expect(analysis.requests.length, 1);
    await finish(tester);
  });

  for (final size in [const Size(320, 568), const Size(780, 360)]) {
    for (final dark in [false, true]) {
      testWidgets('intro, empty steps and review fit $size at large text dark=$dark', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(capture(dark: dark, scale: 2));
        await tester.pumpAndSettle();
        expect(find.text('Add this product').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Add this product'));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('capture-photo-action')).hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await preparePhotos();
        await tester.pumpWidget(capture(dark: dark, scale: 2));
        await tester.pumpAndSettle();
        expect(find.text('Analyze Product').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(find.text('Ingredients'), 200);
        expect(tester.takeException(), isNull);
        await finish(tester);
      });
    }
  }
}
