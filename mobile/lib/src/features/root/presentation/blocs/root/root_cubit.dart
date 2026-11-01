import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'root_state.dart';
part 'root_cubit.freezed.dart';

@lazySingleton
class RootCubit extends Cubit<RootState> {
  @factoryMethod
  RootCubit() : super(const _RootStateIdle());

  void setSelectedIndex(int selectedIndex) {
    emit(state.copyWith(selectedIndex: selectedIndex));
  }
}
