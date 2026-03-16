import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/privacy/data/private_data_manager.dart';
import 'package:web_buddy/features/tabs/application/tabs_controller.dart';
import 'package:web_buddy/features/tabs/domain/models/browser_tab_state.dart';
import 'package:web_buddy/features/tabs/domain/models/tabs_state.dart';

/// A fake data manager that tracks cleanup calls.
class FakePrivateDataManager extends PrivateDataManager {
  int clearCallCount = 0;

  @override
  Future<void> clearPrivateSessionData({dynamic webViewController}) async {
    clearCallCount++;
  }
}

void main() {
  group('TabsController — private tab behavior', () {
    late TabsController controller;
    late FakePrivateDataManager fakeManager;

    setUp(() {
      fakeManager = FakePrivateDataManager();
      final initial = const BrowserTabState(id: 'tab1');
      controller = TabsController(
        TabsState(tabs: [initial], activeTabId: 'tab1'),
        dataManager: fakeManager,
      );
    });

    test('createNewTab with isPrivate creates a private tab', () {
      controller.createNewTab(isPrivate: true);

      expect(controller.state.tabs.length, 2);
      expect(controller.state.activeTab.isPrivate, isTrue);
    });

    test('hasPrivateTabs returns true when private tab exists', () {
      controller.createNewTab(isPrivate: true);
      expect(controller.state.hasPrivateTabs, isTrue);
    });

    test('hasPrivateTabs returns false when no private tabs', () {
      expect(controller.state.hasPrivateTabs, isFalse);
    });

    test('privateTabCount returns correct count', () {
      controller.createNewTab(isPrivate: true);
      controller.createNewTab(isPrivate: true);
      controller.createNewTab(isPrivate: false);

      expect(controller.state.privateTabCount, 2);
    });

    test('isActiveTabPrivate reflects current tab', () {
      expect(controller.state.isActiveTabPrivate, isFalse);

      controller.createNewTab(isPrivate: true);
      expect(controller.state.isActiveTabPrivate, isTrue);

      controller.switchTab('tab1');
      expect(controller.state.isActiveTabPrivate, isFalse);
    });

    test('closing last private tab triggers session cleanup', () {
      controller.createNewTab(isPrivate: true);
      final privateId = controller.state.tabs.last.id;

      controller.closeTab(privateId);

      expect(fakeManager.clearCallCount, 1);
    });

    test('closing non-last private tab does not trigger cleanup', () {
      controller.createNewTab(isPrivate: true);
      controller.createNewTab(isPrivate: true);
      final firstPrivateId = controller.state.tabs[1].id;

      controller.closeTab(firstPrivateId);

      expect(fakeManager.clearCallCount, 0);
      expect(controller.state.privateTabCount, 1);
    });

    test('closing regular tab does not trigger cleanup', () {
      controller.createNewTab(isPrivate: true);
      controller.closeTab('tab1');

      expect(fakeManager.clearCallCount, 0);
    });

    test('closing the only tab (regular) creates replacement', () {
      controller.closeTab('tab1');

      expect(controller.state.tabs.length, 1);
      expect(controller.state.activeTab.isPrivate, isFalse);
      expect(fakeManager.clearCallCount, 0);
    });

    test('shouldRecordHistory is false for private tabs', () {
      expect(fakeManager.shouldRecordHistory(isPrivate: true), isFalse);
    });

    test('shouldPersistTab is false for private tabs', () {
      expect(fakeManager.shouldPersistTab(isPrivate: true), isFalse);
    });
  });
}
