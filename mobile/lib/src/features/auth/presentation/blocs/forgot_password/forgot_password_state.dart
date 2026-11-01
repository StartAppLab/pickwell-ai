part of 'forgot_password_cubit.dart';

@freezed
abstract class ForgotPasswordState with _$ForgotPasswordState {
  const ForgotPasswordState._();

  const factory ForgotPasswordState.idle({
    @Default(ValidatedString.empty) ValidatedString email,
    String? errorText,
  }) = ForgotPasswordStateIdle;
  const factory ForgotPasswordState.loading() = _ForgotPasswordStateLoading;
  const factory ForgotPasswordState.success() = _ForgotPasswordStateSuccess;
  const factory ForgotPasswordState.error({required DataError error}) = _ForgotPasswordStateError;

  bool get isValid => isRequiredFieldsNotEmpty && isFieldsValid;

  bool get isRequiredFieldsNotEmpty {
    if (this is! ForgotPasswordStateIdle) return false;
    final state = this as ForgotPasswordStateIdle;
    return !state.email.isEmpty;
  }

  bool get isFieldsValid {
    if (this is! ForgotPasswordStateIdle) return false;
    final state = this as ForgotPasswordStateIdle;
    return state.email.isValid.valid;
  }
}
