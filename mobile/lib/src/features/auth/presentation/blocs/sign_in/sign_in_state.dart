part of 'sign_in_cubit.dart';

@freezed
abstract class SignInState with _$SignInState {
  const SignInState._();

  const factory SignInState.idle({
    @Default(ValidatedString.empty) ValidatedString email,
    @Default(ValidatedString.empty) ValidatedString password,
    @Default(true) bool obscurePassword,
    @Default(false) bool socialLoading,
    String? errorText,
  }) = SignInStateIdle;
  const factory SignInState.loading() = _SignInStateLoading;
  const factory SignInState.success() = _SignInStateSuccess;
  const factory SignInState.error({required DataError error}) = _SignInStateError;

  bool get isValid => isRequiredFieldsNotEmpty && isFieldsValid;

  bool get isRequiredFieldsNotEmpty {
    if (this is! SignInStateIdle) return false;
    final state = this as SignInStateIdle;
    return !state.email.isEmpty && !state.password.isEmpty;
  }

  bool get isFieldsValid {
    if (this is! SignInStateIdle) return false;
    final state = this as SignInStateIdle;
    return state.email.isValid.valid && state.password.isValid.valid;
  }
}
