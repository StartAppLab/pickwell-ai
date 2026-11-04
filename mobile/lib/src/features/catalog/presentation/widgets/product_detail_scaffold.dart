import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/_core.dart';
import '../../../app/presentation/widgets/edge_blur.dart';

/// Full-bleed canvas with scroll-under navigation for both result routes.
/// Content receives toolbar clearance as a safe inset; lists can scroll behind it.
class ProductDetailScaffold extends StatelessWidget {
  final Widget body;
  final List<Widget>? actions;
  const ProductDetailScaffold({super.key, required this.body, this.actions});

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme, d = context.themeData.dimensionsData;
    final canvas = Color.lerp(colors.surfaceContainerLowest, colors.surface, .3)!;
    final media = MediaQuery.of(context);
    final gutter = context.themeData.edgeInsetsData.pagePadding.left;
    final toolbarHeight = d.minimumTouchTarget + d.paddingXs * 2;
    final overlay = colors.brightness == Brightness.light
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light;
    return Scaffold(
      backgroundColor: canvas,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        forceMaterialTransparency: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: toolbarHeight,
        leadingWidth: d.minimumTouchTarget + gutter * 2,
        systemOverlayStyle: overlay.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemStatusBarContrastEnforced: false,
          systemNavigationBarContrastEnforced: false,
        ),
        leading: Padding(
          padding: EdgeInsets.symmetric(horizontal: gutter, vertical: d.paddingXs),
          child: IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: const Icon(CupertinoIcons.chevron_back),
            style: IconButton.styleFrom(
              minimumSize: Size.square(d.minimumTouchTarget),
              backgroundColor: colors.surfaceContainerLowest,
              foregroundColor: colors.primary,
              side: BorderSide(color: colors.outlineVariant),
            ),
            onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
          ),
        ),
        actions: actions,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MediaQuery(
            data: media.copyWith(
              padding: media.padding.copyWith(top: media.padding.top + toolbarHeight),
            ),
            child: body,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: EdgeBlur(height: toolbarHeight, color: canvas, position: EdgeBlurPosition.top),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: EdgeBlur(height: d.spacingLg, color: canvas),
          ),
        ],
      ),
    );
  }
}
