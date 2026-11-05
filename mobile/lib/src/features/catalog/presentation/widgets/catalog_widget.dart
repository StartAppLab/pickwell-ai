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
  final Widget? image, status, trailing;
  const CatalogWidget({
    super.key,
    required this.entry,
    required this.onTap,
    this.image,
    this.status,
    this.trailing,
  });
  @override
  Widget build(BuildContext context) {
    final d = context.themeData.dimensionsData, l = context.l10n;
    final product = entry.product;
    return Semantics(
      button: true,
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
                image ?? ProductCardThumbnail(thumbnail: product?.thumbnail),
                Gap(d.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product == null)
                        Text(l.pkCardUnavailable, style: context.textTheme.bodyMedium)
                      else
                        ProductIdentityHeader(product: product, compact: true),
                      if (status != null) ...[Gap(d.spacingXxs), status!],
                    ],
                  ),
                ),
                Gap(d.spacingXs),
                trailing ??
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
