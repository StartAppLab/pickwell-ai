import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../config/app_config.dart';
import '../../../domain/entities/analysis_entity.dart';
import '../../../domain/entities/label_photo.dart';

abstract class AnalysisApiService {
  Future<Map<String, dynamic>> submit(AnalysisRequest request);
}

@LazySingleton(as: AnalysisApiService)
class SupabaseAnalysisApiService implements AnalysisApiService {
  final AppConfig config;
  final SupabaseClient? _client;
  SupabaseAnalysisApiService(this.config) : _client = null;
  SupabaseAnalysisApiService.withClient(this.config, this._client);

  Future<Uint8List> _bytes(LabelPhoto photo) async {
    const limit = 5 * 1024 * 1024;
    if (photo.byteLength <= 0 ||
        photo.byteLength > limit ||
        photo.width > 2400 ||
        photo.height > 2400) {
      throw StateError('invalid_image');
    }
    final builder = BytesBuilder(copy: false);
    await for (final chunk in File(photo.path).openRead()) {
      if (builder.length + chunk.length > limit) throw StateError('invalid_image');
      builder.add(chunk);
    }
    final bytes = builder.takeBytes();
    if (bytes.length != photo.byteLength || bytes.length < 24) throw StateError('invalid_image');
    final png =
        bytes[0] == 137 &&
        bytes[1] == 80 &&
        bytes[2] == 78 &&
        bytes[3] == 71 &&
        bytes[4] == 13 &&
        bytes[5] == 10 &&
        bytes[6] == 26 &&
        bytes[7] == 10;
    final jpeg =
        bytes[0] == 255 && bytes[1] == 216 && bytes[bytes.length - 2] == 255 && bytes.last == 217;
    if (!(png && photo.mimeType == 'image/png') && !(jpeg && photo.mimeType == 'image/jpeg')) {
      throw StateError('invalid_image');
    }
    return bytes;
  }

  @override
  Future<Map<String, dynamic>> submit(AnalysisRequest request) async {
    if (!config.features.backendEnabled || !config.features.authEnabled) {
      return {'status': 'auth_required'};
    }
    final client = _client ?? Supabase.instance.client;
    var session = client.auth.currentSession;
    if (session == null) return {'status': 'auth_required'};
    if (session.isExpired) {
      try {
        session = (await client.auth.refreshSession().timeout(const Duration(seconds: 10))).session;
      } on AuthException catch (error) {
        if (['400', '401', '403'].contains(error.statusCode)) return {'status': 'auth_required'};
        rethrow;
      }
      if (session == null) return {'status': 'auth_required'};
    }
    final owner = session.user.id;
    Uint8List nutrition, ingredients;
    try {
      nutrition = await _bytes(request.nutrition).timeout(const Duration(seconds: 10));
    } catch (_) {
      return {
        'status': 'needs_retake',
        'retake': ['nutrition'],
      };
    }
    try {
      ingredients = await _bytes(request.ingredients).timeout(const Duration(seconds: 10));
    } catch (_) {
      return {
        'status': 'needs_retake',
        'retake': ['ingredients'],
      };
    }
    if (client.auth.currentUser?.id != owner) return {'status': 'auth_required'};
    final abort = Completer<void>();
    final timer = Timer(const Duration(seconds: 45), () {
      if (!abort.isCompleted) abort.complete();
    });
    try {
      final response = await client.functions
          .invoke(
            'analyze-product',
            body: <String, String>{
              'barcode': request.barcode,
              'idempotency_key': request.requestId,
            },
            files: [
              MultipartFile.fromBytes('nutrition_image', nutrition, filename: 'nutrition'),
              MultipartFile.fromBytes('ingredients_image', ingredients, filename: 'ingredients'),
            ],
            headers: {
              'apikey': config.apiKey,
              'Authorization': 'Bearer ${session.accessToken}',
              'Idempotency-Key': request.requestId,
            },
            abortSignal: abort.future,
          )
          .timeout(const Duration(seconds: 46));
      if (client.auth.currentUser?.id != owner) return {'status': 'auth_required'};
      if ([401, 403].contains(response.status)) return {'status': 'auth_required'};
      if (response.data is! Map) throw const FormatException();
      return Map<String, dynamic>.from(response.data as Map);
    } on FunctionException catch (error) {
      if ([401, 403].contains(error.status) || client.auth.currentUser?.id != owner) {
        return {'status': 'auth_required'};
      }
      if (error.details is Map) return Map<String, dynamic>.from(error.details as Map);
      rethrow;
    } finally {
      timer.cancel();
    }
  }
}
