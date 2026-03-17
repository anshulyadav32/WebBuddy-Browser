import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/tabs/domain/models/browser_tab_state.dart';
import 'package:web_buddy/features/tabs/domain/models/tabs_state.dart';
import 'package:web_buddy/features/tabs/application/tabs_controller.dart';

/// Tests for tab restoration logic and session persistence rules.
void main() {
  group('Tab restoration logic', () {
    test('last selected tab ID is tracked in state', () {
      final tab1 = const BrowserTabState(id: 'tab1');
      final tab2 = const BrowserTabState(id: 'tab2');

      final controller = TabsController(
        TabsState(tabs: [tab1, tab2], activeTabId: 'tab1'),
      );

      controller.switchTab('tab2');
      expect(controller.state.activeTabId, 'tab2');
    });

    test('private tabs can be identified for exclusion', () {
      final normal = const BrowserTabState(id: 'n1');
      final private = const BrowserTabState(id: 'p1', isPrivate: true);

      final state = TabsState(tabs: [normal, private], activeTabId: 'n1');

      final nonPrivateTabs = state.tabs.where((t) => !t.isPrivate).toList();
      expect(nonPrivateTabs.length, 1);
      expect(nonPrivateTabs.first.id, 'n1');
    });

    test('private tab count tracks correctly', () {
      final tab1 = const BrowserTabState(id: 'n1');
      final controller = TabsController(
        TabsState(tabs: [tab1], activeTabId: 'n1'),
      );

      controller.createNewTab(isPrivate: true);
      controller.createNewTab(isPrivate: true);

      expect(controller.state.privateTabCount, 2);
    });

    test('hasPrivateTabs is false when only normal tabs exist', () {
      final tab1 = const BrowserTabState(id: 'n1');
      final state = TabsState(tabs: [tab1], activeTabId: 'n1');

      expect(state.hasPrivateTabs, isFalse);
    });

    test('hasPrivateTabs is true when private tabs exist', () {
      final tab1 = const BrowserTabState(id: 'n1');
      final tab2 = const BrowserTabState(id: 'p1', isPrivate: true);
      final state = TabsState(tabs: [tab1, tab2], activeTabId: 'n1');

      expect(state.hasPrivateTabs, isTrue);
    });
  });
}
