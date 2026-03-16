import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../settings/domain/browser_settings.dart';
import '../../../settings/presentation/settings_controller.dart';
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
    final settings = ref.read(settingsControllerProvider);

    _webViewController = WebViewController()
      ..setJavaScriptMode(
        settings.javaScriptEnabled
            ? JavaScriptMode.unrestricted
            : JavaScriptMode.disabled,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: controller.onPageStarted,
          onPageFinished: controller.onPageFinished,
          onProgress: controller.onProgress,
          onUrlChange: controller.onUrlChange,
          onNavigationRequest: (request) {
            // Best-effort pop-up blocking: block navigations that look
            // like new-window pop-ups (isMainFrame == false) when the
            // setting is enabled.
            if (settings.popUpBlockingEnabled && !request.isMainFrame) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
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
