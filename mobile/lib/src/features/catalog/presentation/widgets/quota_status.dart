import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../config/app_session.dart';
import '../../../../core/_core.dart';
import '../../domain/entities/quota_snapshot.dart';

class QuotaStatus extends StatefulWidget {
  final QuotaSnapshot? snapshot;
  final QuotaMetric metric;
  final AppSession? session;
  final bool rateLimited, unavailable, loadedResult;
  const QuotaStatus({
    super.key,
    this.snapshot,
    this.metric = QuotaMetric.barcodeLookup,
    this.session,
    this.rateLimited = false,
    this.unavailable = false,
    this.loadedResult = false,
  });
  @override
  State<QuotaStatus> createState() => _QuotaStatusState();
}

class _QuotaStatusState extends State<QuotaStatus> {
  Timer? _expiry;
  bool _pastReset = false;
  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void didUpdateWidget(covariant QuotaStatus old) {
    super.didUpdateWidget(old);
    if (old.snapshot != widget.snapshot) _schedule();
  }

  void _schedule() {
    _expiry?.cancel();
    _pastReset = false;
    final reset = widget.snapshot?.resetAt;
    if (reset != null) {
      final delay = reset.difference(DateTime.now().toUtc());
      if (delay > Duration.zero) {
        _expiry = Timer(delay, () {
          if (mounted) {
            setState(() {
              _pastReset = true;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _expiry?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.session ?? const AlwaysStoppedAnimation<int>(0),
    builder: (context, _) {
      final l = context.l10n, d = context.themeData.dimensionsData;
      final user = widget.session?.userId;
      final guest = user == null;
      final q = widget.snapshot;
      final own = !guest && q?.ownerId == user;
      final expired = _pastReset || (q?.expired(DateTime.now().toUtc()) ?? false);
      final known = own && !widget.unavailable && !expired;
      final metric = q?.metric ?? widget.metric;
      final label = metric == QuotaMetric.aiAnalysis ? l.pkQuotaAnalysis : l.pkQuotaBarcode;
      String? reset;
      if (known) {
        final local = q!.resetAt.toLocal();
        final m = MaterialLocalizations.of(context);
        reset =
            '${m.formatMediumDate(local)} · ${m.formatTimeOfDay(TimeOfDay.fromDateTime(local))} ${local.timeZoneName}';
      }
      return Semantics(
        container: true,
        liveRegion: true,
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(d.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(label, style: context.textTheme.titleSmall),
                Gap(d.spacingXs),
                if (guest)
                  Text(
                    metric == QuotaMetric.aiAnalysis
                        ? l.pkQuotaSignInAnalysis
                        : widget.rateLimited
                        ? l.pkQuotaGuestLimited
                        : l.pkQuotaGuestFairUse,
                  )
                else if (widget.rateLimited)
                  Text(l.pkQuotaRateLimited)
                else if (known) ...[
                  Text(
                    l.pkQuotaRemaining(q!.remaining, q.limit),
                    style: context.textTheme.titleMedium,
                  ),
                  if (q.reserved > 0) Text(l.pkQuotaReserved(q.reserved)),
                  Text(l.pkQuotaReset(reset!)),
                  Text(l.pkQuotaReported, style: context.textTheme.bodySmall),
                  if (q.remaining == 0) Text(q.reserved > 0 ? l.pkQuotaHeld : l.pkQuotaExhausted),
                ] else
                  Text(expired && own ? l.pkQuotaRefresh : l.pkQuotaUnavailable),
                if (widget.loadedResult) Text(l.pkQuotaLoadedAvailable),
              ],
            ),
          ),
        ),
      );
    },
  );
}
