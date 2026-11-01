part of 'root_cubit.dart';

@freezed
abstract class RootState with _$RootState {
  const factory RootState.idle({@Default(0) int selectedIndex}) = _RootStateIdle;
}
