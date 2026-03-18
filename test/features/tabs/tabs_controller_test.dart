import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/tabs/application/tabs_controller.dart';
import 'package:web_buddy/features/tabs/domain/models/browser_tab_state.dart';
import 'package:web_buddy/features/tabs/domain/models/tabs_state.dart';

void main() {
  group('TabsController Tests', () {
    late TabsController controller;
    late BrowserTabState initialTab;

    setUp(() {
      initialTab = const BrowserTabState(
        id: 'tab1',
        currentUrl: 'https://flutter.dev',
      );

      controller = TabsController(
        TabsState(tabs: [initialTab], activeTabId: initialTab.id),
      );
    });

    test('Initial state has one tab', () {
      expect(controller.state.tabs.length, 1);
      expect(controller.state.activeTabId, 'tab1');
    });

    test('createNewTab adds tab and makes it active', () {
      controller.createNewTab();

      expect(controller.state.tabs.length, 2);
      expect(controller.state.activeTabId, controller.state.tabs.last.id);
    });

    test('createNewTab can open in background', () {
      controller.createNewTab(url: 'https://example.com', makeActive: false);

      expect(controller.state.tabs.length, 2);
      expect(controller.state.activeTabId, 'tab1');
      expect(
        controller.state.tabs.any((t) => t.currentUrl == 'https://example.com'),
        true,
      );
    });

    test('switchTab changes active tab', () {
      controller.createNewTab();
      final newTabId = controller.state.tabs.last.id;

      controller.switchTab('tab1');

      expect(controller.state.activeTabId, 'tab1');
      expect(newTabId != 'tab1', true);
    });

    test('closeTab removes tab', () {
      controller.createNewTab();
      final newTabId = controller.state.tabs.last.id;

      controller.closeTab(newTabId);

      expect(controller.state.tabs.length, 1);
    });

    test('closing active tab selects another tab', () {
      controller.createNewTab();
      final newTabId = controller.state.tabs.last.id;

      controller.closeTab(newTabId);

      expect(controller.state.activeTabId, 'tab1');
    });

    test('closing last tab creates replacement tab', () {
      controller.closeTab('tab1');

      expect(controller.state.tabs.length, 1);
      expect(controller.state.activeTabId, controller.state.tabs.first.id);
    });

    test('updateActiveTab updates title and url', () {
      controller.updateActiveTab(
        title: 'Flutter Docs',
        currentUrl: 'https://docs.flutter.dev',
      );

      final tab = controller.state.activeTab;

      expect(tab.title, 'Flutter Docs');
      expect(tab.currentUrl, 'https://docs.flutter.dev');
    });

    test('private tab created correctly', () {
      controller.createNewTab(isPrivate: true);

      expect(controller.state.activeTab.isPrivate, true);
    });

    group('Private Tab Tests', () {
      test('multiple private tabs can be created', () {
        controller.createNewTab(isPrivate: true);
        controller.createNewTab(isPrivate: true);

        expect(controller.state.tabs.length, 3);
        expect(controller.state.tabs.where((t) => t.isPrivate).length, 2);
      });

      test('hasPrivateTabs returns true when private tabs exist', () {
        controller.createNewTab(isPrivate: true);

        expect(controller.state.hasPrivateTabs, true);
      });

      test('hasPrivateTabs returns false when no private tabs exist', () {
        expect(controller.state.hasPrivateTabs, false);
      });

      test('can switch between private and normal tabs', () {
        controller.createNewTab(isPrivate: true);
        final privateTabId = controller.state.activeTab.id;

        controller.createNewTab(isPrivate: false);
        final normalTabId = controller.state.activeTab.id;

        expect(controller.state.activeTab.isPrivate, false);

        controller.switchTab(privateTabId);

        expect(controller.state.activeTab.isPrivate, true);

        controller.switchTab(normalTabId);

        expect(controller.state.activeTab.isPrivate, false);
      });

      test('private tab with custom URL is created correctly', () {
        controller.createNewTab(
          isPrivate: true,
          url: 'https://private.example.com',
        );

        final activeTab = controller.state.activeTab;

        expect(activeTab.isPrivate, true);
        expect(activeTab.currentUrl, 'https://private.example.com');
      });

      test('closing all private tabs removes them from tabs list', () {
        controller.createNewTab(isPrivate: true);
        final privateTab1 = controller.state.activeTab.id;

        controller.createNewTab(isPrivate: true);
        final privateTab2 = controller.state.activeTab.id;

        controller.closeTab(privateTab1);
        controller.closeTab(privateTab2);

        expect(controller.state.hasPrivateTabs, false);
        expect(controller.state.tabs.length, 1);
      });

      test('closing one private tab keeps others intact', () {
        controller.createNewTab(isPrivate: true);
        final privateTab1 = controller.state.activeTab.id;

        controller.createNewTab(isPrivate: true);
        final privateTab2 = controller.state.activeTab.id;

        controller.closeTab(privateTab1);

        expect(controller.state.hasPrivateTabs, true);
        expect(controller.state.tabs.any((t) => t.id == privateTab2), true);
      });

      test(
        'closing private tab when active switches to another available tab',
        () {
          controller.createNewTab(isPrivate: true);
          final privateTabId = controller.state.activeTab.id;

          expect(controller.state.activeTabId, privateTabId);

          controller.closeTab(privateTabId);

          expect(controller.state.activeTabId, 'tab1');
        },
      );

      test('private tab deduplication works correctly', () {
        controller.createNewTab(isPrivate: true, url: 'https://same.com');
        final firstTabId = controller.state.activeTab.id;

        // Try to create same private tab - should switch to existing
        controller.createNewTab(isPrivate: true, url: 'https://same.com');

        expect(controller.state.activeTabId, firstTabId);
        expect(controller.state.tabs.length, 2); // Still 2 tabs total
      });

      test('background dedupe keeps current active tab', () {
        controller.createNewTab(isPrivate: true, url: 'https://same.com');
        final privateTabId = controller.state.activeTab.id;
        controller.switchTab('tab1');

        controller.createNewTab(
          isPrivate: true,
          url: 'https://same.com',
          makeActive: false,
        );

        expect(controller.state.tabs.length, 2);
        expect(controller.state.activeTabId, 'tab1');
        expect(controller.state.tabs.any((t) => t.id == privateTabId), true);
      });

      test('private and normal tabs with same URL are separate', () {
        const url = 'https://example.com';

        controller.createNewTab(isPrivate: false, url: url);
        final normalTabId = controller.state.activeTab.id;

        controller.createNewTab(isPrivate: true, url: url);
        final privateTabId = controller.state.activeTab.id;

        expect(normalTabId, isNot(privateTabId));
        expect(
          controller.state.tabs.where((t) => t.currentUrl == url).length,
          2,
        );
      });

      test('private tab properties can be updated', () {
        controller.createNewTab(isPrivate: true);

        controller.updateActiveTab(
          title: 'Private Search',
          currentUrl: 'https://private-search.com',
          isLoading: true,
        );

        final updatedTab = controller.state.activeTab;

        expect(updatedTab.isPrivate, true);
        expect(updatedTab.title, 'Private Search');
        expect(updatedTab.currentUrl, 'https://private-search.com');
        expect(updatedTab.isLoading, true);
      });

      test('normal tab remains normal after updates', () {
        controller.updateActiveTab(
          title: 'Normal Tab',
          currentUrl: 'https://normal.com',
        );

        expect(controller.state.activeTab.isPrivate, false);
      });

      test('restoring should preserve private tab flag', () {
        controller.createNewTab(isPrivate: true);
        final privateTab = controller.state.activeTab;

        final restoredTab = privateTab.copyWith(
          currentUrl: 'https://new-url.com',
        );

        expect(restoredTab.isPrivate, true);
        expect(restoredTab.currentUrl, 'https://new-url.com');
      });
    });
  });
}
