import 'package:flutter/material.dart';

import '../../../../core/_core.dart';
import '../../../../config/_config.dart';
import '../../../../resources/_resources.dart';
import '../../../app/app.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      appBar: EmptyAppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: context.themeData.edgeInsetsData.pagePadding.copyWith(
            bottom: context.themeData.edgeInsetsData.pagePadding.bottom + bottomInset + 60,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppAssets.images.appIcon.image(width: 100, height: 100),
              const SizedBox(height: 24),
              Text(
                context.l10n.welcomeTitle(getIt<AppConfig>().appName),
                style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
