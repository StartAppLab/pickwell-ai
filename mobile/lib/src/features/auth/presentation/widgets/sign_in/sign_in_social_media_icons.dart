import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../../core/_core.dart';
import '../../../../../config/_config.dart';
import '../../../../../resources/_resources.dart';
import '../../../../app/app.dart';
import '../../blocs/_blocs.dart';

class SignInSocialMediaIcons extends StatelessWidget {
  const SignInSocialMediaIcons({super.key});

  @override
  Widget build(BuildContext context) {
    final features = getIt<AppConfig>().features;
    if (!features.googleSignInEnabled && !features.appleSignInEnabled) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        // Or Divider
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Divider(
                thickness: 0.5,
                endIndent: context.themeData.dimensionsData.smallSpacing,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(context.l10n.or, style: TextStyle(color: context.colorScheme.onSurfaceVariant)),
            Expanded(
              child: Divider(
                thickness: 0.5,
                indent: context.themeData.dimensionsData.smallSpacing,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Gap(context.themeData.dimensionsData.mediumSpacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google
            if (getIt<AppConfig>().features.googleSignInEnabled)
              SocialMediaIcon(
                icon: AppAssets.icons.icGoogle.svg(height: 28),
                color: context.themeColor.socialMediaIconColor,
                onTap: () => _signInWithGoogle(context),
              ),
            // Apple
            if (getIt<AppConfig>().features.appleSignInEnabled &&
                (Platform.isIOS || Platform.isMacOS)) ...{
              Gap(context.themeData.dimensionsData.mediumSpacing),
              SocialMediaIcon(
                icon: AppAssets.icons.icApple.svg(height: 28),
                color: context.themeColor.socialMediaIconColor,
                onTap: () => _signInWithApple(context),
              ),
            },
          ],
        ),
      ],
    );
  }

  void _signInWithGoogle(BuildContext context) async {
    context.read<SignInCubit>().setErrorText(null);
    await AppWidgets.loadingDialog(
      context,
      loadingText: context.l10n.signingInWith(context.l10n.google),
      onLoading: () async {
        await context.read<SignInCubit>().signInWithGoogle();
      },
    );
  }

  void _signInWithApple(BuildContext context) async {
    context.read<SignInCubit>().setErrorText(null);
    await AppWidgets.loadingDialog(
      context,
      loadingText: context.l10n.signingInWith(context.l10n.apple),
      onLoading: () async {
        await context.read<SignInCubit>().signInWithApple();
      },
    );
  }
}
