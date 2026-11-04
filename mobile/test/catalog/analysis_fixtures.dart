import 'dart:async';
import 'package:fpdart/fpdart.dart';
import '../../lib/src/core/errors/_errors.dart';
import '../../lib/src/features/catalog/domain/_domain.dart';

class FakeAnalysis extends AnalysisRepository {
  final requests = <AnalysisRequest>[];
  AnalysisResult result = const AnalysisResult(
    AnalysisPhase.retake,
    retake: {LabelKind.ingredients},
  );
  Completer<Either<Failure, AnalysisResult>>? pending;
  bool transportError = false;
  int cancelledReviews = 0;
  @override
  Future<Either<Failure, AnalysisResult>> cancelReview(String requestId, String barcode) async {
    cancelledReviews++;
    return const Right(AnalysisResult(AnalysisPhase.idle));
  }

  @override
  Future<Either<Failure, AnalysisResult>> submit(AnalysisRequest request) async {
    requests.add(request);
    if (pending != null) return pending!.future;
    if (transportError) {
      return Left(
        ServerFailure(
          error: const DataError(stackTrace: 'fixture', statusCode: 'unavailable'),
        ),
      );
    }
    return Right(result);
  }
}

ProductRecord resultFixture({bool missing = false}) => ProductRecord(
  barcode: '00000096385074',
  name: 'SYNTHETIC WIDGET FIXTURE',
  brand: 'Test fixture',
  isDemo: true,
  summary: 'Synthetic label facts only; not a real food analysis.',
  nutrition: {
    'raw': 'Per serving (30 g)',
    'basis': 'per_serving',
    'serving_size': '30 g',
    'nutrients': [
      {'name': 'Protein', 'value': missing ? null : 4, 'unit': 'g'},
      {
        'name': 'A very long nutrient description that must wrap without hiding its units',
        'value': missing ? null : 2.5,
        'unit': missing ? 'unknown' : 'ug',
      },
    ],
  },
  ingredients: {
    'raw': 'Oats, milk. Contains milk.',
    'items': [
      'Oats',
      'An exceptionally long compound ingredient description that must wrap on small screens, including its sub-ingredients',
    ],
    'declared_allergens': missing ? null : 'Contains milk.',
  },
  findings: missing
      ? []
      : [
          for (final severity in ['green', 'yellow', 'red'])
            {
              'severity': severity,
              'title': '$severity nutrient reference',
              'explanation': 'Specific nutrient context only; not an overall certification.',
              'source_details': {
                'rule_id': 'synthetic:$severity',
                'evidence': [
                  {'source': 'Printed fixture span'},
                ],
              },
            },
        ],
  explanations: [
    {'photo': 'ingredients', 'source': 'Oats', 'text': 'The ingredient label states: Oats'},
  ],
  missingInformation: missing ? ['Serving context could not be confirmed.'] : [],
  analyzedAt: DateTime.utc(2026, 11, 3),
  modelVersion: 'fixture:no-provider',
  rulesVersion: 'fixture:rules',
  provenance: {'prompt_version': 'fixture:prompt'},
);
