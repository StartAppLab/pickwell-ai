import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/_core.dart';
import '../../../domain/_domain.dart';

part 'change_password_state.dart';
part 'change_password_cubit.freezed.dart';

@lazySingleton
class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final ChangePasswordUseCase _changePasswordUseCase;

  late StringValidator _passwordValidator;

  @factoryMethod
  ChangePasswordCubit(this._changePasswordUseCase) : super(const ChangePasswordStateIdle()) {
    _passwordValidator = StringValidator().minLength(8);
  }

  Future<void> changePassword() async {
    if (state is ChangePasswordStateIdle) {
      final changePasswordState = state as ChangePasswordStateIdle;
      final password = changePasswordState.password;

      emit(const ChangePasswordState.loading());

      // Use case
      final either = await _changePasswordUseCase(password.value);
      if (isClosed) return;
      either.fold(
        (failure) {
          emit(ChangePasswordState.error(error: failure.error));
          emit(changePasswordState);
        },
        (response) {
          emit(const ChangePasswordState.success());
          emit(const ChangePasswordState.idle());
        },
      );
    }
  }

  void showPassword(bool obscurePassword) {
    if (state is ChangePasswordStateIdle) {
      final changePasswordState = state as ChangePasswordStateIdle;
      emit(changePasswordState.copyWith(obscurePassword: obscurePassword));
    }
  }

  void showConfirmPassword(bool obscureConfirmPassword) {
    if (state is ChangePasswordStateIdle) {
      final changePasswordState = state as ChangePasswordStateIdle;
      emit(changePasswordState.copyWith(obscureConfirmPassword: obscureConfirmPassword));
    }
  }

  void setPassword(String password) {
    if (state is ChangePasswordStateIdle) {
      final changePasswordState = state as ChangePasswordStateIdle;
      emit(
        changePasswordState.copyWith(
          password: ValidatedString(value: password, isValid: _passwordValidator.test(password)),
        ),
      );
    }
  }

  void setConfirmPassword(String confirmPassword) {
    if (state is ChangePasswordStateIdle) {
      final changePasswordState = state as ChangePasswordStateIdle;
      emit(
        changePasswordState.copyWith(
          confirmPassword: ValidatedString(
            value: confirmPassword,
            isValid: _passwordValidator.test(confirmPassword),
          ),
        ),
      );
    }
  }

  void setErrorText(String? errorText) {
    if (state is ChangePasswordStateIdle) {
      final changePasswordState = state as ChangePasswordStateIdle;
      emit(changePasswordState.copyWith(errorText: errorText));
    }
  }
}
