import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../widgets/_widgets.dart';

class SettingsSubscriptionDebugView extends StatelessWidget {
  const SettingsSubscriptionDebugView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }
    return Scaffold(
      appBar: MaterialAppBar(title: const Text('Subscription Debug')),
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: context.themeData.edgeInsetsData.pagePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: const SubscriptionDebugCard(),
            ),
          ),
        ),
      ),
    );
  }
}
