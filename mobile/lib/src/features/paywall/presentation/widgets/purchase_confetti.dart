import 'dart:math' as math;

import 'package:flutter/material.dart';

/// One brief, decorative burst. It never owns purchase state or navigation.
class PurchaseConfetti extends StatefulWidget {
  const PurchaseConfetti({super.key});

  @override
  State<PurchaseConfetti> createState() => _PurchaseConfettiState();
}

class _PurchaseConfettiState extends State<PurchaseConfetti> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) setState(() => _finished = true);
        });
  final _particles = _Particle.createBurst();
  bool _played = false;
  bool _finished = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final media = MediaQuery.of(context);
    if (media.disableAnimations || media.accessibleNavigation) {
      _played = true;
      _finished = true;
      _controller.stop();
    } else if (!_played) {
      _played = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return const SizedBox.shrink();
    return IgnorePointer(
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _ConfettiPainter(_controller, _particles, Theme.of(context).colorScheme),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _Particle {
  const _Particle(this.left, this.velocity, this.lift, this.delay, this.size, this.rotation);

  final bool left;
  final double velocity;
  final double lift;
  final double delay;
  final double size;
  final double rotation;

  static List<_Particle> createBurst() {
    final random = math.Random(42);
    return List.generate(
      40,
      (index) => _Particle(
        index.isEven,
        .25 + random.nextDouble() * .6,
        .7 + random.nextDouble() * .5,
        random.nextDouble() * .12,
        4 + random.nextDouble() * 4,
        random.nextDouble() * math.pi * 2,
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.progress, this.particles, this.scheme)
    : colors = [
        scheme.primary,
        scheme.secondary,
        scheme.tertiary,
        scheme.primaryContainer,
        scheme.secondaryContainer,
        scheme.tertiaryContainer,
      ],
      super(repaint: progress);

  final Animation<double> progress;
  final List<_Particle> particles;
  final ColorScheme scheme;
  final List<Color> colors;
  final _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    for (var index = 0; index < particles.length; index++) {
      final particle = particles[index];
      final t = ((progress.value - particle.delay) / (1 - particle.delay)).clamp(0.0, 1.0);
      if (t == 0 || t == 1) continue;
      final direction = particle.left ? 1 : -1;
      final x = (particle.left ? -.02 : 1.02) + direction * particle.velocity * t;
      final y = .28 - particle.lift * t + 1.9 * t * t;
      final opacity = math.min(t * 12, 1.0) * math.min((1 - t) * 4, 1.0);
      final color = colors[index % colors.length];
      _paint.color = color.withValues(alpha: color.a * opacity);
      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(particle.rotation + direction * t * math.pi * 3);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size * .45),
        _paint,
      );
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.scheme != scheme ||
      oldDelegate.progress != progress ||
      oldDelegate.particles != particles;
}
