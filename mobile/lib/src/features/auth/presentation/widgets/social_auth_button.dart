import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../app/app.dart';

enum SocialAuthButtonStyle { black, white, whiteOutlined, blackOutlined, custom }

class SocialAuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final dynamic icon;
  final Widget? image;
  final SocialAuthButtonStyle style;
  final double height;
  final BorderRadius borderRadius;
  final Color? customColor;

  const SocialAuthButton({
    required this.text,
    required this.onPressed,
    this.icon,
    this.image,
    this.style = SocialAuthButtonStyle.black,
    this.height = 44,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.customColor,
    super.key,
  });

  Color get _backgroundColor {
    switch (style) {
      case SocialAuthButtonStyle.black:
      case SocialAuthButtonStyle.blackOutlined:
        return Colors.black;
      case SocialAuthButtonStyle.white:
      case SocialAuthButtonStyle.whiteOutlined:
        return Colors.white;
      case SocialAuthButtonStyle.custom:
        return customColor ?? Colors.grey;
    }
  }

  Color get _contrastColor {
    switch (style) {
      case SocialAuthButtonStyle.black:
      case SocialAuthButtonStyle.blackOutlined:
        return Colors.white;
      case SocialAuthButtonStyle.white:
      case SocialAuthButtonStyle.whiteOutlined:
      case SocialAuthButtonStyle.custom:
        return Colors.black;
    }
  }

  Border? get _border {
    switch (style) {
      case SocialAuthButtonStyle.black:
      case SocialAuthButtonStyle.white:
      case SocialAuthButtonStyle.custom:
        return null;
      case SocialAuthButtonStyle.whiteOutlined:
        return Border.all(width: 1, color: Colors.black);
      case SocialAuthButtonStyle.blackOutlined:
        return Border.all(width: 1, color: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = height * 0.43;
    return SizedBox(
      height: height,
      child: SizedBox.expand(
        child: CupertinoButton(
          borderRadius: borderRadius,
          padding: EdgeInsets.zero,
          color: _backgroundColor,
          onPressed: onPressed,
          child: Container(
            height: height,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: borderRadius, border: _border),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null || image != null)
                  SizedBox(
                    height: fontSize,
                    width: fontSize * (25 / 31),
                    child: icon != null
                        ? AppIcon(icon: icon, color: _contrastColor, size: fontSize)
                        : image!,
                  ),
                if (icon != null || image != null) const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    text,
                    style: TextStyle(
                      inherit: false,
                      fontSize: fontSize,
                      color: _contrastColor,
                      fontFamily: '.SF Pro Text',
                      letterSpacing: -0.41,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
