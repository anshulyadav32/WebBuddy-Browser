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
  });
}
