import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/_core.dart';
import 'barcode_lookup_loading.dart';

/// Reflects real submission/request status; does not invent completed AI substeps.
class CaptureAnalysisLoading extends StatelessWidget {
  final Widget? requestNotice;
  const CaptureAnalysisLoading({super.key, this.requestNotice});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final content = BarcodeLookupLoading(
        title: context.l10n.pkAnalysisLoadingTitle,
        description: context.l10n.pkAnalysisLoadingBody,
        icon: HugeIcons.strokeRoundedSparkles,
        showSweep: false,
      );
      if (requestNotice == null) {
        return Padding(padding: context.themeData.edgeInsetsData.pagePadding, child: content);
      }
      return SingleChildScrollView(
        padding: context.themeData.edgeInsetsData.pagePadding,
        child: Column(
          children: [
            SizedBox(height: math.max(320, constraints.maxHeight * .7), child: content),
            requestNotice!,
          ],
        ),
      );
    },
  );
}
