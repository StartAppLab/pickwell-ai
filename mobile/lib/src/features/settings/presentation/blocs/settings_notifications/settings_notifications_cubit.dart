import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../../config/_config.dart';
import '../../../../../core/_core.dart';
import '../../../../notification/notification.dart';
import '../../../../paywall/paywall.dart';

part 'settings_notifications_state.dart';
part 'settings_notifications_cubit.freezed.dart';

@injectable
class SettingsNotificationsCubit extends Cubit<SettingsNotificationsState> {
  SettingsNotificationsCubit() : super(const SettingsNotificationsState.loading());

  Future<void> load() async {
    final enabled = await getIt<DataStorage>().read(DataStorageKeys.remindersEnabled) != false;
    if (!isClosed) emit(SettingsNotificationsState.idle(enabled: enabled));
  }

  Future<void> toggle(bool value) async {
    final enabled = state.maybeWhen(idle: (current) => current, orElse: () => null);
    if (enabled == null || state is SettingsNotificationsStateSaving) return;
    emit(SettingsNotificationsState.saving(enabled: enabled));
    try {
      if (value && !await NotificationManager.requestPermission()) {
        if (!isClosed) {
          emit(SettingsNotificationsState.permissionDenied(enabled: enabled));
          emit(SettingsNotificationsState.idle(enabled: enabled));
        }
        return;
      }
      await NotificationManager.setEnabled(value);
      if (value && getIt<AppConfig>().features.billingEnabled) {
        await getIt<SubscriptionCubit>().refresh();
      }
      if (!isClosed) {
        emit(SettingsNotificationsState.success(enabled: value));
        emit(SettingsNotificationsState.idle(enabled: value));
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          SettingsNotificationsState.error(
            enabled: enabled,
            message: 'Unable to save notification preferences.',
          ),
        );
        emit(SettingsNotificationsState.idle(enabled: enabled));
      }
    }
  }
}
