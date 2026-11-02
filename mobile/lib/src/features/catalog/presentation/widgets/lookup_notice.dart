import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/_core.dart';
import '../../domain/entities/catalog_entity.dart';

class LookupNotice extends StatelessWidget {
  final LookupStatus status;
  final String? error;
  final Map<String, dynamic>? quota;
  final VoidCallback retry;
  const LookupNotice({
    super.key,
    required this.status,
    this.error,
    this.quota,
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
        ? l.pkDenied
        : l.pkError;
    final reset = DateTime.tryParse(quota?['reset_at']?.toString() ?? '')?.toLocal();
    return Padding(
      padding: context.themeData.edgeInsetsData.pagePadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, textAlign: TextAlign.center),
          if (reset != null)
            Text(MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(reset))),
          Gap(context.themeData.dimensionsData.spacingMd),
          FilledButton(onPressed: retry, child: Text(l.pkRetry)),
        ],
      ),
    );
  }
}
