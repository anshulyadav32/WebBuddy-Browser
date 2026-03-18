import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/tabs/application/tabs_controller.dart';
import 'package:web_buddy/features/tabs/domain/models/browser_tab_state.dart';
import 'package:web_buddy/features/tabs/domain/models/tabs_state.dart';

void main() {
  group('TabsController group management', () {
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

    test('createGroup creates a group and assigns tab', () {
      final groupId = controller.createGroup('Work', tabId: 'tab1');

      expect(groupId.isNotEmpty, isTrue);
      expect(controller.state.groupNames[groupId], 'Work');
      expect(controller.state.tabs.first.groupId, groupId);
    });

    test('groupTabByName reuses existing group id for same name', () {
      final first = controller.createGroup('Work');
      controller.createNewTab(url: 'https://dart.dev');
      final secondTabId = controller.state.activeTabId;

      controller.groupTabByName(secondTabId, 'Work');

      expect(controller.state.groupNames.length, 1);
      expect(controller.state.tabs.where((t) => t.groupId == first).length, 1);
    });

    test('removeTabFromGroup ungroups tab', () {
      final groupId = controller.createGroup('Research', tabId: 'tab1');
      expect(controller.state.tabs.first.groupId, groupId);

      controller.removeTabFromGroup('tab1');

      expect(controller.state.tabs.first.groupId, isNull);
      expect(controller.state.groupNames, isEmpty);
    });

    test('private tabs are not assigned to groups', () {
      controller.createNewTab(isPrivate: true, url: 'https://private.example');
      final privateTabId = controller.state.activeTabId;
      final groupId = controller.createGroup('Secret', tabId: privateTabId);

      final privateTab = controller.state.tabs.firstWhere(
        (t) => t.id == privateTabId,
      );
      expect(privateTab.isPrivate, isTrue);
      expect(privateTab.groupId, isNull);
      expect(controller.state.groupNames[groupId], 'Secret');
    });

    test('closing last tab in group removes empty group metadata', () {
      final groupId = controller.createGroup('Work', tabId: 'tab1');
      expect(controller.state.groupNames.containsKey(groupId), isTrue);

      controller.closeTab('tab1');

      expect(controller.state.groupNames.containsKey(groupId), isFalse);
    });
  });
}
