import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/_core.dart';
import '../../domain/entities/catalog_entity.dart';
import 'product_identity_header.dart';
import 'product_card_thumbnail.dart';

class ProductResultHeader extends StatelessWidget {
  final ProductRecord product;
  final Widget? privateThumbnail;
  const ProductResultHeader({super.key, required this.product, this.privateThumbnail});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final d = context.themeData.dimensionsData;
      final stacked =
          constraints.maxWidth < 300 || MediaQuery.textScalerOf(context).scale(16) >= 25;
      final imageSize = (constraints.maxWidth * .4).clamp(112.0, 184.0);
      final photo = SizedBox(
        width: imageSize,
        height: imageSize,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(d.heroCornerRadius),
          child:
              privateThumbnail ??
              ProductCardThumbnail(
                thumbnail: product.thumbnail,
                placeholderLabel: context.l10n.pkNoProductPhoto,
                width: imageSize,
                height: imageSize,
              ),
        ),
      );
      final identity = ProductIdentityHeader(product: product);
      return Padding(
        padding: EdgeInsets.only(top: d.paddingXs),
        child: stacked
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [photo, Gap(d.spacingMd), identity],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  photo,
                  Gap(d.spacingMd),
                  Expanded(child: identity),
                ],
              ),
      );
    },
  );
}
