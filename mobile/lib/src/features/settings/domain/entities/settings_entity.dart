import 'package:flutter/widgets.dart';

class SettingsEntity {
  final int id;
  final String title;
  final VoidCallback onPressed;
  final String? description;
  final List<List<dynamic>>? icon;
  final String? image;
  final bool? isSelected;

  SettingsEntity({
    this.id = 0,
    required this.title,
    required this.onPressed,
    this.description,
    this.icon,
    this.image,
    this.isSelected,
  });
}
