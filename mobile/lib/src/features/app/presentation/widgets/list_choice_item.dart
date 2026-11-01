import 'package:flutter/material.dart';

import 'package:hugeicons/hugeicons.dart';

import '../../../../core/_core.dart';
import '../../app.dart';

class ListChoiceItem extends StatelessWidget {
  final String text;
  final Color? color;
  final Widget? icon;
  final Color? iconBackgroundColor;
  final double? iconContainerSize;
  final double expandedIconInset;
  final bool expandIcon;
  final bool? isSelected;
  final VoidCallback? onPressed;

  const ListChoiceItem({
    super.key,
    required this.text,
    this.color,
    this.icon,
    this.iconBackgroundColor,
    this.iconContainerSize,
    this.expandedIconInset = 0,
    this.expandIcon = false,
    this.isSelected,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListItem(
      onPressed: onPressed,
      leading: icon == null
          ? const SizedBox.shrink()
          : iconContainerSize == null
          ? icon!
          : Container(
              width: iconContainerSize,
              height: iconContainerSize,
              decoration: BoxDecoration(color: iconBackgroundColor, shape: BoxShape.circle),
              child: Padding(
                padding: EdgeInsets.all(expandedIconInset),
                child: expandIcon
                    ? ClipOval(child: SizedBox.expand(child: icon))
                    : Center(child: icon),
              ),
            ),
      trailing: isSelected ?? false
          ? AppIcon(
              icon: HugeIcons.strokeRoundedCheckmarkCircle01,
              color: color ?? context.colorScheme.primary,
            )
          : const SizedBox.shrink(),
      child: Text(text, style: context.textTheme.titleMedium?.copyWith(color: color)),
    );
  }
}
