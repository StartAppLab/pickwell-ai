import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  final String text;

  const ProfileWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text);
  }
}
