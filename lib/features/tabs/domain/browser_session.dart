import 'package:web_buddy/features/tabs/domain/browser_tab.dart';

/// Represents the complete browser session state.
class BrowserSession {
  final List<BrowserTab> tabs;
  final String? activeTabId;
  final bool isIncognitoSession;

  const BrowserSession({
    this.tabs = const [],
    this.activeTabId,
    this.isIncognitoSession = false,
  });

  BrowserTab? get activeTab {
    if (activeTabId == null) return null;
    try {
      return tabs.firstWhere((t) => t.id == activeTabId);
    } catch (_) {
      return tabs.isNotEmpty ? tabs.first : null;
    }
  }

  int get tabCount => tabs.length;

  int get activeTabIndex {
    if (activeTabId == null) return -1;
    return tabs.indexWhere((t) => t.id == activeTabId);
  }

  BrowserSession copyWith({
    List<BrowserTab>? tabs,
    String? activeTabId,
    bool? isIncognitoSession,
  }) {
    return BrowserSession(
      tabs: tabs ?? this.tabs,
      activeTabId: activeTabId ?? this.activeTabId,
      isIncognitoSession: isIncognitoSession ?? this.isIncognitoSession,
    );
  }
}
