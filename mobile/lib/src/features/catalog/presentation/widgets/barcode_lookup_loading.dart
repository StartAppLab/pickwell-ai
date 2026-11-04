import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';

/// Indeterminate lookup feedback only: no artificial delay or claimed percentage.
class BarcodeLookupLoading extends StatefulWidget {
  final String? title, description;
  final dynamic icon;
  final bool showSweep;
  const BarcodeLookupLoading({
    super.key,
    this.title,
    this.description,
    this.icon = HugeIcons.strokeRoundedBarcodeScan,
    this.showSweep = true,
  });
  @override
  State<BarcodeLookupLoading> createState() => _BarcodeLookupLoadingState();
}

class _BarcodeLookupLoadingState extends State<BarcodeLookupLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  bool _reducedMotion = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (_reducedMotion || !widget.showSweep) {
      _sweep.stop();
      _sweep.value = .5;
    } else if (!_sweep.isAnimating) {
      _sweep.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = context.themeData.dimensionsData, colors = context.colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        const maxIllustrationSize = 192.0, minIllustrationSize = 80.0;
        final illustration = math.max(
          minIllustrationSize,
          math.min(
            maxIllustrationSize,
            math.min(constraints.maxWidth * .56, constraints.maxHeight * .42),
          ),
        );
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExcludeSemantics(
                      child: Container(
                        width: illustration,
                        height: illustration,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primaryContainer,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AppIcon(
                              icon: widget.icon,
                              size: illustration * .58,
                              color: colors.primary,
                            ),
                            if (widget.showSweep)
                              AnimatedBuilder(
                                animation: _sweep,
                                builder: (context, _) => Align(
                                  alignment: Alignment(0, -.4 + _sweep.value * .8),
                                  child: Container(
                                    width: illustration * .62,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: colors.tertiaryContainer,
                                      borderRadius: BorderRadius.circular(d.nestedCornerRadius),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Gap(d.spacingXl),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        widget.title ?? context.l10n.pkChecking,
                        textAlign: TextAlign.center,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                    ),
                    if (widget.description != null) ...[
                      Gap(d.spacingSm),
                      Text(
                        widget.description!,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    Gap(d.spacingLg),
                    ExcludeSemantics(
                      child: TickerMode(
                        enabled: !_reducedMotion,
                        child: LinearProgressIndicator(
                          borderRadius: BorderRadius.circular(d.nestedCornerRadius),
                          color: colors.secondary,
                          backgroundColor: colors.outlineVariant,
                        ),
                      ),
                    ),
                    Gap(d.spacingLg),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
