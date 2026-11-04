import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:fpdart/fpdart.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import '../../lib/src/config/theme/_theme.dart';
import '../../lib/src/features/catalog/domain/_domain.dart';
import '../../lib/src/features/catalog/presentation/blocs/catalog/catalog_cubit.dart';
import '../../lib/src/features/catalog/presentation/blocs/catalog/label_capture_cubit.dart';
import '../../lib/src/features/catalog/presentation/blocs/catalog/analysis_submission_cubit.dart';
import '../../lib/src/features/catalog/presentation/views/product_detail_view.dart';
import '../../lib/src/features/catalog/presentation/views/capture_entry_view.dart';
import '../../lib/src/features/catalog/presentation/widgets/product_result_content.dart';
import '../../lib/src/features/catalog/presentation/widgets/nutrition_fact_row.dart';
import '../../lib/src/features/catalog/presentation/widgets/interpretation_explanation.dart';
import '../../lib/src/features/catalog/presentation/widgets/analysis_submission_notice.dart';
import '../../lib/src/localization/l10n/app_localizations.dart';
import 'analysis_fixtures.dart';
import 'catalog_cubit_test.dart' show FakeCatalog;
import 'label_capture_test.dart' show DraftMedia, photo, pngFixture;

Widget host(Widget child, {bool dark = false, double scale = 1}) => MaterialApp(
  theme: dark
      ? AppTheme.darkTheme(AppColorScheme.darkColorScheme)
      : AppTheme.lightTheme(AppColorScheme.lightColorScheme),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, content) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: content!,
  ),
  home: child,
);
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'pending review is bounded and cancellable without infinite loading or trust certification',
    (tester) async {
      var cancelled = false, checked = false;
      await tester.pumpWidget(
        host(
          Scaffold(
            body: SingleChildScrollView(
              child: AnalysisSubmissionNotice(
                state: AnalysisSubmissionState(
                  phase: AnalysisPhase.review,
                  canRetry: true,
                  result: AnalysisResult(
                    AnalysisPhase.review,
                    reviewExpiresAt: DateTime.utc(2026, 11, 4, 12),
                  ),
                ),
                retry: () => checked = true,
                cancelReview: () => cancelled = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsNothing);
      await tester.tap(find.text('Cancel review'));
      expect(cancelled, true);
      await tester.tap(find.text('Check request again'));
      expect(checked, true);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('front identity observations show variant and quantity without a verification claim', (
    tester,
  ) async {
    final p = resultFixture();
    p.provenance['identity'] = {
      'front': {'variant': 'Original', 'net_quantity': '500 g'},
    };
    p.provenance['identity_verification'] = 'unverified';
    await tester.pumpWidget(host(Scaffold(body: ProductResultContent(product: p))));
    await tester.pumpAndSettle();
    expect(find.text('Original · 500 g'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('About this analysis'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('About this analysis'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text(
        'Barcode ownership has not been independently verified. Identity is read from the submitted packaging.',
      ),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.text(
        'Barcode ownership has not been independently verified. Identity is read from the submitted packaging.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('reviewed ingredient explanations expand with sources, limitations and uncertainty', (
    tester,
  ) async {
    final fixture = resultFixture();
    final product = ProductRecord(
      barcode: fixture.barcode,
      name: fixture.name,
      summary: 'This serving contributes sodium. Lecithin helps keep ingredients mixed.',
      nutrition: fixture.nutrition,
      ingredients: fixture.ingredients,
      findings: fixture.findings,
      explanations: [
        {
          'photo': 'ingredients',
          'source': 'Soy Lecithin',
          'ingredient': 'Soy Lecithin',
          'kind': 'background',
          'text': 'Commonly used to keep ingredients mixed and reduce separation.',
          'limitations': 'Common function only; exact dose is unknown.',
          'references': [
            {
              'id': 'fda-ingredients',
              'title': 'FDA: Types of Food Ingredients',
              'url':
                  'https://www.fda.gov/food/food-additives-and-gras-ingredients-information-consumers/types-food-ingredients',
            },
          ],
        },
      ],
      missingInformation: ['An unfamiliar ingredient has no matched reviewed reference.'],
      provenance: {
        'interpretation_version': 'evidence-composition-v1',
        'reference_version': '2026-11-03',
      },
    );
    final key = GlobalKey();
    await tester.pumpWidget(
      host(
        RepaintBoundary(
          key: key,
          child: Scaffold(body: ProductResultContent(product: product)),
        ),
      ),
    );
    await tester.scrollUntilVisible(
      find.byType(InterpretationExplanation),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Soy Lecithin'), findsOneWidget);
    await tester.ensureVisible(find.text('Soy Lecithin'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Soy Lecithin').hitTestable());
    await tester.pumpAndSettle();
    expect(
      find.text('Commonly used to keep ingredients mixed and reduce separation.'),
      findsOneWidget,
    );
    expect(find.text('Common function only; exact dose is unknown.'), findsOneWidget);
    expect(find.textContaining('FDA: Types of Food Ingredients'), findsOneWidget);
    expect(find.textContaining('https://www.fda.gov'), findsOneWidget);
    expect(find.text('Add to List'), findsNothing);
    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(tester.takeException(), isNull);
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File(
        '../.secrets/interpretation-results.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
    await tester.scrollUntilVisible(
      find.text('An unfamiliar ingredient has no matched reviewed reference.'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.text('An unfamiliar ingredient has no matched reviewed reference.'),
      findsOneWidget,
    );
  });
  testWidgets('printed units and historical unknown source remain visible', (tester) async {
    for (final entry in [
      ['IU', '71 IU'],
      ['ug RAE', '71 µg RAE'],
      ['ug DFE', '71 µg DFE'],
      ['mg NE', '71 mg NE'],
      ['mg α-TE', '71 mg α-TE'],
      ['%DV', '71 % DV'],
    ]) {
      await tester.pumpWidget(
        host(
          Scaffold(
            body: NutritionFactRow(
              nutrient: {
                'name': 'Vitamin D',
                'value': 71,
                'unit': entry[0],
                'source': 'Vitamin D 71 IU',
              },
            ),
          ),
        ),
      );
      expect(find.text(entry[1]), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(
      host(
        const Scaffold(
          body: NutritionFactRow(
            nutrient: {
              'name': 'Vitamin D',
              'value': null,
              'unit': 'unknown',
              'source': 'Vitamin D 71 IU',
            },
          ),
        ),
      ),
    );
    expect(find.text('“Vitamin D 71 IU”'), findsOneWidget);
    expect(find.text('71 IU'), findsNothing); // Source quote, not a fabricated parsed amount.
    expect(tester.takeException(), isNull);
  });
  setUpAll(() async {
    await (FontLoader(
      'Manrope',
    )..addFont(rootBundle.load('assets/fonts/Manrope/Manrope-Regular.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  for (final dark in [false, true]) {
    testWidgets('nested details show accountable findings and long/unknown content, dark=$dark', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(720, 1280);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = FakeCatalog(), cubit = CatalogCubit(GetCatalogUseCase(repo));
      repo.result = Right(
        CatalogEntity(
          status: LookupStatus.found,
          barcode: '00000096385074',
          product: resultFixture(),
        ),
      );
      await cubit.check('96385074', local: true);
      final key = GlobalKey();
      await tester.pumpWidget(
        host(
          RepaintBoundary(
            key: key,
            child: BlocProvider.value(value: cubit, child: const ProductDetailView()),
          ),
          dark: dark,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(CupertinoIcons.chevron_back), findsOneWidget);
      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
      expect(find.textContaining('92/100'), findsNothing);
      expect(find.text('Add to List'), findsNothing);
      await tester.scrollUntilVisible(
        find.text('Favourable finding'),
        150,
        scrollable: find
            .descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable))
            .first,
      );
      expect(find.text('Favourable finding'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Concern'),
        150,
        scrollable: find
            .descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable))
            .first,
      );
      expect(find.text('Concern'), findsOneWidget);
      expect(find.text('Needs context'), findsOneWidget);
      // Render only the real widget tree with explicitly synthetic content; no generated art.
      final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          '../.secrets/t061-results-${dark ? 'dark' : 'light'}.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      await tester.scrollUntilVisible(
        find.text('Declared allergens'),
        200,
        scrollable: find
            .descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable))
            .first,
      );
      expect(find.text('Contains milk.'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.textContaining('Per serving'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.scrollUntilVisible(
        find.text('About this analysis'),
        200,
        scrollable: find
            .descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable))
            .first,
      );
      expect(find.textContaining('fixture:no-provider'), findsNothing);
      await tester.tap(find.text('About this analysis'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.textContaining('fixture:no-provider'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('fixture:no-provider'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await cubit.close();
    });
  }
  testWidgets(
    'large text, missing photo/value/allergen/basis context remain explicit without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(640, 1280);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        host(Scaffold(body: ProductResultContent(product: resultFixture(missing: true))), scale: 2),
      );
      await tester.pumpAndSettle();
      final semantics = tester.ensureSemantics();
      expect(
        find.bySemanticsLabel(RegExp('Product photo unavailable; showing a placeholder')),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.text('No supported colour findings for the available label context.'),
        200,
        scrollable: find
            .descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable))
            .first,
      );
      await tester.scrollUntilVisible(
        find.text('Not stated'),
        200,
        scrollable: find
            .descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable))
            .first,
      );
      await tester.scrollUntilVisible(
        find.text('Nutrition'),
        200,
        scrollable: find
            .descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable))
            .first,
      );
      expect(find.text('Unknown'), findsWidgets);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );
  testWidgets(
    'processing/retake/unknown/error notices are explicit and have no fake progress percent',
    (tester) async {
      for (final phase in [
        AnalysisPhase.processing,
        AnalysisPhase.retake,
        AnalysisPhase.error,
        AnalysisPhase.blocked,
        AnalysisPhase.cleanupFailed,
      ]) {
        await tester.pumpWidget(
          host(
            Scaffold(
              body: AnalysisSubmissionNotice(
                state: AnalysisSubmissionState(
                  phase: phase,
                  result: const AnalysisResult(
                    AnalysisPhase.retake,
                    retake: {LabelKind.ingredients},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.textContaining('%'), findsNothing);
        expect(tester.takeException(), isNull);
      }
    },
  );
  testWidgets('accepted submission deletes the draft and navigates to the same product route', (
    tester,
  ) async {
    final dir = (await tester.runAsync(() => Directory.systemTemp.createTemp('submit_widget_')))!;
    final file = (await tester.runAsync(() => pngFixture(dir)))!;
    final media = DraftMedia()..next = photo(file.path);
    final actual = LabelCaptureCubit(CaptureLabelUseCase(media));
    await actual.begin('96385074');
    final previousPhoto = media.next;
    media.next = photo('front');
    await actual.capture(LabelKind.front);
    media.next = previousPhoto;
    await actual.capture(LabelKind.nutrition);
    media.next = photo('${file.path}-separate-mock-reference');
    await actual.capture(LabelKind.ingredients);
    final repo = FakeAnalysis()
      ..result = AnalysisResult(AnalysisPhase.ready, product: resultFixture());
    final sender = AnalysisSubmissionCubit(AnalyzeProductUseCase(repo), actual);
    final router = GoRouter(
      initialLocation: '/capture',
      routes: [
        GoRoute(
          path: '/capture',
          builder: (_, _) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: actual),
              BlocProvider.value(value: sender),
            ],
            child: const CaptureEntryView(barcode: '00000096385074'),
          ),
        ),
        GoRoute(
          path: '/capture-auth/:barcode',
          builder: (_, _) => Scaffold(
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () => context.pop(true),
                child: const Text('VERIFIED SESSION FIXTURE'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/product/:barcode',
          builder: (_, _) => Scaffold(body: ProductResultContent(product: resultFixture())),
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
    await tester.scrollUntilVisible(
      find.text('Analyze Product'),
      180,
      scrollable: find
          .descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable))
          .first,
    );
    await tester.ensureVisible(find.text('Analyze Product'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Analyze Product'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('VERIFIED SESSION FIXTURE'));
    await tester.pumpAndSettle();
    expect(find.byType(ProductResultContent), findsOneWidget);
    expect(actual.state.count, 0);
    expect(media.deleted.length, 3);
    expect(repo.requests.length, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
    await sender.close();
    await actual.close();
    await tester.runAsync(() => dir.delete(recursive: true));
  });
}
