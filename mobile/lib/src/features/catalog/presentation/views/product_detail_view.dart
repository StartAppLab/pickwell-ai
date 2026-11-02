import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../../domain/_domain.dart';
import '../blocs/catalog/catalog_cubit.dart';
import '../widgets/lookup_notice.dart';

class ProductDetailView extends StatelessWidget {
  const ProductDetailView({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) => Clipboard.setData(ClipboardData(text: value)),
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
          final d = context.themeData.dimensionsData;
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
          final nutrients = p.nutrition['nutrients'] as List? ?? [];
          return ListView(
            padding: context.themeData.edgeInsetsData.pagePadding,
            children: [
              const AppIcon(icon: Icons.inventory_2_outlined, size: 64),
              Gap(d.spacingMd),
              Text(p.name ?? l.pkFoodProduct, style: context.textTheme.headlineSmall),
              if (p.brand != null) Text(p.brand!),
              Text(p.barcode, style: context.textTheme.bodySmall),
              if (p.isDemo) Text(l.pkDemo),
              if (!state.recentSaved) Text(l.pkRecentNotSaved),
              Gap(d.spacingLg),
              Text(l.pkOverview, style: context.textTheme.titleLarge),
              Gap(d.spacingXs),
              Text(p.summary),
              Gap(d.spacingLg),
              Text(l.pkFindings, style: context.textTheme.titleLarge),
              for (final f in p.findings)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(d.paddingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${f['severity'] ?? ''} · ${f['title'] ?? ''}',
                          style: context.textTheme.titleMedium,
                        ),
                        Text(f['explanation']?.toString() ?? l.pkUnknownValue),
                      ],
                    ),
                  ),
                ),
              Gap(d.spacingLg),
              Text(l.pkIngredients, style: context.textTheme.titleLarge),
              Gap(d.spacingXs),
              Text(p.ingredients['raw']?.toString() ?? l.pkUnknownValue),
              Text(p.ingredients['declared_allergens']?.toString() ?? l.pkUnknownAllergens),
              Gap(d.spacingLg),
              Text(l.pkNutrition, style: context.textTheme.titleLarge),
              Text('${l.pkBasis}: ${p.nutrition['basis'] ?? l.pkUnknownValue}'),
              if (p.nutrition['serving_size'] != null) Text(p.nutrition['serving_size'].toString()),
              for (final n in nutrients)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(n['name']?.toString() ?? l.pkUnknownValue),
                  trailing: Text(
                    n['value'] == null ? l.pkUnknownValue : '${n['value']} ${n['unit'] ?? ''}',
                  ),
                ),
              Gap(d.spacingLg),
              Text(l.pkCaveat, style: context.textTheme.bodySmall),
            ],
          );
        },
      ),
    ),
  );
}
