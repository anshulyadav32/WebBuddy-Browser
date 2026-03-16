import 'browser_tab_state.dart';

/// Holds the list of open tabs and which one is active.
class TabsState {
  const TabsState({
    required this.tabs,
    required this.activeTabId,
  });

  final List<BrowserTabState> tabs;
  final String activeTabId;

  /// Returns the currently active tab.
  BrowserTabState get activeTab =>
      tabs.firstWhere((t) => t.id == activeTabId);

  TabsState copyWith({
    List<BrowserTabState>? tabs,
    String? activeTabId,
  }) {
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
          tabs.length == other.tabs.length;

  @override
  int get hashCode => Object.hash(activeTabId, tabs.length);

  @override
  String toString() =>
      'TabsState(tabs: ${tabs.length}, activeTabId: $activeTabId)';
}
