import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';

class ProductFindingCard extends StatelessWidget {
  final Map<String, dynamic> finding;
  const ProductFindingCard({super.key, required this.finding});
  @override
  Widget build(BuildContext context) {
    final l = context.l10n, d = context.themeData.dimensionsData;
    final severity = finding['severity'];
    final color = switch (severity) {
      'green' => context.colorScheme.secondary,
      'yellow' => context.colorScheme.tertiary,
      'red' => context.colorScheme.error,
      _ => context.colorScheme.onSurfaceVariant,
    };
    final icon = switch (severity) {
      'green' => Icons.check_circle_outline,
      'red' => Icons.warning_amber_rounded,
      _ => Icons.info_outline,
    };
    final label = switch (severity) {
      'green' => l.pkFindingGreen,
      'yellow' => l.pkFindingYellow,
      'red' => l.pkFindingRed,
      _ => l.pkUnknownValue,
    };
    final source = finding['source_details'] as Map?;
    final evidence = source?['evidence'] as List? ?? [];
    return Semantics(
      container: true,
      child: Material(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(d.nestedCornerRadius),
        child: Padding(
          padding: EdgeInsets.all(d.paddingSm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppIcon(icon: icon, color: color),
                  Gap(d.spacingXs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: context.textTheme.labelLarge?.copyWith(color: color)),
                        Text(
                          finding['title']?.toString() ?? l.pkUnknownValue,
                          style: context.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Gap(d.spacingXs),
              Text(finding['explanation']?.toString() ?? l.pkUnknownValue),
              if (evidence.isNotEmpty || source?['rule_id'] != null)
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(l.pkEvidence),
                  children: [
                    for (final item in evidence)
                      if (item is Map)
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            (item['source'] ??
                                    item['label_text'] ??
                                    item['reference'] ??
                                    l.pkUnknownValue)
                                .toString(),
                          ),
                        ),
                    if (source?['rule_id'] != null)
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text('${l.pkRule}: ${source!['rule_id']}'),
                      ),
                    if (source?['reference'] is String)
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: SelectableText(source!['reference'] as String),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
