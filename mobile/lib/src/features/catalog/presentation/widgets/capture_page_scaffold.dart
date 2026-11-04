import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/_core.dart';
import '../../../home/presentation/widgets/home_backdrop.dart';
import 'scanner_circle_button.dart';

/// Capture-only page chrome: fixed actions, a bounded reading width and safe areas.
class CapturePageScaffold extends StatelessWidget {
  final Widget body;
  final Widget? bottomActions;
  final String? title;
  final List<Widget>? actions;
  final VoidCallback onBack;
  final bool decorated;
  const CapturePageScaffold({
    super.key,
    required this.body,
    required this.onBack,
    this.bottomActions,
    this.title,
    this.actions,
    this.decorated = false,
  });

  @override
  Widget build(BuildContext context) {
    final d = context.themeData.dimensionsData, colors = context.colorScheme;
    final canvas = Color.lerp(colors.surfaceContainerLowest, colors.surface, .3)!;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (decorated) const HomeBackdrop() else ColoredBox(color: canvas),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            forceMaterialTransparency: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            title: title == null
                ? null
                : Text(
                    title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
            toolbarHeight: d.minimumTouchTarget + d.paddingXs * 2,
            leadingWidth: d.minimumTouchTarget + d.paddingMd * 2,
            leading: Padding(
              padding: EdgeInsets.symmetric(horizontal: d.paddingMd, vertical: d.paddingXs),
              child: ScannerCircleButton(
                icon: CupertinoIcons.chevron_back,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: onBack,
              ),
            ),
            actions: actions,
          ),
          body: SafeArea(
            top: false,
            bottom: bottomActions == null,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: d.maxWidth),
                child: body,
              ),
            ),
          ),
          bottomNavigationBar: bottomActions == null
              ? null
              : DecoratedBox(
                  decoration: BoxDecoration(
                    color: canvas.withValues(alpha: .97),
                    border: Border(top: BorderSide(color: colors.outlineVariant)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Center(
                      heightFactor: 1,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: d.maxWidth),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: d.paddingMd,
                            vertical: d.paddingSm,
                          ),
                          child: bottomActions,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
