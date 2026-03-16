import 'package:webview_flutter/webview_flutter.dart';

import '../../features/settings/data/site_settings_repository.dart';

/// What categories of data to clear.
class ClearDataOptions {
  const ClearDataOptions({
    this.cookies = false,
    this.cache = false,
    this.localStorage = false,
    this.siteSettings = false,
  });

  final bool cookies;
  final bool cache;
  final bool localStorage;
  final bool siteSettings;

  /// Convenience: everything except bookmarks.
  const ClearDataOptions.all()
    : cookies = true,
      cache = true,
      localStorage = true,
      siteSettings = true;

  bool get hasAny => cookies || cache || localStorage || siteSettings;
}

/// Clears browsing data across categories.
///
/// ## Platform limitations
///
/// - **Cookies**: Cleared via `WebViewCookieManager.clearCookies()`.
///   On macOS/iOS this clears WKWebView cookies globally.
/// - **Cache**: Cleared via JavaScript `caches.delete()` in the current
///   WebView. True HTTP cache clearing is not exposed by `webview_flutter`.
/// - **Local / session storage**: Cleared via JavaScript in the current
///   WebView instance only. Other WebView instances are not affected until
///   they are also cleared.
/// - **Site settings**: Removed from SharedPreferences via the repository.
/// - **Bookmarks** are preserved by default and can only be cleared by
///   explicit user action through a separate flow.
class ClearBrowsingDataService {
  ClearBrowsingDataService({
    WebViewCookieManager? cookieManager,
    required this.siteSettingsRepo,
  }) : _cookieManager = cookieManager;

  final WebViewCookieManager? _cookieManager;
  final SiteSettingsRepository siteSettingsRepo;

  /// Executes the clearing operation for each enabled category.
  ///
  /// Pass an active [webViewController] to clear cache/storage via JS.
  Future<ClearDataResult> clear(
    ClearDataOptions options, {
    WebViewController? webViewController,
  }) async {
    var cookiesCleared = false;
    var cacheCleared = false;
    var storageCleared = false;
    var siteSettingsCleared = false;

    if (options.cookies) {
      try {
        final cm = _cookieManager ?? WebViewCookieManager();
        await cm.clearCookies();
        cookiesCleared = true;
      } catch (_) {}
    }

    if (options.cache && webViewController != null) {
      try {
        await webViewController.runJavaScript('''
          if (window.caches) {
            caches.keys().then(function(names) {
              for (var name of names) caches.delete(name);
            });
          }
        ''');
        cacheCleared = true;
      } catch (_) {}
    }

    if (options.localStorage && webViewController != null) {
      try {
        await webViewController.runJavaScript('''
          try { localStorage.clear(); } catch(e) {}
          try { sessionStorage.clear(); } catch(e) {}
        ''');
        storageCleared = true;
      } catch (_) {}
    }

    if (options.siteSettings) {
      await siteSettingsRepo.clearAll();
      siteSettingsCleared = true;
    }

    return ClearDataResult(
      cookiesCleared: cookiesCleared,
      cacheCleared: cacheCleared,
      storageCleared: storageCleared,
      siteSettingsCleared: siteSettingsCleared,
    );
  }
}

/// Result of a clear-data operation.
class ClearDataResult {
  const ClearDataResult({
    this.cookiesCleared = false,
    this.cacheCleared = false,
    this.storageCleared = false,
    this.siteSettingsCleared = false,
  });

  final bool cookiesCleared;
  final bool cacheCleared;
  final bool storageCleared;
  final bool siteSettingsCleared;

  int get clearedCount => [
    cookiesCleared,
    cacheCleared,
    storageCleared,
    siteSettingsCleared,
  ].where((b) => b).length;
}
