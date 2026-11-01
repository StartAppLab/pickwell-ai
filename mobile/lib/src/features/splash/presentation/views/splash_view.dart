import 'dart:async';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../../../config/_config.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  bool _isChecking = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_loadingFinished());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EmptyAppBar(),
      body: SafeArea(
        child: Center(
          child: _hasError
              ? Padding(
                  padding: context.themeData.edgeInsetsData.pagePadding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(context.l10n.authContinueError, textAlign: TextAlign.center),
                      SizedBox(height: context.themeData.dimensionsData.smallSpacing),
                      ElevatedButton(
                        onPressed: _isChecking ? null : _loadingFinished,
                        child: Text(context.l10n.retryButton),
                      ),
                    ],
                  ),
                )
              : AppWidgets.loadingIndicator(context),
        ),
      ),
    );
  }

  Future<void> _loadingFinished() async {
    if (_isChecking) return;
    setState(() {
      _isChecking = true;
      _hasError = false;
    });
    try {
      final destination = await AppFlowResolver.resolve();
      if (mounted) context.go(AppFlowResolver.takeLocation(destination));
    } catch (error, stackTrace) {
      AppLogger.logError(error, stackTrace: stackTrace);
      if (mounted) setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }
}
