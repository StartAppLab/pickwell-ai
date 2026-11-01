part of 'settings_cubit.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState.idle({
    LocaleState? localeState,
    ThemeState? themeState,
    ThemeMode? themeMode,
    @Default(-1) int selectedLanguage,
    @Default(0) int selectedTheme,
    @Default(0) int selectedDarkMode,
    String? errorText,
  }) = _SettingsStateIdle;
}
