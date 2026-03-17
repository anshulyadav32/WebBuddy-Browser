import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:web_buddy/core/services/storage_service.dart';
import 'package:web_buddy/features/offline/data/offline_pages_repository.dart';
import 'package:web_buddy/features/offline/domain/offline_page.dart';

void main() {
  group('OfflinePagesRepository', () {
    late OfflinePagesRepository repo;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      repo = OfflinePagesRepository(StorageService(prefs));
    });

    test('loadAll returns empty by default', () {
      expect(repo.loadAll(), isEmpty);
    });

    test('saveAll then loadAll round-trips values', () async {
      final pages = [
        OfflinePage(
          id: '1',
          url: 'https://example.com',
          title: 'Example',
          filePath: '/tmp/example.html',
          savedAt: DateTime(2026, 1, 1),
        ),
      ];

      await repo.saveAll(pages);
      final loaded = repo.loadAll();

      expect(loaded, pages);
    });

    test('clearAll removes persisted pages', () async {
      await repo.saveAll([
        OfflinePage(
          id: '1',
          url: 'https://example.com',
          title: 'Example',
          filePath: '/tmp/example.html',
          savedAt: DateTime(2026, 1, 1),
        ),
      ]);

      await repo.clearAll();
      expect(repo.loadAll(), isEmpty);
    });

    test('loadAll handles corrupt JSON', () async {
      await prefs.setString('offline.pages', 'corrupt json');
      expect(repo.loadAll(), isEmpty);
    });
  });
}
