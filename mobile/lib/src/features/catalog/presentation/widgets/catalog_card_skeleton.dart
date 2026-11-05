import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/_core.dart';

/// Matches the product card footprint without presenting placeholder product data.
class CatalogCardSkeleton extends StatelessWidget {
  const CatalogCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final d = context.themeData.dimensionsData, colors = context.colorScheme;
    final shape = BorderRadius.circular(d.nestedCornerRadius);
    return Semantics(
      label: context.l10n.loading,
      liveRegion: true,
      child: ExcludeSemantics(
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(d.cardCornerRadius)),
          child: Padding(
            padding: EdgeInsets.all(d.paddingXs),
            child: Row(
              children: [
                Container(
                  width: 100,
                  height: 80,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: shape,
                  ),
                ),
                Gap(d.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final width in [.4, .85, .6]) ...[
                        FractionallySizedBox(
                          widthFactor: width,
                          child: Container(
                            height: d.spacingSm,
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest,
                              borderRadius: shape,
                            ),
                          ),
                        ),
                        Gap(d.spacingXs),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
