import 'package:flutter/material.dart';

enum EdgeBlurPosition { top, bottom }

class EdgeBlur extends StatelessWidget {
  final double height;
  final Color? color;
  final double tintOpacity;
  final EdgeBlurPosition position;

  const EdgeBlur({
    super.key,
    required this.height,
    this.color,
    this.tintOpacity = 0.8,
    this.position = EdgeBlurPosition.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = color ?? Theme.of(context).colorScheme.surface;
    final safeAreaInset = switch (position) {
      EdgeBlurPosition.top => MediaQuery.paddingOf(context).top,
      EdgeBlurPosition.bottom => MediaQuery.paddingOf(context).bottom,
    };
    final begin = switch (position) {
      EdgeBlurPosition.top => Alignment.bottomCenter,
      EdgeBlurPosition.bottom => Alignment.topCenter,
    };
    final end = switch (position) {
      EdgeBlurPosition.top => Alignment.topCenter,
      EdgeBlurPosition.bottom => Alignment.bottomCenter,
    };

    return IgnorePointer(
      child: Container(
        height: height + safeAreaInset,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            colors: [
              surfaceColor.withValues(alpha: 0),
              surfaceColor.withValues(alpha: tintOpacity),
            ],
          ),
        ),
      ),
    );
  }
}
