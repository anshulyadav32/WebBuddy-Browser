import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_buddy/core/services/storage_service.dart';
import 'package:web_buddy/features/bookmarks/data/bookmarks_repository.dart';
import 'package:web_buddy/features/bookmarks/domain/bookmark.dart';

void main() {
  group('BookmarksRepository', () {
    late SharedPreferences prefs;
    late BookmarksRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      repo = BookmarksRepository(StorageService(prefs));
    });

    test('loadAll returns empty list initially', () {
      expect(repo.loadAll(), isEmpty);
    });

    test('save bookmark and load round-trips', () async {
      final bookmark = Bookmark(
        id: '1',
        url: 'https://flutter.dev',
        title: 'Flutter',
        createdAt: DateTime(2025, 1, 1),
      );
      await repo.add(bookmark);

      final loaded = repo.loadAll();
      expect(loaded.length, 1);
      expect(loaded.first.id, '1');
      expect(loaded.first.url, 'https://flutter.dev');
      expect(loaded.first.title, 'Flutter');
    });

    test('getAllBookmarks returns persisted items (Phase 4 API)', () async {
      final bookmark = Bookmark(
        id: '1',
        url: 'https://flutter.dev',
        title: 'Flutter',
        createdAt: DateTime(2025, 1, 1),
      );
      await repo.saveBookmark(bookmark);

      final loaded = await repo.getAllBookmarks();
      expect(loaded.length, 1);
      expect(loaded.first.url, 'https://flutter.dev');
    });

    test('remove bookmark by URL', () async {
      final b1 = Bookmark(
        id: '1',
        url: 'https://flutter.dev',
        title: 'Flutter',
        createdAt: DateTime(2025, 1, 1),
      );
      final b2 = Bookmark(
        id: '2',
        url: 'https://dart.dev',
        title: 'Dart',
        createdAt: DateTime(2025, 1, 2),
      );
      await repo.add(b1);
      await repo.add(b2);

      await repo.removeByUrl('https://flutter.dev');

      final loaded = repo.loadAll();
      expect(loaded.length, 1);
      expect(loaded.first.url, 'https://dart.dev');
    });

    test('deleteBookmark removes by URL (Phase 4 API)', () async {
      final bookmark = Bookmark(
        id: '1',
        url: 'https://flutter.dev',
        title: 'Flutter',
        createdAt: DateTime(2025, 1, 1),
      );
      await repo.saveBookmark(bookmark);
      await repo.deleteBookmark('https://flutter.dev');

      expect(repo.loadAll(), isEmpty);
    });

    test('duplicate URL handling replaces existing bookmark', () async {
      final b1 = Bookmark(
        id: '1',
        url: 'https://flutter.dev',
        title: 'Flutter',
        createdAt: DateTime(2025, 1, 1),
      );
      final b2 = Bookmark(
        id: '2',
        url: 'https://flutter.dev',
        title: 'Flutter Updated',
        createdAt: DateTime(2025, 1, 2),
      );
      await repo.add(b1);
      await repo.add(b2);

      final loaded = repo.loadAll();
      expect(loaded.length, 1);
      expect(loaded.first.title, 'Flutter Updated');
    });

    test('isBookmarked returns true for saved URL', () async {
      final bookmark = Bookmark(
        id: '1',
        url: 'https://flutter.dev',
        title: 'Flutter',
        createdAt: DateTime(2025, 1, 1),
      );
      await repo.add(bookmark);

      expect(repo.isBookmarked('https://flutter.dev'), isTrue);
    });

    test('exists returns true for saved URL (Phase 4 API)', () async {
      final bookmark = Bookmark(
        id: '1',
        url: 'https://flutter.dev',
        title: 'Flutter',
        createdAt: DateTime(2025, 1, 1),
      );
      await repo.saveBookmark(bookmark);

      expect(await repo.exists('https://flutter.dev'), isTrue);
    });

    test('isBookmarked returns false for unknown URL', () {
      expect(repo.isBookmarked('https://unknown.com'), isFalse);
    });

    test('clearAll removes all bookmarks', () async {
      final b1 = Bookmark(
        id: '1',
        url: 'https://flutter.dev',
        title: 'Flutter',
        createdAt: DateTime(2025, 1, 1),
      );
      await repo.add(b1);
      await repo.clearAll();

      expect(repo.loadAll(), isEmpty);
    });

    test('loadAll handles corrupt JSON gracefully', () async {
      await prefs.setString('bookmarks.items', 'not-json');
      expect(repo.loadAll(), isEmpty);
    });
  });
}
