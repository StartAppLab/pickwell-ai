import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/config/app_config.dart';
import '../lib/src/config/app_features.dart';

AppConfig config(String key, {bool backend = false}) => AppConfig(
  features: AppFeatures(backendEnabled: backend),
  baseUrl: 'https://example.supabase.co',
  apiKey: key,
  sentryDsn: '',
  postHogApiKey: '',
  postHogHost: '',
  revenueCatAndroidApiKey: '',
  revenueCatiOSApiKey: '',
  revenueCatEntitlementId: '',
);

String jwt(String role) =>
    'header.${base64Url.encode(utf8.encode(jsonEncode({'role': role}))).replaceAll('=', '')}.signature';

void main() {
  test('privileged and malformed keys fail before bootstrap without leaking values', () {
    for (final backend in [false, true]) {
      for (final key in [
        'sb_secret_${'fixture' * 8}',
        jwt('service_role'),
        jwt('authenticated'),
        'bad',
      ]) {
        try {
          config(key, backend: backend).validate();
          fail('Private or malformed key accepted');
        } on ArgumentError catch (error) {
          expect(error.toString(), isNot(contains(key)));
          expect(error.toString(), contains('public Supabase key'));
        }
      }
    }
  });

  test('public credentials and disabled offline defaults remain supported', () {
    config('').validate();
    config('sb_publishable_fixture', backend: true).validate();
    config(jwt('anon'), backend: true).validate();
    expect(() => config('', backend: true).validate(), throwsArgumentError);
  });
}
