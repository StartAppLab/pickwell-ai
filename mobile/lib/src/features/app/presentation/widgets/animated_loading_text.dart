import 'package:flutter/material.dart';

class AnimatedLoadingText extends StatefulWidget {
  const AnimatedLoadingText({
    super.key,
    required this.words,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.textStyle,
  });

  final List<String> words;
  final Duration animationDuration;
  final TextStyle? textStyle;

  @override
  State<AnimatedLoadingText> createState() => _AnimatedLoadingTextState();
}

class _AnimatedLoadingTextState extends State<AnimatedLoadingText> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  int _currentWordIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.animationDuration, vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
      ),
    );

    _startAnimation();
  }

  void _startAnimation() {
    _controller.forward().then((_) {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) {
            setState(() {
              _currentWordIndex = (_currentWordIndex + 1) % widget.words.length;
            });
            _startAnimation();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Text(
              '${widget.words[_currentWordIndex]}...',
              style: widget.textStyle,
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
