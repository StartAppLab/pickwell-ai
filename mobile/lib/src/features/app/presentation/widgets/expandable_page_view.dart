import 'package:flutter/material.dart';

class ExpandablePageView extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final bool isReverse;
  final ScrollPhysics? scrollPhysics;
  final PageController? controller;
  final ValueChanged<int>? onPageChanged;

  const ExpandablePageView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.isReverse = false,
    this.scrollPhysics,
    this.controller,
    this.onPageChanged,
  });

  @override
  State<ExpandablePageView> createState() => _ExpandablePageViewState();
}

class _ExpandablePageViewState extends State<ExpandablePageView> {
  PageController? _pageController;
  List<double> _heights = [];
  int _currentPage = 0;

  double get _currentHeight {
    if (_heights.isEmpty || _currentPage >= _heights.length) {
      return 0;
    }
    return _heights[_currentPage];
  }

  @override
  void initState() {
    super.initState();
    _pageController = widget.controller ?? PageController();
    _pageController?.addListener(_onUpdatePage);
    _heights = List.filled(widget.itemCount, 0, growable: true);
  }

  @override
  void didUpdateWidget(ExpandablePageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount) {
      // Resize heights list if itemCount changed
      if (widget.itemCount > _heights.length) {
        _heights.addAll(List.filled(widget.itemCount - _heights.length, 0));
      } else if (widget.itemCount < _heights.length) {
        _heights = _heights.sublist(0, widget.itemCount);
      }
    }
  }

  @override
  void dispose() {
    _pageController?.removeListener(_onUpdatePage);
    // Only dispose the controller if we created it (widget.controller was null)
    if (widget.controller == null) {
      _pageController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return TweenAnimationBuilder<double>(
          curve: Curves.easeInOutCubic,
          tween: Tween<double>(begin: _heights.isEmpty ? 0 : _heights.first, end: _currentHeight),
          duration: const Duration(milliseconds: 100),
          builder: (context, value, child) => SizedBox(height: value, child: child),
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.itemCount,
            itemBuilder: (context, index) => _itemBuilder(context, index, constraints),
            onPageChanged: widget.onPageChanged,
            reverse: widget.isReverse,
            physics: widget.scrollPhysics,
            allowImplicitScrolling: true,
          ),
        );
      },
    );
  }

  Widget _itemBuilder(BuildContext context, int index, BoxConstraints constraints) {
    final item = widget.itemBuilder(context, index);
    return OverflowBox(
      minHeight: 0,
      maxHeight: constraints.maxHeight.isFinite ? constraints.maxHeight : double.infinity,
      alignment: Alignment.topCenter,
      child: SizeReportingWidget(
        onSizeChange: (size) => setState(() => _heights[index] = size.height),
        child: item,
      ),
    );
  }

  void _onUpdatePage() {
    final newPage = _pageController?.page?.round();
    if (_currentPage != newPage) {
      setState(() {
        _currentPage = newPage ?? _currentPage;
      });
    }
  }
}

class SizeReportingWidget extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onSizeChange;

  const SizeReportingWidget({super.key, required this.child, required this.onSizeChange});

  @override
  State<SizeReportingWidget> createState() => _SizeReportingWidgetState();
}

class _SizeReportingWidgetState extends State<SizeReportingWidget> {
  Size? _oldSize;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
    return widget.child;
  }

  void _notifySize() {
    if (!mounted) return;
    final size = context.size;
    if (_oldSize != size) {
      _oldSize = size;
      if (size != null) widget.onSizeChange(size);
    }
  }
}
