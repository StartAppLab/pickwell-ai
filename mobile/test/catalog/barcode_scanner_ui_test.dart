import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import '../../lib/src/features/catalog/domain/entities/catalog_entity.dart';
import '../../lib/src/features/catalog/presentation/blocs/catalog/catalog_cubit.dart';
import '../../lib/src/features/catalog/presentation/widgets/barcode_scanner_page.dart';
import '../../lib/src/features/catalog/presentation/widgets/barcode_lookup_loading.dart';
import '../../lib/src/features/catalog/presentation/widgets/scanner_circle_button.dart';
import '../../lib/src/features/catalog/presentation/views/catalog_view.dart';
import '../../lib/src/features/catalog/presentation/views/product_detail_view.dart';
import '../../lib/src/features/catalog/domain/use_cases/get_catalog_use_case.dart';
import '../../lib/src/core/errors/_errors.dart';
import 'catalog_cubit_test.dart' show FakeCatalog;
import 'analysis_fixtures.dart' show resultFixture;
import 'product_results_test.dart' show host;

// Synthetic viewport fixture only, not a camera photograph or product evidence.
Widget preview() => const DecoratedBox(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF6C746A), Color(0xFF2E3731)],
    ),
  ),
);

Widget page({
  LookupStatus status = LookupStatus.scanning,
  String? error,
  Widget? camera,
  VoidCallback? close,
  gallery,
  manual,
  retry,
  settings,
  torch,
}) => BarcodeScannerPage(
  state: CatalogState(status: status, error: error),
  camera: camera ?? preview(),
  torchAction: ScannerCircleButton(
    icon: HugeIcons.strokeRoundedFlashOff,
    tooltip: 'Flashlight',
    onPressed: torch ?? () {},
    overCamera: true,
  ),
  onClose: close ?? () {},
  onGallery: gallery ?? () {},
  onManual: manual ?? () {},
  onRetry: retry ?? () {},
  onOpenSettings: settings ?? () {},
);

