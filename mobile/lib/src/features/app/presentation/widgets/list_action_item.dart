import 'package:flutter/material.dart';

import '../../../../core/_core.dart';
import '../../app.dart';

class ListActionItem extends StatelessWidget {
  final String text;
  final Color? textColor;
  final VoidCallback? onPressed;

  const ListActionItem({super.key, required this.text, this.textColor, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ListItem(
      onPressed: onPressed,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: context.textTheme.titleMedium?.copyWith(color: textColor),
      ),
    );
  }
}
