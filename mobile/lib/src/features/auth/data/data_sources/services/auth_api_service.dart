import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../config/app_config.dart';

abstract class AuthApiService {
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String firstName,
    String? lastName,
  });

  Future<AuthResponse> signIn({required String email, required String password});

  Future<void> signOut({required SignOutScope scope});

  Future<AuthResponse> otpVerify({required String email, required String token});

  Future<ResendResponse> otpResend({required String email});

  Future<void> forgotPassword({required String email});

  Future<UserResponse> changePassword({required String password});
}

@Injectable(as: AuthApiService)
class AuthApiServiceImpl implements AuthApiService {
  final SupabaseClient _client;
  final AppConfig _config;

  @factoryMethod
  const AuthApiServiceImpl(this._client, this._config);

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String firstName,
    String? lastName,
  }) async {
    var data = {'first_name': firstName, 'display_name': firstName, 'full_name': firstName};
    if (lastName?.isNotEmpty ?? false) {
      data = {
        'first_name': firstName,
        'last_name': lastName!,
        'display_name': '$firstName $lastName',
        'full_name': '$firstName $lastName',
      };
    }
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: data,
      emailRedirectTo: _config.authRedirectUrl,
    );
  }

  @override
  Future<AuthResponse> signIn({required String email, required String password}) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signOut({required SignOutScope scope}) async {
    await _client.auth.signOut(scope: scope);
  }

  @override
  Future<AuthResponse> otpVerify({required String email, required String token}) async {
    return await _client.auth.verifyOTP(email: email, token: token, type: OtpType.email);
  }

  @override
  Future<ResendResponse> otpResend({required String email}) async {
    return await _client.auth.resend(
      email: email,
      type: OtpType.signup,
      emailRedirectTo: _config.authRedirectUrl,
    );
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await _client.auth.resetPasswordForEmail(email, redirectTo: _config.authRedirectUrl);
  }

  @override
  Future<UserResponse> changePassword({required String password}) async {
    return await _client.auth.updateUser(UserAttributes(password: password));
  }
}
