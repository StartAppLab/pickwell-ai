import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';

class ProductThumbnailPlaceholder extends StatelessWidget {
  final String? label;
  const ProductThumbnailPlaceholder({super.key, this.label});
  @override
  Widget build(BuildContext context) {
    final d = context.themeData.dimensionsData, colors = context.colorScheme;
    return Semantics(
      label: label ?? context.l10n.pkPhotoPlaceholder,
      child: ExcludeSemantics(
        child: ColoredBox(
          color: Color.lerp(colors.surfaceContainerLowest, colors.onSurfaceVariant, .12)!,
          child: Padding(
            padding: EdgeInsets.all(d.paddingXxs),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final style = context.textTheme.bodySmall!;
                final labelHeight =
                    MediaQuery.textScalerOf(context).scale(style.fontSize!) * (style.height ?? 1.4);
                final showLabel = labelHeight + d.iconSize + d.spacingXxs <= constraints.maxHeight;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppIcon(
                      icon: HugeIcons.strokeRoundedPackage01,
                      size: d.iconSize,
                      color: colors.onSurfaceVariant,
                    ),
                    if (showLabel) ...[
                      Gap(d.spacingXxs),
                      Text(
                        context.l10n.pkNoPhoto,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: style.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
