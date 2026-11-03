import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/_core.dart';
import '../../domain/entities/catalog_entity.dart';
import '../../domain/entities/quota_snapshot.dart';
import '../../../../config/app_session.dart';
import 'quota_status.dart';

class LookupNotice extends StatelessWidget {
  final LookupStatus status;
  final String? error;
  final QuotaSnapshot? quota;
  final AppSession? session;
  final VoidCallback retry;
  const LookupNotice({
    super.key,
    required this.status,
    this.error,
    this.quota,
    this.session,
    required this.retry,
  });
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = error == 'camera'
        ? l.pkCameraHint
        : error == 'invalid_barcode'
        ? l.pkInvalidBarcode
        : error == 'no_barcode'
        ? l.pkNoBarcode
        : status == LookupStatus.processing
        ? l.pkProcessing
        : status == LookupStatus.denied
        ? (error == 'quota_exceeded' &&
                  session?.isAuthenticated == true &&
                  quota?.ownerId == session?.userId
              ? l.pkQuotaExhausted
              : l.pkQuotaRateLimited)
        : l.pkError;
    return Padding(
      padding: context.themeData.edgeInsetsData.pagePadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status == LookupStatus.processing ? Icons.hourglass_top_rounded : Icons.info_outline,
            size: context.themeData.dimensionsData.iconLarge,
            color: context.colorScheme.primary,
          ),
          Gap(context.themeData.dimensionsData.spacingSm),
          Semantics(
            liveRegion: true,
            child: Text(text, textAlign: TextAlign.center, style: context.textTheme.titleMedium),
          ),
          if (!{'camera', 'invalid_barcode', 'no_barcode'}.contains(error))
            QuotaStatus(
              snapshot: quota,
              session: session,
              rateLimited: error == 'rate_limited',
              unavailable: status == LookupStatus.error,
            ),
          Gap(context.themeData.dimensionsData.spacingMd),
          FilledButton(onPressed: retry, child: Text(l.pkRetry)),
        ],
      ),
    );
  }
}
