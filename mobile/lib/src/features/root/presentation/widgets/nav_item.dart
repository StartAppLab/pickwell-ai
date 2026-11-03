import 'package:flutter/material.dart';

import '../../../../core/_core.dart';
import '../../../app/app.dart';

class NavItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final dynamic icon;
  final String label;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;
    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(vertical: context.themeData.dimensionsData.paddingXs),
            constraints: const BoxConstraints(minHeight: 64),
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon(
                  icon: icon,
                  color: isSelected
                      ? context.colorScheme.onPrimaryContainer
                      : context.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? context.colorScheme.onPrimaryContainer
                        : context.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
