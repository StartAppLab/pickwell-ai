import 'package:flutter/material.dart';

class BottomEdgeFade extends StatelessWidget {
  final double height;
  final Color? color;
  final double endAlpha;

  const BottomEdgeFade({super.key, required this.height, this.color, this.endAlpha = 0.8});

  @override
  Widget build(BuildContext context) {
    final fadeColor = color ?? Theme.of(context).colorScheme.surface;
    return IgnorePointer(
      child: Container(
        height: height + MediaQuery.paddingOf(context).bottom,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              fadeColor.withValues(alpha: 0),
              fadeColor.withValues(alpha: endAlpha),
            ],
          ),
        ),
      ),
    );
  }
}
