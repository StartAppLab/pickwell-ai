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
      elevation: 2,
      shadowColor: context.colorScheme.shadow.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(d.cardCornerRadius)),
      child: InkWell(
        borderRadius: BorderRadius.circular(d.cardCornerRadius),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(d.paddingSm),
          child: Row(
            children: [
              Semantics(
                label: context.l10n.pkPhotoPlaceholder,
                child: Container(
                  width: 76,
                  height: 88,
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(d.nestedCornerRadius),
                  ),
                  child: AppIcon(
                    icon: Icons.inventory_2_outlined,
                    size: d.iconLarge,
                    color: context.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              Gap(d.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.product?.name ?? context.l10n.pkFoodProduct,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap(d.spacingXxs),
                    Text(
                      entry.product?.brand ?? entry.barcode,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (entry.product == null) ...[
                      Gap(d.spacingXxs),
                      Text(context.l10n.pkError, style: context.textTheme.bodySmall),
                    ],
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
