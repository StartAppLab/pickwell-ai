import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import '../../../../../core/_core.dart';
import '../../../domain/entities/_entities.dart';

/// Widget for displaying an onboarding slide page.
///
/// Shows an SVG image, title, and description for each onboarding slide.
class SlidePageWidget extends StatelessWidget {
  final SlideEntity slide;

  const SlidePageWidget({super.key, required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.themeData.edgeInsetsData.pagePadding,
      child: Column(
        children: [
          // Slide Image
          AspectRatio(
            aspectRatio: 1.5,
            child: SvgPicture(
              SvgAssetLoader(
                slide.image,
                colorMapper: SvgColorMapper(
                  fromPrimaryColor: context.themeColor.primaryColor,
                  primaryColor: context.colorScheme.primary,
                ),
              ),
            ),
          ),
          Gap(context.themeData.dimensionsData.largeSpacing),
          // Slide Title
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          Gap(context.themeData.dimensionsData.smallSpacing),
          // Slide Description
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
