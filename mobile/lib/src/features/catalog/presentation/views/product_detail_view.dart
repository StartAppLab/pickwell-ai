import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/_core.dart';
import '../../domain/_domain.dart';
import '../blocs/catalog/catalog_cubit.dart';
import '../widgets/lookup_notice.dart';
import '../widgets/product_result_content.dart';

class ProductDetailView extends StatelessWidget {
  const ProductDetailView({super.key});
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
          if (state.status == LookupStatus.miss) context.replace('/capture/${state.barcode}');
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
            return LookupNotice(
              status: state.status,
              error: state.error,
              quota: state.quota,
              retry: () => context.read<CatalogCubit>().retry(),
            );
          }
          return ProductResultContent(product: p, recentSaved: state.recentSaved);
        },
      ),
    ),
  );
}