Future<void> render(WidgetTester tester, GlobalKey key, String name) async {
  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await File('../.secrets/$name.png').writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  setUpAll(() async {
    await (FontLoader(
      'Manrope',
    )..addFont(rootBundle.load('assets/fonts/Manrope/Manrope-Regular.ttf'))).load();
  });

  testWidgets('guide is centered on first layout and does not follow preview startup size', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final initialized = ValueNotifier(false);
    addTearDown(initialized.dispose);
    final boundary = GlobalKey();
    await tester.pumpWidget(
      host(
        RepaintBoundary(
          key: boundary,
          child: page(
            camera: ValueListenableBuilder<bool>(
              valueListenable: initialized,
              builder: (_, ready, _) => Align(
                alignment: Alignment.topLeft,
                child: SizedBox(width: ready ? 390 : 0, height: ready ? 844 : 0, child: preview()),
              ),
            ),
          ),
        ),
      ),
    );
    final frame = find.byKey(const ValueKey('barcode-frame-guide'));
    final initial = tester.getRect(frame);
    expect(initial.center, const Offset(195, 422));
    expect(initial.left, greaterThanOrEqualTo(24));
    initialized.value = true;
    await tester.pumpAndSettle();
    expect(tester.getRect(frame), initial);
    expect(find.text('Align the food barcode inside the frame'), findsOneWidget);
    expect(find.text('Scan barcode'), findsNothing);
    await render(tester, boundary, 'barcode-scanning-ui-camera-fixture');
    expect(tester.takeException(), isNull);
  });

  testWidgets('overlay leaves close, flashlight, gallery and manual controls tappable', (
    tester,
  ) async {
    var closed = 0, gallery = 0, manual = 0, torch = 0;
    await tester.pumpWidget(
      host(
        page(
          close: () => closed++,
          gallery: () => gallery++,
          manual: () => manual++,
          torch: () => torch++,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Flashlight'));
    await tester.tap(find.byTooltip('Choose barcode photo'));
    await tester.tap(find.text('Enter barcode'));
    await tester.tap(find.byTooltip('Cancel'));
    expect([closed, gallery, manual, torch], [1, 1, 1, 1]);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'checking has a moving barcode illustration and indeterminate progress, with cancel only',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final boundary = GlobalKey();
      await tester.pumpWidget(
        host(
          RepaintBoundary(
            key: boundary,
            child: page(status: LookupStatus.checking),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.byType(BarcodeLookupLoading), findsOneWidget);
      expect(find.text('Checking barcode…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(
        tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value,
        isNull,
      );
      expect(find.byTooltip('Cancel').hitTestable(), findsOneWidget);
      expect(find.text('Enter barcode'), findsNothing);
      expect(find.byTooltip('Choose barcode photo'), findsNothing);
      expect(find.byKey(const ValueKey('barcode-frame-guide')), findsNothing);
      await render(tester, boundary, 'barcode-scanning-ui-checking');
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );

  for (final resultStatus in [LookupStatus.found, LookupStatus.miss]) {
    testWidgets('pending scanner lookup shows checking then opens $resultStatus directly', (
      tester,
    ) async {
      final repo = FakeCatalog()..pending = Completer<Either<Failure, CatalogEntity>>();
      final cubit = CatalogCubit(GetCatalogUseCase(repo));
      final router = GoRouter(
        initialLocation: '/scan',
        routes: [
          GoRoute(
            path: '/scan',
            builder: (_, _) => BlocProvider.value(value: cubit, child: const CatalogView()),
          ),
          GoRoute(
            path: '/product/:barcode',
            builder: (_, _) => BlocProvider.value(value: cubit, child: const ProductDetailView()),
          ),
          GoRoute(
            path: '/capture/:barcode',
            builder: (_, _) => const Scaffold(body: Text('Existing capture flow')),
          ),
        ],
      );
      // Use the real scanner view; the camera plugin is unavailable in this test.
      // The lookup is driven by its existing Cubit, with no camera/provider mocks
      // treated as evidence of physical-device scanning or model inference.
      await tester.pumpWidget(host(Router.withConfig(config: router)));
      await tester.pumpAndSettle();
      final lookup = cubit.check('96385074');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(BarcodeLookupLoading), findsOneWidget);
      expect(repo.requests.length, 1);
      repo.pending!.complete(
        Right(
          CatalogEntity(
            status: resultStatus,
            barcode: '00000096385074',
            product: resultStatus == LookupStatus.found ? resultFixture() : null,
          ),
        ),
      );
      await lookup;
      await tester.pumpAndSettle();
      expect(find.byType(BarcodeLookupLoading), findsNothing);
      if (resultStatus == LookupStatus.found) {
        expect(find.byType(ProductDetailView), findsOneWidget);
        expect(find.text('SYNTHETIC WIDGET FIXTURE'), findsOneWidget);
      } else {
        expect(find.text('Existing capture flow'), findsOneWidget);
      }
      expect(repo.requests.length, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      router.dispose();
      await cubit.close();
    });
  }

  testWidgets('camera permission recovery retains settings, retry and alternate inputs', (
    tester,
  ) async {
    var retried = 0, opened = 0;
    await tester.pumpWidget(
      host(
        page(
          status: LookupStatus.denied,
          error: 'camera',
          retry: () => retried++,
          settings: () => opened++,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Try again'));
    await tester.tap(find.text('Open device settings'));
    expect([retried, opened], [1, 1]);
    expect(find.text('Enter barcode').hitTestable(), findsOneWidget);
    expect(find.byTooltip('Choose barcode photo').hitTestable(), findsOneWidget);
    expect(find.byKey(const ValueKey('barcode-frame-guide')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final size in [const Size(320, 568), const Size(780, 360), const Size(834, 1112)]) {
    for (final dark in [false, true]) {
      testWidgets('scanner states fit $size with large text, reduced motion, dark=$dark', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        for (final status in [LookupStatus.scanning, LookupStatus.checking, LookupStatus.denied]) {
          await tester.pumpWidget(
            host(
              Builder(
                builder: (context) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    disableAnimations: true,
                    padding: const EdgeInsets.only(top: 24, bottom: 16),
                  ),
                  child: page(
                    status: status,
                    error: status == LookupStatus.denied ? 'camera' : null,
                  ),
                ),
              ),
              dark: dark,
              scale: 2,
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byTooltip('Cancel').hitTestable(), findsOneWidget);
          if (status == LookupStatus.checking) expect(tester.binding.transientCallbackCount, 0);
          expect(tester.takeException(), isNull);
        }
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
