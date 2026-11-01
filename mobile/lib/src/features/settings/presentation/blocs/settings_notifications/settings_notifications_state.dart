part of 'settings_notifications_cubit.dart';

@freezed
abstract class SettingsNotificationsState with _$SettingsNotificationsState {
  const factory SettingsNotificationsState.idle({required bool enabled}) =
      SettingsNotificationsStateIdle;
  const factory SettingsNotificationsState.loading() = SettingsNotificationsStateLoading;
  const factory SettingsNotificationsState.saving({required bool enabled}) =
      SettingsNotificationsStateSaving;
  const factory SettingsNotificationsState.permissionDenied({required bool enabled}) =
      SettingsNotificationsStatePermissionDenied;
  const factory SettingsNotificationsState.success({required bool enabled}) =
      SettingsNotificationsStateSuccess;
  const factory SettingsNotificationsState.error({required bool enabled, required String message}) =
      SettingsNotificationsStateError;
}
