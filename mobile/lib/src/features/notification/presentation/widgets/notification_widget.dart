import 'package:flutter/material.dart';

class NotificationWidget extends StatelessWidget {
  final String text;

  const NotificationWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text);
  }
}
