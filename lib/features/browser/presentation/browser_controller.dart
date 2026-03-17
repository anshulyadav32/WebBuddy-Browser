import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/utils/url_utils.dart';
import '../../settings/domain/browser_settings.dart';
import '../../settings/presentation/settings_controller.dart';
import '../../tabs/application/tabs_controller.dart';
import '../../tabs/domain/models/browser_tab_state.dart';
import '../../tabs/domain/models/tabs_state.dart';
import '../domain/browser_page_state.dart';
import '../platform/platform_webview_controller.dart';

// ── Provider ─────────────────────────────────────────────────────────
final browserControllerProvider =
    StateNotifierProvider<BrowserController, BrowserPageState>((ref) {
      final settings = ref.watch(settingsControllerProvider);
      final initialTab = ref.read(tabsControllerProvider).activeTab;
      final controller = BrowserController(
        settings,
        ref: ref,
        initialUrl: initialTab.currentUrl,
      );

      // Navigate the WebView whenever the active tab changes.
      ref.listen<TabsState>(tabsControllerProvider, (prev, next) {
        if (prev?.activeTabId != next.activeTabId) {
          controller.navigateToTab(next.activeTab);
        }
      });

      return controller;
    });

// ── Controller ───────────────────────────────────────────────────────
class BrowserController extends StateNotifier<BrowserPageState> {
  BrowserController(
    this._settings, {
    Ref? ref,
    String initialUrl = 'about:blank',
  }) : _ref = ref,
       super(BrowserPageState(currentUrl: initialUrl));

  final BrowserSettings _settings;
  final Ref? _ref;
  PlatformWebViewController? _webViewController;

  /// Bind the platform WebViewController once the widget creates it.
  void attachWebView(PlatformWebViewController controller) {
    _webViewController = controller;
  }

  // ── Navigation ───────────────────────────────────────────────────

  /// Processes omnibox input: loads as URL or performs a search.
  Future<void> loadInput(String input) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return;

    final url = UrlUtils.isUrl(trimmed)
        ? UrlUtils.normalise(trimmed)
        : UrlUtils.buildSearchUrl(
            trimmed,
            searchUrl: _settings.searchEngine.searchUrl,
          );

