import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/_core.dart';
import '../../../domain/_domain.dart';

part 'sign_out_state.dart';
part 'sign_out_cubit.freezed.dart';

@lazySingleton
class SignOutCubit extends Cubit<SignOutState> {
  final SignOutUseCase _signOutUseCase;

  @factoryMethod
  SignOutCubit(this._signOutUseCase) : super(const SignOutState.idle());

  Future<void> signOut() async {
    if (state is _SignOutStateIdle) {
      final signOutState = state as _SignOutStateIdle;

      emit(const SignOutState.loading());

      // Use case
      final either = await _signOutUseCase(SignOutScope.local);
      if (isClosed) return;
      either.fold(
        (failure) {
          emit(SignOutState.error(error: failure.error));
          emit(signOutState);
        },
        (response) {
          emit(const SignOutState.success());
          emit(signOutState);
        },
      );
    }
  }
}
