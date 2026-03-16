import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/browser_tab_state.dart';
import '../domain/models/tabs_state.dart';

// ── Provider ─────────────────────────────────────────────────────────

final tabsControllerProvider =
    StateNotifierProvider<TabsController, TabsState>((ref) {
  final initial = BrowserTabState.create();
  return TabsController(
    TabsState(tabs: [initial], activeTabId: initial.id),
  );
});

// ── Controller ───────────────────────────────────────────────────────

class TabsController extends StateNotifier<TabsState> {
  TabsController(super.state);

  /// Opens a new tab and makes it active.
  void createNewTab({bool isPrivate = false}) {
    final tab = BrowserTabState.create(isPrivate: isPrivate);
    state = state.copyWith(
      tabs: [...state.tabs, tab],
      activeTabId: tab.id,
    );
  }

  /// Switches to the tab with [tabId].
  void switchTab(String tabId) {
    if (state.tabs.any((t) => t.id == tabId)) {
      state = state.copyWith(activeTabId: tabId);
    }
  }

  /// Closes the tab with [tabId].
  /// If it was the active tab, selects an adjacent tab.
  /// If it was the last tab, creates a replacement.
  void closeTab(String tabId) {
    final index = state.tabs.indexWhere((t) => t.id == tabId);
    if (index == -1) return;

    final remaining = [...state.tabs]..removeAt(index);

    // If no tabs left, create a replacement.
    if (remaining.isEmpty) {
      final replacement = BrowserTabState.create();
      state = TabsState(
        tabs: [replacement],
        activeTabId: replacement.id,
      );
      return;
    }

    // If we closed the active tab, pick a neighbour.
    String newActiveId = state.activeTabId;
    if (tabId == state.activeTabId) {
      final newIndex = index.clamp(0, remaining.length - 1);
      newActiveId = remaining[newIndex].id;
    }

    state = TabsState(tabs: remaining, activeTabId: newActiveId);
  }

  /// Updates the currently active tab's metadata.
  void updateActiveTab({
    String? currentUrl,
    String? title,
    bool? isLoading,
    double? progress,
    bool? canGoBack,
    bool? canGoForward,
  }) {
    final updated = state.tabs.map((t) {
      if (t.id != state.activeTabId) return t;
      return t.copyWith(
        currentUrl: currentUrl,
        title: title,
        isLoading: isLoading,
        progress: progress,
        canGoBack: canGoBack,
        canGoForward: canGoForward,
      );
    }).toList();

    state = state.copyWith(tabs: updated);
  }
}
