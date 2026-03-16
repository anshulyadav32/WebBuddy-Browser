import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../browser_controller.dart';

/// Wraps the platform WebView and wires callbacks to [BrowserController].
class BrowserWebView extends ConsumerStatefulWidget {
  const BrowserWebView({super.key});

  @override
  ConsumerState<BrowserWebView> createState() => _BrowserWebViewState();
}

class _BrowserWebViewState extends ConsumerState<BrowserWebView> {
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();

    final controller = ref.read(browserControllerProvider.notifier);
    final initialUrl = ref.read(browserControllerProvider).currentUrl;

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: controller.onPageStarted,
          onPageFinished: controller.onPageFinished,
          onProgress: controller.onProgress,
          onUrlChange: controller.onUrlChange,
        ),
      )
      ..loadRequest(Uri.parse(initialUrl));

    controller.attachWebView(_webViewController);
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _webViewController);
  }
}
