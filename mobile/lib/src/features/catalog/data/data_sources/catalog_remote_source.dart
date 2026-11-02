import 'package:injectable/injectable.dart';
import 'services/catalog_api_service.dart';

@lazySingleton
class CatalogRemoteSource {
  final CatalogApiService service;
  CatalogRemoteSource(this.service);
  Future<Map<String, dynamic>> lookup(String barcode, String key) => service.lookup(barcode, key);
}
