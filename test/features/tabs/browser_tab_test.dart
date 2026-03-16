import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/tabs/domain/browser_tab.dart';
import 'package:web_buddy/features/tabs/domain/browser_session.dart';

void main() {
  group('BrowserTab', () {
    test('create() generates unique IDs', () {
      final tab1 = BrowserTab.create();
      final tab2 = BrowserTab.create();
      expect(tab1.id, isNot(equals(tab2.id)));
    });

    test('create() defaults to about:blank', () {
      final tab = BrowserTab.create();
      expect(tab.url, 'about:blank');
      expect(tab.isNewTab, isTrue);
    });

    test('create() with initial URL', () {
      final tab = BrowserTab.create(initialUrl: 'https://example.com');
      expect(tab.url, 'https://example.com');
      expect(tab.isNewTab, isFalse);
    });

    test('create() incognito flag', () {
      final tab = BrowserTab.create(isIncognito: true);
      expect(tab.isIncognito, isTrue);
    });

    test('copyWith preserves ID', () {
      final tab = BrowserTab.create();
      final updated = tab.copyWith(url: 'https://example.com', title: 'Example');
      expect(updated.id, tab.id);
      expect(updated.url, 'https://example.com');
      expect(updated.title, 'Example');
    });

    test('equality is based on ID', () {
      final tab = BrowserTab.create();
      final copy = tab.copyWith(title: 'Different');
      expect(tab, equals(copy));
    });
  });

  group('BrowserSession', () {
    test('activeTab returns correct tab', () {
      final tab1 = BrowserTab.create();
      final tab2 = BrowserTab.create();
      final session = BrowserSession(
        tabs: [tab1, tab2],
        activeTabId: tab2.id,
      );
      expect(session.activeTab, tab2);
    });

    test('activeTab returns null when no tabs', () {
      const session = BrowserSession();
      expect(session.activeTab, isNull);
    });

    test('tabCount returns correct count', () {
      final session = BrowserSession(
        tabs: [BrowserTab.create(), BrowserTab.create()],
      );
      expect(session.tabCount, 2);
    });

    test('activeTabIndex returns correct index', () {
      final tab1 = BrowserTab.create();
      final tab2 = BrowserTab.create();
      final session = BrowserSession(
        tabs: [tab1, tab2],
        activeTabId: tab2.id,
      );
      expect(session.activeTabIndex, 1);
    });

    test('activeTabIndex returns -1 when no active tab', () {
      const session = BrowserSession();
      expect(session.activeTabIndex, -1);
    });
  });
}
