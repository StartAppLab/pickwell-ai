import 'dart:math';

enum LookupStatus { idle, scanning, checking, found, miss, processing, denied, error }

class ProductRecord {
  final String barcode;
  final String? name, brand;
  final String summary;
  final Map<String, dynamic> nutrition, ingredients;
  final List<Map<String, dynamic>> findings;
  final bool isDemo;
  const ProductRecord({
    required this.barcode,
    this.name,
    this.brand,
    required this.summary,
    required this.nutrition,
    required this.ingredients,
    required this.findings,
    this.isDemo = false,
  });
}

class RecentProduct {
  final String barcode;
  final DateTime openedAt;
  final ProductRecord? product;
  const RecentProduct(this.barcode, this.openedAt, {this.product});
}

class CatalogEntity {
  final LookupStatus status;
  final String barcode;
  final ProductRecord? product;
  final Map<String, dynamic>? quota;
  final String? errorCode;
  final bool recentSaved;
  const CatalogEntity({
    required this.status,
    required this.barcode,
    this.product,
    this.quota,
    this.errorCode,
    this.recentSaved = true,
  });
}

String normalizeGtin(String input, {bool upce = false}) {
  var code = input.trim();
  if (upce) {
    if (!RegExp(r'^[01][0-9]{7}$').hasMatch(code)) throw const FormatException();
    final d = code.substring(1, 7), f = int.parse(code[6]);
    code =
        code[0] +
        (f <= 2
            ? '${d.substring(0, 2)}${d[5]}0000${d.substring(2, 5)}'
            : f == 3
            ? '${d.substring(0, 3)}00000${d.substring(3, 5)}'
            : f == 4
            ? '${d.substring(0, 4)}00000${d[4]}'
            : '${d.substring(0, 5)}0000${d[5]}') +
        code[7];
  }
  if (!RegExp(r'^([0-9]{8}|[0-9]{12}|[0-9]{13}|[0-9]{14})$').hasMatch(code)) {
    throw const FormatException();
  }
  var sum = 0;
  for (var n = 1; n < code.length; n++) {
    sum += int.parse(code[code.length - 1 - n]) * (n.isOdd ? 3 : 1);
  }
  if ((10 - sum % 10) % 10 != int.parse(code[code.length - 1])) throw const FormatException();
  return code.padLeft(14, '0');
}

// Request identity is independent of UI and never conveys user authorization.
String createCatalogRequestId() {
  final random = Random.secure();
  final bytes = List.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 15) | 64;
  bytes[8] = (bytes[8] & 63) | 128;
  final s = bytes.map((v) => v.toRadixString(16).padLeft(2, '0')).join();
  return '${s.substring(0, 8)}-${s.substring(8, 12)}-${s.substring(12, 16)}-${s.substring(16, 20)}-${s.substring(20)}';
}

List<RecentProduct> filterRecentProducts(
  List<RecentProduct> items, {
  String query = '',
  bool foodOnly = false,
}) {
  final needle = query.trim().toLowerCase();
  final visible = items.where((entry) {
    // Published Pickwell records currently describe food only. Unresolved
    // references have no known category and remain available under All.
    if (foodOnly && entry.product == null) return false;
    final text = '${entry.product?.name ?? ''} ${entry.product?.brand ?? ''} ${entry.barcode}';
    return needle.isEmpty || text.toLowerCase().contains(needle);
  }).toList();
  visible.sort((a, b) => b.openedAt.compareTo(a.openedAt));
  return visible;
}
