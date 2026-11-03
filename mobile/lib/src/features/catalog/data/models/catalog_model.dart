import '../../domain/entities/catalog_entity.dart';
import '../../domain/entities/quota_snapshot.dart';
import 'quota_model.dart';

class CatalogModel {
  static CatalogEntity parse(Map<String, dynamic> json, String barcode) {
    final status = switch (json['status']) {
      'ready' => LookupStatus.found,
      'not_found' => LookupStatus.miss,
      'processing' => LookupStatus.processing,
      'rate_limited' || 'quota_exceeded' => LookupStatus.denied,
      'error' => LookupStatus.error,
      _ => throw const FormatException(),
    };
    ProductRecord? product;
    if (status == LookupStatus.found) {
      final p = Map<String, dynamic>.from(json['product'] as Map);
      if (p['barcode'] != barcode || p['summary'] is! String) throw const FormatException();
      final nutrition = Map<String, dynamic>.from(p['nutrition'] as Map);
      final ingredients = Map<String, dynamic>.from(p['ingredients'] as Map);
      if (nutrition['raw'] is! String ||
          !{'per_100g', 'per_100ml', 'per_serving'}.contains(nutrition['basis']) ||
          nutrition['nutrients'] is! List ||
          ingredients['raw'] is! String ||
          ingredients['items'] is! List ||
          !(ingredients['items'] as List).every((e) => e is String)) {
        throw const FormatException();
      }
      if (nutrition['basis'] == 'per_serving' && nutrition['serving_size'] is! String) {
        throw const FormatException();
      }
      for (final value in nutrition['nutrients'] as List) {
        if (value is! Map ||
            value['name'] is! String ||
            !{'g', 'mg', 'ug', 'kcal', 'kJ', 'unknown'}.contains(value['unit'])) {
          throw const FormatException();
        }
        final number = value['value'];
        if (number != null &&
            (number is! num || !number.isFinite || number < 0 || value['unit'] == 'unknown')) {
          throw const FormatException();
        }
      }
      final findings = (p['findings'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(growable: false);
      for (final f in findings) {
        if (!{'green', 'yellow', 'red'}.contains(f['severity']) ||
            f['title'] is! String ||
            f['explanation'] is! String) {
          throw const FormatException();
        }
      }
      for (final finding in findings) {
        final details = finding['source_details'];
        if (details is! Map ||
            details['rule_id'] is! String ||
            details['evidence'] is! List ||
            (details['evidence'] as List).isEmpty) {
          throw const FormatException();
        }
        if (!(details['evidence'] as List).every((entry) => entry is Map)) {
          throw const FormatException();
        }
        if (details['thresholds'] != null && details['thresholds'] is! Map) {
          throw const FormatException();
        }
        if (details['portion'] != null && details['portion'] is! Map) throw const FormatException();
      }
      final explanations = (p['explanations'] as List? ?? [])
          .map((v) => Map<String, dynamic>.from(v as Map))
          .toList();
      if (!explanations.every(
        (v) =>
            ['nutrition', 'ingredients'].contains(v['photo']) &&
            v['source'] is String &&
            v['text'] is String,
      )) {
        throw const FormatException();
      }
      final missing = p['missing_information'] as List? ?? [];
      if (!missing.every((v) => v is String)) throw const FormatException();
      product = ProductRecord(
        barcode: barcode,
        name: p['name'] as String?,
        brand: p['brand'] as String?,
        summary: p['summary'] as String,
        nutrition: Map.unmodifiable(nutrition),
        ingredients: Map.unmodifiable(ingredients),
        findings: List.unmodifiable(findings.map((f) => Map<String, dynamic>.unmodifiable(f))),
        isDemo: p['is_demo'] == true,
        explanations: List.unmodifiable(
          explanations.map((v) => Map<String, dynamic>.unmodifiable(v)),
        ),
        missingInformation: List<String>.unmodifiable(missing),
        analyzedAt: p['analyzed_at'] is String
            ? DateTime.tryParse(p['analyzed_at'] as String)
            : null,
        provenance: Map<String, dynamic>.unmodifiable(
          p['provenance'] is Map ? p['provenance'] as Map : {},
        ),
        modelVersion: p['model_version'] as String?,
        rulesVersion: p['rules_version'] as String?,
      );
    }
    return CatalogEntity(
      status: status,
      barcode: barcode,
      product: product,
      quota: QuotaModel.parse(json, QuotaMetric.barcodeLookup),
      errorCode:
          json['error'] as String? ??
          (status == LookupStatus.denied ? json['status'] as String : null),
    );
  }
}
