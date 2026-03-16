import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:web_buddy/core/utils/platform_utils.dart';
import 'package:web_buddy/core/utils/url_utils.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_toolbar.dart';
import 'package:web_buddy/features/history/presentation/providers/history_provider.dart';
import 'package:web_buddy/features/privacy/domain/services/filter_engine.dart';
import 'package:web_buddy/features/privacy/presentation/providers/privacy_provider.dart';
import 'package:web_buddy/features/settings/presentation/providers/settings_provider.dart';
import 'package:web_buddy/features/tabs/presentation/providers/tab_provider.dart';

final _log = Logger('WebViewContainer');

/// Wraps the platform WebView for a single tab.
///
/// Platform behavior:
/// - Android: Uses Android System WebView (Chromium-backed)
/// - iOS/macOS: Uses WKWebView
/// - Windows: WebView2 (requires webview_flutter_windows, limited support)
/// - Linux: No stable webview plugin; shows placeholder
///
/// Request interception limitations:
/// - Android: NavigationDelegate can intercept main-frame navigations only.
///   Sub-resource blocking (images, scripts) is NOT supported via Flutter's
///   webview_flutter plugin. For sub-resource blocking, a content-blocker
///   approach via WebView settings or injected JS is needed.
/// - iOS/macOS (WKWebView): WKContentRuleList provides Safari-style content
///   blocking via JSON rules. This is the most effective blocking path.
/// - All platforms: Full request interception like a desktop browser extension
///   is not possible through Flutter plugins alone.
class WebViewContainer extends ConsumerStatefulWidget {
  final String tabId;

  const WebViewContainer({super.key, required this.tabId});

  @override
  ConsumerState<WebViewContainer> createState() => _WebViewContainerState();
}

