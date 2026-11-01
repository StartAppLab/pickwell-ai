import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/storage/data_storage.dart';
import 'app_config.dart';

/// Reactive auth and onboarding state used by navigation and account surfaces.
@lazySingleton
class AppSession extends ChangeNotifier {
  AppSession(this.config, this.storage);
  final AppConfig config;
  final DataStorage storage;
  SupabaseClient? client;
  StreamSubscription<AuthState>? _subscription;
  bool onboardingCompleted = false;
  bool onboardingPaywallCompleted = false;
  bool recoveringPassword = false;
  String? returnLocation;
  bool _debugGuestMode = false;

  String? get userId => config.features.authEnabled ? client?.auth.currentUser?.id : null;
  bool get isAuthenticated => userId != null;
  bool get debugGuestMode => kDebugMode && _debugGuestMode;
  bool get hasAuthenticatedUi => isAuthenticated || debugGuestMode;

  /// Validate the pending URL without consuming it while auth/setup is unfinished.
  String? get pendingReturnLocation {
    final destination = returnLocation;
    if (destination == null || !destination.startsWith('/') || destination.startsWith('//')) {
      return null;
    }
    final uri = Uri.tryParse(destination);
    return uri != null && !uri.hasScheme && !uri.hasAuthority ? destination : null;
  }

  /// Consume the requested in-app URL only when normal account navigation can resume.
  String? takeReturnLocation() {
    if (!isAuthenticated || recoveringPassword) return null;
    final destination = pendingReturnLocation;
    returnLocation = null;
    return destination;
  }

  void enableDebugGuestMode() {
    if (!kDebugMode) return;
    _debugGuestMode = true;
    notifyListeners();
  }

  void disableDebugGuestMode() {
    if (!kDebugMode || !_debugGuestMode) return;
    _debugGuestMode = false;
    notifyListeners();
  }

  Future<void> init(SupabaseClient? backend) async {
    client = backend;
    onboardingCompleted = await storage.read(DataStorageKeys.onboardingCompleted) == true;
    onboardingPaywallCompleted =
        await storage.read(DataStorageKeys.onboardingPaywallCompleted) == true;
    if (config.features.authEnabled) {
      _subscription = client?.auth.onAuthStateChange.listen((event) {
        if (event.session != null) _debugGuestMode = false;
        if (event.event == AuthChangeEvent.passwordRecovery) recoveringPassword = true;
        if (event.event == AuthChangeEvent.signedOut) recoveringPassword = false;
        notifyListeners();
      });
    }
  }

  Future<void> completeOnboarding() async {
    if (await storage.write(DataStorageKeys.onboardingCompleted, true) != true) {
      throw StateError('Unable to save onboarding progress. Please try again.');
    }
    onboardingCompleted = true;
    notifyListeners();
  }

  Future<void> resetOnboarding({bool resetHomeSheets = false}) async {
    final keys = [
      DataStorageKeys.onboardingCompleted,
      DataStorageKeys.onboardingPaywallCompleted,
      if (resetHomeSheets) ...[
        DataStorageKeys.hasSeenWelcomeSheet,
        DataStorageKeys.lastSeenAppVersion,
      ],
    ];
    for (final key in keys) {
      if (await storage.remove(key) != true) {
        throw StateError('Unable to reset onboarding progress.');
      }
    }
    onboardingCompleted = false;
    onboardingPaywallCompleted = false;
    if (resetHomeSheets) returnLocation = null;
    notifyListeners();
  }

  Future<void> completeOnboardingPaywall() async {
    if (await storage.write(DataStorageKeys.onboardingPaywallCompleted, true) != true) {
      throw StateError('Unable to save paywall progress. Please try again.');
    }
    onboardingPaywallCompleted = true;
    notifyListeners();
  }

  void finishRecovery() {
    recoveringPassword = false;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
