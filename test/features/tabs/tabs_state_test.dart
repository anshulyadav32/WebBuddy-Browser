import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/tabs/domain/models/browser_tab_state.dart';
import 'package:web_buddy/features/tabs/domain/models/tabs_state.dart';

void main() {
  group('TabsState', () {
    test('activeTab getter returns correct tab', () {
      const tab1 = BrowserTabState(id: '1');
      const tab2 = BrowserTabState(id: '2');

      final state = TabsState(tabs: [tab1, tab2], activeTabId: '2');
      expect(state.activeTab.id, '2');
    });

    test('copyWith updates tabs', () {
      const tab1 = BrowserTabState(id: '1');
      final state = TabsState(tabs: [tab1], activeTabId: '1');

      const tab2 = BrowserTabState(id: '2');
      final updated = state.copyWith(tabs: [tab1, tab2]);

      expect(updated.tabs.length, 2);
      expect(updated.activeTabId, '1');
    });

    test('copyWith updates activeTabId', () {
      const tab1 = BrowserTabState(id: '1');
      const tab2 = BrowserTabState(id: '2');
      final state = TabsState(tabs: [tab1, tab2], activeTabId: '1');

      final updated = state.copyWith(activeTabId: '2');
      expect(updated.activeTabId, '2');
    });

    test('isActiveTabPrivate returns true when active tab is private', () {
      const tab1 = BrowserTabState(id: '1', isPrivate: true);
      final state = TabsState(tabs: [tab1], activeTabId: '1');

      expect(state.isActiveTabPrivate, isTrue);
    });

    test('isActiveTabPrivate returns false when active tab is regular', () {
      const tab1 = BrowserTabState(id: '1');
      final state = TabsState(tabs: [tab1], activeTabId: '1');

      expect(state.isActiveTabPrivate, isFalse);
    });

    test('privateTabCount returns count of private tabs', () {
      const tab1 = BrowserTabState(id: '1');
      const tab2 = BrowserTabState(id: '2', isPrivate: true);
      const tab3 = BrowserTabState(id: '3', isPrivate: true);
      final state = TabsState(tabs: [tab1, tab2, tab3], activeTabId: '1');

      expect(state.privateTabCount, 2);
    });

    test('hasPrivateTabs returns true when private tabs exist', () {
      const tab1 = BrowserTabState(id: '1');
      const tab2 = BrowserTabState(id: '2', isPrivate: true);
      final state = TabsState(tabs: [tab1, tab2], activeTabId: '1');

      expect(state.hasPrivateTabs, isTrue);
    });

    test('hasPrivateTabs returns false when no private tabs', () {
      const tab1 = BrowserTabState(id: '1');
      final state = TabsState(tabs: [tab1], activeTabId: '1');

      expect(state.hasPrivateTabs, isFalse);
    });

    test('equality based on activeTabId and tabs length', () {
      const tab1 = BrowserTabState(id: '1');
      final a = TabsState(tabs: [tab1], activeTabId: '1');
      final b = TabsState(tabs: [tab1], activeTabId: '1');

      expect(a, equals(b));
    });
  });
}
