import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/_core.dart';

part 'home_state.dart';
part 'home_cubit.freezed.dart';

@lazySingleton
class HomeCubit extends Cubit<HomeState> {
  @factoryMethod
  HomeCubit() : super(const _HomeStateIdle());

  Future<void> init() async {
    // Initialize home data if needed
  }

  Future<void> load() async {
    emit(const HomeState.loading());
    await Future.delayed(const Duration(milliseconds: 2000));
    emit(const HomeState.idle());
  }
}
