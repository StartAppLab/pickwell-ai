import 'catalog_entity.dart';

/// Presentation of validated fields only; never infers identity from label prose,
/// serving size, barcode or a thumbnail. Front observations remain observations.
class ProductDisplayIdentity {
  final String? brand, name, variant, netQuantity;
  const ProductDisplayIdentity({this.brand, this.name, this.variant, this.netQuantity});

  factory ProductDisplayIdentity.fromProduct(ProductRecord? product) {
    final identity = product?.provenance['identity'];
    final front = identity is Map ? identity['front'] : null;
    final observed = front is Map ? front : const <String, Object?>{};
    return ProductDisplayIdentity(
      brand: _text(product?.brand) ?? _text(observed['brand']),
      name: _text(product?.name) ?? _text(observed['product_name']),
      variant: _text(observed['variant']),
      netQuantity: _text(observed['net_quantity']),
    );
  }

  String? get subtitle {
    final parts = [variant, netQuantity].whereType<String>().toList(growable: false);
    return parts.isEmpty ? null : parts.join(' · ');
  }

  static String? _text(Object? value) {
    if (value is! String) return null;
    final text = value.trim();
    return text.isEmpty ? null : text;
  }
}
