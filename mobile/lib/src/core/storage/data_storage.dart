import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../_core.dart';

class DataStorageKeys {
  static const recentProducts = 'PICKWELL_RECENT_PRODUCTS_V1';
  static const onboardingAnswers = 'ONBOARDING_ANSWERS';
  static const remindersEnabled = 'REMINDERS_ENABLED';
  static const onboardingCompleted = 'ONBOARDING_COMPLETED';
  static const onboardingPaywallCompleted = 'ONBOARDING_PAYWALL_COMPLETED';
  static const isFirstOpen = 'IS_FIRST_OPEN';
  static const hasSeenWelcomeSheet = 'HAS_SEEN_WELCOME_SHEET';
  static const lastSeenAppVersion = 'LAST_SEEN_APP_VERSION';
  static const language = 'LANGUAGE';
  static const theme = 'THEME';
  static const darkMode = 'DARK_MODE';
  static const paywallSoftTriggerPrefix = 'PAYWALL_SOFT_TRIGGER_';
}

@lazySingleton
abstract class DataStorage extends Storage {
  @factoryMethod
  const factory DataStorage({required SharedPreferences storage}) = _DataStorageImpl;
}

class _DataStorageImpl implements DataStorage {
  final SharedPreferences storage;

  const _DataStorageImpl({required this.storage});

  @override
  Future<bool?> write(String key, Object data) async {
    try {
      switch (data.runtimeType) {
        case const (int):
          return await storage.setInt(key, data as int);
        case const (bool):
          return await storage.setBool(key, data as bool);
        case const (double):
          return await storage.setDouble(key, data as double);
        case const (String):
          return await storage.setString(key, data as String);
        case const (List<String>):
          return await storage.setStringList(key, data as List<String>);
      }
    } on Exception catch (e) {
      AppLogger.logException(e);
    }
    return false;
  }

  @override
  Future<Object?> read(String key) async {
    try {
      Object? value = storage.get(key);
      switch (value.runtimeType) {
        case const (int):
          return storage.getInt(key);
        case const (bool):
          return storage.getBool(key);
        case const (double):
          return storage.getDouble(key);
        case const (String):
          return storage.getString(key);
        case const (List<String>):
          return storage.getStringList(key);
      }
    } on Exception catch (e) {
      AppLogger.logException(e);
    }
    return null;
  }

  @override
  Future<bool?> remove(String key) async {
    try {
      return await storage.remove(key);
    } on Exception catch (e) {
      AppLogger.logException(e);
    }
    return false;
  }

  @override
  Future<bool?> removeAll() async {
    try {
      return await storage.clear();
    } on Exception catch (e) {
      AppLogger.logException(e);
    }
    return false;
  }
}
