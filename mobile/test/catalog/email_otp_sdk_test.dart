import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../lib/src/config/app_config.dart';
import '../../lib/src/config/app_features.dart';
import '../../lib/src/features/auth/data/data_sources/services/auth_api_service.dart';
import '../../lib/src/features/auth/data/data_sources/services/email_otp_api_service.dart';
import '../../lib/src/features/auth/data/repositories/email_otp_repository.dart';

AppConfig config(String url, {bool enabled = true}) => AppConfig(
  features: AppFeatures(authMode: enabled ? AuthMode.optional : AuthMode.disabled),
  baseUrl: url,
  apiKey: 'public-fixture',
  sentryDsn: '',
  postHogApiKey: '',
  postHogHost: '',
  revenueCatAndroidApiKey: '',
  revenueCatiOSApiKey: '',
  revenueCatEntitlementId: '',
);
Map<String, dynamic> fixtureSession({bool expired = false}) {
  String encode(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  final exp = DateTime.now().millisecondsSinceEpoch ~/ 1000 + (expired ? -100 : 3600);
  return {
    'access_token': '${encode({'alg': 'HS256', 'typ': 'JWT'})}.${encode({'exp': exp})}.fixture',
    'refresh_token': 'refresh-fixture',
    'token_type': 'bearer',
    'expires_in': expired ? -100 : 3600,
    'user': {
      'id': '10000000-0000-4000-8000-000000000001',
      'aud': 'authenticated',
      'email': 'fixture@example.invalid',
      'email_confirmed_at': '2026-11-02T00:00:00Z',
      'created_at': '2026-11-02T00:00:00Z',
      'app_metadata': {},
      'user_metadata': {},
      'is_anonymous': false,
    },
  };
}

void main() {
  test(
    'SDK adapter uses real loopback Auth/Functions HTTP, safe errors, cooldown and serialized session restore',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final url = 'http://127.0.0.1:${server.port}';
      final trace = <String>[];
      var authStatus = 200;
      final subscription = server.listen((request) async {
        final path = request.uri.path;
        trace.add(path);
        final text = await utf8.decoder.bind(request).join();
        final body = text.isEmpty ? <String, dynamic>{} : jsonDecode(text) as Map;
        request.response.headers.contentType = ContentType.json;
        Object response = {};
        if (path == '/auth/v1/otp') {
          expect(body['email'], 'fixture@example.invalid');
          expect(body['create_user'], true);
        } else if (path == '/auth/v1/verify') {
          if (body['token'] == '00000000') {
            request.response.statusCode = 403;
            response = {'error_code': 'otp_expired', 'msg': 'PRIVATE fixture diagnostic'};
          } else {
            response = fixtureSession();
          }
        } else if (path == '/functions/v1/authorize-analysis') {
          request.response.statusCode = authStatus;
          response = authStatus == 200
              ? {'status': 'authorized'}
              : {'error': 'service_unavailable'};
        } else {
          request.response.statusCode = 404;
        }
        request.response.write(jsonEncode(response));
        await request.response.close();
      });
      SupabaseClient client() => SupabaseClient(
        url,
        'public-fixture',
        authOptions: const AuthClientOptions(
          autoRefreshToken: false,
          authFlowType: AuthFlowType.implicit,
        ),
      );
      final first = client(), restored = client();
      final c = config(url);
      EmailOtpRepositoryImpl repo(SupabaseClient sdk) =>
          EmailOtpRepositoryImpl(EmailOtpApiService(sdk, c, AuthApiServiceImpl(sdk, c)));
      final api = repo(first);
      try {
        expect((await api.authorize()).getOrElse((_) => true), false);
        expect(trace, isEmpty);
        expect((await api.send('fixture@example.invalid')).isRight(), true);
        expect((await api.send('fixture@example.invalid')).isLeft(), true);
        expect(trace.where((p) => p == '/auth/v1/otp').length, 1);
        final wrong = await api.verify('fixture@example.invalid', '00000000');
        expect(wrong.isLeft(), true);
        wrong.fold((f) {
          expect(f.error.statusCode, 'invalid_code');
          expect(f.error.stackTrace, 'email_otp');
        }, (_) => fail('Unexpected authorization'));
        final good = await api.verify('fixture@example.invalid', '12345678');
        expect(good.getOrElse((_) => false), true);
        final saved = jsonEncode(first.auth.currentSession!.toJson());
        await restored.auth.recoverSession(saved);
        expect((await repo(restored).authorize()).getOrElse((_) => false), true);
        authStatus = 503;
        expect((await repo(restored).authorize()).isLeft(), true);
        authStatus = 403;
        expect((await repo(restored).authorize()).getOrElse((_) => true), false);
        expect(
          trace.every((p) => p.startsWith('/auth/') || p == '/functions/v1/authorize-analysis'),
          true,
        );
      } finally {
        await first.dispose();
        await restored.dispose();
        await subscription.cancel();
        await server.close(force: true);
      }
    },
  );

  test(
    'expired SDK session refresh is attempted, rejected refresh needs email, disabled mode never calls Auth',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final url = 'http://127.0.0.1:${server.port}';
      final trace = <String>[];
      final subscription = server.listen((request) async {
        trace.add(request.uri.path);
        await request.drain<void>();
        request.response.statusCode = 400;
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode({'error_code': 'refresh_token_not_found', 'msg': 'Refresh session fixture'}),
        );
        await request.response.close();
      });
      final sdk = SupabaseClient(
        url,
        'public-fixture',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      );
      try {
        await sdk.auth.setInitialSession(jsonEncode(fixtureSession(expired: true)));
        final c = config(url), disabled = config(url, enabled: false);
        final api = EmailOtpApiService(sdk, c, AuthApiServiceImpl(sdk, c));
        expect(await api.authorize(), false);
        expect(trace, contains('/auth/v1/token'));
        final before = trace.length;
        final off = EmailOtpRepositoryImpl(
          EmailOtpApiService(sdk, disabled, AuthApiServiceImpl(sdk, disabled)),
        );
        expect((await off.send('fixture@example.invalid')).isLeft(), true);
        expect(trace.length, before);
      } finally {
        await sdk.dispose();
        await subscription.cancel();
        await server.close(force: true);
      }
    },
  );
}
