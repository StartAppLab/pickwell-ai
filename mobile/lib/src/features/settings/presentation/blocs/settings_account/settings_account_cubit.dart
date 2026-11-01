import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../auth/presentation/services/auth_actions.dart';

part 'settings_account_state.dart';
part 'settings_account_cubit.freezed.dart';

@lazySingleton
class SettingsAccountCubit extends Cubit<SettingsAccountState> {
  @factoryMethod
  SettingsAccountCubit(this._authActions) : super(const SettingsAccountState.idle());

  final AuthActions _authActions;

  Future<void> changeEmail(String email) =>
      _run(() => _authActions.changeEmail(email), 'Check your email to confirm the change.');

  Future<void> deleteAccount() => _run(_authActions.deleteAccount, 'Your account was deleted.');

  Future<void> _run(Future<void> Function() action, String successMessage) async {
    if (state is SettingsAccountStateLoading) return;
    emit(const SettingsAccountState.loading());
    try {
      await action();
      if (!isClosed) {
        emit(SettingsAccountState.success(message: successMessage));
        emit(const SettingsAccountState.idle());
      }
    } catch (_) {
      if (!isClosed) {
        emit(const SettingsAccountState.error(message: 'Unable to complete this request.'));
        emit(const SettingsAccountState.idle());
      }
    }
  }
}
