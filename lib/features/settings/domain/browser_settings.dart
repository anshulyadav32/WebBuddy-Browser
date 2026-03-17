import 'package:flutter/material.dart';

/// Supported search engines.
enum SearchEngine {
  google('Google', 'https://www.google.com/search?q='),
  duckDuckGo('DuckDuckGo', 'https://duckduckgo.com/?q='),
  bing('Bing', 'https://www.bing.com/search?q='),
  brave('Brave', 'https://search.brave.com/search?q=');

  const SearchEngine(this.label, this.searchUrl);
  final String label;
  final String searchUrl;
}

/// Cookie acceptance policy.
///
/// ## Platform limitations
///
/// `webview_flutter` does not expose per-policy cookie controls on all
/// platforms. On macOS/iOS the WKWebView `httpCookieAcceptPolicy` is not
/// surfaced through the plugin. These values are therefore **best-effort**:
///
/// - [acceptAll] – default WebView behaviour (accept all cookies).
/// - [blockThirdParty] – on platforms that support it the WebView will
///   reject third-party cookies; elsewhere it falls back to [acceptAll].
/// - [blockAll] – cookies are cleared on every navigation event.
enum CookiePolicy {
  acceptAll('Accept all'),
  blockThirdParty('Block third-party'),
  blockAll('Block all');

  const CookiePolicy(this.label);
  final String label;
}

/// Application-wide settings.
class BrowserSettings {
  const BrowserSettings({
    this.themeMode = ThemeMode.system,
    this.searchEngine = SearchEngine.google,
    this.adBlockEnabled = true,
    this.httpsUpgradeEnabled = true,
    this.homePage = 'https://google.com',
    this.javaScriptEnabled = true,
    this.cacheEnabled = true,
    this.scrollbarsEnabled = true,
    this.customUserAgent = '',
    this.popUpBlockingEnabled = true,
    this.cookiePolicy = CookiePolicy.acceptAll,
  });

  final ThemeMode themeMode;
  final SearchEngine searchEngine;
  final bool adBlockEnabled;
  final bool httpsUpgradeEnabled;
  final String homePage;
  final bool javaScriptEnabled;
  final bool cacheEnabled;
  final bool scrollbarsEnabled;
  final String customUserAgent;
  final bool popUpBlockingEnabled;
  final CookiePolicy cookiePolicy;

  BrowserSettings copyWith({
    ThemeMode? themeMode,
    SearchEngine? searchEngine,
    bool? adBlockEnabled,
    bool? httpsUpgradeEnabled,
    String? homePage,
    bool? javaScriptEnabled,
    bool? cacheEnabled,
    bool? scrollbarsEnabled,
    String? customUserAgent,
    bool? popUpBlockingEnabled,
    CookiePolicy? cookiePolicy,
  }) {
    return BrowserSettings(
      themeMode: themeMode ?? this.themeMode,
      searchEngine: searchEngine ?? this.searchEngine,
      adBlockEnabled: adBlockEnabled ?? this.adBlockEnabled,
      httpsUpgradeEnabled: httpsUpgradeEnabled ?? this.httpsUpgradeEnabled,
      homePage: homePage ?? this.homePage,
      javaScriptEnabled: javaScriptEnabled ?? this.javaScriptEnabled,
      cacheEnabled: cacheEnabled ?? this.cacheEnabled,
      scrollbarsEnabled: scrollbarsEnabled ?? this.scrollbarsEnabled,
      customUserAgent: customUserAgent ?? this.customUserAgent,
      popUpBlockingEnabled: popUpBlockingEnabled ?? this.popUpBlockingEnabled,
      cookiePolicy: cookiePolicy ?? this.cookiePolicy,
    );
  }

  /// Serialize to a flat `Map<String, dynamic>` for SharedPreferences.
  Map<String, dynamic> toMap() => {
    'themeMode': themeMode.index,
    'searchEngine': searchEngine.index,
    'adBlockEnabled': adBlockEnabled,
    'httpsUpgradeEnabled': httpsUpgradeEnabled,
    'homePage': homePage,
    'javaScriptEnabled': javaScriptEnabled,
    'cacheEnabled': cacheEnabled,
    'scrollbarsEnabled': scrollbarsEnabled,
    'customUserAgent': customUserAgent,
    'popUpBlockingEnabled': popUpBlockingEnabled,
    'cookiePolicy': cookiePolicy.index,
  };

  /// Deserialize from a `Map<String, dynamic>`.
  factory BrowserSettings.fromMap(Map<String, dynamic> map) {
    return BrowserSettings(
      themeMode: ThemeMode.values[map['themeMode'] as int? ?? 0],
      searchEngine: SearchEngine.values[map['searchEngine'] as int? ?? 0],
      adBlockEnabled: map['adBlockEnabled'] as bool? ?? true,
      httpsUpgradeEnabled: map['httpsUpgradeEnabled'] as bool? ?? true,
      homePage: map['homePage'] as String? ?? 'https://google.com',
      javaScriptEnabled: map['javaScriptEnabled'] as bool? ?? true,
      cacheEnabled: map['cacheEnabled'] as bool? ?? true,
      scrollbarsEnabled: map['scrollbarsEnabled'] as bool? ?? true,
      customUserAgent: map['customUserAgent'] as String? ?? '',
      popUpBlockingEnabled: map['popUpBlockingEnabled'] as bool? ?? true,
      cookiePolicy: CookiePolicy.values[map['cookiePolicy'] as int? ?? 0],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrowserSettings &&
          themeMode == other.themeMode &&
          searchEngine == other.searchEngine &&
          adBlockEnabled == other.adBlockEnabled &&
          httpsUpgradeEnabled == other.httpsUpgradeEnabled &&
          homePage == other.homePage &&
          javaScriptEnabled == other.javaScriptEnabled &&
          cacheEnabled == other.cacheEnabled &&
          scrollbarsEnabled == other.scrollbarsEnabled &&
          customUserAgent == other.customUserAgent &&
          popUpBlockingEnabled == other.popUpBlockingEnabled &&
          cookiePolicy == other.cookiePolicy;

  @override
  int get hashCode => Object.hash(
    themeMode,
    searchEngine,
    adBlockEnabled,
    httpsUpgradeEnabled,
    homePage,
    javaScriptEnabled,
    cacheEnabled,
    scrollbarsEnabled,
    customUserAgent,
    popUpBlockingEnabled,
    cookiePolicy,
  );

  @override
  String toString() =>
      'BrowserSettings(theme: $themeMode, search: $searchEngine, '
      'js: $javaScriptEnabled, popUp: $popUpBlockingEnabled, '
      'cookie: $cookiePolicy)';
}
