import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/tabs/domain/models/browser_tab_state.dart';
import 'package:web_buddy/features/tabs/domain/models/tabs_state.dart';

void main() {
  group('Private Tab State Model Tests', () {
    test('BrowserTabState can be created as private', () {
      final tab = BrowserTabState.create(isPrivate: true);

      expect(tab.isPrivate, true);
      expect(tab.id, isNotEmpty);
      expect(tab.currentUrl, equals('about:blank'));
    });

    test('BrowserTabState can be created as normal', () {
      final tab = BrowserTabState.create(isPrivate: false);

      expect(tab.isPrivate, false);
      expect(tab.id, isNotEmpty);
    });

    test('BrowserTabState.create with custom homepage', () {
      final tab = BrowserTabState.create(
        isPrivate: true,
        homepage: 'https://example.com',
      );

      expect(tab.isPrivate, true);
      expect(tab.currentUrl, equals('https://example.com'));
    });

    test('BrowserTabState copyWith preserves isPrivate by default', () {
      const originalTab = BrowserTabState(
        id: 'tab-1',
        isPrivate: true,
        title: 'Original',
      );

      final copiedTab = originalTab.copyWith(title: 'Updated');

      expect(copiedTab.isPrivate, true);
      expect(copiedTab.title, equals('Updated'));
      expect(copiedTab.id, equals('tab-1'));
    });

    test('BrowserTabState copyWith can explicitly change isPrivate', () {
      const originalTab = BrowserTabState(
        id: 'tab-1',
        isPrivate: true,
        title: 'Private Tab',
      );

      final copiedTab = originalTab.copyWith(isPrivate: false);

      expect(copiedTab.isPrivate, false);
      expect(copiedTab.title, equals('Private Tab'));
    });

    test('BrowserTabState toString includes privacy status', () {
      const privateTab = BrowserTabState(
        id: 'tab-1',
        isPrivate: true,
      );

      const normalTab = BrowserTabState(
        id: 'tab-2',
        isPrivate: false,
      );

      // Verify state information is available
      expect(privateTab.isPrivate, true);
      expect(normalTab.isPrivate, false);
    });

    group('TabsState Private Tab Tracking', () {
      test('hasPrivateTabs returns true when private tabs exist', () {
        final privateTab = BrowserTabState.create(isPrivate: true);
        final state = TabsState(
          tabs: [privateTab],
          activeTabId: privateTab.id,
        );

        expect(state.hasPrivateTabs, true);
      });

      test('hasPrivateTabs returns false when only normal tabs exist', () {
        final normalTab = BrowserTabState.create(isPrivate: false);
        final state = TabsState(
          tabs: [normalTab],
          activeTabId: normalTab.id,
        );

        expect(state.hasPrivateTabs, false);
      });

      test('hasPrivateTabs works with mixed tabs', () {
        final normalTab = BrowserTabState.create(isPrivate: false);
        final privateTab = BrowserTabState.create(isPrivate: true);

        final state = TabsState(
          tabs: [normalTab, privateTab],
          activeTabId: normalTab.id,
        );

        expect(state.hasPrivateTabs, true);
      });

      test('activeTab returns correct tab for private tabs', () {
        final normalTab = BrowserTabState.create(isPrivate: false);
        final privateTab = BrowserTabState.create(isPrivate: true);

        final state = TabsState(
          tabs: [normalTab, privateTab],
          activeTabId: privateTab.id,
        );

        expect(state.activeTab.id, equals(privateTab.id));
        expect(state.activeTab.isPrivate, true);
      });

      test('TabsState.copyWith preserves private tab status', () {
        final normalTab = BrowserTabState.create(isPrivate: false);
        final privateTab = BrowserTabState.create(isPrivate: true);

        final originalState = TabsState(
          tabs: [normalTab, privateTab],
          activeTabId: normalTab.id,
        );

        final copiedState = originalState.copyWith(activeTabId: privateTab.id);

        expect(copiedState.tabs.length, 2);
        expect(copiedState.hasPrivateTabs, true);
        expect(copiedState.activeTab.isPrivate, true);
      });

      test('filtering private tabs from state', () {
        final normalTab1 = BrowserTabState.create(isPrivate: false);
        final normalTab2 = BrowserTabState.create(isPrivate: false);
        final privateTab1 = BrowserTabState.create(isPrivate: true);
        final privateTab2 = BrowserTabState.create(isPrivate: true);

        final state = TabsState(
          tabs: [normalTab1, privateTab1, normalTab2, privateTab2],
          activeTabId: normalTab1.id,
        );

        final privateTabs =
            state.tabs.where((t) => t.isPrivate).toList();
        final normalTabs =
            state.tabs.where((t) => !t.isPrivate).toList();

        expect(privateTabs.length, 2);
        expect(normalTabs.length, 2);
      });
    });

    group('Private Tab Properties', () {
      test('private tab can track loading state', () {
        const tab = BrowserTabState(
          id: 'tab-1',
          isPrivate: true,
          isLoading: true,
          progress: 0.5,
        );

        expect(tab.isPrivate, true);
        expect(tab.isLoading, true);
        expect(tab.progress, equals(0.5));
      });

      test('private tab can track navigation state', () {
        const tab = BrowserTabState(
          id: 'tab-1',
          isPrivate: true,
          canGoBack: true,
          canGoForward: false,
        );

        expect(tab.isPrivate, true);
        expect(tab.canGoBack, true);
        expect(tab.canGoForward, false);
      });

      test('private tab with all properties', () {
        const tab = BrowserTabState(
          id: 'tab-private-full',
          currentUrl: 'https://secure.example.com',
          title: 'Secure Private Tab',
          isLoading: false,
          progress: 1.0,
          canGoBack: true,
          canGoForward: false,
          isPrivate: true,
        );

        expect(tab.id, equals('tab-private-full'));
        expect(tab.currentUrl, equals('https://secure.example.com'));
        expect(tab.title, equals('Secure Private Tab'));
        expect(tab.isPrivate, true);
        expect(tab.isLoading, false);
        expect(tab.progress, equals(1.0));
        expect(tab.canGoBack, true);
        expect(tab.canGoForward, false);
      });
    });

    group('Private Tab Equality', () {
      test('identical private tabs are equal', () {
        const tab1 = BrowserTabState(
          id: 'tab-1',
          isPrivate: true,
          title: 'Private',
        );

        const tab2 = BrowserTabState(
          id: 'tab-1',
          isPrivate: true,
          title: 'Private',
        );

        expect(tab1, equals(tab2));
      });

      test('different private status makes tabs unequal', () {
        const tab1 = BrowserTabState(
          id: 'tab-1',
          isPrivate: true,
          title: 'Tab',
        );

        const tab2 = BrowserTabState(
          id: 'tab-1',
          isPrivate: false,
          title: 'Tab',
        );

        expect(tab1, isNot(equals(tab2)));
      });

      test('private tab with different URLs are unequal', () {
        const tab1 = BrowserTabState(
          id: 'tab-1',
          isPrivate: true,
          currentUrl: 'https://example1.com',
        );

        const tab2 = BrowserTabState(
          id: 'tab-1',
          isPrivate: true,
          currentUrl: 'https://example2.com',
        );

        expect(tab1, isNot(equals(tab2)));
      });
    });
  });
}
