import 'package:flutter/foundation.dart';

import 'browser_tab_state.dart';

/// Holds the list of open tabs and which one is active.
class TabsState {
  const TabsState({
    required this.tabs,
    required this.activeTabId,
    this.groupNames = const {},
  });

  final List<BrowserTabState> tabs;
  final String activeTabId;
  final Map<String, String> groupNames;

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

  /// Tabs grouped by group id (private tabs excluded).
  Map<String, List<BrowserTabState>> get groupedTabs {
    final grouped = <String, List<BrowserTabState>>{};
    for (final tab in tabs) {
      if (tab.isPrivate || tab.groupId == null) continue;
      grouped.putIfAbsent(tab.groupId!, () => []).add(tab);
    }
    return grouped;
  }

  /// Regular tabs with no group assignment.
  List<BrowserTabState> get ungroupedRegularTabs =>
      tabs.where((t) => !t.isPrivate && t.groupId == null).toList();

  /// Private tabs are intentionally separate from group management.
  List<BrowserTabState> get privateTabs => tabs.where((t) => t.isPrivate).toList();

  TabsState copyWith({
    List<BrowserTabState>? tabs,
    String? activeTabId,
    Map<String, String>? groupNames,
  }) {
    return TabsState(
      tabs: tabs ?? this.tabs,
      activeTabId: activeTabId ?? this.activeTabId,
      groupNames: groupNames ?? this.groupNames,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TabsState &&
          activeTabId == other.activeTabId &&
          mapEquals(groupNames, other.groupNames) &&
          listEquals(tabs, other.tabs);

  @override
      int get hashCode =>
        Object.hash(activeTabId, Object.hashAll(tabs), Object.hashAll(groupNames.entries));

  @override
  String toString() =>
      'TabsState(tabs: ${tabs.length}, activeTabId: $activeTabId)';
}
