import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../../domain/entities/catalog_entity.dart';

class CatalogWidget extends StatelessWidget {
  final RecentProduct entry;
  final VoidCallback onTap;
  const CatalogWidget({super.key, required this.entry, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final d = context.themeData.dimensionsData;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(d.cardCornerRadius),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(d.paddingMd),
          child: Row(
            children: [
              Semantics(
                label: context.l10n.pkPhotoPlaceholder,
                child: Container(
                  width: 64,
                  height: 72,
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(d.nestedCornerRadius),
                  ),
                  child: const AppIcon(icon: Icons.inventory_2_outlined),
                ),
              ),
              Gap(d.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.product?.name ?? context.l10n.pkFoodProduct,
                      style: context.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap(d.spacingXxs),
                    Text(
                      entry.product?.brand ?? entry.barcode,
                      style: context.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              AppIcon(icon: Icons.chevron_right, size: d.iconMedium),
            ],
          ),
        ),
      ),
    );
  }
}
