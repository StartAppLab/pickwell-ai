import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/_core.dart';
import '../../../domain/_domain.dart';

part 'forgot_password_state.dart';
part 'forgot_password_cubit.freezed.dart';

@lazySingleton
class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final ForgotPasswordUseCase _forgotPasswordUseCase;

  late StringValidator _emailValidator;

  @factoryMethod
  ForgotPasswordCubit(this._forgotPasswordUseCase) : super(const ForgotPasswordStateIdle()) {
    _emailValidator = StringValidator().forEmail;
  }

  Future<void> submit() async {
    if (state is ForgotPasswordStateIdle) {
      final forgotPasswordState = state as ForgotPasswordStateIdle;
      final email = forgotPasswordState.email;

      emit(const ForgotPasswordState.loading());

      // Use case
      final either = await _forgotPasswordUseCase(email.value.trim());
      if (isClosed) return;
      either.fold(
        (failure) {
          emit(ForgotPasswordState.error(error: failure.error));
          emit(forgotPasswordState);
        },
        (response) {
          emit(const ForgotPasswordState.success());
          emit(forgotPasswordState);
        },
      );
    }
  }

  void setEmail(String email) {
    if (state is ForgotPasswordStateIdle) {
      final forgotPasswordState = state as ForgotPasswordStateIdle;
      emit(
        forgotPasswordState.copyWith(
          email: ValidatedString(value: email, isValid: _emailValidator.test(email)),
        ),
      );
    }
  }

  void setErrorText(String? errorText) {
    if (state is ForgotPasswordStateIdle) {
      final forgotPasswordState = state as ForgotPasswordStateIdle;
      emit(forgotPasswordState.copyWith(errorText: errorText));
    }
  }
}
