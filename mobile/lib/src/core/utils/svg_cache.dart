import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SvgCache {
  Future precache(String assetName, BuildContext context) async {
    final loader = SvgAssetLoader(assetName);
    await svg.cache.putIfAbsent(loader.cacheKey(context), () => loader.loadBytes(context));
  }
}
