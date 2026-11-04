import 'package:flutter/material.dart';
import '../../../../core/_core.dart';
import '../../../../config/app_config.dart';
import '../../../../config/injection_container.dart';
import '../../domain/entities/product_thumbnail.dart';
import 'product_thumbnail_placeholder.dart';

/// Only published derivative references are eligible. Framework image cache is
/// bounded; private evidence files and arbitrary server-provided URLs are unused.
class ProductCardThumbnail extends StatelessWidget {
  final ProductThumbnail? thumbnail;
  final String? placeholderLabel;
  final double width, height;
  const ProductCardThumbnail({
    super.key,
    this.thumbnail,
    this.placeholderLabel,
    this.width = 100,
    this.height = 80,
  });
  @override
  Widget build(BuildContext context) {
    final config = thumbnail != null && getIt.isRegistered<AppConfig>() ? getIt<AppConfig>() : null;
    final url = config == null || !config.features.backendEnabled
        ? null
        : thumbnail?.url(config.baseUrl);
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.themeData.dimensionsData.nestedCornerRadius),
        child: url == null
            ? ProductThumbnailPlaceholder(label: placeholderLabel)
            : Image.network(
                url,
                semanticLabel: context.l10n.pkFrontPackaging,
                headers: {'apikey': config!.apiKey},
                fit: BoxFit.contain,
                cacheWidth: thumbnail!.width,
                cacheHeight: thumbnail!.height,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : ProductThumbnailPlaceholder(label: placeholderLabel),
                errorBuilder: (context, error, stack) =>
                    ProductThumbnailPlaceholder(label: placeholderLabel),
              ),
      ),
    );
  }
}
