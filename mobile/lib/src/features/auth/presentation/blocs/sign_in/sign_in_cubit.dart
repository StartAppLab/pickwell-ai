import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/_core.dart';
import '../../../../../config/_config.dart';
import '../../services/auth_actions.dart';
import '../../../domain/_domain.dart';

part 'sign_in_state.dart';
part 'sign_in_cubit.freezed.dart';

@lazySingleton
class SignInCubit extends Cubit<SignInState> {
  final SignInUseCase _signInUseCase;

  late StringValidator _emailValidator;
  late StringValidator _passwordValidator;

  @factoryMethod
  SignInCubit(this._signInUseCase) : super(const SignInStateIdle()) {
    _emailValidator = StringValidator().forEmail;
    _passwordValidator = StringValidator();
  }

  Future<void> signIn() async {
    if (state is SignInStateIdle) {
      final signInState = state as SignInStateIdle;
      final email = signInState.email;
      final password = signInState.password;

      emit(const SignInState.loading());

      // Use case
      final either = await _signInUseCase(
        SignInInput(email: email.value.trim(), password: password.value),
      );
      if (isClosed) return;
      either.fold(
        (failure) {
          emit(SignInState.error(error: failure.error));
          emit(signInState);
        },
        (response) {
          emit(const SignInState.success());
          emit(const SignInState.idle());
        },
      );
    }
  }

  Future<void> signInWithGoogle() async {
    if (state is! SignInStateIdle) return;
    final signInState = state as SignInStateIdle;
    emit(signInState.copyWith(socialLoading: true, errorText: null));
    try {
      await getIt<AuthActions>().signInWithGoogle();
    } catch (_) {
      if (!isClosed) {
        emit(
          signInState.copyWith(
            socialLoading: false,
            errorText: 'Unable to sign in with Google. Please try again.',
          ),
        );
      }
      return;
    }
    if (!isClosed) emit(signInState.copyWith(socialLoading: false));
  }

  Future<void> signInWithApple() async {
    if (state is! SignInStateIdle) return;
    final signInState = state as SignInStateIdle;
    emit(signInState.copyWith(socialLoading: true, errorText: null));
    try {
      await getIt<AuthActions>().signInWithApple();
    } catch (_) {
      if (!isClosed) {
        emit(
          signInState.copyWith(
            socialLoading: false,
            errorText: 'Unable to sign in with Apple. Please try again.',
          ),
        );
      }
      return;
    }
    if (!isClosed) emit(signInState.copyWith(socialLoading: false));
  }

  void showPassword(bool obscurePassword) {
    if (state is SignInStateIdle) {
      final signInState = state as SignInStateIdle;
      emit(signInState.copyWith(obscurePassword: obscurePassword));
    }
  }

  void setEmail(String email) {
    if (state is SignInStateIdle) {
      final signInState = state as SignInStateIdle;
      emit(
        signInState.copyWith(
          email: ValidatedString(value: email, isValid: _emailValidator.test(email)),
        ),
      );
    }
  }

  void setPassword(String password) {
    if (state is SignInStateIdle) {
      final signInState = state as SignInStateIdle;
      emit(
        signInState.copyWith(
          password: ValidatedString(value: password, isValid: _passwordValidator.test(password)),
        ),
      );
    }
  }

  void setErrorText(String? errorText) {
    if (state is SignInStateIdle) {
      final signInState = state as SignInStateIdle;
      emit(signInState.copyWith(errorText: errorText));
    }
  }
}
