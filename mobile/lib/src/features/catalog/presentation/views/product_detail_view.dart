import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/_core.dart';
import '../../../../config/app_session.dart';
import '../widgets/quota_status.dart';
import '../widgets/pending_capture_card.dart';
import '../blocs/catalog/label_capture_cubit.dart';
import '../../domain/_domain.dart';
import '../blocs/catalog/catalog_cubit.dart';
import '../widgets/lookup_notice.dart';
import '../widgets/product_result_content.dart';

class ProductDetailView extends StatelessWidget {
  final AppSession? session;
  final LabelCaptureCubit? drafts;
  const ProductDetailView({super.key, this.session, this.drafts});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: BackButton(
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        },
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) async {
            try {
              await Clipboard.setData(ClipboardData(text: value));
            } catch (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(context.l10n.pkError)));
              }
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: context.read<CatalogCubit>().state.barcode ?? '',
              child: Text(context.l10n.pkCopyBarcode),
            ),
          ],
        ),
      ],
    ),
    body: SafeArea(
      child: BlocConsumer<CatalogCubit, CatalogState>(
        listener: (context, state) {
          if (state.status == LookupStatus.miss) {
            context.replace('/capture/${state.barcode}', extra: state.quota);
          }
        },
        builder: (context, state) {
          final p = state.product;
          final l = context.l10n;
          if (state.status == LookupStatus.checking) {
            return Center(
              child: Semantics(label: l.pkChecking, child: const CircularProgressIndicator()),
            );
          }
          if (p == null) {
            return Column(
              children: [
                if (drafts != null) PendingCaptureCard(draft: drafts!, barcode: state.barcode),
                Expanded(
                  child: LookupNotice(
                    status: state.status,
                    error: state.error,
                    quota: state.quota,
                    session: session,
                    retry: () => context.read<CatalogCubit>().retry(),
                  ),
                ),
              ],
            );
          }
          return ProductResultContent(
            product: p,
            recentSaved: state.recentSaved,
            statusNotice: Column(
              children: [
                if (drafts != null) PendingCaptureCard(draft: drafts!, barcode: state.barcode),
                QuotaStatus(
                  snapshot: state.quota,
                  session: session,
                  metric: state.quota?.metric ?? QuotaMetric.barcodeLookup,
                  unavailable: state.status == LookupStatus.error,
                  rateLimited: state.error == 'rate_limited',
                  loadedResult:
                      state.status == LookupStatus.error ||
                      state.status == LookupStatus.denied ||
                      state.quota?.remaining == 0,
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
