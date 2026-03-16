import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_buddy/core/constants/app_constants.dart';
import 'package:web_buddy/features/tabs/domain/browser_session.dart';
import 'package:web_buddy/features/tabs/domain/browser_tab.dart';

/// Provider for the main (normal) browser session.
final browserSessionProvider =
    NotifierProvider<BrowserSessionNotifier, BrowserSession>(
  BrowserSessionNotifier.new,
);

/// Provider for the incognito session.
final incognitoSessionProvider =
    NotifierProvider<IncognitoSessionNotifier, BrowserSession>(
  IncognitoSessionNotifier.new,
);

/// Manages the normal browsing session with multiple tabs.
class BrowserSessionNotifier extends Notifier<BrowserSession> {
  @override
  BrowserSession build() {
    final initialTab = BrowserTab.create();
    return BrowserSession(
      tabs: [initialTab],
      activeTabId: initialTab.id,
    );
  }

  /// Creates a new tab and optionally navigates to a URL.
  String addTab({String? url, bool setActive = true}) {
    if (state.tabCount >= AppConstants.maxTabs) return state.activeTabId ?? '';

    final tab = BrowserTab.create(initialUrl: url);
    final updatedTabs = [...state.tabs, tab];
    state = state.copyWith(
      tabs: updatedTabs,
      activeTabId: setActive ? tab.id : state.activeTabId,
    );
    return tab.id;
  }

  /// Closes a tab by ID.
  void closeTab(String tabId) {
    final tabIndex = state.tabs.indexWhere((t) => t.id == tabId);
    if (tabIndex == -1) return;

    final updatedTabs = List<BrowserTab>.from(state.tabs)..removeAt(tabIndex);

    // If we're closing the active tab, switch to an adjacent one
    String? newActiveId = state.activeTabId;
    if (tabId == state.activeTabId) {
      if (updatedTabs.isEmpty) {
        // Always keep at least one tab
        final newTab = BrowserTab.create();
        updatedTabs.add(newTab);
        newActiveId = newTab.id;
      } else {
        final newIndex = tabIndex >= updatedTabs.length
            ? updatedTabs.length - 1
            : tabIndex;
        newActiveId = updatedTabs[newIndex].id;
      }
    }

    state = state.copyWith(tabs: updatedTabs, activeTabId: newActiveId);
  }

  /// Switches the active tab.
  void setActiveTab(String tabId) {
    if (state.tabs.any((t) => t.id == tabId)) {
      state = state.copyWith(activeTabId: tabId);
    }
  }

  /// Updates a specific tab's state.
  void updateTab(String tabId, BrowserTab Function(BrowserTab) updater) {
    final updatedTabs = state.tabs.map((t) {
      if (t.id == tabId) return updater(t);
      return t;
    }).toList();
    state = state.copyWith(tabs: updatedTabs);
  }

  /// Reorders tabs (for drag-and-drop).
  void reorderTabs(int oldIndex, int newIndex) {
    final tabs = List<BrowserTab>.from(state.tabs);
    final tab = tabs.removeAt(oldIndex);
    tabs.insert(newIndex.clamp(0, tabs.length), tab);
    state = state.copyWith(tabs: tabs);
  }

  /// Closes all tabs and opens one new tab.
  void closeAllTabs() {
    final newTab = BrowserTab.create();
    state = BrowserSession(
      tabs: [newTab],
      activeTabId: newTab.id,
    );
  }

  /// Closes all tabs except the given one.
  void closeOtherTabs(String keepTabId) {
    final tab = state.tabs.where((t) => t.id == keepTabId).toList();
    if (tab.isEmpty) return;
    state = state.copyWith(tabs: tab, activeTabId: keepTabId);
  }

  /// Duplicates a tab.
  String duplicateTab(String tabId) {
    final original = state.tabs.where((t) => t.id == tabId).firstOrNull;
    if (original == null) return '';
    return addTab(url: original.url);
  }
}

/// Incognito session — same behavior but data is never persisted.
class IncognitoSessionNotifier extends Notifier<BrowserSession> {
  @override
  BrowserSession build() {
    return const BrowserSession(isIncognitoSession: true);
  }

  String addTab({String? url, bool setActive = true}) {
    if (state.tabCount >= AppConstants.maxTabs) return state.activeTabId ?? '';

    final tab = BrowserTab.create(isIncognito: true, initialUrl: url);
    final updatedTabs = [...state.tabs, tab];
    state = state.copyWith(
      tabs: updatedTabs,
      activeTabId: setActive ? tab.id : state.activeTabId,
    );
    return tab.id;
  }

  void closeTab(String tabId) {
    final tabIndex = state.tabs.indexWhere((t) => t.id == tabId);
    if (tabIndex == -1) return;

    final updatedTabs = List<BrowserTab>.from(state.tabs)..removeAt(tabIndex);
    String? newActiveId = state.activeTabId;
    if (tabId == state.activeTabId) {
      if (updatedTabs.isEmpty) {
        newActiveId = null;
      } else {
        final newIndex = tabIndex >= updatedTabs.length
            ? updatedTabs.length - 1
            : tabIndex;
        newActiveId = updatedTabs[newIndex].id;
      }
    }
    state = state.copyWith(tabs: updatedTabs, activeTabId: newActiveId);
  }

  void setActiveTab(String tabId) {
    if (state.tabs.any((t) => t.id == tabId)) {
      state = state.copyWith(activeTabId: tabId);
    }
  }

  void updateTab(String tabId, BrowserTab Function(BrowserTab) updater) {
    final updatedTabs = state.tabs.map((t) {
      if (t.id == tabId) return updater(t);
      return t;
    }).toList();
    state = state.copyWith(tabs: updatedTabs);
  }

  /// Destroys all incognito data.
  void endIncognitoSession() {
    state = const BrowserSession(isIncognitoSession: true);
  }
}
