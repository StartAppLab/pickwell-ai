import 'package:flutter/material.dart';

import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../../domain/_domain.dart';

class ListSettingsItem extends StatelessWidget {
  final SettingsEntity settings;
  final Widget? trailing;
  final Color? color;

  const ListSettingsItem({super.key, required this.settings, this.trailing, this.color});

  @override
  Widget build(BuildContext context) {
    return ListItem(
      onPressed: settings.onPressed,
      backgroundColor: context.colorScheme.surfaceContainer,
      leading: settings.icon != null
          ? AppIcon(icon: settings.icon!, color: color ?? context.colorScheme.primary)
          : const SizedBox.shrink(),
      trailing: Row(
        children: [
          if (trailing != null) ...{
            trailing!,
          } else ...{
            Gap(context.themeData.dimensionsData.smallSpacing),
            AppIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              color: color ?? context.colorScheme.primary,
            ),
          },
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(settings.title, style: context.textTheme.titleMedium?.copyWith(color: color)),
          if (settings.description != null) ...{
            Text(
              settings.description!,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.brightness == Brightness.light
                    ? context.colorScheme.onSurface.lighten()
                    : context.colorScheme.onSurface.darken(),
              ),
            ),
          },
        ],
      ),
    );
  }
}
