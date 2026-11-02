import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/_domain.dart';
part 'catalog_state.dart';

@injectable
class CatalogCubit extends Cubit<CatalogState> {
  final GetCatalogUseCase lookup;
  String? _key, _code;
  int _generation = 0;
  CatalogCubit(this.lookup) : super(const CatalogState());
  static String requestKey() {
    final bytes = List.generate(16, (_) => Random.secure().nextInt(256));
    bytes[6] = (bytes[6] & 15) | 64;
    bytes[8] = (bytes[8] & 63) | 128;
    final s = bytes.map((v) => v.toRadixString(16).padLeft(2, '0')).join();
    return '${s.substring(0, 8)}-${s.substring(8, 12)}-${s.substring(12, 16)}-${s.substring(16, 20)}-${s.substring(20)}';
  }

  void scanning() {
    if (!isClosed) emit(const CatalogState(status: LookupStatus.scanning));
  }

  void cameraDenied() {
    if (!isClosed) emit(const CatalogState(status: LookupStatus.denied, error: 'camera'));
  }

  void cameraError() {
    if (!isClosed) emit(const CatalogState(status: LookupStatus.error, error: 'camera'));
  }

  Future<void> check(
    String raw, {
    bool upce = false,
    bool retry = false,
    bool local = false,
  }) async {
    if (isClosed || state.status == LookupStatus.checking) return;
    String code;
    try {
      code = normalizeGtin(raw, upce: upce);
    } catch (_) {
      emit(const CatalogState(status: LookupStatus.error, error: 'invalid_barcode'));
      return;
    }
    if (!retry || _code != code) {
      _key = requestKey();
    }
    _code = code;
    final generation = ++_generation;
    emit(CatalogState(status: LookupStatus.checking, barcode: code));
    final result = await lookup((code, _key!, local));
    if (isClosed || generation != _generation) return;
    result.fold(
      (failure) => emit(
        CatalogState(status: LookupStatus.error, barcode: code, error: failure.error.statusCode),
      ),
      (entity) => emit(
        CatalogState(
          status: entity.status,
          barcode: code,
          product: entity.product,
          quota: entity.quota,
          error: entity.errorCode,
          recentSaved: entity.recentSaved,
        ),
      ),
    );
  }

  Future<void> retry() => _code == null
      ? Future.value()
      : check(
          _code!,
          retry:
              state.status == LookupStatus.error &&
              !{'idempotency_expired', 'idempotency_conflict'}.contains(state.error),
        );
  @override
  Future<void> close() {
    _generation++;
    return super.close();
  }
}
