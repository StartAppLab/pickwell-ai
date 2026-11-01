import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../config/_config.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../widgets/purchase_confetti.dart';

/// Presentation only: callers verify purchases or open a debug preview.
class CongratulationsView extends StatefulWidget {
  const CongratulationsView({super.key});

  static Future<void> show(BuildContext context) =>
      Navigator.of(context, rootNavigator: true).push<void>(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => const CongratulationsView(),
        ),
      );

  @override
  State<CongratulationsView> createState() => _CongratulationsViewState();
}

class _CongratulationsViewState extends State<CongratulationsView> {
  bool _continuing = false;

  void _continue() {
    if (_continuing) return;
    setState(() => _continuing = true);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.themeData.dimensionsData;
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: context.colorScheme.surface,
            appBar: EmptyAppBar(),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: context.themeData.edgeInsetsData.pagePadding,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ExcludeSemantics(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: context.colorScheme.primaryContainer,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Icon(
                                      Icons.check_rounded,
                                      size: 56,
                                      color: context.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ),
                              Gap(spacing.largeSpacing),
                              Text(
                                context.l10n.subscriptionSuccessTitle,
                                textAlign: TextAlign.center,
                                style: context.textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Gap(spacing.smallSpacing),
                              Text(
                                context.l10n.subscriptionSuccessBody(getIt<AppConfig>().appName),
                                textAlign: TextAlign.center,
                                style: context.textTheme.bodyLarge?.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            bottomNavigationBar: SafeArea(
              top: false,
              child: Padding(
                padding: context.themeData.edgeInsetsData.pagePadding,
                child: Center(
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _continuing ? null : _continue,
                        child: Text(context.l10n.continueButton),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Positioned.fill(child: PurchaseConfetti()),
        ],
      ),
    );
  }
}
