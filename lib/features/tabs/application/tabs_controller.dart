import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../privacy/data/private_data_manager.dart';
import '../../privacy/presentation/privacy_controller.dart';
import '../domain/models/browser_tab_state.dart';
import '../domain/models/tabs_state.dart';

// ── Provider ─────────────────────────────────────────────────────────

final tabsControllerProvider = StateNotifierProvider<TabsController, TabsState>(
  (ref) {
    final initial = BrowserTabState.create();
    final dataManager = ref.watch(privateDataManagerProvider);
    return TabsController(
      TabsState(tabs: [initial], activeTabId: initial.id),
      dataManager: dataManager,
    );
  },
);

// ── Controller ───────────────────────────────────────────────────────

class TabsController extends StateNotifier<TabsState> {
  TabsController(super.state, {PrivateDataManager? dataManager})
    : _dataManager = dataManager;

  final PrivateDataManager? _dataManager;

  /// Opens a new tab.
  ///
  /// If [makeActive] is true, the new/existing tab becomes active.
  /// If [makeActive] is false, the tab opens in the background.
  void createNewTab({
    bool isPrivate = false,
    String? url,
    String? groupId,
    bool makeActive = true,
  }) {
    // Only dedupe when caller explicitly requests a URL.
    if (url != null && url.isNotEmpty) {
      final existing = state.tabs
          .where(
            (t) =>
                t.currentUrl == url &&
                t.isPrivate == isPrivate &&
                t.groupId == groupId,
          )
          .toList();
      if (existing.isNotEmpty) {
        if (makeActive) {
          state = state.copyWith(activeTabId: existing.first.id);
        }
        return;
      }
    }

    final tab = BrowserTabState.create(
      isPrivate: isPrivate,
      homepage: url ?? 'about:blank',
      groupId: isPrivate ? null : groupId,
    );
    state = state.copyWith(
      tabs: [...state.tabs, tab],
      activeTabId: makeActive ? tab.id : state.activeTabId,
    );
  }

  /// Creates a tab group and optionally assigns a tab to it.
  String createGroup(String name, {String? tabId}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';

    final existingEntry = state.groupNames.entries
        .where((e) => e.value.toLowerCase() == trimmed.toLowerCase())
        .toList();
    final groupId = existingEntry.isNotEmpty
        ? existingEntry.first.key
        : const Uuid().v4();

    final updatedGroups = {...state.groupNames, groupId: trimmed};

    var updatedTabs = state.tabs;
    if (tabId != null) {
      updatedTabs = state.tabs.map((t) {
        if (t.id != tabId || t.isPrivate) return t;
        return t.copyWith(groupId: groupId);
      }).toList();
    }

    state = state.copyWith(tabs: updatedTabs, groupNames: updatedGroups);
    return groupId;
  }

  /// Renames an existing tab group.
  void renameGroup(String groupId, String name) {
    if (!state.groupNames.containsKey(groupId)) return;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    state = state.copyWith(groupNames: {...state.groupNames, groupId: trimmed});
  }

  /// Assigns a non-private tab to an existing group.
  void addTabToGroup(String tabId, String groupId) {
    if (!state.groupNames.containsKey(groupId)) return;
    final updatedTabs = state.tabs.map((t) {
      if (t.id != tabId || t.isPrivate) return t;
      return t.copyWith(groupId: groupId);
    }).toList();
    state = state.copyWith(tabs: updatedTabs);
  }

  /// Removes a tab from its group.
  void removeTabFromGroup(String tabId) {
    final updatedTabs = state.tabs.map((t) {
      if (t.id != tabId) return t;
      return t.copyWith(clearGroup: true);
    }).toList();
    state = state.copyWith(tabs: updatedTabs);
    _cleanupEmptyGroups();
  }

  /// Assigns a tab to a group by name, creating group if needed.
  void groupTabByName(String tabId, String groupName) {
    final groupId = createGroup(groupName, tabId: tabId);
    if (groupId.isEmpty) return;
    addTabToGroup(tabId, groupId);
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
  /// Triggers private session cleanup when the last private tab closes.
  void closeTab(String tabId) {
    final index = state.tabs.indexWhere((t) => t.id == tabId);
    if (index == -1) return;

    final closedTab = state.tabs[index];
    final remaining = [...state.tabs]..removeAt(index);

    // If no tabs left, create a replacement.
    if (remaining.isEmpty) {
      final replacement = BrowserTabState.create();
      state = TabsState(tabs: [replacement], activeTabId: replacement.id);
      _checkPrivateSessionEnd(closedTab);
      return;
    }

    // If we closed the active tab, pick a neighbour.
    String newActiveId = state.activeTabId;
    if (tabId == state.activeTabId) {
      final newIndex = index.clamp(0, remaining.length - 1);
      newActiveId = remaining[newIndex].id;
    }

    state = TabsState(tabs: remaining, activeTabId: newActiveId);
    _checkPrivateSessionEnd(closedTab);
    _cleanupEmptyGroups();
  }

  /// If the closed tab was private and no private tabs remain, clean up.
  void _checkPrivateSessionEnd(BrowserTabState closedTab) {
    if (closedTab.isPrivate && !state.hasPrivateTabs) {
      _dataManager?.clearPrivateSessionData();
    }
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

  /// Removes group metadata that no longer has tabs assigned.
  void _cleanupEmptyGroups() {
    final usedGroupIds = state.tabs
        .where((t) => t.groupId != null && !t.isPrivate)
        .map((t) => t.groupId!)
        .toSet();

    final cleaned = Map<String, String>.fromEntries(
      state.groupNames.entries.where(
        (entry) => usedGroupIds.contains(entry.key),
      ),
    );

    if (cleaned.length != state.groupNames.length) {
      state = state.copyWith(groupNames: cleaned);
    }
  }
}
