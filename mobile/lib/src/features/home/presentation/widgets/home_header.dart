import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/_core.dart';
import '../../../../config/_config.dart';
import '../../../../resources/_resources.dart';
import '../../../app/app.dart';
import 'home_control_metrics.dart';

class HomeHeader extends StatelessWidget {
  final bool searching;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onOpen, onBack, onClear;
  final ValueChanged<String> onChanged;
  const HomeHeader({
    super.key,
    required this.searching,
    required this.controller,
    required this.focusNode,
    required this.onOpen,
    required this.onBack,
    required this.onClear,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n, d = context.themeData.dimensionsData, colors = context.colorScheme;
    if (searching) {
      return SizedBox(
        height: homeHeaderHeight(context),
        child: Row(
          children: [
            IconButton(
              tooltip: l.pkCloseSearch,
              onPressed: onBack,
              icon: const AppIcon(icon: CupertinoIcons.chevron_back),
            ),
            Gap(d.spacingXs),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: onChanged,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  constraints: BoxConstraints.tightFor(height: homeHeaderHeight(context)),
                  hintText: l.pkSearch,
                  filled: true,
                  fillColor: colors.surfaceContainerLowest,
                  suffixIcon: IconButton(
                    tooltip: l.pkClearSearch,
                    onPressed: onClear,
                    icon: const AppIcon(icon: HugeIcons.strokeRoundedCancel01),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      height: homeHeaderHeight(context),
      child: Row(
        children: [
          AppAssets.images.appIcon.image(width: 40, height: 40, excludeFromSemantics: true),
          Gap(d.spacingXs),
          Expanded(
            child: Text(
              getIt<AppConfig>().appName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 30,
                color: colors.primary,
              ),
            ),
          ),
          Material(
            color: colors.surfaceContainerLowest,
            elevation: 3,
            shadowColor: colors.shadow.withValues(alpha: .14),
            shape: const CircleBorder(),
            child: IconButton(
              style: IconButton.styleFrom(minimumSize: const Size(56, 56)),
              tooltip: l.pkSearch,
              onPressed: onOpen,
              icon: const AppIcon(icon: HugeIcons.strokeRoundedSearch01, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}
