import 'dart:async';

import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../../config/theme/_theme.dart';
import '../../../../../core/_core.dart';
import '../../../../../localization/_localization.dart';

part 'settings_state.dart';
part 'settings_cubit.freezed.dart';

@lazySingleton
class SettingsCubit extends Cubit<SettingsState> {
  @factoryMethod
  SettingsCubit(this._storage) : super(const _SettingsStateIdle());

  final DataStorage _storage;
  Future<void> _writeQueue = Future.value();

  Future<void> init() async {
    final settings = await Future.wait([
      _storage.read(DataStorageKeys.language),
      _storage.read(DataStorageKeys.theme),
      _storage.read(DataStorageKeys.darkMode),
    ]);

    if (isClosed) return;
    final language = settings[0] is int ? settings[0] as int : -1;
    final theme = settings[1] is int ? settings[1] as int : 0;
    final darkMode = settings[2] is int ? settings[2] as int : 0;
    final localeState = LocaleState.locales.where((element) => element.id == language).firstOrNull;
    final themeState = ThemeState.themes.firstWhere(
      (element) => element.id == theme,
      orElse: () => ThemeState.themes.first,
    );
    final themeMode = darkMode >= 0 && darkMode < ThemeMode.values.length
        ? ThemeMode.values[darkMode]
        : ThemeMode.system;

    emit(
      state.copyWith(
        localeState: localeState,
        selectedLanguage: localeState?.id ?? -1,
        themeState: themeState,
        selectedTheme: themeState.id,
        themeMode: themeMode,
        selectedDarkMode: themeMode.index,
      ),
    );
  }

  Future<void> setLanguage(LocaleState? localeState) => _persist(
    DataStorageKeys.language,
    localeState?.id ?? -1,
    () => state.copyWith(localeState: localeState, selectedLanguage: localeState?.id ?? -1),
  );

  Future<void> setTheme(ThemeState themeState) => _persist(
    DataStorageKeys.theme,
    themeState.id,
    () => state.copyWith(themeState: themeState, selectedTheme: themeState.id),
  );

  Future<void> setDarkMode(ThemeMode themeMode) => _persist(
    DataStorageKeys.darkMode,
    themeMode.index,
    () => state.copyWith(themeMode: themeMode, selectedDarkMode: themeMode.index),
  );

  Future<void> _persist(String key, Object value, SettingsState Function() next) {
    // Preserve request order even when platform writes complete asynchronously.
    _writeQueue = _writeQueue.then((_) async {
      if (isClosed) return;
      try {
        final saved = await _storage.write(key, value);
        if (isClosed) return;
        if (saved != true) {
          emit(state.copyWith(errorText: 'Unable to save settings'));
          return;
        }
        emit(next().copyWith(errorText: null));
      } catch (error, stackTrace) {
        AppLogger.logError(error, stackTrace: stackTrace);
        if (!isClosed) emit(state.copyWith(errorText: 'Unable to save settings'));
      }
    });
    return _writeQueue;
  }
}
