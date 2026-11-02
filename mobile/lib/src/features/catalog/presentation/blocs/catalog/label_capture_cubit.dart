import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../data/data_sources/services/scanner_media_service.dart';

class LabelCaptureState {
  final List<Uint8List> labels;
  final bool busy, failed;
  const LabelCaptureState({this.labels = const [], this.busy = false, this.failed = false});
}

@injectable
class LabelCaptureCubit extends Cubit<LabelCaptureState> {
  final ScannerMediaService media;
  LabelCaptureCubit(this.media) : super(const LabelCaptureState());
  Future<void> capture() async {
    if (state.busy || state.labels.length >= 2) return;
    final labels = state.labels;
    emit(LabelCaptureState(labels: labels, busy: true));
    try {
      final bytes = await media.captureLabel();
      if (!isClosed) {
        emit(
          LabelCaptureState(labels: bytes == null ? labels : List.unmodifiable([...labels, bytes])),
        );
      }
    } catch (_) {
      if (!isClosed) emit(LabelCaptureState(labels: labels, failed: true));
    }
  }

  void reset() {
    if (!isClosed && !state.busy) emit(const LabelCaptureState());
  }
}
