import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/config/theme/_theme.dart';
import '../../lib/src/features/catalog/domain/_domain.dart';
import '../../lib/src/features/catalog/data/models/analysis_model.dart';
import '../../lib/src/features/catalog/presentation/blocs/catalog/analysis_submission_cubit.dart';
import '../../lib/src/features/catalog/presentation/widgets/analysis_submission_notice.dart';
import '../../lib/src/features/catalog/presentation/widgets/retake_diagnostic.dart';
import '../../lib/src/localization/l10n/app_localizations.dart';

Widget host(Widget child, {double scale = 1}) => MaterialApp(
  theme: AppTheme.lightTheme(AppColorScheme.lightColorScheme),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, c) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: c!,
  ),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);
void main() {
  test('retake parser accepts only closed diagnostics for requested photos', () {
    final r = AnalysisModel.parse({
      'status': 'needs_retake',
      'retake': ['nutrition'],
      'retake_details': [
        {
          'photo': 'nutrition',
          'source': 'validation',
          'code': 'numeric_source',
          'field': 'fat',
          'raw': 'PRIVATE payload',
        },
        {
          'photo': 'ingredients',
          'source': 'model',
          'code': 'cropped_label',
          'field': 'ingredients_list',
        },
        {'photo': 'nutrition', 'source': 'raw secret', 'code': 'wrong_photo', 'field': 'fat'},
        {
          'photo': 'nutrition',
          'source': 'model',
          'code': 'arbitrary provider text',
          'field': 'fat',
        },
      ],
    }, '00000096385074');
    expect(r.retakeDetails.length, 1);
    expect(r.retakeDetails.single.origin, RetakeOrigin.validation);
    expect(r.retakeDetails.single.cause, RetakeCause.numericSource);
    expect(r.retakeDetails.single.field, RetakeField.fat);
  });
  testWidgets('retake UI distinguishes model/photo issue from backend evidence failure', (
    tester,
  ) async {
    final r = AnalysisModel.parse({
      'status': 'needs_retake',
      'retake': ['nutrition', 'ingredients'],
      'retake_details': [
        {'photo': 'nutrition', 'source': 'validation', 'code': 'numeric_source', 'field': 'fat'},
        {
          'photo': 'ingredients',
          'source': 'model',
          'code': 'cropped_label',
          'field': 'ingredients_list',
        },
      ],
    }, '00000096385074');
    await tester.pumpWidget(
      host(
        AnalysisSubmissionNotice(
          state: AnalysisSubmissionState(phase: AnalysisPhase.retake, result: r),
        ),
      ),
    );
    expect(find.text('Validation check · Fat'), findsOneWidget);
    expect(find.text('Meta photo review · Ingredient list'), findsOneWidget);
    expect(find.textContaining('matched to the transcribed label text'), findsOneWidget);
    expect(find.textContaining('Include the complete panel'), findsOneWidget);
    expect(find.textContaining('PRIVATE'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('legacy response admits unknown reason without inventing blur or wrong input', (
    tester,
  ) async {
    final r = AnalysisModel.parse({
      'status': 'needs_retake',
      'retake': ['nutrition'],
    }, '00000096385074');
    await tester.pumpWidget(
      host(
        AnalysisSubmissionNotice(
          state: AnalysisSubmissionState(phase: AnalysisPhase.retake, result: r),
        ),
      ),
    );
    expect(find.textContaining('No specific reason was stored'), findsOneWidget);
    expect(find.textContaining('Meta reported blur'), findsNothing);
  });
  testWidgets(
    'all reason messages render with long text and large scale; origin changes unreadable-values wording',
    (tester) async {
      for (final cause in RetakeCause.values) {
        await tester.pumpWidget(
          host(
            RetakeDiagnostic(
              detail: RetakeDetail(
                photo: LabelKind.nutrition,
                origin: RetakeOrigin.validation,
                cause: cause,
                field: RetakeField.nutritionPanel,
              ),
            ),
            scale: 2,
          ),
        );
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(
        host(
          const RetakeDiagnostic(
            detail: RetakeDetail(
              photo: LabelKind.nutrition,
              origin: RetakeOrigin.model,
              cause: RetakeCause.noReadableValues,
              field: RetakeField.nutritionPanel,
            ),
          ),
        ),
      );
      expect(find.textContaining('Meta could not read any numeric'), findsOneWidget);
    },
  );
  testWidgets('only legacy-authorized results offer an explicit paid saved-photo recheck', (
    tester,
  ) async {
    var clicks = 0;
    final r = AnalysisModel.parse({
      'status': 'needs_retake',
      'retake': ['nutrition'],
      'allow_diagnostic_reanalysis': true,
    }, '00000096385074');
    await tester.pumpWidget(
      host(
        AnalysisSubmissionNotice(
          state: AnalysisSubmissionState(phase: AnalysisPhase.retake, result: r),
          reanalyzeSaved: () => clicks++,
        ),
      ),
    );
    expect(find.text('Reanalyze saved photos'), findsOneWidget);
    expect(find.textContaining('counts as another provider attempt'), findsOneWidget);
    await tester.tap(find.text('Reanalyze saved photos'));
    expect(clicks, 1);
    final modern = AnalysisModel.parse({
      'status': 'needs_retake',
      'retake': ['nutrition'],
    }, '00000096385074');
    await tester.pumpWidget(
      host(
        AnalysisSubmissionNotice(
          state: AnalysisSubmissionState(phase: AnalysisPhase.retake, result: modern),
          reanalyzeSaved: () => clicks++,
        ),
      ),
    );
    expect(find.text('Reanalyze saved photos'), findsNothing);
  });
}
