import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/_core.dart';
import '../../../domain/_domain.dart';

part 'otp_state.dart';
part 'otp_cubit.freezed.dart';

@lazySingleton
class OtpCubit extends Cubit<OtpState> {
  final OtpVerifyUseCase _otpVerifyUseCase;
  final OtpResendUseCase _otpResendUseCase;

  late StringValidator _tokenValidator;

  @factoryMethod
  OtpCubit(this._otpVerifyUseCase, this._otpResendUseCase) : super(const OtpStateIdle()) {
    _tokenValidator = StringValidator().forNumbersOnly.withLength(min: 6, max: 6);
  }

  Future<void> otpVerify() async {
    if (state is OtpStateIdle) {
      final otpState = state as OtpStateIdle;
      final email = otpState.email;
      final token = otpState.token;

      emit(const OtpState.loading());

      // Use case
      final either = await _otpVerifyUseCase(OtpVerifyInput(email: email!, token: token.value));
      if (isClosed) return;
      either.fold(
        (failure) {
          emit(OtpState.error(error: failure.error));
          emit(otpState);
        },
        (response) {
          emit(const OtpState.success());
          emit(otpState);
        },
      );
    }
  }

  Future<void> otpResend() async {
    if (state is OtpStateIdle) {
      final otpState = state as OtpStateIdle;
      final email = otpState.email;

      emit(const OtpState.loading());

      // Use case
      final either = await _otpResendUseCase(email!);
      if (isClosed) return;
      either.fold(
        (failure) {
          emit(OtpState.error(error: failure.error));
          emit(otpState);
        },
        (response) {
          emit(otpState);
        },
      );
    }
  }

  void setToken(String token) {
    if (state is OtpStateIdle) {
      final otpState = state as OtpStateIdle;
      emit(
        otpState.copyWith(
          token: ValidatedString(value: token, isValid: _tokenValidator.test(token)),
        ),
      );
    }
  }

  void setEmail(String email) {
    if (state is OtpStateIdle) {
      final otpState = state as OtpStateIdle;
      emit(otpState.copyWith(email: email));
    }
  }

  void setErrorText(String? errorText) {
    if (state is OtpStateIdle) {
      final otpState = state as OtpStateIdle;
      emit(otpState.copyWith(errorText: errorText));
    }
  }

  void setCanResend(bool? canResend) {
    if (state is OtpStateIdle) {
      final otpState = state as OtpStateIdle;
      emit(otpState.copyWith(canResend: canResend));
    }
  }
}
