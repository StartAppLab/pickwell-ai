import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/_core.dart';
import '../../../../catalog/domain/_domain.dart';

part 'home_state.dart';
part 'home_cubit.freezed.dart';

@lazySingleton
class HomeCubit extends Cubit<HomeState> {
  final GetRecentProductsUseCase recents;
  HomeCubit(this.recents) : super(const HomeState.idle());
  Future<void> init() => load();
  Future<void> load() async {
    final result = await recents();
    if (isClosed) return;
    result.fold(
      (failure) => emit(HomeState.error(error: failure.error)),
      (items) => emit(HomeState.ready(items: items)),
    );
  }
}
