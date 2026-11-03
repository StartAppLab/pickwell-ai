import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/_domain.dart';
import 'label_capture_cubit.dart';

class AnalysisSubmissionState {
  final AnalysisPhase phase;
  final String? barcode, error;
  final AnalysisResult? result;
  final bool canRetry;
  const AnalysisSubmissionState({
    this.phase = AnalysisPhase.idle,
    this.barcode,
    this.error,
    this.result,
    this.canRetry = false,
  });
  bool get busy => phase == AnalysisPhase.authenticating || phase == AnalysisPhase.submitting;
}

@lazySingleton
class AnalysisSubmissionCubit extends Cubit<AnalysisSubmissionState> {
  final AnalyzeProductUseCase analyze;
  final LabelCaptureCubit draft;
  String? _stamp, _key;
  LabelCaptureState? _submitted;
  int _attempts = 0;
  AnalysisSubmissionCubit(this.analyze, this.draft) : super(const AnalysisSubmissionState());
  String _fingerprint(LabelCaptureState s) =>
      '${s.barcode}|${s.nutrition?.path}|${s.nutrition?.capturedAt.toIso8601String()}|${s.ingredients?.path}|${s.ingredients?.capturedAt.toIso8601String()}';
  bool get current => _stamp == _fingerprint(draft.state);
  bool get canStart =>
      !isClosed &&
      !state.busy &&
      draft.state.ready &&
      draft.attempts < 3 &&
      (!current || state.phase == AnalysisPhase.idle || state.phase == AnalysisPhase.authRequired);
  bool beginAuthorization() {
    if (!canStart) return false;
    final s = draft.state, stamp = _fingerprint(s);
    if (stamp != _stamp) {
      _stamp = stamp;
      _key = draft.requestId ?? createCatalogRequestId();
      _attempts = draft.attempts;
    }
    _submitted = s;
    emit(AnalysisSubmissionState(phase: AnalysisPhase.authenticating, barcode: s.barcode));
    return true;
  }

  Future<void> finishAuthorization(bool authorized) async {
    if (isClosed || state.phase != AnalysisPhase.authenticating) return;
    if (!authorized) {
      emit(AnalysisSubmissionState(barcode: state.barcode));
      return;
    }
    emit(AnalysisSubmissionState(barcode: state.barcode));
    await submit();
  }

  Future<void> submit() async {
    if (isClosed ||
        state.busy ||
        !current ||
        !draft.state.ready ||
        _key == null ||
        _attempts >= 3) {
      return;
    }
    final snapshot = draft.state;
    _submitted = snapshot;
    _attempts++;
    emit(AnalysisSubmissionState(phase: AnalysisPhase.submitting, barcode: snapshot.barcode));
    if (!await draft.recordAttempts(_attempts)) {
      _attempts--;
      await draft.recordAttempts(_attempts);
      if (!isClosed) {
        emit(
          AnalysisSubmissionState(
            phase: AnalysisPhase.error,
            barcode: snapshot.barcode,
            error: 'draft_save',
            canRetry: true,
          ),
        );
      }
      return;
    }
    final response = await analyze(
      AnalysisRequest(
        barcode: snapshot.barcode!,
        requestId: _key!,
        nutrition: snapshot.nutrition!,
        ingredients: snapshot.ingredients!,
      ),
    );
    final result = response.fold(
      (_) =>
          const AnalysisResult(AnalysisPhase.error, error: 'transport_uncertain', retryable: true),
      (value) => value,
    );
    if (result.phase == AnalysisPhase.ready) {
      final clean = await draft.discardSubmitted(snapshot);
      if (clean) {
        _submitted = null;
        _stamp = null;
        _key = null;
      }
      if (!isClosed) {
        emit(
          AnalysisSubmissionState(
            phase: clean ? AnalysisPhase.ready : AnalysisPhase.cleanupFailed,
            barcode: snapshot.barcode,
            result: result,
          ),
        );
      }
      return;
    }
    if (isClosed) return;
    // A definitive quota denial made no model attempt; manual same-key checks
    // may re-evaluate a reset/config change. Only explicit no-provider admission responses
    // permit a fresh persisted request key; uncertain provider outcomes always reuse it.
    if (result.phase == AnalysisPhase.authRequired ||
        result.phase == AnalysisPhase.denied ||
        result.restartAllowed) {
      _attempts--;
      await draft.recordAttempts(_attempts);
      if (result.restartAllowed) {
        await draft.renewRequest();
        _key = draft.requestId;
        _attempts = 0;
      }
    }
    emit(
      AnalysisSubmissionState(
        phase: result.phase,
        barcode: snapshot.barcode,
        result: result,
        error: result.error,
        canRetry: result.retryable && _attempts < 3,
      ),
    );
  }

  bool get retryAvailable => state.canRetry && current;
  Future<void> retry() async {
    if (state.canRetry) await submit();
  }

  Future<void> retryCleanup() async {
    if (isClosed || state.phase != AnalysisPhase.cleanupFailed || _submitted == null) return;
    final result = state.result, barcode = state.barcode;
    final clean = await draft.discardSubmitted(_submitted!);
    if (clean) {
      _submitted = null;
      _stamp = null;
      _key = null;
    }
    if (!isClosed) {
      emit(
        AnalysisSubmissionState(
          phase: clean ? AnalysisPhase.ready : AnalysisPhase.cleanupFailed,
          barcode: barcode,
          result: result,
        ),
      );
    }
  }

  @override
  @disposeMethod
  Future<void> close() => super.close();
}
