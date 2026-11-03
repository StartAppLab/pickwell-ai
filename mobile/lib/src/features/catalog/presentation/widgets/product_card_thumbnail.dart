import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';

/// Honest image-area fallback: the published catalogue has no package-media
/// field. Private capture photos must never become permanent product thumbnails.
class ProductCardThumbnail extends StatelessWidget {
  const ProductCardThumbnail({super.key});

  @override
  Widget build(BuildContext context) {
    final d = context.themeData.dimensionsData, colors = context.colorScheme;
    return SizedBox(
      width: 100,
      child: AspectRatio(
        aspectRatio: 5 / 4,
        child: Semantics(
          label: context.l10n.pkPhotoPlaceholder,
          child: ExcludeSemantics(
            child: Container(
              padding: EdgeInsets.all(d.paddingXxs),
              decoration: BoxDecoration(
                color: Color.lerp(colors.surfaceContainerLowest, colors.onSurfaceVariant, .12),
                borderRadius: BorderRadius.circular(d.nestedCornerRadius),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final style = context.textTheme.bodySmall!;
                  final labelHeight =
                      MediaQuery.textScalerOf(context).scale(style.fontSize!) *
                      (style.height ?? 1.4);
                  final showLabel =
                      labelHeight + d.iconSize + d.spacingXxs <= constraints.maxHeight;
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
      ),
    );
  }
}
