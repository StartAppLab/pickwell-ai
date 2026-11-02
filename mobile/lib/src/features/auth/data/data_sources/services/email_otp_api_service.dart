import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../config/app_config.dart';
import 'auth_api_service.dart';

class EmailGateException implements Exception {
  final String code;
  const EmailGateException(this.code);
}

@lazySingleton
class EmailOtpApiService {
  final SupabaseClient client;
  final AppConfig config;
  final AuthApiService auth;
  DateTime? _nextSend;
  EmailOtpApiService(this.client, this.config, this.auth);
  int get resendAfter {
    final seconds = _nextSend?.difference(DateTime.now()).inMilliseconds ?? 0;
    return seconds <= 0 ? 0 : (seconds / 1000).ceil();
  }

  void _enabled() {
    if (!config.features.authEnabled) throw const EmailGateException('auth_disabled');
  }

  Future<void> send(String email) async {
    _enabled();
    if (resendAfter > 0) throw const EmailGateException('rate_limited');
    // Hold a local attempt cooldown even after a transport error: the server may
    // already have sent mail. Supabase's actual limits remain authoritative.
    _nextSend = DateTime.now().add(const Duration(seconds: 60));
    await client.auth
        .signInWithOtp(email: email, shouldCreateUser: true)
        .timeout(const Duration(seconds: 15));
  }

  Future<bool> verify(String email, String code) async {
    _enabled();
    // Reuse the template's email OTP SDK operation, not its signup resend method.
    final result = await auth
        .otpVerify(email: email, token: code)
        .timeout(const Duration(seconds: 15));
    if (result.session == null) throw const EmailGateException('invalid_code');
    return authorize();
  }

  Future<bool> authorize() async {
    _enabled();
    var session = client.auth.currentSession;
    if (session == null) return false;
    if (session.isExpired) {
      try {
        session = (await client.auth.refreshSession().timeout(const Duration(seconds: 15))).session;
      } on AuthException catch (error) {
        if (['400', '401', '403'].contains(error.statusCode)) return false;
        rethrow;
      }
      if (session == null) return false;
    }
    try {
      final response = await client.functions
          .invoke(
            'authorize-analysis',
            body: <String, dynamic>{},
            headers: {'apikey': config.apiKey, 'Authorization': 'Bearer ${session.accessToken}'},
          )
          .timeout(const Duration(seconds: 15));
      if ([401, 403].contains(response.status)) return false;
      if (response.status != 200 ||
          response.data is! Map ||
          response.data['status'] != 'authorized') {
        throw const EmailGateException('unavailable');
      }
      return true;
    } on FunctionException catch (error) {
      if ([401, 403].contains(error.status)) return false;
      throw const EmailGateException('unavailable');
    }
  }
}
