import 'package:flutter/material.dart';

/// Code-drawn background shapes from the Home reference, never product imagery.
class HomeBackdrop extends StatelessWidget {
  const HomeBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _HomeBackdropPainter(
            canvas: Color.lerp(colors.surfaceContainerLowest, colors.surface, 0.3)!,
            leaf: colors.primaryContainer,
          ),
        ),
      ),
    );
  }
}

class _HomeBackdropPainter extends CustomPainter {
  final Color canvas, leaf;
  const _HomeBackdropPainter({required this.canvas, required this.leaf});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawColor(this.canvas, BlendMode.src);
    final paint = Paint()..color = leaf;
    canvas.drawPath(
      Path()
        ..moveTo(w * .34, 0)
        ..cubicTo(w * .43, h * .13, w * .63, h * .08, w * .83, h * .15)
        ..quadraticBezierTo(w * .95, h * .19, w, h * .16)
        ..lineTo(w, 0)
        ..close(),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, h * .82)
        ..cubicTo(w * .26, h * .84, w * .31, h * .96, w * .58, h * .91)
        ..cubicTo(w * .76, h * .86, w * .88, h * .82, w, h * .85)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _HomeBackdropPainter oldDelegate) =>
      oldDelegate.canvas != canvas || oldDelegate.leaf != leaf;
}
