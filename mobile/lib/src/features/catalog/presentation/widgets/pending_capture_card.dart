import '../../domain/_domain.dart';
import '../blocs/catalog/private_product_card_cubit.dart';
import '../blocs/catalog/analysis_submission_cubit.dart';
import 'private_analysis_card.dart';
import '../../../../config/injection_container.dart';
import '../../../../config/app_session.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../app/app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/_core.dart';
import '../blocs/catalog/label_capture_cubit.dart';

class PendingCaptureCard extends StatelessWidget {
  final LabelCaptureCubit draft;
  final String? barcode;
  final String query;
  final int refreshRevision;
  final ValueChanged<bool>? onHasItemsChanged;
  final Future<void> Function()? onPublished;
  const PendingCaptureCard({
    super.key,
    required this.draft,
    this.barcode,
    this.query = '',
    this.refreshRevision = 0,
    this.onHasItemsChanged,
    this.onPublished,
  });
  AppSession? get session => getIt.isRegistered<AppSession>() ? getIt<AppSession>() : null;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: session ?? const AlwaysStoppedAnimation<int>(0),
    builder: (context, _) => BlocBuilder<LabelCaptureCubit, LabelCaptureState>(
      bloc: draft,
      builder: (context, state) {
        final items = state.pending
            .where(
              (d) =>
                  (d.privateOwnerId == null || d.privateOwnerId == session?.userId) &&
                  (barcode == null || barcode == d.barcode) &&
                  d.barcode.contains(query.trim()),
            )
            .toList();
        final l = context.l10n;
        if (onHasItemsChanged != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) onHasItemsChanged!(items.isNotEmpty);
          });
        }
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
              if (item.privateJobId != null &&
                  getIt.isRegistered<AnalyzeProductUseCase>() &&
                  getIt.isRegistered<GetCatalogUseCase>())
                BlocProvider(
                  key: ValueKey('private-${session?.userId}-${item.privateJobId}'),
                  create: (_) => PrivateProductCardCubit(
                    item: item,
                    analyze: getIt<AnalyzeProductUseCase>(),
                    lookup: getIt<GetCatalogUseCase>(),
                    drafts: draft,
                    authorized: () => session?.userId == item.privateOwnerId,
                    onPublished: onPublished,
                    initial: getIt.isRegistered<AnalysisSubmissionCubit>()
                        ? getIt<AnalysisSubmissionCubit>().state.result
                        : null,
                  )..load(),
                  child: PrivateAnalysisCard(item: item, refreshRevision: refreshRevision),
                )
              else
                Card(
                  key: ValueKey('pending-${item.barcode}'),
                  child: Padding(
                    padding: context.themeData.edgeInsetsData.pagePadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            AppIcon(
                              icon: HugeIcons.strokeRoundedAlert02,
                              color: context.colorScheme.tertiary,
                            ),
                            Gap(context.themeData.dimensionsData.spacingXs),
                            Expanded(
                              child: Text(
                                item.privateJobId != null ? l.pkPrivateReady : l.pkPendingTitle,
                                style: context.textTheme.titleMedium,
                              ),
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
                          onPressed: state.busy
                              ? null
                              : () => context.push(
                                  item.privateJobId == null
                                      ? '/capture/${item.barcode}'
                                      : '/analysis/${item.privateJobId}',
                                  extra: item.barcode,
                                ),
                          child: Text(
                            item.privateJobId != null ? l.pkPrivateView : l.pkPendingResume,
                          ),
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
    ),
  );
}
