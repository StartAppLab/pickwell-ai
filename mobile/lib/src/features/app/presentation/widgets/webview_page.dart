import 'dart:async';

import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/_core.dart';
import '../../app.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({
    super.key,
    required this.url,
    required this.title,
    this.allowedDomains = const [],
    this.customJavaScript,
    this.allowSubdomains = false,
  });

  final String url;
  final String title;
  final List<String> allowedDomains;
  final String? customJavaScript;
  final bool allowSubdomains;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  late final WebNavigationPolicy _policy;
  var _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    final initialUri = Uri.parse(widget.url);
    _policy = WebNavigationPolicy(
      initialUri: initialUri,
      allowedDomains: widget.allowedDomains,
      allowSubdomains: widget.allowSubdomains,
    );
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            if (widget.customJavaScript != null) {
              unawaited(_runJavaScript(widget.customJavaScript!));
            }
            setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            if (!mounted || error.isForMainFrame != true) return;
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (_policy.allows(uri)) return NavigationDecision.navigate;
            if (WebNavigationPolicy.canOpenExternally(uri)) {
              unawaited(_navigateToUrl(uri!));
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(initialUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MaterialAppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading) Center(child: AppWidgets.loadingIndicator(context)),
            if (_hasError)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Unable to load this page'),
                    TextButton(onPressed: _controller.reload, child: const Text('Retry')),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _runJavaScript(String script) async {
    try {
      await _controller.runJavaScript(script);
    } catch (error, stackTrace) {
      AppLogger.logError(error, stackTrace: stackTrace);
    }
  }

  Future<void> _navigateToUrl(Uri uri) async {
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Unable to open external link');
      }
    } catch (error, stackTrace) {
      AppLogger.logError(error, stackTrace: stackTrace);
      if (mounted) AppWidgets.showErrorSnackBar(context, 'Unable to open this link');
    }
  }
}
