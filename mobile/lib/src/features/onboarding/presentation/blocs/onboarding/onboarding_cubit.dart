import 'dart:convert';

import 'package:bloc/bloc.dart';
import '../../../../../core/_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'onboarding_state.dart';
part 'onboarding_cubit.freezed.dart';
part 'onboarding_cubit.g.dart';

@lazySingleton
class OnboardingCubit extends Cubit<OnboardingState> {
  @factoryMethod
  OnboardingCubit(this._storage) : super(const _OnboardingStateIdle());

  bool get hasProgress => state != const OnboardingState.idle();

  final DataStorage _storage;
  Future<void> _writeQueue = Future.value();

  Future<void> init() async {
    final value = await _storage.read(DataStorageKeys.onboardingAnswers);
    if (value is! String) return;
    try {
      final decoded = jsonDecode(value) as Map<String, dynamic>;
      if (!isClosed) emit(OnboardingState.fromJson(decoded));
    } catch (error) {
      AppLogger.logError(error);
    }
  }

  @override
  void onChange(Change<OnboardingState> change) {
    super.onChange(change);
    final snapshot = jsonEncode(change.nextState.toJson());
    _writeQueue = _writeQueue
        .then((_) async {
          await _storage.write(DataStorageKeys.onboardingAnswers, snapshot);
        })
        .catchError((Object error) {
          AppLogger.logError(error);
        });
  }

  Future<void> save() async {
    await _writeQueue;
    if (await _storage.write(DataStorageKeys.onboardingAnswers, jsonEncode(state.toJson())) !=
        true) {
      throw StateError('Unable to save onboarding answers.');
    }
  }

  void setSlideIndex(int slideIndex) {
    emit(state.copyWith(slideIndex: slideIndex));
  }

  void setName(String name) {
    emit(state.copyWith(name: name));
  }

  void setAgeRange(String ageRange) {
    emit(state.copyWith(ageRange: ageRange));
  }

  void setGender(String gender) {
    emit(state.copyWith(gender: gender));
  }

  void setFrequency(String frequency) {
    emit(state.copyWith(frequency: frequency));
  }

  void setGoal(String goal) {
    emit(state.copyWith(goal: goal));
  }

  void setChallenge(String challenge) {
    emit(state.copyWith(challenge: challenge));
  }

  void setCaptureTime(String captureTime) {
    emit(state.copyWith(captureTime: captureTime));
  }

  void setHasUsedOtherApps(bool value) {
    emit(state.copyWith(hasUsedOtherApps: value));
  }

  void setWantsDailyReminders(bool value) {
    emit(state.copyWith(wantsDailyReminders: value));
  }

  void setDidAllowNotifications(bool value) {
    emit(state.copyWith(didAllowNotifications: value));
  }

  void toggleUseCase(String useCase) {
    final currentList = List<String>.from(state.selectedUseCases);
    if (currentList.contains(useCase)) {
      currentList.remove(useCase);
    } else {
      currentList.add(useCase);
    }
    emit(state.copyWith(selectedUseCases: currentList));
  }

  void reset() {
    emit(const _OnboardingStateIdle());
  }
}
