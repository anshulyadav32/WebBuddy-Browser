import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../privacy/presentation/shields_controller.dart';
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
    final shieldsController = ref.read(shieldsControllerProvider.notifier);

    _webViewController = WebViewController()
      ..setJavaScriptMode(
        settings.javaScriptEnabled
            ? JavaScriptMode.unrestricted
            : JavaScriptMode.disabled,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            controller.onPageStarted(url);
            // Notify shields of the new page to reset stats.
            shieldsController.setCurrentPage(url);
          },
          onPageFinished: (url) {
            controller.onPageFinished(url);
            // Inject cosmetic element-hiding CSS after page load.
            _injectCosmeticFilters(url);
          },
          onProgress: controller.onProgress,
          onUrlChange: controller.onUrlChange,
          onWebResourceError: controller.onWebResourceError,
          onNavigationRequest: (request) {
            // Best-effort pop-up blocking.
            if (settings.popUpBlockingEnabled && !request.isMainFrame) {
              return NavigationDecision.prevent;
            }

            // Shields: evaluate navigation requests against filter rules.
            final pageUrl = ref.read(browserControllerProvider).currentUrl;
            final decision = shieldsController.evaluateRequest(
              requestUrl: request.url,
              pageUrl: pageUrl,
            );
            if (decision.shouldBlock) {
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(initialUrl));

    controller.attachWebView(_webViewController);
  }

  /// Injects CSS to hide cosmetic ad elements after page load.
  void _injectCosmeticFilters(String pageUrl) {
    final shieldsController = ref.read(shieldsControllerProvider.notifier);
    final script = shieldsController.buildCosmeticInjectionScript(pageUrl);
    if (script != null) {
      _webViewController.runJavaScript(script);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _webViewController);
  }
}
