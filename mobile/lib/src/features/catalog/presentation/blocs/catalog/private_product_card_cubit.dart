import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../../domain/_domain.dart';
import 'label_capture_cubit.dart';

class PrivateProductCardState {
  final ProductRecord? product;
  final bool loading, published, unavailable, expired, cleanupFailed;
  const PrivateProductCardState({
    this.product,
    this.loading = false,
    this.published = false,
    this.unavailable = false,
    this.expired = false,
    this.cleanupFailed = false,
  });
}

/// Ephemeral owner-only display state. Never writes private facts to shared recents.
class PrivateProductCardCubit extends Cubit<PrivateProductCardState> {
  final PendingCapture item;
  final AnalyzeProductUseCase analyze;
  final GetCatalogUseCase lookup;
  final LabelCaptureCubit drafts;
  final bool Function() authorized;
  final Future<void> Function()? onPublished;
  Timer? _expiry;
  PrivateProductCardCubit({
    required this.item,
    required this.analyze,
    required this.lookup,
    required this.drafts,
    required this.authorized,
    this.onPublished,
    AnalysisResult? initial,
  }) : super(
         PrivateProductCardState(
           product:
               initial?.phase == AnalysisPhase.privateReady &&
                   initial?.ownerId == item.privateOwnerId &&
                   initial?.jobId == item.privateJobId &&
                   initial?.product?.barcode == item.barcode &&
                   (initial?.privateExpiresAt?.isAfter(DateTime.now()) ?? false)
               ? initial?.product
               : null,
         ),
       ) {
    final until = item.privateExpiresAt != null && item.privateExpiresAt!.isBefore(item.expiresAt)
        ? item.privateExpiresAt!
        : item.expiresAt;
    _expiry = Timer(until.difference(DateTime.now()), () {
      if (!isClosed) emit(const PrivateProductCardState(expired: true));
    });
  }
  Future<void> load() async {
    try {
      await _load();
    } catch (_) {
      if (!isClosed && authorized() && !state.expired) {
        emit(
          PrivateProductCardState(
            product: state.product,
            published: state.published,
            unavailable: true,
          ),
        );
      }
    }
  }

  Future<void> _load() async {
    if (isClosed || state.loading || state.expired || !authorized()) return;
    final previous = state;
    emit(
      PrivateProductCardState(
        product: previous.product,
        loading: true,
        published: previous.published,
      ),
    );
    final response = await analyze.privateResult(item.privateJobId!, item.barcode);
    if (isClosed || !authorized() || state.expired) return;
    final result = response.fold((_) => null, (r) => r);
    if (result?.phase == AnalysisPhase.privateReady &&
        (result?.ownerId != item.privateOwnerId || result?.jobId != item.privateJobId)) {
      emit(const PrivateProductCardState(unavailable: true));
      return;
    }
    final publicProduct = result?.phase == AnalysisPhase.ready
        ? result?.product
        : result?.phase == AnalysisPhase.privateReady && result?.publicationStatus == 'published'
        ? result?.canonicalProduct
        : null;
    if (publicProduct != null && publicProduct.barcode == item.barcode) {
      // The repository has cached only the server's sanitized canonical record.
      // Reuse the normal local opening path to persist its reference before cleanup.
      final opened = await lookup((item.barcode, createCatalogRequestId(), true));
      if (isClosed || !authorized() || state.expired) return;
      final saved = opened.fold(
        (_) => false,
        (p) =>
            p.status == LookupStatus.found && p.product?.barcode == item.barcode && p.recentSaved,
      );
      emit(PrivateProductCardState(product: publicProduct, published: true, unavailable: !saved));
      if (saved) {
        await onPublished?.call();
        if (authorized()) {
          final clean = await drafts.discardExpected(item);
          if (!clean &&
              !isClosed &&
              authorized() &&
              drafts.state.pending.any(
                (d) => d.requestId == item.requestId && d.privateJobId == item.privateJobId,
              )) {
            emit(
              PrivateProductCardState(product: publicProduct, published: true, cleanupFailed: true),
            );
          }
        }
      }
      return;
    }
    if (result?.phase == AnalysisPhase.privateReady &&
        result?.ownerId == item.privateOwnerId &&
        result?.jobId == item.privateJobId &&
        (result?.privateExpiresAt?.isAfter(DateTime.now()) ?? false)) {
      emit(PrivateProductCardState(product: result!.product));
    } else if (result?.phase == AnalysisPhase.authRequired ||
        result?.phase == AnalysisPhase.blocked) {
      emit(PrivateProductCardState(expired: result?.error == 'private_expired', unavailable: true));
    } else {
      emit(
        PrivateProductCardState(
          product: previous.product,
          published: previous.published,
          unavailable: true,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _expiry?.cancel();
    return super.close();
  }
}
