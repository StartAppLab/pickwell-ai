import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../../core/_core.dart';
import '../../../../../config/_config.dart';
import '../../../../../resources/_resources.dart';
import '../../../../app/app.dart';
import '../../blocs/_blocs.dart';

class SignUpSocialMediaIcons extends StatelessWidget {
  const SignUpSocialMediaIcons({super.key});

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
                onTap: () => _signUpWithGoogle(context),
              ),
            // Apple
            if (getIt<AppConfig>().features.appleSignInEnabled &&
                (Platform.isIOS || Platform.isMacOS)) ...{
              Gap(context.themeData.dimensionsData.mediumSpacing),
              SocialMediaIcon(
                icon: AppAssets.icons.icApple.svg(height: 28),
                color: context.themeColor.socialMediaIconColor,
                onTap: () => _signUpWithApple(context),
              ),
            },
          ],
        ),
      ],
    );
  }

  void _signUpWithGoogle(BuildContext context) async {
    context.read<SignUpCubit>().setErrorText(null);
    await AppWidgets.loadingDialog(
      context,
      loadingText: context.l10n.signingUpWith(context.l10n.google),
      onLoading: () async {
        await context.read<SignUpCubit>().signUpWithGoogle();
      },
    );
  }

  void _signUpWithApple(BuildContext context) async {
    context.read<SignUpCubit>().setErrorText(null);
    await AppWidgets.loadingDialog(
      context,
      loadingText: context.l10n.signingUpWith(context.l10n.apple),
      onLoading: () async {
        await context.read<SignUpCubit>().signUpWithApple();
      },
    );
  }
}
