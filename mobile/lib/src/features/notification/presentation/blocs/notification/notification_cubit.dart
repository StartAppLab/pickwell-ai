import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/_core.dart';
import '../../../domain/_domain.dart';

part 'notification_state.dart';
part 'notification_cubit.freezed.dart';

@lazySingleton
class NotificationCubit extends Cubit<NotificationState> {
  final GetNotificationUseCase _getNotificationUseCase;

  @factoryMethod
  NotificationCubit(this._getNotificationUseCase)
    : super(const NotificationStateIdle(errorText: null));

  Future<void> getNotification() async {
    if (state is NotificationStateIdle) {
      final notificationState = state as NotificationStateIdle;

      emit(const NotificationState.loading());

      // Use case
      final either = await _getNotificationUseCase(0);
      either.fold(
        (failure) {
          emit(NotificationState.error(error: failure.error));
          emit(notificationState);
        },
        (entity) {
          emit(const NotificationState.success());
          emit(notificationState);
        },
      );
    }
  }

  void setErrorText(String? errorText) {
    if (state is NotificationStateIdle) {
      final notificationState = state as NotificationStateIdle;
      emit(notificationState.copyWith(errorText: errorText));
    }
  }
}
