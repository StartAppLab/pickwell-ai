part of 'otp_cubit.dart';

@freezed
abstract class OtpState with _$OtpState {
  const OtpState._();

  const factory OtpState.idle({
    @Default(ValidatedString.empty) ValidatedString token,
    String? email,
    String? errorText,
    bool? canResend,
  }) = OtpStateIdle;
  const factory OtpState.loading() = _OtpStateLoading;
  const factory OtpState.success() = _OtpStateSuccess;
  const factory OtpState.error({required DataError error}) = _OtpStateError;

  bool get isValid => isRequiredFieldsNotEmpty && isFieldsValid;

  bool get isRequiredFieldsNotEmpty {
    if (this is! OtpStateIdle) return false;
    final state = this as OtpStateIdle;
    return !state.token.isEmpty;
  }

  bool get isFieldsValid {
    if (this is! OtpStateIdle) return false;
    final state = this as OtpStateIdle;
    return state.token.isValid.valid;
  }
}
