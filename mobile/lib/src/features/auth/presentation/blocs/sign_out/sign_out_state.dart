part of 'sign_out_cubit.dart';

@freezed
abstract class SignOutState with _$SignOutState {
  const SignOutState._();

  const factory SignOutState.idle({@Default(ValidatedString.empty) ValidatedString email}) =
      _SignOutStateIdle;
  const factory SignOutState.loading() = _SignOutStateLoading;
  const factory SignOutState.success() = _SignOutStateSuccess;
  const factory SignOutState.error({required DataError error}) = _SignOutStateError;

  bool get isValid => isRequiredFieldsNotEmpty && isFieldsValid;

  bool get isRequiredFieldsNotEmpty {
    if (this is! _SignOutStateIdle) return false;
    final state = this as _SignOutStateIdle;
    return !state.email.isEmpty;
  }

  bool get isFieldsValid {
    if (this is! _SignOutStateIdle) return false;
    final state = this as _SignOutStateIdle;
    return state.email.isValid.valid;
  }
}
