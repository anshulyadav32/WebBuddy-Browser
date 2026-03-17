import 'package:flutter/foundation.dart';

import 'browser_tab_state.dart';

/// Holds the list of open tabs and which one is active.
class TabsState {
  const TabsState({required this.tabs, required this.activeTabId});

  final List<BrowserTabState> tabs;
  final String activeTabId;

  /// Returns the currently active tab, falling back to the first tab if the
  /// active ID is stale (e.g. after state restoration).
  BrowserTabState get activeTab => tabs.firstWhere(
        (t) => t.id == activeTabId,
        orElse: () => tabs.first,
      );

  /// Whether the active tab is a private tab.
  bool get isActiveTabPrivate => activeTab.isPrivate;

  /// Number of private tabs currently open.
  int get privateTabCount => tabs.where((t) => t.isPrivate).length;

  /// Whether any private tabs are open.
  bool get hasPrivateTabs => tabs.any((t) => t.isPrivate);

  TabsState copyWith({List<BrowserTabState>? tabs, String? activeTabId}) {
    return TabsState(
      tabs: tabs ?? this.tabs,
      activeTabId: activeTabId ?? this.activeTabId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TabsState &&
          activeTabId == other.activeTabId &&
          listEquals(tabs, other.tabs);

  @override
  int get hashCode => Object.hash(activeTabId, Object.hashAll(tabs));

  @override
  String toString() =>
      'TabsState(tabs: ${tabs.length}, activeTabId: $activeTabId)';
}
