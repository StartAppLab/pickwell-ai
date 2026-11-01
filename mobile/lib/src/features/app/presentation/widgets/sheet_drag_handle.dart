import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extension.dart';

/// Shared handle for the app's floating modal sheets.
class SheetDragHandle extends StatelessWidget {
  const SheetDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final dimensions = context.themeData.dimensionsData;
    return ExcludeSemantics(
      child: Center(
        child: Container(
          width: dimensions.sheetHandleWidth,
          height: dimensions.sheetHandleHeight,
          margin: EdgeInsets.only(top: dimensions.sheetHandleTopInset),
          decoration: ShapeDecoration(
            color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
            shape: const StadiumBorder(),
          ),
        ),
      ),
    );
  }
}
