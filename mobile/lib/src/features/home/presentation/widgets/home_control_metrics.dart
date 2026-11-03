import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/_core.dart';

// Shared measured heights keep Home controls aligned without capping text scale.
double _lineHeight(BuildContext context, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: 'Ag', style: style),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
  )..layout();
  final height = painter.height;
  painter.dispose();
  return height;
}

double homeControlHeight(BuildContext context) => math.max(
  context.themeData.dimensionsData.minimumTouchTarget,
  _lineHeight(context, context.textTheme.titleMedium!) +
      context.themeData.dimensionsData.paddingXs * 2 +
      2, // Border plus content insets.
);

double homeHeaderHeight(BuildContext context) => math.max(
  56,
  math.max(
    _lineHeight(context, context.textTheme.headlineSmall!.copyWith(fontSize: 30)),
    _lineHeight(context, context.textTheme.titleMedium!) +
        context.themeData.edgeInsetsData.contentPadding.vertical,
  ),
);
