import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/_domain.dart';

class LabelCaptureState {
  final String? barcode, error;
  final LabelPhoto? front, nutrition, ingredients;
  final LabelKind? capturing;
  final bool saving;
  final List<PendingCapture> pending;
  const LabelCaptureState({
    this.barcode,
    this.front,
    this.nutrition,
    this.ingredients,
    this.capturing,
    this.saving = false,
    this.pending = const [],
    this.error,
  });
  bool get busy => capturing != null || saving;
  bool get ready => front != null && nutrition != null && ingredients != null;
  int get count =>
      (front == null ? 0 : 1) + (nutrition == null ? 0 : 1) + (ingredients == null ? 0 : 1);
}

// App-owned bounded queue. Switching the active product never discards another draft.
@lazySingleton
class LabelCaptureCubit extends Cubit<LabelCaptureState> {
  static const maxDrafts = PendingCapture.maxDrafts;
  static const draftLifetime = Duration(hours: 24);
  final CaptureLabelUseCase captureLabel;
  final PendingCaptureRepository? drafts;
  String? _requestId;
  DateTime? _expiresAt;
  int _attempts = 0;
  Future<void>? _restoring;
  String? get requestId => _requestId;
  int get attempts => _attempts;
  DateTime? get expiresAt => _expiresAt;
  final _expiries = <String, Timer>{};
  final _pending = <String, PendingCapture>{};
  int _generation = 0;
  final Set<LabelPhoto> _pendingCleanup = {};
  LabelCaptureCubit(this.captureLabel, [this.drafts]) : super(const LabelCaptureState());

  void _show(LabelCaptureState next) {
    if (isClosed) return;
    final items = _pending.values.toList()..sort((a, b) => b.expiresAt.compareTo(a.expiresAt));
    emit(
      LabelCaptureState(
        barcode: next.barcode,
        front: next.front,
        nutrition: next.nutrition,
        ingredients: next.ingredients,
        capturing: next.capturing,
        saving: next.saving,
        error: next.error,
        pending: List.unmodifiable(items),
      ),
    );
  }

  void _activate(PendingCapture item) {
    _requestId = item.requestId;
    _expiresAt = item.expiresAt;
    _attempts = item.attempts;
    _show(
      LabelCaptureState(
        barcode: item.barcode,
        front: item.front,
        nutrition: item.nutrition,
        ingredients: item.ingredients,
      ),
    );
  }

  Future<void> restore() => _restoring ??= _restore();
  Future<void> retryRestore() async {
    if (isClosed || state.busy || _pending.isNotEmpty || state.count > 0) return;
    _restoring = null;
    await restore();
  }

  Future<void> _restore() async {
    try {
      final saved = await drafts?.loadAll() ?? <PendingCapture>[];
      if (isClosed) return;
      for (final item in saved) {
        _pending[item.barcode] = item;
        _schedule(item.barcode, item.expiresAt);
      }
      if (saved.isNotEmpty) {
        _activate(saved.first);
      } else if (state.error == 'draft_load') {
        _show(const LabelCaptureState());
      }
    } catch (_) {
      if (!isClosed) {
        _show(
          LabelCaptureState(
            barcode: state.barcode,
            front: state.front,
            nutrition: state.nutrition,
            ingredients: state.ingredients,
            error: 'draft_load',
          ),
        );
      }
    }
  }

  Future<bool> _persist() async {
    final code = state.barcode;
    if (code == null) return true;
    if (state.count == 0) return true;
    final item = PendingCapture(
      barcode: code,
      requestId: _requestId!,
      expiresAt: _expiresAt!,
      front: state.front,
      nutrition: state.nutrition,
      ingredients: state.ingredients,
      attempts: _attempts,
    );
    try {
      await drafts?.save(item);
      _pending[code] = item;
      _show(
        LabelCaptureState(
          barcode: state.barcode,
          front: state.front,
          nutrition: state.nutrition,
          ingredients: state.ingredients,
          saving: state.saving,
          capturing: state.capturing,
          error: state.error == 'draft_save' ? null : state.error,
        ),
      );
      return true;
    } catch (_) {
      _pending[code] = PendingCapture(
        barcode: code,
        requestId: _requestId!,
        expiresAt: _expiresAt!,
        front: state.front,
        nutrition: state.nutrition,
        ingredients: state.ingredients,
        attempts: _attempts,
        saved: false,
      );
      if (!isClosed) {
        _show(
          LabelCaptureState(
            barcode: state.barcode,
            front: state.front,
            nutrition: state.nutrition,
            ingredients: state.ingredients,
            error: 'draft_save',
          ),
        );
      }
      return false;
    }
  }