class _WebViewContainerState extends ConsumerState<WebViewContainer> {
  WebViewController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (PlatformUtils.hasWebViewSupport) {
      _initWebView();
    }
  }

  void _initWebView() {
    final settings = ref.read(settingsProvider);

    final controller = WebViewController();

    controller
      ..setJavaScriptMode(
        settings.javascriptEnabled
            ? JavaScriptMode.unrestricted
            : JavaScriptMode.disabled,
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: _onPageStarted,
        onPageFinished: _onPageFinished,
        onProgress: _onProgress,
        onNavigationRequest: _onNavigationRequest,
        onWebResourceError: _onWebResourceError,
        onUrlChange: _onUrlChange,
      ))
      ..setUserAgent(null); // Use platform default with our suffix

    // Enable zoom controls
    controller.enableZoom(true);

    // Load the tab's current URL
    final session = ref.read(browserSessionProvider);
    final tab = session.tabs.where((t) => t.id == widget.tabId).firstOrNull;
    if (tab != null && tab.url != 'about:blank') {
      final url = settings.httpsUpgradeEnabled
          ? UrlUtils.tryUpgradeToHttps(tab.url)
          : tab.url;
      controller.loadRequest(Uri.parse(url));
    }

    _controller = controller;

    // Set up navigation actions via provider listener
    // (handled in build method via ref.listen)

    setState(() => _initialized = true);
  }

  void _handleToolbarAction(String action) {
    final controller = _controller;
    if (controller == null) return;

    switch (action) {
      case 'back':
        controller.goBack();
      case 'forward':
        controller.goForward();
      case 'refresh':
        controller.reload();
      case 'stop':
        // webview_flutter doesn't expose stop(); reload is the fallback
        break;
    }
  }

  void _onPageStarted(String url) {
    // Reset blocked count for new page load
    ref.read(blockedCountProvider(widget.tabId).notifier).state = 0;
    ref.read(blockedUrlsProvider(widget.tabId).notifier).state = [];

    ref.read(browserSessionProvider.notifier).updateTab(
      widget.tabId,
      (tab) => tab.copyWith(
        url: url,
        isLoading: true,
        loadProgress: 0.0,
        errorMessage: null,
      ),
    );
  }

  void _onPageFinished(String url) async {
    final controller = _controller;
    if (controller == null) return;

    final title = await controller.getTitle();
    final canGoBack = await controller.canGoBack();
    final canGoForward = await controller.canGoForward();

    ref.read(browserSessionProvider.notifier).updateTab(
      widget.tabId,
      (tab) => tab.copyWith(
        url: url,
        title: title ?? UrlUtils.titleFromUrl(url),
        isLoading: false,
        loadProgress: 1.0,
        canGoBack: canGoBack,
        canGoForward: canGoForward,
      ),
    );

    // Record in history (not for incognito or about: pages)
    final session = ref.read(browserSessionProvider);
    final currentTab =
        session.tabs.where((t) => t.id == widget.tabId).firstOrNull;
    if (currentTab != null &&
        !currentTab.isIncognito &&
        !UrlUtils.isInternalPage(url)) {
      ref.read(historyActionsProvider).addEntry(
        title: title ?? '',
        url: url,
      );
    }

    // Inject cosmetic filter CSS if shields are up
    _injectCosmeticFilters(url);
  }

  void _onProgress(int progress) {
    ref.read(browserSessionProvider.notifier).updateTab(
      widget.tabId,
      (tab) => tab.copyWith(loadProgress: progress / 100.0),
    );
  }

  NavigationDecision _onNavigationRequest(NavigationRequest request) {
    final url = request.url;

    // Handle external schemes
    if (UrlUtils.isExternalScheme(url)) {
      // TODO: Use url_launcher to handle external schemes
      // Platform limitation: Cannot intercept all external schemes on all platforms
      return NavigationDecision.prevent;
    }

    // Check filter engine for main-frame navigations
    // Note: This only catches main-frame navigations, NOT sub-resources.
    // Sub-resource blocking is handled differently per platform (see class doc).
    final settings = ref.read(settingsProvider);
    if (settings.adBlockingEnabled || settings.trackerBlockingEnabled) {
      final engine = ref.read(filterEngineProvider);
      final session = ref.read(browserSessionProvider);
      final currentTab =
          session.tabs.where((t) => t.id == widget.tabId).firstOrNull;
      final pageHost = currentTab != null
          ? UrlUtils.extractDomain(currentTab.url)
          : null;

      final result = engine.shouldBlock(url, pageHost: pageHost);
      if (result.blocked) {
        // Log the blocked request
        final count = ref.read(blockedCountProvider(widget.tabId));
        ref.read(blockedCountProvider(widget.tabId).notifier).state =
            count + 1;
        ref.read(blockedUrlsProvider(widget.tabId).notifier).update((state) => [
              ...state,
              BlockedRequestInfo(
                url: url,
                matchedRule: result.matchedRule,
                blockedAt: DateTime.now(),
              ),
            ]);
        _log.fine('Blocked: $url (rule: ${result.matchedRule})');
        return NavigationDecision.prevent;
      }
    }

    // HTTPS upgrade
    if (settings.httpsUpgradeEnabled && url.startsWith('http://')) {
      final upgraded = UrlUtils.tryUpgradeToHttps(url);
      if (upgraded != url) {
        _controller?.loadRequest(Uri.parse(upgraded));
        return NavigationDecision.prevent;
      }
    }

    return NavigationDecision.navigate;
  }

  void _onWebResourceError(WebResourceError error) {
    _log.warning('Web resource error: ${error.description} '
        '(type: ${error.errorType}, code: ${error.errorCode})');

    ref.read(browserSessionProvider.notifier).updateTab(
      widget.tabId,
      (tab) => tab.copyWith(
        isLoading: false,
        errorMessage: error.description,
      ),
    );
  }

  void _onUrlChange(UrlChange change) {
    if (change.url != null) {
      ref.read(browserSessionProvider.notifier).updateTab(
        widget.tabId,
        (tab) => tab.copyWith(url: change.url!),
      );
    }
  }

  /// Injects CSS to hide elements matching cosmetic filter rules.
  Future<void> _injectCosmeticFilters(String url) async {
    final controller = _controller;
    if (controller == null) return;

    final settings = ref.read(settingsProvider);
    if (!settings.adBlockingEnabled) return;

    final engine = ref.read(filterEngineProvider);
    final domain = UrlUtils.extractDomain(url);
    final selectors = engine.getCosmeticSelectorsForDomain(domain);

    if (selectors.isEmpty) return;

    // Inject CSS to hide matched elements
    // Sanitize selectors to prevent script injection
    final safeSelectors = selectors
        .where((s) => !s.contains('<') && !s.contains('>'))
        .join(', ');

    if (safeSelectors.isEmpty) return;

    final css = '$safeSelectors { display: none !important; }';
    final js = '''
      (function() {
        var style = document.createElement('style');
        style.type = 'text/css';
        style.appendChild(document.createTextNode(${_escapeJsString(css)}));
        document.head.appendChild(style);
      })();
    ''';

    try {
      await controller.runJavaScript(js);
    } catch (e) {
      _log.fine('Failed to inject cosmetic filters: $e');
    }
  }

  String _escapeJsString(String s) {
    return "'${s.replaceAll('\\', '\\\\').replaceAll("'", "\\'").replaceAll('\n', '\\n')}'";
  }

  @override
  Widget build(BuildContext context) {
    // Watch for URL changes from the tab state (e.g., omnibox navigation)
    final session = ref.watch(browserSessionProvider);
    final tab = session.tabs.where((t) => t.id == widget.tabId).firstOrNull;

    // Listen for navigation actions from toolbar
    ref.listen(navigationActionProvider(widget.tabId), (prev, next) {
      if (next != null && _controller != null) {
        _handleToolbarAction(next);
        // Reset after handling
        ref.read(navigationActionProvider(widget.tabId).notifier).state = null;
      }
    });

    if (!PlatformUtils.hasWebViewSupport) {
      return _UnsupportedPlatformView(
        platform: PlatformUtils.isWindows ? 'Windows' : 'Linux',
      );
    }

    if (!_initialized || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return WebViewWidget(controller: _controller!);
  }

  @override
  void didUpdateWidget(WebViewContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the tab ID changed, reinitialize
    if (oldWidget.tabId != widget.tabId) {
      _initWebView();
    }
  }
}

/// Placeholder for platforms without WebView support.
class _UnsupportedPlatformView extends StatelessWidget {
  final String platform;

  const _UnsupportedPlatformView({required this.platform});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            'WebView not fully supported on $platform',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'WebView2 integration is needed for $platform.\n'
            'This is a known limitation of the current implementation.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
