import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/_domain.dart';

class LabelCaptureState {
  final String? barcode, error;
  final LabelPhoto? nutrition, ingredients;
  final LabelKind? capturing;
  const LabelCaptureState({
    this.barcode,
    this.nutrition,
    this.ingredients,
    this.capturing,
    this.error,
  });
  bool get busy => capturing != null;
  bool get ready => nutrition != null && ingredients != null;
  int get count => (nutrition == null ? 0 : 1) + (ingredients == null ? 0 : 1);
}

// App-owned single draft: route replacement for OTP must not close this Cubit.
// Nothing is serialized; draft files expire and are removed on discard/replacement.
@lazySingleton
class LabelCaptureCubit extends Cubit<LabelCaptureState> {
  static const draftLifetime = Duration(hours: 1);
  final CaptureLabelUseCase captureLabel;
  Timer? _expiry;
  int _generation = 0;
  final Set<LabelPhoto> _pendingCleanup = {};
  LabelCaptureCubit(this.captureLabel) : super(const LabelCaptureState());

  Future<void> begin(String raw) async {
    final code = normalizeGtin(raw);
    if (isClosed || state.barcode == code) return;
    final old = [state.nutrition, state.ingredients].whereType<LabelPhoto>().toList();
    _generation++;
    _expiry?.cancel();
    emit(LabelCaptureState(barcode: code));
    _scheduleExpiry();
    await _delete(old);
  }

  void _scheduleExpiry() {
    _expiry?.cancel();
    _expiry = Timer(draftLifetime, () => discard(expired: true));
  }

  Future<void> _delete(Iterable<LabelPhoto> photos) async {
    _pendingCleanup.addAll(photos);
    for (final photo in _pendingCleanup.toList()) {
      try {
        await captureLabel.discard(photo);
        _pendingCleanup.remove(photo);
      } catch (_) {
        // Do not accumulate more photos while cleanup fails. Retry on the next
        // action; private OS cache is also swept by the next process/session.
      }
    }
  }

  Future<void> capture(LabelKind kind) async {
    if (isClosed ||
        state.busy ||
        state.barcode == null ||
        (kind == LabelKind.ingredients && state.nutrition == null)) {
      return;
    }
    final previous = state;
    final generation = _generation;
    emit(
      LabelCaptureState(
        barcode: previous.barcode,
        nutrition: previous.nutrition,
        ingredients: previous.ingredients,
        capturing: kind,
      ),
    );
    await _delete([]);
    try {
      if (_pendingCleanup.isNotEmpty) throw StateError('cleanup');
      await captureLabel.prepare();
    } catch (_) {
      if (!isClosed && generation == _generation) {
        emit(
          LabelCaptureState(
            barcode: previous.barcode,
            nutrition: previous.nutrition,
            ingredients: previous.ingredients,
            error: 'cleanup',
          ),
        );
      }
      return;
    }
    if (isClosed || generation != _generation) return;
    final result = await captureLabel();
    final photo = result.fold((_) => null, (photo) => photo);
    if (isClosed || generation != _generation) {
      if (photo != null) await _delete([photo]);
      return;
    }
    final error = result.fold((failure) => failure.error.statusCode, (_) => null);
    final replaced = kind == LabelKind.nutrition ? previous.nutrition : previous.ingredients;
    if (photo != null && replaced != null) await _delete([replaced]);
    if (isClosed || generation != _generation) {
      if (photo != null) await _delete([photo]);
      return;
    }
    _expiry ??= Timer(draftLifetime, () => discard(expired: true));
    emit(
      LabelCaptureState(
        barcode: previous.barcode,
        nutrition: kind == LabelKind.nutrition ? photo ?? previous.nutrition : previous.nutrition,
        ingredients: kind == LabelKind.ingredients
            ? photo ?? previous.ingredients
            : previous.ingredients,
        error: error ?? (_pendingCleanup.isNotEmpty ? 'cleanup' : null),
      ),
    );
  }

  Future<void> discard({bool expired = false}) async {
    if (isClosed) return;
    final old = [state.nutrition, state.ingredients].whereType<LabelPhoto>().toList();
    _generation++;
    _expiry?.cancel();
    _expiry = null;
    emit(LabelCaptureState(barcode: state.barcode, error: expired ? 'draft_expired' : null));
    await _delete(old);
    if (!isClosed && _pendingCleanup.isNotEmpty) {
      emit(LabelCaptureState(barcode: state.barcode, error: 'cleanup'));
    }
  }

  @override
  @disposeMethod
  Future<void> close() async {
    _generation++;
    _expiry?.cancel();
    await _delete([state.nutrition, state.ingredients].whereType<LabelPhoto>());
    await super.close();
  }
}
