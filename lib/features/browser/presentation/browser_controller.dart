import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/utils/url_utils.dart';
import '../../settings/domain/browser_settings.dart';
import '../../settings/presentation/settings_controller.dart';
import '../domain/browser_page_state.dart';

// ── Provider ─────────────────────────────────────────────────────────
final browserControllerProvider =
    StateNotifierProvider<BrowserController, BrowserPageState>((ref) {
      final settings = ref.watch(settingsControllerProvider);
      return BrowserController(settings);
    });

// ── Controller ───────────────────────────────────────────────────────
class BrowserController extends StateNotifier<BrowserPageState> {
  BrowserController(this._settings) : super(const BrowserPageState());

  final BrowserSettings _settings;
  WebViewController? _webViewController;

  /// Bind the platform WebViewController once the widget creates it.
  void attachWebView(WebViewController controller) {
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

    state = state.copyWith(currentUrl: url, isLoading: true, progress: 0.0);
    await _webViewController?.loadRequest(Uri.parse(url));
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
    await _webViewController?.reload();
  }

  Future<void> stopLoading() async {
    await _webViewController?.runJavaScript('window.stop()');
    state = state.copyWith(isLoading: false);
  }

  // ── Callbacks from WebView ───────────────────────────────────────

  void onPageStarted(String url) {
    state = state.copyWith(currentUrl: url, isLoading: true, progress: 0.0);
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
  }

  void onProgress(int percent) {
    state = state.copyWith(progress: percent / 100.0, isLoading: percent < 100);
  }

  void onUrlChange(UrlChange change) async {
    if (change.url != null) {
      final canBack = await _webViewController?.canGoBack() ?? false;
      final canFwd = await _webViewController?.canGoForward() ?? false;
      state = state.copyWith(
        currentUrl: change.url!,
        canGoBack: canBack,
        canGoForward: canFwd,
      );
    }
  }
}