  Future<bool> renewRequest() async {
    _requestId = createCatalogRequestId();
    _attempts = 0;
    return _persist();
  }

  Future<bool> recordAttempts(int attempts) async {
    _attempts = attempts;
    return _persist();
  }

  Future<void> begin(String raw) async {
    await restore();
    final code = normalizeGtin(raw);
    if (isClosed || state.barcode == code || state.busy || state.error == 'draft_load') return;
    if (state.count > 0 && !await _persist()) return;
    if (isClosed) return;
    final saved = _pending[code];
    if (saved == null && _pending.length >= PendingCapture.maxDrafts) {
      _show(
        LabelCaptureState(
          barcode: state.barcode,
          front: state.front,
          nutrition: state.nutrition,
          ingredients: state.ingredients,
          error: 'draft_limit',
        ),
      );
      return;
    }
    if (state.count == 0 && state.barcode != null) _expiries.remove(state.barcode)?.cancel();
    _generation++;
    if (saved != null) {
      _activate(saved);
      return;
    }
    _requestId = createCatalogRequestId();
    _attempts = 0;
    _expiresAt = DateTime.now().toUtc().add(draftLifetime);
    _show(LabelCaptureState(barcode: code));
    _schedule(code, _expiresAt!);
  }

  void _schedule(String code, DateTime expires) {
    if (isClosed) return;
    _expiries.remove(code)?.cancel();
    _expiries[code] = Timer(
      expires.difference(DateTime.now().toUtc()),
      () => discardBarcode(code, expired: true),
    );
  }

