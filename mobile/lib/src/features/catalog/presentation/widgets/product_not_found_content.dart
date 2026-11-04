import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';

class ProductNotFoundContent extends StatelessWidget {
  final String barcode;
  final Widget? additionalInformation;
  const ProductNotFoundContent({super.key, required this.barcode, this.additionalInformation});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n, d = context.themeData.dimensionsData, colors = context.colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: context.themeData.edgeInsetsData.pagePadding,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: (constraints.maxHeight - d.paddingMd * 2).clamp(0, double.infinity),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ExcludeSemantics(
                  child: Container(
                    width: 136,
                    height: 136,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.primaryContainer,
                    ),
                    child: AppIcon(
                      icon: HugeIcons.strokeRoundedPackageSearch,
                      size: 80,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
              Gap(d.spacingLg),
              Text(
                l.pkProductNotFoundTitle,
                textAlign: TextAlign.center,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
              Gap(d.spacingSm),
              Text(
                l.pkProductNotFoundBody,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  color: colors.onSurfaceVariant,
                ),
              ),
              Gap(d.spacingLg),
              Card(
                elevation: 0,
                color: colors.surfaceContainerLowest,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(d.cardCornerRadius),
                  side: BorderSide(color: colors.outlineVariant),
                ),
                child: Padding(
                  padding: EdgeInsets.all(d.paddingMd),
                  child: Column(
                    children: [
                      ExcludeSemantics(
                        child: AppIcon(
                          icon: HugeIcons.strokeRoundedBarCode01,
                          size: 64,
                          color: colors.primary,
                        ),
                      ),
                      Gap(d.spacingXs),
                      SelectableText(
                        barcode,
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (additionalInformation != null) ...[Gap(d.spacingMd), additionalInformation!],
              Gap(d.spacingMd),
            ],
          ),
        ),
      ),
    );
  }
}
