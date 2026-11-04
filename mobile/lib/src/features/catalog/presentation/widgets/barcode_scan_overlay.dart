import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/_core.dart';

/// A viewport-owned guide: camera initialization never determines its position.
/// This is visual guidance only; it does not change barcode detection/cropping.
class BarcodeScanOverlay extends StatelessWidget {
  const BarcodeScanOverlay({super.key});

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final colors = context.colorScheme;
          final inset = context.themeData.dimensionsData.paddingLg;
          const maxGuideWidth = 360.0, maxGuideHeight = 220.0;
          final width = math.max(0.0, math.min(constraints.maxWidth - inset * 2, maxGuideWidth));
          final height = math.min(
            width * .64,
            math.min(constraints.maxHeight * .38, maxGuideHeight),
          );
          final frame = Rect.fromCenter(
            center: Offset(constraints.maxWidth / 2, constraints.maxHeight / 2),
            width: width,
            height: height,
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _BarcodeScrimPainter(frame, colors.scrim.withValues(alpha: .38)),
              ),
              Positioned.fromRect(
                rect: frame,
                child: CustomPaint(
                  key: const ValueKey('barcode-frame-guide'),
                  painter: _BarcodeCornersPainter(colors.tertiaryContainer),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

class _BarcodeScrimPainter extends CustomPainter {
  final Rect frame;
  final Color color;
  const _BarcodeScrimPainter(this.frame, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    const guideRadius = Radius.circular(20);
    canvas.drawPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(Offset.zero & size)
        ..addRRect(RRect.fromRectAndRadius(frame, guideRadius)),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_BarcodeScrimPainter oldDelegate) =>
      frame != oldDelegate.frame || color != oldDelegate.color;
}

class _BarcodeCornersPainter extends CustomPainter {
  final Color scanColor;
  const _BarcodeCornersPainter(this.scanColor);
  @override
  void paint(Canvas canvas, Size size) {
    // Guide geometry is independent of text/spacing tokens and of camera aspect.
    const radius = 20.0, cornerLength = 34.0, strokeWidth = 4.0;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(0, cornerLength)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..lineTo(cornerLength, 0)
      ..moveTo(w - cornerLength, 0)
      ..lineTo(w - radius, 0)
      ..quadraticBezierTo(w, 0, w, radius)
      ..lineTo(w, cornerLength)
      ..moveTo(w, h - cornerLength)
      ..lineTo(w, h - radius)
      ..quadraticBezierTo(w, h, w - radius, h)
      ..lineTo(w - cornerLength, h)
      ..moveTo(cornerLength, h)
      ..lineTo(radius, h)
      ..quadraticBezierTo(0, h, 0, h - radius)
      ..lineTo(0, h - cornerLength);
    canvas.drawPath(path, paint);
    paint.color = scanColor;
    canvas.drawLine(Offset(strokeWidth, h / 2), Offset(w - strokeWidth, h / 2), paint);
  }

  @override
  bool shouldRepaint(_BarcodeCornersPainter oldDelegate) => scanColor != oldDelegate.scanColor;
}
