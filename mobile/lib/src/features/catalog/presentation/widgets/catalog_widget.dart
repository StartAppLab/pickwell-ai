import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../../domain/entities/catalog_entity.dart';
import 'product_card_thumbnail.dart';

class CatalogWidget extends StatelessWidget {
  final RecentProduct entry;
  final VoidCallback onTap;
  const CatalogWidget({super.key, required this.entry, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final d = context.themeData.dimensionsData, l = context.l10n;
    final product = entry.product;
    final name = product?.name?.trim() ?? '';
    final title = name.isNotEmpty ? name : l.pkFoodProduct;
    return Semantics(
      button: true,
      label: product == null ? l.pkCardUnavailable : null,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        shadowColor: context.colorScheme.shadow.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(d.cardCornerRadius)),
        child: InkWell(
          borderRadius: BorderRadius.circular(d.cardCornerRadius),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(d.paddingXs),
            child: Row(
              children: [
                const ProductCardThumbnail(),
                Gap(d.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Gap(d.spacingXs),
                AppIcon(
                  icon: CupertinoIcons.chevron_forward,
                  size: d.iconMedium,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
