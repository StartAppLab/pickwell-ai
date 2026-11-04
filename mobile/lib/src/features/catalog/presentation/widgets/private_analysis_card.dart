import 'dart:async';
import 'package:hugeicons/hugeicons.dart';
import '../../../app/app.dart';
import 'product_card_thumbnail.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/_core.dart';
import '../../domain/_domain.dart';
import '../blocs/catalog/private_product_card_cubit.dart';
import 'catalog_widget.dart';

class PrivateAnalysisCard extends StatefulWidget {
  final PendingCapture item;
  final int refreshRevision;
  const PrivateAnalysisCard({super.key, required this.item, this.refreshRevision = 0});
  @override
  State<PrivateAnalysisCard> createState() => _PrivateAnalysisCardState();
}

class _PrivateAnalysisCardState extends State<PrivateAnalysisCard> {
  PendingCapture get item => widget.item;
  @override
  void didUpdateWidget(covariant PrivateAnalysisCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshRevision != widget.refreshRevision) {
      unawaited(context.read<PrivateProductCardCubit>().load());
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<PrivateProductCardCubit, PrivateProductCardState>(
        builder: (context, state) {
          final cubit = context.read<PrivateProductCardCubit>(), l = context.l10n;
          return Padding(
            padding: EdgeInsets.only(bottom: context.themeData.dimensionsData.spacingSm),
            child: CatalogWidget(
              entry: RecentProduct(
                item.barcode,
                state.product?.analyzedAt ??
                    item.front?.capturedAt ??
                    item.expiresAt.subtract(const Duration(hours: 24)),
                product: state.product,
              ),
              onTap: () async {
                if (!cubit.authorized()) return;
                await context.push(
                  state.published ? '/product/${item.barcode}' : '/analysis/${item.privateJobId}',
                  extra: item.barcode,
                );
                if (context.mounted) await cubit.load();
              },
              image:
                  !state.expired && !state.published && state.product != null && item.front != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(
                        context.themeData.dimensionsData.nestedCornerRadius,
                      ),
                      child: Image.file(
                        File(item.front!.path),
                        width: 100,
                        height: 80,
                        fit: BoxFit.cover,
                        cacheWidth: 384,
                        semanticLabel: l.pkFrontPackaging,
                        errorBuilder: (_, _, _) => const ProductCardThumbnail(),
                      ),
                    )
                  : null,
              status: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!state.published)
                    Row(
                      children: [
                        AppIcon(
                          icon: HugeIcons.strokeRoundedSquareLock01,
                          size: context.themeData.dimensionsData.iconSmall,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: context.themeData.dimensionsData.spacingXxs),
                        Flexible(
                          child: Text(
                            state.expired ? l.pkPrivateExpired : l.pkPrivateCardLabel,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (state.loading && state.product == null) const LinearProgressIndicator(),
                  if (state.cleanupFailed)
                    Text(l.pkCaptureCleanupError, style: context.textTheme.bodySmall)
                  else if (state.unavailable)
                    Text(l.pkStoredUnavailable, style: context.textTheme.bodySmall),
                ],
              ),
              trailing: PopupMenuButton<String>(
                tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
                onSelected: (value) async {
                  if (value == 'retry') await cubit.load();
                  if (value == 'remove' && cubit.authorized() && !cubit.drafts.state.busy) {
                    await cubit.drafts.discardExpected(item);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'retry', child: Text(l.pkRetry)),
                  PopupMenuItem(value: 'remove', child: Text(l.pkRemoveLocalAnalysis)),
                ],
              ),
            ),
          );
        },
      );
}
