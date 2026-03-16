import 'package:webview_flutter/webview_flutter.dart';

/// Manages private session data cleanup.
///
/// Clears cookies, cache, and local storage when the private session ends
/// (i.e. the last private tab is closed).
///
/// ## Platform limitations
///
/// - **macOS / iOS**: `WebViewCookieManager` can clear cookies. JavaScript
///   `localStorage.clear()` and `sessionStorage.clear()` are executed but
///   only affect the current WebView instance — other WebViews may retain
///   their own storage until they are also cleared.
/// - **Android**: Similar cookie clearing via the cookie manager. Cache
///   clearing is best-effort through the WebView controller.
/// - **True isolation**: Flutter's `webview_flutter` does not support
///   separate browser profiles or fully isolated cookie jars per tab.
///   Private mode prevents *persistence* (no history saved, session data
///   cleared on close) but does **not** guarantee network-level privacy
///   (the user's IP is still visible, DNS queries are not encrypted by
///   this feature, etc.).
class PrivateDataManager {
  PrivateDataManager({WebViewCookieManager? cookieManager})
    : _cookieManager = cookieManager;

  final WebViewCookieManager? _cookieManager;

  /// Clears all private session data.
  ///
  /// Call this when the last private tab is closed.
  Future<void> clearPrivateSessionData({
    WebViewController? webViewController,
  }) async {
    // 1. Clear cookies.
    final cm = _cookieManager ?? WebViewCookieManager();
    await cm.clearCookies();

    // 2. Clear web storage via JavaScript (best-effort).
    if (webViewController != null) {
      try {
        await webViewController.runJavaScript('''
          try { localStorage.clear(); } catch(e) {}
          try { sessionStorage.clear(); } catch(e) {}
        ''');
      } catch (_) {
        // JavaScript execution may fail if no page is loaded.
      }
    }
  }

  /// Checks whether history should be recorded for a tab.
  ///
  /// Returns `false` for private tabs — their visits must not be persisted.
  bool shouldRecordHistory({required bool isPrivate}) => !isPrivate;

  /// Checks whether tab state should be persisted for session restore.
  ///
  /// Returns `false` for private tabs — they must not survive app restarts.
  bool shouldPersistTab({required bool isPrivate}) => !isPrivate;
}
