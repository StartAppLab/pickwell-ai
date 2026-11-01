part of 'sign_up_cubit.dart';

@freezed
abstract class SignUpState with _$SignUpState {
  const SignUpState._();

  const factory SignUpState.idle({
    @Default(ValidatedString.empty) ValidatedString email,
    @Default(ValidatedString.empty) ValidatedString password,
    @Default(ValidatedString.empty) ValidatedString confirmPassword,
    @Default(ValidatedString.empty) ValidatedString firstName,
    @Default(ValidatedString.empty) ValidatedString lastName,
    @Default(true) bool obscurePassword,
    @Default(true) bool obscureConfirmPassword,
    String? errorText,
  }) = SignUpStateIdle;
  const factory SignUpState.loading() = _SignUpStateLoading;
  const factory SignUpState.success() = _SignUpStateSuccess;
  const factory SignUpState.error({required DataError error}) = _SignUpStateError;

  bool get isValid => isRequiredFieldsNotEmpty && isFieldsValid && isPasswordMatch;

  bool get isRequiredFieldsNotEmpty {
    if (this is! SignUpStateIdle) return false;
    final state = this as SignUpStateIdle;
    return !state.email.isEmpty &&
        !state.password.isEmpty &&
        !state.confirmPassword.isEmpty &&
        !state.firstName.isEmpty;
  }

  bool get isFieldsValid {
    if (this is! SignUpStateIdle) return false;
    final state = this as SignUpStateIdle;
    return state.email.isValid.valid &&
        state.password.isValid.valid &&
        state.confirmPassword.isValid.valid &&
        state.firstName.isValid.valid &&
        state.lastName.isValid.valid;
  }

  bool get isPasswordMatch {
    if (this is! SignUpStateIdle) return false;
    final state = this as SignUpStateIdle;
    return state.password.value == state.confirmPassword.value;
  }
}
