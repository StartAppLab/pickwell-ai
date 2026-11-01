import 'package:flutter/material.dart';

extension ImageExtension on AssetImage {
  Future<void> precache(BuildContext context) async {
    await precacheImage(this, context);
  }
}
