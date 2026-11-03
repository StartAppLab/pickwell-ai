import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/_core.dart';

class ProductSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const ProductSection({super.key, required this.title, required this.children});
  @override
  Widget build(BuildContext context) {
    final d = context.themeData.dimensionsData;
    return Card(
      color: context.colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: EdgeInsets.all(d.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: context.textTheme.titleLarge),
            Gap(d.spacingMd),
            for (var index = 0; index < children.length; index++) ...[
              if (index > 0) Gap(d.spacingSm),
              children[index],
            ],
          ],
        ),
      ),
    );
  }
}
