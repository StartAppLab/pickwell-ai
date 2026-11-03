import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/config/injection_container.dart';
import '../../lib/src/config/app_config.dart';
import '../../lib/src/config/theme/_theme.dart';
import '../../lib/src/features/home/presentation/blocs/home/home_cubit.dart';
import '../../lib/src/features/home/presentation/views/home_view.dart';
import '../../lib/src/features/root/presentation/blocs/root/root_cubit.dart';
import '../../lib/src/features/root/presentation/views/root_view.dart';
import '../../lib/src/features/catalog/domain/_domain.dart';
import '../../lib/src/features/catalog/presentation/widgets/product_result_content.dart';
import '../../lib/src/features/catalog/presentation/widgets/lookup_notice.dart';
import '../../lib/src/features/auth/domain/use_cases/email_otp_use_case.dart';
import '../../lib/src/features/auth/presentation/blocs/email_otp/email_otp_cubit.dart';
import '../../lib/src/features/auth/presentation/views/email_otp_gate_view.dart';
import '../../lib/src/localization/l10n/app_localizations.dart';
import '../../lib/src/features/catalog/presentation/blocs/catalog/label_capture_cubit.dart';
import '../../lib/src/features/catalog/presentation/blocs/catalog/analysis_submission_cubit.dart';
import '../../lib/src/features/catalog/presentation/views/capture_entry_view.dart';
import '../../lib/src/features/catalog/presentation/widgets/analysis_submission_notice.dart';
import 'label_capture_test.dart' show DraftMedia, photo, pngFixture;
import 'analysis_fixtures.dart';
import 'catalog_cubit_test.dart' show FakeCatalog;
import 'home_widget_test.dart' show config;
import 'email_otp_test.dart' show OtpFixture;

Widget host(Widget child, {bool dark = false, double scale = 1, double keyboard = 0}) =>
    MaterialApp(
      theme: dark
          ? AppTheme.darkTheme(AppColorScheme.darkColorScheme)
          : AppTheme.lightTheme(AppColorScheme.lightColorScheme),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, content) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          padding: const EdgeInsets.only(top: 24, bottom: 24),
          viewPadding: const EdgeInsets.only(top: 24, bottom: 24),
          viewInsets: EdgeInsets.only(bottom: keyboard),
        ),
        child: content!,
      ),
      home: child,
    );
