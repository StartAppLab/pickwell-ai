import 'package:flutter/material.dart';

import '../../../../core/_core.dart';

class SocialMediaIcon extends StatelessWidget {
  final Widget icon;
  final double padding;
  final double borderRadius;
  final Color color;
  final VoidCallback? onTap;

  const SocialMediaIcon({
    super.key,
    required this.icon,
    this.padding = 12,
    this.borderRadius = 50,
    this.color = Colors.white,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: context.colorScheme.onSurfaceVariant,
            width: 0.5,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(padding: EdgeInsets.all(padding), child: icon),
      ),
    );
  }
}
