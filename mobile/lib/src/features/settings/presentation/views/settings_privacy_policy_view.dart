import 'package:flutter/material.dart';

import '../../../../core/_core.dart';
import '../../../../config/_config.dart';
import '../../../app/app.dart';

class SettingsPrivacyPolicyView extends StatelessWidget {
  const SettingsPrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    final url = getIt<AppConfig>().privacyUrl;
    if (url.isEmpty) {
      return Scaffold(
        appBar: MaterialAppBar(title: Text(context.l10n.privacyPolicy)),
        body: const Center(child: Text('This page is not configured yet.')),
      );
    }
    return WebViewPage(url: url, title: context.l10n.privacyPolicy);
  }
}
