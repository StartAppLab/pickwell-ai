part of 'profile_cubit.dart';

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState.idle({required ProfileEntity entity, String? firstName}) =
      _ProfileStateIdle;
  const factory ProfileState.loading({String? firstName}) = _ProfileStateLoading;
  const factory ProfileState.success({String? firstName}) = _ProfileStateSuccess;
  const factory ProfileState.error({required DataError error, String? firstName}) =
      _ProfileStateError;
}
