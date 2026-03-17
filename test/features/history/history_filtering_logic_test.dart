import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_buddy/core/services/storage_service.dart';
import 'package:web_buddy/features/history/data/history_repository.dart';
import 'package:web_buddy/features/history/domain/history_item.dart';
import 'package:web_buddy/features/privacy/data/private_data_manager.dart';

/// Tests for history filtering, ordering, and private-mode exclusion.
void main() {
  late StorageService storage;
  late HistoryRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storage = StorageService(prefs);
    repo = HistoryRepository(storage);
  });

  group('History filtering and ordering', () {
    test('loadAll returns items in newest-first order', () async {
      final older = HistoryItem(
        id: '1',
        url: 'https://old.com',
        title: 'Old',
        visitedAt: DateTime(2024, 1, 1),
      );
      final newer = HistoryItem(
        id: '2',
        url: 'https://new.com',
        title: 'New',
        visitedAt: DateTime(2024, 6, 1),
      );

      await repo.add(older);
      await repo.add(newer);

      final items = repo.loadAll();
      expect(items.first.id, '2'); // newer first
      expect(items.last.id, '1');
    });

    test('internal blank pages can be identified', () {
      const blankUrls = ['about:blank', '', 'about:newtab'];

      for (final url in blankUrls) {
        final isInternal = url.isEmpty ||
            url.startsWith('about:');
        expect(isInternal, isTrue, reason: 'Expected $url to be internal');
      }
    });

    test('private pages excluded via PrivateDataManager', () {
      final manager = PrivateDataManager();

      expect(manager.shouldRecordHistory(isPrivate: true), isFalse);
      expect(manager.shouldRecordHistory(isPrivate: false), isTrue);
    });

    test('empty history returns empty list', () {
      expect(repo.loadAll(), isEmpty);
    });

    test('clearAll leaves empty list', () async {
      final item = HistoryItem(
        id: '1',
        url: 'https://example.com',
        title: 'Example',
        visitedAt: DateTime.now(),
      );
      await repo.add(item);
      await repo.clearAll();

      expect(repo.loadAll(), isEmpty);
    });

    test('duplicate URLs are not suppressed at repository level', () async {
      // Repository doesn't de-duplicate — each add creates a new entry
      final item1 = HistoryItem(
        id: '1',
        url: 'https://example.com',
        title: 'First visit',
        visitedAt: DateTime(2024, 1, 1),
      );
      final item2 = HistoryItem(
        id: '2',
        url: 'https://example.com',
        title: 'Second visit',
        visitedAt: DateTime(2024, 1, 2),
      );

      await repo.add(item1);
      await repo.add(item2);

      expect(repo.loadAll().length, 2);
    });
  });
}
