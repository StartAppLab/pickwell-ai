import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/storage/data_storage.dart';

@lazySingleton
class PaywallGateService {
  final DataStorage _dataStorage;
  final SharedPreferences _sharedPreferences;

  Future<void> _queue = Future.value();

  @factoryMethod
  PaywallGateService(this._dataStorage, this._sharedPreferences);

  Future<bool> shouldShowSoftPaywall({required String featureKey, int showEvery = 3}) {
    if (featureKey.trim().isEmpty) throw ArgumentError('featureKey must not be empty');
    if (showEvery < 1) throw ArgumentError('showEvery must be at least 1');
    final result = _queue.then((_) async {
      final key = '${DataStorageKeys.paywallSoftTriggerPrefix}$featureKey';
      final value = await _dataStorage.read(key);
      final next = (value is int ? value : 0) + 1;
      if (await _dataStorage.write(key, next) != true) {
        throw StateError('Unable to save paywall counter');
      }
      return next % showEvery == 0;
    });
    _queue = result.then<void>((_) {}, onError: (Object error, StackTrace stack) {});
    return result;
  }

  Future<void> resetSoftPaywallTrigger(String featureKey) {
    if (featureKey.trim().isEmpty) throw ArgumentError('featureKey must not be empty');
    return _reset(() => ['${DataStorageKeys.paywallSoftTriggerPrefix}$featureKey']);
  }

  Future<void> resetAllSoftPaywallTriggers() => _reset(
    () => _sharedPreferences
        .getKeys()
        .where((key) => key.startsWith(DataStorageKeys.paywallSoftTriggerPrefix))
        .toList(),
  );

  Future<void> _reset(Iterable<String> Function() keys) {
    final result = _queue.then((_) async {
      for (final key in keys()) {
        if (await _dataStorage.remove(key) != true) {
          throw StateError('Unable to reset paywall counters. Please try again.');
        }
      }
    });
    _queue = result.then<void>((_) {}, onError: (Object error, StackTrace stack) {});
    return result;
  }
}
