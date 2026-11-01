import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/_core.dart';
import '../../../domain/_domain.dart';

part 'profile_state.dart';
part 'profile_cubit.freezed.dart';

@lazySingleton
class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase _getProfileUseCase;

  @factoryMethod
  ProfileCubit(this._getProfileUseCase) : super(_ProfileStateIdle(entity: ProfileEntity.empty()));

  void setFirstName(String? firstName) {
    if (isClosed) return;
    state.map(
      idle: (current) => emit(current.copyWith(firstName: firstName)),
      loading: (current) => emit(current.copyWith(firstName: firstName)),
      success: (current) => emit(current.copyWith(firstName: firstName)),
      error: (current) => emit(current.copyWith(firstName: firstName)),
    );
  }

  Future<void> getProfile(int id) async {
    if (state is _ProfileStateIdle) {
      final profileState = state as _ProfileStateIdle;

      final firstName = state.maybeWhen(
        idle: (_, value) => value,
        loading: (value) => value,
        success: (value) => value,
        error: (_, value) => value,
        orElse: () => null,
      );
      emit(ProfileState.loading(firstName: firstName));

      // Use case
      final either = await _getProfileUseCase(id);
      either.fold(
        (failure) {
          emit(ProfileState.error(error: failure.error, firstName: firstName));
          emit(profileState);
        },
        (entity) {
          emit(ProfileState.success(firstName: firstName));
          emit(ProfileState.idle(entity: entity, firstName: firstName));
        },
      );
    }
  }
}
