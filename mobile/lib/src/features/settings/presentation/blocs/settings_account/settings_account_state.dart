part of 'settings_account_cubit.dart';

@freezed
abstract class SettingsAccountState with _$SettingsAccountState {
  const factory SettingsAccountState.idle() = SettingsAccountStateIdle;
  const factory SettingsAccountState.loading() = SettingsAccountStateLoading;
  const factory SettingsAccountState.success({required String message}) =
      SettingsAccountStateSuccess;
  const factory SettingsAccountState.error({required String message}) = SettingsAccountStateError;
}