  Future<void> _delete(Iterable<LabelPhoto> photos) async {
    _pendingCleanup.addAll(photos);
    for (final photo in _pendingCleanup.toList()) {
      try {
        await captureLabel.discard(photo).timeout(const Duration(seconds: 5));
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
        (kind != LabelKind.front && state.front == null) ||
        (kind == LabelKind.ingredients && state.nutrition == null)) {
      return;
    }
    _expiresAt ??= DateTime.now().toUtc().add(draftLifetime);
    _requestId ??= createCatalogRequestId();
    final previous = state;
    final generation = _generation;
    _show(
      LabelCaptureState(
        barcode: previous.barcode,
        front: previous.front,
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
        _show(
          LabelCaptureState(
            barcode: previous.barcode,
            front: previous.front,
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
    final replaced = switch (kind) {
      LabelKind.front => previous.front,
      LabelKind.nutrition => previous.nutrition,
      LabelKind.ingredients => previous.ingredients,
    };
    if (photo != null && replaced != null) await _delete([replaced]);
    if (isClosed || generation != _generation) {
      if (photo != null) await _delete([photo]);
      return;
    }
    if (photo != null) {
      _requestId = createCatalogRequestId();
      _attempts = 0;
    }
    _schedule(state.barcode!, _expiresAt!);
    _show(
      LabelCaptureState(
        barcode: previous.barcode,
        front: kind == LabelKind.front ? photo ?? previous.front : previous.front,
        nutrition: kind == LabelKind.nutrition ? photo ?? previous.nutrition : previous.nutrition,
        ingredients: kind == LabelKind.ingredients
            ? photo ?? previous.ingredients
            : previous.ingredients,
        error: error ?? (_pendingCleanup.isNotEmpty ? 'cleanup' : null),
        saving: photo != null && drafts != null,
      ),
    );
    await _persist();
    if (!isClosed && generation == _generation && state.saving) {
      _show(
        LabelCaptureState(
          barcode: state.barcode,
          front: state.front,
          nutrition: state.nutrition,
          ingredients: state.ingredients,
          error: state.error,
        ),
      );
    }
  }

  Future<void> discard({bool expired = false}) async {
    final code = state.barcode;
    if (code != null) await discardBarcode(code, expired: expired);
  }

  Future<void> discardBarcode(String raw, {bool expired = false}) async {
    final code = normalizeGtin(raw);
    if (isClosed) return;
    final active = state.barcode == code;
    final old = active
        ? [state.front, state.nutrition, state.ingredients].whereType<LabelPhoto>().toList()
        : [
            _pending[code]?.front,
            _pending[code]?.nutrition,
            _pending[code]?.ingredients,
          ].whereType<LabelPhoto>().toList();
    try {
      await drafts?.clear(code);
    } catch (_) {
      if (!isClosed) {
        _show(
          LabelCaptureState(
            barcode: state.barcode,
            front: state.front,
            nutrition: state.nutrition,
            ingredients: state.ingredients,
            error: 'cleanup',
          ),
        );
      }
      return;
    }
    _pending.remove(code);
    _expiries.remove(code)?.cancel();
    if (active) {
      _requestId = null;
      _attempts = 0;
      _expiresAt = null;
      _generation++;
      _show(LabelCaptureState(barcode: code, error: expired ? 'draft_expired' : null));
    } else {
      _show(
        LabelCaptureState(
          barcode: state.barcode,
          front: state.front,
          nutrition: state.nutrition,
          ingredients: state.ingredients,
          error: state.error,
        ),
      );
    }
    await _delete(old.where((p) => !_inUse(p)));
    if (!isClosed && _pendingCleanup.isNotEmpty) {
      _show(
        LabelCaptureState(
          barcode: state.barcode,
          front: state.front,
          nutrition: state.nutrition,
          ingredients: state.ingredients,
          error: 'cleanup',
        ),
      );
    }
  }

  bool _inUse(LabelPhoto photo) =>
      identical(photo, state.front) ||
      identical(photo, state.nutrition) ||
      identical(photo, state.ingredients) ||
      _pending.values.any(
        (d) =>
            identical(photo, d.front) ||
            identical(photo, d.nutrition) ||
            identical(photo, d.ingredients),
      );
  // A late completion clears only the submitted version of its product, not a
  // switched active product or a newer retake of the same barcode.
  Future<bool> discardSubmitted(LabelCaptureState submitted) async {
    final saved = _pending[submitted.barcode];
    final matchesSaved =
        saved != null &&
        identical(saved.front, submitted.front) &&
        identical(saved.nutrition, submitted.nutrition) &&
        identical(saved.ingredients, submitted.ingredients);
    final matchesActive =
        state.barcode == submitted.barcode &&
        identical(state.front, submitted.front) &&
        identical(state.nutrition, submitted.nutrition) &&
        identical(state.ingredients, submitted.ingredients);
    if (matchesSaved || matchesActive) {
      await discardBarcode(submitted.barcode!);
    } else {
      await _delete(
        [
          submitted.front,
          submitted.nutrition,
          submitted.ingredients,
        ].whereType<LabelPhoto>().where((p) => !_inUse(p)),
      );
    }
    return _pendingCleanup.isEmpty &&
        ![
          submitted.front,
          submitted.nutrition,
          submitted.ingredients,
        ].whereType<LabelPhoto>().any(_inUse);
  }

  @override
  @disposeMethod
  Future<void> close() async {
    _generation++;
    for (final timer in _expiries.values) {
      timer.cancel();
    }
    if (drafts == null) {
      await _delete({
        ..._pending.values
            .expand((d) => [d.front, d.nutrition, d.ingredients])
            .whereType<LabelPhoto>(),
        ...([state.front, state.nutrition, state.ingredients].whereType<LabelPhoto>()),
      });
    }
    await super.close();
  }
}
