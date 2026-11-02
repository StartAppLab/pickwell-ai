import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../config/app_config.dart';

abstract class CatalogApiService {
  Future<Map<String, dynamic>> lookup(String barcode, String requestId);
}

@LazySingleton(as: CatalogApiService)
class SupabaseCatalogApiService implements CatalogApiService {
  final AppConfig config;
  SupabaseCatalogApiService(this.config);
  @override
  Future<Map<String, dynamic>> lookup(String barcode, String requestId) async {
    if (!config.features.backendEnabled) throw StateError('backend_disabled');
    final client = Supabase.instance.client;
    var session = client.auth.currentSession;
    if (session != null && session.isExpired) {
      session = (await client.auth.refreshSession().timeout(const Duration(seconds: 10))).session;
      if (session == null) throw StateError('session_expired');
    }
    try {
      final response = await client.functions
          .invoke(
            'get-product',
            body: {'barcode': barcode},
            headers: {
              'Idempotency-Key': requestId,
              'apikey': config.apiKey,
              'Authorization': 'Bearer ${session?.accessToken ?? config.apiKey}',
            },
          )
          .timeout(const Duration(seconds: 15));
      return Map<String, dynamic>.from(response.data as Map);
    } on FunctionException catch (e) {
      if (e.details is Map) return Map<String, dynamic>.from(e.details as Map);
      rethrow;
    }
  }
}