    state = state.copyWith(
      currentUrl: url,
      isLoading: true,
      progress: 0.0,
      hasError: false,
      errorDescription: '',
    );
    await _webViewController?.loadUrl(url);
  }

  /// Navigates directly to the given [tab]'s URL, restoring its saved state.
  Future<void> navigateToTab(BrowserTabState tab) async {
    state = state.copyWith(
      currentUrl: tab.currentUrl,
      title: tab.title,
      isLoading: tab.isLoading,
      progress: tab.progress,
      canGoBack: tab.canGoBack,
      canGoForward: tab.canGoForward,
      hasError: false,
      errorDescription: '',
    );
    await _webViewController?.loadUrl(tab.currentUrl);
  }

  Future<void> goBack() async {
    if (state.canGoBack) {
      await _webViewController?.goBack();
    }
  }

  Future<void> goForward() async {
    if (state.canGoForward) {
      await _webViewController?.goForward();
    }
  }

  Future<void> reload() async {
    state = state.copyWith(hasError: false, errorDescription: '');
    await _webViewController?.reload();
  }

  Future<void> stopLoading() async {
    await _webViewController?.stopLoading();
    state = state.copyWith(isLoading: false);
  }

  Future<String> executeJavaScript(String script) async {
    if (_webViewController == null) {
      return 'WebView not ready.';
    }
    final trimmed = script.trim();
    if (trimmed.isEmpty) return 'Script is empty.';
    try {
      final result = await _webViewController!.runJavaScriptReturningResult(
        trimmed,
      );
      return (result == null || result.isEmpty)
          ? 'Execution completed.'
          : result;
    } catch (e) {
      return 'JavaScript error: $e';
    }
  }

  Future<Map<String, String>> inspectSiteData() async {
    final details = <String, String>{};
    final uri = Uri.tryParse(state.currentUrl);
    details['URL'] = state.currentUrl;
    details['Host'] = uri?.host ?? 'Unknown';
    details['Scheme'] = uri?.scheme ?? 'Unknown';

    if (_webViewController == null) {
      details['Status'] = 'WebView not ready';
      return details;
    }

    try {
      final cookie = await _webViewController!.runJavaScriptReturningResult(
        'document.cookie',
      );
      details['Cookies'] = cookie == null || cookie.isEmpty ? 'None' : cookie;
    } catch (_) {
      details['Cookies'] = 'Unavailable on this platform';
    }

    try {
      final storageLen = await _webViewController!.runJavaScriptReturningResult(
        'String(localStorage.length)',
      );
      details['LocalStorage keys'] = storageLen ?? 'Unknown';
    } catch (_) {
      details['LocalStorage keys'] = 'Unavailable on this platform';
    }

    return details;
  }

  Future<void> clearSiteData() async {
    if (_webViewController == null) return;
    try {
      await _webViewController!.runJavaScript('''
        (function() {
          try { localStorage.clear(); } catch (e) {}
          try { sessionStorage.clear(); } catch (e) {}
          try {
            document.cookie.split(';').forEach(function(c) {
              var eqPos = c.indexOf('=');
              var name = eqPos > -1 ? c.substr(0, eqPos) : c;
              document.cookie = name + '=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/';
            });
          } catch (e) {}
        })();
      ''');
    } catch (_) {
      // Best-effort cleanup.
    }
  }

  Future<String?> savePageForOffline() async {
    if (_webViewController == null) return null;
    try {
      final html = await _webViewController!.runJavaScriptReturningResult(
        'document.documentElement.outerHTML',
      );
      if (html == null || html.isEmpty) return null;

      final docsDir = await getApplicationDocumentsDirectory();
      final offlineDir = Directory('${docsDir.path}/offline_pages');
      if (!offlineDir.existsSync()) {
        offlineDir.createSync(recursive: true);
      }

      final host = Uri.tryParse(state.currentUrl)?.host ?? 'page';
      final safeHost = host.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$safeHost.html';
      final file = File('${offlineDir.path}/$fileName');

      final normalizedHtml = _stripWrappedStringResult(html);
      await file.writeAsString(normalizedHtml, encoding: utf8);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  Map<String, String> getSslSummary() {
    final uri = Uri.tryParse(state.currentUrl);
    final isHttps = uri?.scheme.toLowerCase() == 'https';
    return {
      'URL': state.currentUrl,
      'Host': uri?.host ?? 'Unknown',
      'Transport': isHttps ? 'HTTPS' : 'Not secure (HTTP/other)',
      'Certificate details':
          'Full certificate chain is not exposed by current Flutter WebView plugins.',
    };
  }

  void setLongPressTarget(String url, String type) {
    state = state.copyWith(lastLongPressUrl: url, lastLongPressType: type);
  }

  void clearLongPressTarget() {
    state = state.copyWith(clearLastLongPress: true);
  }

  // ── Find in page (best-effort via JavaScript) ────────────────────

  /// Attempts to highlight text on the page using `window.find()`.
  ///
  /// **Platform limitation**: `window.find()` is a non-standard API
  /// supported by most desktop browsers but may not work on all WebView
  /// implementations. On Android WebView it is generally unsupported.
  /// On iOS/macOS WKWebView support is partial. This is best-effort.
  Future<bool> findInPage(String query) async {
    if (_webViewController == null || query.isEmpty) return false;
    try {
      final escaped = query.replaceAll("'", "\\'").replaceAll('\\', '\\\\');
      await _webViewController!.runJavaScript(
        "window.find('$escaped', false, false, true)",
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Clears find-in-page highlights by collapsing the selection.
  Future<void> clearFind() async {
    try {
      await _webViewController?.runJavaScript(
        'window.getSelection().removeAllRanges()',
      );
    } catch (_) {
      // Ignore — best-effort.
    }
  }

  // ── Callbacks from WebView ───────────────────────────────────────

  void onPageStarted(String url) {
    state = state.copyWith(
      currentUrl: url,
      isLoading: true,
      progress: 0.0,
      hasError: false,
      errorDescription: '',
    );
    _syncToActiveTab(url: url, isLoading: true, progress: 0.0);
  }

  void onPageFinished(String url) async {
    final canBack = await _webViewController?.canGoBack() ?? false;
    final canFwd = await _webViewController?.canGoForward() ?? false;
    final title = await _webViewController?.getTitle() ?? '';

    state = state.copyWith(
      currentUrl: url,
      title: title,
      isLoading: false,
      progress: 1.0,
      canGoBack: canBack,
      canGoForward: canFwd,
    );
    _syncToActiveTab(
      url: url,
      title: title,
      isLoading: false,
      progress: 1.0,
      canGoBack: canBack,
      canGoForward: canFwd,
    );
  }

  void onProgress(int percent) {
    final progress = percent / 100.0;
    final isLoading = percent < 100;
    state = state.copyWith(progress: progress, isLoading: isLoading);
    _syncToActiveTab(progress: progress, isLoading: isLoading);
  }

  void onUrlChange(String? url) async {
    if (url != null) {
      final canBack = await _webViewController?.canGoBack() ?? false;
      final canFwd = await _webViewController?.canGoForward() ?? false;
      state = state.copyWith(
        currentUrl: url,
        canGoBack: canBack,
        canGoForward: canFwd,
      );
      _syncToActiveTab(url: url, canGoBack: canBack, canGoForward: canFwd);
    }
  }

  /// Called when the WebView encounters a resource error.
  void onWebResourceError(
    String description, {
    int? errorCode,
    bool isForMainFrame = true,
  }) {
    if (isForMainFrame) {
      state = state.copyWith(
        hasError: true,
        isLoading: false,
        errorDescription: description,
        errorCode: errorCode,
      );
      _syncToActiveTab(isLoading: false);
    }
  }

  // ── Private helpers ──────────────────────────────────────────────

  void _syncToActiveTab({
    String? url,
    String? title,
    bool? isLoading,
    double? progress,
    bool? canGoBack,
    bool? canGoForward,
  }) {
    try {
      _ref
          ?.read(tabsControllerProvider.notifier)
          .updateActiveTab(
            currentUrl: url,
            title: title,
            isLoading: isLoading,
            progress: progress,
            canGoBack: canGoBack,
            canGoForward: canGoForward,
          );
    } catch (_) {
      // Guard against disposal timing issues.
    }
  }

  String _stripWrappedStringResult(String value) {
    final trimmed = value.trim();
    if (trimmed.length >= 2 &&
        trimmed.startsWith('"') &&
        trimmed.endsWith('"')) {
      try {
        return jsonDecode(trimmed) as String;
      } catch (_) {
        return trimmed.substring(1, trimmed.length - 1);
      }
    }
    return trimmed;
  }
}
