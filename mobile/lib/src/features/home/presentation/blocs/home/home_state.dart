part of 'home_cubit.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState.idle() = _HomeStateIdle;
  const factory HomeState.loading() = _HomeStateLoading;
  const factory HomeState.ready({required List<RecentProduct> items}) = _HomeStateReady;
  const factory HomeState.success() = _HomeStateSuccess;
  const factory HomeState.error({required DataError error}) = _HomeStateError;
}