Future<void> snapshot(WidgetTester tester, GlobalKey key, String name) async {
  await tester.runAsync(
    () => precacheImage(const AssetImage('assets/images/pickwell_lemon.png'), key.currentContext!),
  );
  await tester.pump();
  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('../.secrets/ui-polish/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  setUpAll(() async {
    final font = FontLoader('Manrope')
      ..addFont(rootBundle.load('assets/fonts/Manrope/Manrope-Regular.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  setUp(() => getIt.registerSingleton<AppConfig>(config()));
  tearDown(() => getIt.reset());
  testWidgets('Home dock, local cards and search adapt to phones, landscape, tablet and keyboard', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final size in [
      const Size(320, 690),
      const Size(390, 844),
      const Size(430, 932),
      const Size(844, 390),
      const Size(768, 1024),
    ]) {
      tester.view.physicalSize = size;
      final repo = FakeCatalog()
        ..recentItems = [
          RecentProduct('00000096385074', DateTime.utc(2026), product: resultFixture()),
        ];
      final home = HomeCubit(GetRecentProductsUseCase(repo)), root = RootCubit();
      final key = GlobalKey();
      final content = MultiBlocProvider(
        providers: [
          BlocProvider.value(value: home),
          BlocProvider.value(value: root),
        ],
        child: const RootView(currentPath: '/home', child: HomeView()),
      );
      await tester.pumpWidget(
        host(
          RepaintBoundary(key: key, child: content),
          scale: size.width == 320 ? 1.6 : 1,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final scan = find.byTooltip('Scan barcode');
      expect(tester.getSize(scan).width, greaterThanOrEqualTo(48));
      expect(tester.getRect(find.text('Settings')).top, greaterThan(size.height - 150));
      expect(tester.getCenter(scan).dx, greaterThan(tester.getCenter(find.text('Settings')).dx));
      if (size.width == 390) await snapshot(tester, key, 'home-390');
      await tester.tap(find.byTooltip('Search your products'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(host(RepaintBoundary(key: key, child: content), keyboard: 280));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Scan barcode'), findsNothing);
      await tester.enterText(find.byType(TextField), 'no matching fixture');
      await tester.pumpAndSettle();
      expect(find.text('SYNTHETIC WIDGET FIXTURE'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await home.close();
      await root.close();
    }
  });
  testWidgets('Details keep readable long and unknown content at large text in both appearances', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final dark in [false, true]) {
      final key = GlobalKey();
      await tester.pumpWidget(
        host(
          RepaintBoundary(
            key: key,
            child: Scaffold(
              appBar: AppBar(leading: const BackButton()),
              body: ProductResultContent(product: resultFixture(missing: dark)),
            ),
          ),
          dark: dark,
          scale: 1.3,
        ),
      );
      await tester.pumpAndSettle();
      await snapshot(tester, key, dark ? 'details-dark' : 'details-light');
      await tester.scrollUntilVisible(
        find.text('Nutrition'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(BottomNavigationBar), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
  testWidgets(
    'Email and code forms remain reachable above keyboard and submit with keyboard action',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 690);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repository = OtpFixture();
      final gate = EmailOtpCubit(EmailOtpUseCase(repository));
      await gate.check();
      final key = GlobalKey();
      await tester.pumpWidget(
        host(
          RepaintBoundary(
            key: key,
            child: BlocProvider.value(
              value: gate,
              child: const EmailOtpGateView(barcode: '00000096385074'),
            ),
          ),
          keyboard: 260,
          scale: 1.3,
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byType(TextField),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(find.byType(TextField), 'fixture@example.invalid');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(repository.sends, 1);
      await tester.scrollUntilVisible(
        find.text('Verify'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      final button = tester.getRect(find.widgetWithText(FilledButton, 'Verify'));
      expect(button.bottom, lessThanOrEqualTo(690 - 260));
      await snapshot(tester, key, 'otp-keyboard-320');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await gate.close();
    },
  );
  testWidgets('Network and permission recovery notices fit compact large-text screens', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 690);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final key = GlobalKey();
    var retries = 0;
    await tester.pumpWidget(
      host(
        RepaintBoundary(
          key: key,
          child: Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                child: LookupNotice(
                  status: LookupStatus.denied,
                  error: 'camera',
                  retry: () => retries++,
                ),
              ),
            ),
          ),
        ),
        scale: 1.6,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Try again'));
    expect(retries, 1);
    expect(tester.takeException(), isNull);
    await snapshot(tester, key, 'permission-320');
  });
  test('semantic finding colors have readable contrast on light and dark cards', () {
    for (final scheme in [AppColorScheme.lightColorScheme, AppColorScheme.darkColorScheme]) {
      for (final color in [scheme.secondary, scheme.tertiary, scheme.error]) {
        final background = Color.alphaBlend(
          color.withValues(alpha: 0.06),
          scheme.surfaceContainerLowest,
        );
        final a = color.computeLuminance(), b = background.computeLuminance();
        final contrast = a > b ? (a + 0.05) / (b + 0.05) : (b + 0.05) / (a + 0.05);
        expect(contrast, greaterThanOrEqualTo(4.5));
      }
    }
  });
  testWidgets(
    'capture review and recoverable processing states retain actions on compact screens',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final dir = (await tester.runAsync(() => Directory.systemTemp.createTemp('polish_review_')))!;
      final file = (await tester.runAsync(() => pngFixture(dir)))!;
      final media = DraftMedia()..next = photo(file.path);
      final draft = LabelCaptureCubit(CaptureLabelUseCase(media));
      await draft.begin('96385074');
      await draft.capture(LabelKind.nutrition);
      await draft.capture(LabelKind.ingredients);
      final sender = AnalysisSubmissionCubit(AnalyzeProductUseCase(FakeAnalysis()), draft);
      final key = GlobalKey();
      await tester.pumpWidget(
        host(
          RepaintBoundary(
            key: key,
            child: MultiBlocProvider(
              providers: [
                BlocProvider.value(value: draft),
                BlocProvider.value(value: sender),
              ],
              child: const CaptureEntryView(barcode: '00000096385074'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await snapshot(tester, key, 'capture-review');
      await tester.scrollUntilVisible(
        find.text('Analyze Product'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Analyze Product'), findsOneWidget);
      for (final phase in [
        AnalysisPhase.submitting,
        AnalysisPhase.processing,
        AnalysisPhase.retake,
        AnalysisPhase.denied,
        AnalysisPhase.error,
      ]) {
        await tester.pumpWidget(
          host(
            Scaffold(
              body: SafeArea(
                child: SingleChildScrollView(
                  child: AnalysisSubmissionNotice(
                    state: AnalysisSubmissionState(
                      phase: phase,
                      error: phase == AnalysisPhase.denied ? 'rate_limited' : null,
                      canRetry: true,
                    ),
                    retry: () {},
                  ),
                ),
              ),
            ),
            scale: 1.6,
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await sender.close();
      await draft.close();
      await tester.runAsync(() => dir.delete(recursive: true));
    },
  );
}
