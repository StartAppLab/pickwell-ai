part of 'catalog_cubit.dart';

class CatalogState {
  final LookupStatus status;
  final String? barcode, error;
  final ProductRecord? product;
  final QuotaSnapshot? quota;
  final bool recentSaved;
  const CatalogState({
    this.status = LookupStatus.idle,
    this.barcode,
    this.error,
    this.product,
    this.quota,
    this.recentSaved = true,
  });
}
