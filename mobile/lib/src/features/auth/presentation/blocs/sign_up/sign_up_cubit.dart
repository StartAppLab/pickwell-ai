import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/_core.dart';
import '../../../../../config/_config.dart';
import '../../services/auth_actions.dart';
import '../../../domain/_domain.dart';

part 'sign_up_state.dart';
part 'sign_up_cubit.freezed.dart';

@lazySingleton
class SignUpCubit extends Cubit<SignUpState> {
  final SignUpUseCase _signUpUseCase;

  late StringValidator _emailValidator;
  late StringValidator _passwordValidator;
  late StringValidator _firstNameValidator;
  late StringValidator _lastNameValidator;

  @factoryMethod
  SignUpCubit(this._signUpUseCase) : super(const SignUpStateIdle()) {
    _emailValidator = StringValidator().forEmail;
    _passwordValidator = StringValidator().minLength(8);
    _firstNameValidator = StringValidator().maxLength(50);
    _lastNameValidator = StringValidator.create(
      validators: <StringValidatorCallback>[],
      isOptional: true,
    ).maxLength(50);
  }

  Future<void> signUp() async {
    if (state is SignUpStateIdle) {
      final signUpState = state as SignUpStateIdle;
      final email = signUpState.email;
      final password = signUpState.password;
      final firstName = signUpState.firstName;
      final lastName = signUpState.lastName;

      emit(const SignUpState.loading());

      // Use case
      final either = await _signUpUseCase(
        SignUpInput(
          email: email.value.trim(),
          password: password.value,
          firstName: firstName.value.trim(),
          lastName: lastName.value,
        ),
      );
      if (isClosed) return;
      either.fold(
        (failure) {
          emit(SignUpState.error(error: failure.error));
          emit(signUpState);
        },
        (response) {
          emit(const SignUpState.success());
          emit(const SignUpState.idle());
        },
      );
    }
  }

  Future<void> signUpWithGoogle() async {
    try {
      await getIt<AuthActions>().signInWithGoogle();
    } catch (_) {
      setErrorText('Unable to sign in with Google. Please try again.');
    }
  }

  Future<void> signUpWithApple() async {
    try {
      await getIt<AuthActions>().signInWithApple();
    } catch (_) {
      setErrorText('Unable to sign in with Apple. Please try again.');
    }
  }

  void showPassword(bool obscurePassword) {
    if (state is SignUpStateIdle) {
      final signUpState = state as SignUpStateIdle;
      emit(signUpState.copyWith(obscurePassword: obscurePassword));
    }
  }

  void showConfirmPassword(bool obscureConfirmPassword) {
    if (state is SignUpStateIdle) {
      final signUpState = state as SignUpStateIdle;
      emit(signUpState.copyWith(obscureConfirmPassword: obscureConfirmPassword));
    }
  }

  void setEmail(String email) {
    if (state is SignUpStateIdle) {
      final signUpState = state as SignUpStateIdle;
      emit(
        signUpState.copyWith(
          email: ValidatedString(value: email, isValid: _emailValidator.test(email)),
        ),
      );
    }
  }

  void setPassword(String password) {
    if (state is SignUpStateIdle) {
      final signUpState = state as SignUpStateIdle;
      emit(
        signUpState.copyWith(
          password: ValidatedString(value: password, isValid: _passwordValidator.test(password)),
        ),
      );
    }
  }

  void setConfirmPassword(String confirmPassword) {
    if (state is SignUpStateIdle) {
      final signUpState = state as SignUpStateIdle;
      emit(
        signUpState.copyWith(
          confirmPassword: ValidatedString(
            value: confirmPassword,
            isValid: _passwordValidator.test(confirmPassword),
          ),
        ),
      );
    }
  }

  void setFirstName(String firstName) {
    if (state is SignUpStateIdle) {
      final signUpState = state as SignUpStateIdle;
      emit(
        signUpState.copyWith(
          firstName: ValidatedString(
            value: firstName,
            isValid: _firstNameValidator.test(firstName),
          ),
        ),
      );
    }
  }

  void setLastName(String lastName) {
    if (state is SignUpStateIdle) {
      final signUpState = state as SignUpStateIdle;
      emit(
        signUpState.copyWith(
          lastName: ValidatedString(value: lastName, isValid: _lastNameValidator.test(lastName)),
        ),
      );
    }
  }

  void setErrorText(String? errorText) {
    if (state is SignUpStateIdle) {
      final signUpState = state as SignUpStateIdle;
      emit(signUpState.copyWith(errorText: errorText));
    }
  }
}
