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
    Map<String, dynamic> scoped(Object? data) {
      final result = Map<String, dynamic>.from(data as Map);
      result['_quota_subject'] = session?.user.id;
      if (client.auth.currentUser?.id != session?.user.id) {
        result.remove('quota');
        result['_quota_subject'] = null;
      }
      return result;
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
      return scoped(response.data);
    } on FunctionException catch (e) {
      if (e.details is Map) return scoped(e.details);
      rethrow;
    }
  }
}
