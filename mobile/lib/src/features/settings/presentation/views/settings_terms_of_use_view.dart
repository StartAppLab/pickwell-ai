import 'package:flutter/material.dart';

import '../../../../core/_core.dart';
import '../../../../config/_config.dart';
import '../../../app/app.dart';

class SettingsTermsOfUseView extends StatelessWidget {
  const SettingsTermsOfUseView({super.key});

  @override
  Widget build(BuildContext context) {
    final url = getIt<AppConfig>().termsUrl;
    if (url.isEmpty) {
      return Scaffold(
        appBar: MaterialAppBar(title: Text(context.l10n.termsOfUse)),
        body: const Center(child: Text('This page is not configured yet.')),
      );
    }
    return WebViewPage(url: url, title: context.l10n.termsOfUse);
  }
}
