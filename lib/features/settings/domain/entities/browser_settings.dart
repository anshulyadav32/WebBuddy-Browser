/// All browser settings with defaults.
class BrowserSettings {
  final String searchEngineId;
  final bool adBlockingEnabled;
  final bool trackerBlockingEnabled;
  final bool httpsUpgradeEnabled;
  final bool javascriptEnabled;
  final bool popupBlockingEnabled;
  final bool doNotTrackEnabled;
  final CookiePolicy cookiePolicy;
  final ThemeMode themeMode;
  final bool showTabBar;
  final bool enablePullToRefresh;
  final bool enableIncognitoMode;
  final String homePage;
  final bool antiFingerprinting;

  const BrowserSettings({
    this.searchEngineId = 'google',
    this.adBlockingEnabled = true,
    this.trackerBlockingEnabled = true,
    this.httpsUpgradeEnabled = true,
    this.javascriptEnabled = true,
    this.popupBlockingEnabled = true,
    this.doNotTrackEnabled = true,
    this.cookiePolicy = CookiePolicy.blockThirdParty,
    this.themeMode = ThemeMode.system,
    this.showTabBar = true,
    this.enablePullToRefresh = true,
    this.enableIncognitoMode = false,
    this.homePage = 'about:blank',
    this.antiFingerprinting = false,
  });

  BrowserSettings copyWith({
    String? searchEngineId,
    bool? adBlockingEnabled,
    bool? trackerBlockingEnabled,
    bool? httpsUpgradeEnabled,
    bool? javascriptEnabled,
    bool? popupBlockingEnabled,
    bool? doNotTrackEnabled,
    CookiePolicy? cookiePolicy,
    ThemeMode? themeMode,
    bool? showTabBar,
    bool? enablePullToRefresh,
    bool? enableIncognitoMode,
    String? homePage,
    bool? antiFingerprinting,
  }) {
    return BrowserSettings(
      searchEngineId: searchEngineId ?? this.searchEngineId,
      adBlockingEnabled: adBlockingEnabled ?? this.adBlockingEnabled,
      trackerBlockingEnabled: trackerBlockingEnabled ?? this.trackerBlockingEnabled,
      httpsUpgradeEnabled: httpsUpgradeEnabled ?? this.httpsUpgradeEnabled,
      javascriptEnabled: javascriptEnabled ?? this.javascriptEnabled,
      popupBlockingEnabled: popupBlockingEnabled ?? this.popupBlockingEnabled,
      doNotTrackEnabled: doNotTrackEnabled ?? this.doNotTrackEnabled,
      cookiePolicy: cookiePolicy ?? this.cookiePolicy,
      themeMode: themeMode ?? this.themeMode,
      showTabBar: showTabBar ?? this.showTabBar,
      enablePullToRefresh: enablePullToRefresh ?? this.enablePullToRefresh,
      enableIncognitoMode: enableIncognitoMode ?? this.enableIncognitoMode,
      homePage: homePage ?? this.homePage,
      antiFingerprinting: antiFingerprinting ?? this.antiFingerprinting,
    );
  }

  Map<String, dynamic> toJson() => {
    'searchEngineId': searchEngineId,
    'adBlockingEnabled': adBlockingEnabled,
    'trackerBlockingEnabled': trackerBlockingEnabled,
    'httpsUpgradeEnabled': httpsUpgradeEnabled,
    'javascriptEnabled': javascriptEnabled,
    'popupBlockingEnabled': popupBlockingEnabled,
    'doNotTrackEnabled': doNotTrackEnabled,
    'cookiePolicy': cookiePolicy.index,
    'themeMode': themeMode.index,
    'showTabBar': showTabBar,
    'enablePullToRefresh': enablePullToRefresh,
    'enableIncognitoMode': enableIncognitoMode,
    'homePage': homePage,
    'antiFingerprinting': antiFingerprinting,
  };

  factory BrowserSettings.fromJson(Map<String, dynamic> json) {
    return BrowserSettings(
      searchEngineId: json['searchEngineId'] as String? ?? 'google',
      adBlockingEnabled: json['adBlockingEnabled'] as bool? ?? true,
      trackerBlockingEnabled: json['trackerBlockingEnabled'] as bool? ?? true,
      httpsUpgradeEnabled: json['httpsUpgradeEnabled'] as bool? ?? true,
      javascriptEnabled: json['javascriptEnabled'] as bool? ?? true,
      popupBlockingEnabled: json['popupBlockingEnabled'] as bool? ?? true,
      doNotTrackEnabled: json['doNotTrackEnabled'] as bool? ?? true,
      cookiePolicy: CookiePolicy.values[json['cookiePolicy'] as int? ?? 1],
      themeMode: ThemeMode.values[json['themeMode'] as int? ?? 0],
      showTabBar: json['showTabBar'] as bool? ?? true,
      enablePullToRefresh: json['enablePullToRefresh'] as bool? ?? true,
      enableIncognitoMode: json['enableIncognitoMode'] as bool? ?? false,
      homePage: json['homePage'] as String? ?? 'about:blank',
      antiFingerprinting: json['antiFingerprinting'] as bool? ?? false,
    );
  }
}

enum CookiePolicy {
  allowAll,
  blockThirdParty,
  blockAll,
}

/// Matches the Flutter ThemeMode values but avoids importing material.
enum ThemeMode {
  system,
  light,
  dark,
}
