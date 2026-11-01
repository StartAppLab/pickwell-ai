part of 'change_password_cubit.dart';

@freezed
abstract class ChangePasswordState with _$ChangePasswordState {
  const ChangePasswordState._();

  const factory ChangePasswordState.idle({
    @Default(ValidatedString.empty) ValidatedString password,
    @Default(ValidatedString.empty) ValidatedString confirmPassword,
    @Default(true) bool obscurePassword,
    @Default(true) bool obscureConfirmPassword,
    String? errorText,
  }) = ChangePasswordStateIdle;
  const factory ChangePasswordState.loading() = _ChangePasswordStateLoading;
  const factory ChangePasswordState.success() = _ChangePasswordStateSuccess;
  const factory ChangePasswordState.error({required DataError error}) = _ChangePasswordStateError;

  bool get isValid => isRequiredFieldsNotEmpty && isFieldsValid && isPasswordMatch;

  bool get isRequiredFieldsNotEmpty {
    if (this is! ChangePasswordStateIdle) return false;
    final state = this as ChangePasswordStateIdle;
    return !state.password.isEmpty && !state.confirmPassword.isEmpty;
  }

  bool get isFieldsValid {
    if (this is! ChangePasswordStateIdle) return false;
    final state = this as ChangePasswordStateIdle;
    return state.password.isValid.valid && state.confirmPassword.isValid.valid;
  }

  bool get isPasswordMatch {
    if (this is! ChangePasswordStateIdle) return false;
    final state = this as ChangePasswordStateIdle;
    return state.password.value == state.confirmPassword.value;
  }
}
