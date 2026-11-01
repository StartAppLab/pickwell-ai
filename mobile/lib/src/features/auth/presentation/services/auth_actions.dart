import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/_config.dart';
import '../../../../core/storage/data_storage.dart';

@lazySingleton
class AuthActions {
  AuthActions(this._client, this._config, this._storage);
  final SupabaseClient _client;
  final AppConfig _config;
  final DataStorage _storage;

  Future<void> signInWithGoogle() =>
      _oauth(OAuthProvider.google, _config.features.googleSignInEnabled);
  Future<void> signInWithApple() =>
      _oauth(OAuthProvider.apple, _config.features.appleSignInEnabled);

  Future<void> _oauth(OAuthProvider provider, bool enabled) async {
    if (!enabled || !_config.features.authEnabled) {
      throw StateError('This sign-in provider is disabled.');
    }
    final launched = await _client.auth.signInWithOAuth(
      provider,
      redirectTo: _config.authRedirectUrl,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
    if (!launched) throw StateError('Unable to open the sign-in browser.');
  }

  Future<void> changeEmail(String email) async {
    await _client.auth.updateUser(
      UserAttributes(email: email.trim()),
      emailRedirectTo: _config.authRedirectUrl,
    );
  }

  Future<void> updateProfile({required String firstName, required String lastName}) async {
    final fullName = [firstName.trim(), lastName.trim()].where((v) => v.isNotEmpty).join(' ');
    final data = {
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'full_name': fullName,
      'display_name': fullName,
    };
    final response = await _client.auth.updateUser(UserAttributes(data: data));
    final user = response.user;
    if (user == null) throw StateError('Sign in to update your profile.');
    await _client.from('profiles').update({'full_name': fullName}).eq('id', user.id);
  }

  Future<void> deleteAccount() async {
    final response = await _client.functions.invoke('delete-account', method: HttpMethod.post);
    if (response.status != 200) throw StateError('Unable to delete account. Please try again.');
    await _client.auth.signOut(scope: SignOutScope.local);
    await clearAccountCache();
  }

  Future<void> clearAccountCache() async {
    // Device preferences are retained; cached account data must not cross identities.
    for (final key in ['AUTH_CACHE_KEY', 'PROFILE_CACHE_KEY', 'NOTIFICATION_CACHE_KEY']) {
      await _storage.remove(key);
    }
  }
}
