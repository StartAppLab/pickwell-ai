import 'product_identity_header.dart';
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
                ProductCardThumbnail(thumbnail: product?.thumbnail),
                Gap(d.spacingSm),
                Expanded(child: ProductIdentityHeader(product: product, compact: true)),
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
