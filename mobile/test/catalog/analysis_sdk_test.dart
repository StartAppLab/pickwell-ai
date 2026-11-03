import '../../lib/src/config/app_config.dart';
import '../../lib/src/config/app_features.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../lib/src/features/catalog/data/data_sources/services/analysis_api_service.dart';
import '../../lib/src/features/catalog/domain/_domain.dart';
import 'email_otp_sdk_test.dart' show config, fixtureSession;
import 'label_capture_test.dart' show pngFixture;

void main() {
  test(
    'SDK submits binary two-file multipart only with user session, reuses key and parses safe failures',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final url = 'http://127.0.0.1:${server.port}',
          dir = await Directory.systemTemp.createTemp('analysis_sdk_');
      final calls = <String>[], bodies = <String>[];
      var status = 202;
      final listener = server.listen((request) async {
        final bytes = await request.fold<List<int>>(
          [],
          (previous, chunk) => previous..addAll(chunk),
        );
        calls.add(request.uri.path);
        bodies.add(latin1.decode(bytes));
        expect(request.uri.path, '/functions/v1/analyze-product');
        expect(request.headers.contentType!.mimeType, 'multipart/form-data');
        expect(request.headers.value('authorization'), isNot('Bearer public-fixture'));
        expect(
          request.headers.value('idempotency-key'),
          bodies.last.contains('stable-request') ? 'stable-request' : isNotNull,
        );
        request.response.statusCode = status;
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode(
            status == 401
                ? {'error': 'PRIVATE provider error'}
                : {'status': 'processing', 'retry_after_seconds': 4},
          ),
        );
        await request.response.close();
      });
      final sdk = SupabaseClient(
        url,
        'public-fixture',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      );
      try {
        final file = await pngFixture(dir), bytes = await file.readAsBytes();
        final other = await pngFixture(dir, width: 17);
        LabelPhoto photo(String path) => LabelPhoto(
          path: path,
          mimeType: 'image/png',
          byteLength: bytes.length,
          width: 16,
          height: 16,
          capturedAt: DateTime.now(),
        );
        final request = AnalysisRequest(
          barcode: '00000096385074',
          requestId: 'stable-request',
          nutrition: photo(file.path),
          ingredients: LabelPhoto(
            path: other.path,
            mimeType: 'image/png',
            byteLength: await other.length(),
            width: 17,
            height: 16,
            capturedAt: DateTime.now(),
          ),
        );
        final api = SupabaseAnalysisApiService.withClient(
          AppConfig(
            features: const AppFeatures(authMode: AuthMode.optional, backendEnabled: true),
            baseUrl: url,
            apiKey: 'public-fixture',
            sentryDsn: '',
            postHogApiKey: '',
            postHogHost: '',
            revenueCatAndroidApiKey: '',
            revenueCatiOSApiKey: '',
            revenueCatEntitlementId: '',
          ),
          sdk,
        );
        expect((await api.submit(request))['status'], 'auth_required');
        expect(calls, isEmpty);
        await sdk.auth.setInitialSession(jsonEncode(fixtureSession()));
        expect((await api.submit(request))['status'], 'processing');
        expect((await api.submit(request))['status'], 'processing');
        expect(calls.length, 2);
        for (final body in bodies) {
          expect(body, contains('name="nutrition_image"'));
          expect(body, contains('name="ingredients_image"'));
          expect(body, contains('stable-request'));
          expect(body, contains('00000096385074'));
          expect(body, contains('PNG'));
          expect(body, isNot(contains('name="user_id"')));
          expect(body, isNot(contains('name="verified"')));
          expect(body, isNot(contains(file.path)));
        }
        status = 401;
        expect((await api.submit(request))['status'], 'auth_required');
        final invalid = AnalysisRequest(
          barcode: request.barcode,
          requestId: request.requestId,
          nutrition: LabelPhoto(
            path: file.path,
            mimeType: 'image/png',
            byteLength: 6 * 1024 * 1024,
            width: 16,
            height: 16,
            capturedAt: DateTime.now(),
          ),
          ingredients: request.ingredients,
        );
        final before = calls.length;
        expect((await api.submit(invalid))['retake'], ['nutrition']);
        expect(calls.length, before);
        final off = SupabaseAnalysisApiService.withClient(config(url, enabled: false), sdk);
        expect((await off.submit(request))['status'], 'auth_required');
        expect(calls.length, before);
      } finally {
        await sdk.dispose();
        await listener.cancel();
        await server.close(force: true);
        await dir.delete(recursive: true);
      }
    },
  );
  test('expired SDK session is refreshed; rejected refresh never uploads photos', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0), paths = <String>[];
    final listener = server.listen((request) async {
      paths.add(request.uri.path);
      await request.drain<void>();
      request.response.statusCode = 400;
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode({'error_code': 'refresh_token_not_found', 'msg': 'Synthetic refresh rejection'}),
      );
      await request.response.close();
    });
    final url = 'http://127.0.0.1:${server.port}';
    final client = SupabaseClient(
      url,
      'public-fixture',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    try {
      await client.auth.setInitialSession(jsonEncode(fixtureSession(expired: true)));
      final api = SupabaseAnalysisApiService.withClient(
        AppConfig(
          features: const AppFeatures(authMode: AuthMode.optional, backendEnabled: true),
          baseUrl: url,
          apiKey: 'public-fixture',
          sentryDsn: '',
          postHogApiKey: '',
          postHogHost: '',
          revenueCatAndroidApiKey: '',
          revenueCatiOSApiKey: '',
          revenueCatEntitlementId: '',
        ),
        client,
      );
      final photo = LabelPhoto(
        path: 'never-read',
        mimeType: 'image/png',
        byteLength: 24,
        width: 1,
        height: 1,
        capturedAt: DateTime.now(),
      );
      final result = await api.submit(
        AnalysisRequest(
          barcode: '00000096385074',
          requestId: createCatalogRequestId(),
          nutrition: photo,
          ingredients: photo,
        ),
      );
      expect(result['status'], 'auth_required');
      expect(paths, ['/auth/v1/token']);
    } finally {
      await client.dispose();
      await listener.cancel();
      await server.close(force: true);
    }
  });
}
