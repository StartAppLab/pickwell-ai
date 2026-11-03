import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/_core.dart';
import '../blocs/catalog/label_capture_cubit.dart';

class PendingCaptureCard extends StatelessWidget {
  final LabelCaptureCubit draft;
  final String? barcode;
  final String query;
  const PendingCaptureCard({super.key, required this.draft, this.barcode, this.query = ''});
  @override
  Widget build(BuildContext context) => BlocBuilder<LabelCaptureCubit, LabelCaptureState>(
    bloc: draft,
    builder: (context, state) {
      final items = state.pending
          .where(
            (d) => (barcode == null || barcode == d.barcode) && d.barcode.contains(query.trim()),
          )
          .toList();
      final l = context.l10n;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.error == 'draft_load') ...[
            Text(l.pkPendingLoadError),
            TextButton(onPressed: () => draft.retryRestore(), child: Text(l.pkRetry)),
          ],
          if (state.error == 'draft_limit' && state.pending.length >= LabelCaptureCubit.maxDrafts)
            Text(l.pkPendingLimit(LabelCaptureCubit.maxDrafts)),
          for (final item in items)
            Card(
              key: ValueKey('pending-${item.barcode}'),
              child: Padding(
                padding: context.themeData.edgeInsetsData.pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(l.pkPendingTitle, style: context.textTheme.titleMedium),
                        ),
                      ],
                    ),
                    Text(item.barcode),
                    Text(
                      state.saving && state.barcode == item.barcode
                          ? l.pkPendingSaving
                          : !item.saved
                          ? l.pkPendingSaveError
                          : l.pkPendingSaved,
                    ),
                    FilledButton(
                      onPressed: state.busy ? null : () => context.push('/capture/${item.barcode}'),
                      child: Text(l.pkPendingResume),
                    ),
                    TextButton(
                      onPressed: state.busy ? null : () => draft.discardBarcode(item.barcode),
                      child: Text(l.pkPendingDelete),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}
