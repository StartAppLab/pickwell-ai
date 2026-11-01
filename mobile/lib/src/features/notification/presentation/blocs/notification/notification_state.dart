part of 'notification_cubit.dart';

@freezed
class NotificationState with _$NotificationState {
  const factory NotificationState.idle({String? errorText}) = NotificationStateIdle;
  const factory NotificationState.loading() = _NotificationStateLoading;
  const factory NotificationState.success() = _NotificationStateSuccess;
  const factory NotificationState.error({required DataError error}) = _NotificationStateError;
}
