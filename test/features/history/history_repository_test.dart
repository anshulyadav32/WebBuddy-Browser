import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_buddy/core/services/storage_service.dart';
import 'package:web_buddy/features/history/data/history_repository.dart';
import 'package:web_buddy/features/history/domain/history_item.dart';

void main() {
  group('HistoryRepository', () {
    late SharedPreferences prefs;
    late HistoryRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      repo = HistoryRepository(StorageService(prefs));
    });

    test('loadAll returns empty list initially', () {
      expect(repo.loadAll(), isEmpty);
    });

    test('save history item and load round-trips', () async {
      final item = HistoryItem(
        id: '1',
        url: 'https://flutter.dev',
        title: 'Flutter',
        visitedAt: DateTime(2025, 1, 1, 10, 0),
      );
      await repo.add(item);

      final loaded = repo.loadAll();
      expect(loaded.length, 1);
      expect(loaded.first.id, '1');
      expect(loaded.first.url, 'https://flutter.dev');
    });

    test('items returned newest first', () async {
      final older = HistoryItem(
        id: '1',
        url: 'https://a.com',
        title: 'A',
        visitedAt: DateTime(2025, 1, 1),
      );
      final newer = HistoryItem(
        id: '2',
        url: 'https://b.com',
        title: 'B',
        visitedAt: DateTime(2025, 1, 2),
      );
      await repo.add(older);
      await repo.add(newer);

      final loaded = repo.loadAll();
      expect(loaded.first.id, '2');
      expect(loaded.last.id, '1');
    });

    test('delete one item', () async {
      final item1 = HistoryItem(
        id: '1',
        url: 'https://a.com',
        title: 'A',
        visitedAt: DateTime(2025, 1, 1),
      );
      final item2 = HistoryItem(
        id: '2',
        url: 'https://b.com',
        title: 'B',
        visitedAt: DateTime(2025, 1, 2),
      );
      await repo.add(item1);
      await repo.add(item2);

      await repo.removeById('1');

      final loaded = repo.loadAll();
      expect(loaded.length, 1);
      expect(loaded.first.id, '2');
    });

    test('clear all items', () async {
      final item = HistoryItem(
        id: '1',
        url: 'https://a.com',
        title: 'A',
        visitedAt: DateTime(2025, 1, 1),
      );
      await repo.add(item);
      await repo.clearAll();

      expect(repo.loadAll(), isEmpty);
    });

    test('loadAll handles corrupt JSON gracefully', () async {
      await prefs.setString('history.items', 'not-json');
      expect(repo.loadAll(), isEmpty);
    });
  });
}
