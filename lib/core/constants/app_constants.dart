/// Application-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'WebBuddy';
  static const String appVersion = '1.0.0';
  static const String defaultHomePage = 'about:blank';
  static const String newTabUrl = 'about:blank';

  static const int maxTabs = 50;
  static const int maxHistoryItems = 10000;
  static const int maxBookmarks = 5000;

  static const Duration httpTimeout = Duration(seconds: 30);
  static const Duration searchSuggestionDebounce = Duration(milliseconds: 300);

  static const String defaultSearchEngine = 'google';

  /// User agent suffix appended to identify WebBuddy.
  static const String userAgentSuffix = 'WebBuddy/1.0';
}
