import 'package:flutter/material.dart';
import '../../../../core/_core.dart';

class InterpretationExplanation extends StatelessWidget {
  final Map<String, dynamic> explanation;
  const InterpretationExplanation({super.key, required this.explanation});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final references = explanation['references'] as List? ?? [];
    final content = <Widget>[
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(explanation['text']?.toString() ?? l.pkUnknownValue),
      ),
      if (explanation['limitations'] is String)
        Text(explanation['limitations'] as String, style: context.textTheme.bodySmall),
      if (references.isNotEmpty) ...[
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(l.pkReferences, style: context.textTheme.titleSmall),
        ),
        for (final reference in references)
          if (reference is Map)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: SelectableText(
                '${reference['title']} · ${reference['id']}\n${reference['url']}',
              ),
            ),
      ],
      if (explanation['source'] is String)
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            '${explanation['ingredient'] is String ? l.pkRawLabel : l.pkEvidence}: ${explanation['source']}',
            style: context.textTheme.bodySmall,
          ),
        ),
    ];
    final ingredient = explanation['ingredient'];
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        ingredient is String ? ingredient : explanation['text']?.toString() ?? l.pkUnknownValue,
      ),
      subtitle: ingredient is String ? Text(l.pkIngredientContext) : null,
      childrenPadding: EdgeInsets.only(bottom: context.themeData.dimensionsData.paddingSm),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: content,
    );
  }
}
