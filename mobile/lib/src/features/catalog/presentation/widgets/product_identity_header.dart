import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/_core.dart';
import '../../domain/entities/catalog_entity.dart';
import '../../domain/entities/product_display_identity.dart';

/// The same brand → name → variant/quantity hierarchy in cards and Details.
class ProductIdentityHeader extends StatelessWidget {
  final ProductRecord? product;
  final bool compact;
  const ProductIdentityHeader({super.key, this.product, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final identity = ProductDisplayIdentity.fromProduct(product);
    final d = context.themeData.dimensionsData;
    final secondary = context.textTheme.bodySmall?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (identity.brand case final String brand) ...[
          Text(
            brand,
            style: secondary,
            maxLines: compact ? 1 : null,
            overflow: compact ? TextOverflow.ellipsis : null,
          ),
          Gap(d.spacingXxs),
        ],
        Text(
          identity.name ?? context.l10n.pkFoodProduct,
          style: compact
              ? context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 18)
              : context.textTheme.headlineSmall,
          maxLines: compact ? 2 : null,
          overflow: compact ? TextOverflow.ellipsis : null,
        ),
        if (identity.subtitle case final String subtitle) ...[
          Gap(d.spacingXxs),
          Text(
            subtitle,
            style: secondary,
            maxLines: compact ? 2 : null,
            overflow: compact ? TextOverflow.ellipsis : null,
          ),
        ],
      ],
    );
  }
}
