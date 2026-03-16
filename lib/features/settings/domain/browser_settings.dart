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

/// Application-wide settings.
class BrowserSettings {
  const BrowserSettings({
    this.themeMode = ThemeMode.system,
    this.searchEngine = SearchEngine.google,
    this.adBlockEnabled = true,
    this.httpsUpgradeEnabled = true,
    this.homePage = 'about:blank',
  });

  final ThemeMode themeMode;
  final SearchEngine searchEngine;
  final bool adBlockEnabled;
  final bool httpsUpgradeEnabled;
  final String homePage;

  BrowserSettings copyWith({
    ThemeMode? themeMode,
    SearchEngine? searchEngine,
    bool? adBlockEnabled,
    bool? httpsUpgradeEnabled,
    String? homePage,
  }) {
    return BrowserSettings(
      themeMode: themeMode ?? this.themeMode,
      searchEngine: searchEngine ?? this.searchEngine,
      adBlockEnabled: adBlockEnabled ?? this.adBlockEnabled,
      httpsUpgradeEnabled: httpsUpgradeEnabled ?? this.httpsUpgradeEnabled,
      homePage: homePage ?? this.homePage,
    );
  }

  /// Serialize to a flat `Map<String, dynamic>` for SharedPreferences.
  Map<String, dynamic> toMap() => {
    'themeMode': themeMode.index,
    'searchEngine': searchEngine.index,
    'adBlockEnabled': adBlockEnabled,
    'httpsUpgradeEnabled': httpsUpgradeEnabled,
    'homePage': homePage,
  };

  /// Deserialize from a `Map<String, dynamic>`.
  factory BrowserSettings.fromMap(Map<String, dynamic> map) {
    return BrowserSettings(
      themeMode: ThemeMode.values[map['themeMode'] as int? ?? 0],
      searchEngine: SearchEngine.values[map['searchEngine'] as int? ?? 0],
      adBlockEnabled: map['adBlockEnabled'] as bool? ?? true,
      httpsUpgradeEnabled: map['httpsUpgradeEnabled'] as bool? ?? true,
      homePage: map['homePage'] as String? ?? 'about:blank',
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
          homePage == other.homePage;

  @override
  int get hashCode => Object.hash(
    themeMode,
    searchEngine,
    adBlockEnabled,
    httpsUpgradeEnabled,
    homePage,
  );

  @override
  String toString() =>
      'BrowserSettings(theme: $themeMode, search: $searchEngine, '
      'adBlock: $adBlockEnabled, httpsUpgrade: $httpsUpgradeEnabled)';
}
