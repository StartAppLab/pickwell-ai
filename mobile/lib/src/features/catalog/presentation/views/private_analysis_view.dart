import '../widgets/quota_status.dart';
import '../../domain/entities/quota_snapshot.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_session.dart';
import '../../../../core/_core.dart';
import '../../domain/entities/analysis_entity.dart';
import '../../domain/entities/pending_capture.dart';
import '../../domain/use_cases/analyze_product_use_case.dart';
import '../blocs/catalog/label_capture_cubit.dart';
import '../widgets/product_result_content.dart';

/// Owner-only preliminary analysis. Never enters CatalogCubit or public recents.
class PrivateAnalysisView extends StatefulWidget {
  final String jobId;
  final String barcode;
  final AppSession session;
  final AnalyzeProductUseCase analyze;
  final LabelCaptureCubit drafts;
  const PrivateAnalysisView({
    super.key,
    required this.jobId,
    required this.session,
    required this.analyze,
    required this.drafts,
    this.barcode = '',
  });
  @override
  State<PrivateAnalysisView> createState() => _PrivateAnalysisViewState();
}

class _PrivateAnalysisViewState extends State<PrivateAnalysisView> {
  AnalysisResult? _result;
  PendingCapture? _draft;
  String? _owner;
  bool _busy = false, _failed = false, _authRequired = false;
  int _generation = 0;
  Timer? _expiry;
  @override
  void initState() {
    super.initState();
    widget.session.addListener(_identityChanged);
    _load();
  }

  void _identityChanged() {
    if (_owner != widget.session.userId) {
      _expiry?.cancel();
      setState(() {
        _result = null;
        _draft = null;
      });
      _load();
    }
  }

  Future<void> _load({bool cancel = false}) async {
    final generation = ++_generation, owner = widget.session.userId;
    _owner = owner;
    if (owner == null) {
      setState(() {
        _busy = false;
        _result = null;
        _draft = null;
      });
      return;
    }
    setState(() {
      _busy = true;
      _failed = false;
    });
    await widget.drafts.restore();
    if (!mounted || generation != _generation || widget.session.userId != owner) return;
    final saved = widget.drafts.state.pending
        .where((d) => d.privateJobId == widget.jobId && d.privateOwnerId == owner)
        .firstOrNull;
    final barcode = saved?.barcode ?? widget.barcode;
    final response = cancel && saved != null
        ? await widget.analyze.cancelReview(saved.requestId, barcode)
        : await widget.analyze.privateResult(widget.jobId, barcode);
    if (!mounted || generation != _generation || widget.session.userId != owner) return;
    final result = response.fold((_) => null, (r) => r);
    final valid =
        result?.phase == AnalysisPhase.privateReady &&
        result?.ownerId == owner &&
        result?.jobId == widget.jobId &&
        (result?.privateExpiresAt?.isAfter(DateTime.now()) ?? false);
    final transient =
        result == null ||
        result.phase == AnalysisPhase.error ||
        result.phase == AnalysisPhase.denied;
    final previous = _result;
    final retained =
        transient &&
        previous?.ownerId == owner &&
        (previous?.privateExpiresAt?.isAfter(DateTime.now()) ?? false);
    setState(() {
      _busy = false;
      _authRequired = result?.phase == AnalysisPhase.authRequired;
      _failed = transient;
      _result = valid || result?.phase == AnalysisPhase.ready
          ? result
          : retained
          ? previous
          : null;
      _draft = valid || retained ? saved : null;
    });
    _expiry?.cancel();
    if (_result?.phase == AnalysisPhase.privateReady) {
      _expiry = Timer(_result!.privateExpiresAt!.difference(DateTime.now()), () {
        if (mounted) {
          setState(() {
            _result = null;
            _draft = null;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _generation++;
    _expiry?.cancel();
    widget.session.removeListener(_identityChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final result = _owner == widget.session.userId ? _result : null;
    final product = result?.product;
    final front = _draft?.front;
    final canonical = result?.canonicalProduct;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: product == null
            ? Center(
                child: Padding(
                  padding: context.themeData.edgeInsetsData.pagePadding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_busy)
                        const CircularProgressIndicator()
                      else
                        Text(
                          (widget.session.userId == null || _authRequired)
                              ? l.pkPrivateSignIn
                              : _failed
                              ? l.pkError
                              : l.pkPrivateExpired,
                        ),
                      if (!_busy && (widget.session.userId == null || _authRequired))
                        TextButton(
                          onPressed: () async {
                            await context.push('/email-sign-in');
                            if (mounted) await _load();
                          },
                          child: Text(l.pkContinue),
                        ),
                      if (!_busy) TextButton(onPressed: _load, child: Text(l.pkRetry)),
                    ],
                  ),
                ),
              )
            : ProductResultContent(
                product: product,
                privateThumbnail: front == null
                    ? null
                    : SizedBox(
                        width: 80,
                        height: 96,
                        child: Image.file(
                          File(front.path),
                          fit: BoxFit.cover,
                          cacheWidth: 384,
                          errorBuilder: (_, _, _) => const Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
                statusNotice: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    QuotaStatus(
                      snapshot: result?.quota,
                      session: widget.session,
                      metric: QuotaMetric.aiAnalysis,
                      loadedResult: true,
                    ),
                    Text(l.pkPrivateReady, style: context.textTheme.titleSmall),
                    Text(
                      result?.phase == AnalysisPhase.ready ||
                              result?.publicationStatus == 'published'
                          ? l.pkPrivatePublished
                          : l.pkPrivateNotice,
                    ),
                    if (_failed) Text(l.pkError),
                    Text(l.pkPrivateRetention, style: context.textTheme.bodySmall),
                    if (['rejected', 'cancelled', 'expired'].contains(result?.publicationStatus))
                      Text(l.pkPrivateReviewClosed),
                    if (canonical != null || result?.phase == AnalysisPhase.ready)
                      TextButton(
                        onPressed: () => context.push('/product/${product.barcode}'),
                        child: Text(l.pkPrivateViewShared),
                      ),
                    if (_busy)
                      const LinearProgressIndicator()
                    else ...[
                      TextButton(onPressed: _load, child: Text(l.pkPrivateCheck)),
                      if (_draft != null &&
                          ['pending', 'approved'].contains(result?.publicationStatus))
                        TextButton(
                          onPressed: () => _load(cancel: true),
                          child: Text(l.pkPrivateCancel),
                        ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
