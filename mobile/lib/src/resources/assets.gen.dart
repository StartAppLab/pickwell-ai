// dart format width=100

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart' as _svg;
import 'package:vector_graphics/vector_graphics.dart' as _vg;

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// Directory path: assets/icons/flags
  $AssetsIconsFlagsGen get flags => const $AssetsIconsFlagsGen();

  /// File path: assets/icons/ic_apple.svg
  SvgGenImage get icApple => const SvgGenImage('assets/icons/ic_apple.svg');

  /// File path: assets/icons/ic_google.svg
  SvgGenImage get icGoogle => const SvgGenImage('assets/icons/ic_google.svg');

  /// List of all assets
  List<SvgGenImage> get values => [icApple, icGoogle];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/app_icon.png
  AssetGenImage get appIcon => const AssetGenImage('assets/images/app_icon.png');

  /// File path: assets/images/app_icon_foreground.png
  AssetGenImage get appIconForeground =>
      const AssetGenImage('assets/images/app_icon_foreground.png');

  /// File path: assets/images/app_icon_launcher.png
  AssetGenImage get appIconLauncher => const AssetGenImage('assets/images/app_icon_launcher.png');

  /// List of all assets
  List<AssetGenImage> get values => [appIcon, appIconForeground, appIconLauncher];
}

class $AssetsIconsFlagsGen {
  const $AssetsIconsFlagsGen();

  /// File path: assets/icons/flags/ic_ae.svg
  SvgGenImage get icAe => const SvgGenImage('assets/icons/flags/ic_ae.svg');

  /// File path: assets/icons/flags/ic_cn.svg
  SvgGenImage get icCn => const SvgGenImage('assets/icons/flags/ic_cn.svg');

  /// File path: assets/icons/flags/ic_de.svg
  SvgGenImage get icDe => const SvgGenImage('assets/icons/flags/ic_de.svg');

  /// File path: assets/icons/flags/ic_es.svg
  SvgGenImage get icEs => const SvgGenImage('assets/icons/flags/ic_es.svg');

  /// File path: assets/icons/flags/ic_fr.svg
  SvgGenImage get icFr => const SvgGenImage('assets/icons/flags/ic_fr.svg');

  /// File path: assets/icons/flags/ic_in.svg
  SvgGenImage get icIn => const SvgGenImage('assets/icons/flags/ic_in.svg');

  /// File path: assets/icons/flags/ic_it.svg
  SvgGenImage get icIt => const SvgGenImage('assets/icons/flags/ic_it.svg');

  /// File path: assets/icons/flags/ic_jp.svg
  SvgGenImage get icJp => const SvgGenImage('assets/icons/flags/ic_jp.svg');

  /// File path: assets/icons/flags/ic_kr.svg
  SvgGenImage get icKr => const SvgGenImage('assets/icons/flags/ic_kr.svg');

  /// File path: assets/icons/flags/ic_pt.svg
  SvgGenImage get icPt => const SvgGenImage('assets/icons/flags/ic_pt.svg');

  /// File path: assets/icons/flags/ic_ru.svg
  SvgGenImage get icRu => const SvgGenImage('assets/icons/flags/ic_ru.svg');

  /// File path: assets/icons/flags/ic_us.svg
  SvgGenImage get icUs => const SvgGenImage('assets/icons/flags/ic_us.svg');

  /// List of all assets
  List<SvgGenImage> get values => [
    icAe,
    icCn,
    icDe,
    icEs,
    icFr,
    icIn,
    icIt,
    icJp,
    icKr,
    icPt,
    icRu,
    icUs,
  ];
}

abstract final class AppAssets {
  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName, {this.size, this.flavors = const {}, this.animation});

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}

class SvgGenImage {
  const SvgGenImage(this._assetName, {this.size, this.flavors = const {}}) : _isVecFormat = false;

  const SvgGenImage.vec(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    _svg.ColorMapper? colorMapper,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(_assetName, assetBundle: bundle, packageName: package);
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
        colorMapper: colorMapper,
      );
    }
    return _svg.SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter: colorFilter ?? (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
