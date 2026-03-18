import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_buddy/core/services/storage_service.dart';
import 'package:web_buddy/features/bookmarks/data/bookmarks_repository.dart';
import 'package:web_buddy/features/bookmarks/domain/bookmark.dart';
import 'package:web_buddy/features/bookmarks/presentation/bookmarks_controller.dart';

void main() {
  group('BookmarksController', () {
    late BookmarksRepository repo;
    late BookmarksController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repo = BookmarksRepository(StorageService(prefs));
      controller = BookmarksController(repo);
    });

    test('initial state is empty', () {
      expect(controller.state, isEmpty);
    });

    test('loadBookmarks returns data from repo', () async {
      final bookmark = Bookmark(
        id: '1',
        url: 'https://flutter.dev',
        title: 'Flutter',
        createdAt: DateTime(2025, 1, 1),
      );
      await repo.add(bookmark);

      await controller.loadBookmarks();

      expect(controller.state.length, 1);
      expect(controller.state.first.url, 'https://flutter.dev');
    });

    test('toggleBookmark adds when absent', () async {
      await controller.toggleBookmark(
        url: 'https://flutter.dev',
        title: 'Flutter',
      );

      expect(controller.state.length, 1);
      expect(controller.state.first.url, 'https://flutter.dev');
      expect(controller.state.first.title, 'Flutter');
    });

    test('toggleBookmark removes when present', () async {
      await controller.toggleBookmark(
        url: 'https://flutter.dev',
        title: 'Flutter',
      );
      expect(controller.state.length, 1);

      await controller.toggleBookmark(
        url: 'https://flutter.dev',
        title: 'https://flutter.dev',
      );
      expect(controller.state, isEmpty);
    });

    test('title fallback uses URL when title is empty', () async {
      await controller.toggleBookmark(url: 'https://flutter.dev', title: '');

      expect(controller.state.first.title, 'https://flutter.dev');
    });

    test('title fallback uses URL when title is null', () async {
      await controller.toggleBookmark(
        url: 'https://flutter.dev',
        title: 'https://flutter.dev',
      );

      expect(controller.state.first.title, 'https://flutter.dev');
    });

    test('isBookmarked returns true for existing bookmark', () async {
      await controller.toggleBookmark(
        url: 'https://flutter.dev',
        title: 'Flutter',
      );

      expect(await controller.isBookmarked('https://flutter.dev'), isTrue);
    });

    test('isBookmarked returns false for non-existing bookmark', () async {
      expect(await controller.isBookmarked('https://unknown.com'), isFalse);
    });

    test('removeBookmark removes specific bookmark', () async {
      await controller.toggleBookmark(
        url: 'https://flutter.dev',
        title: 'Flutter',
      );
      await controller.toggleBookmark(url: 'https://dart.dev', title: 'Dart');
      expect(controller.state.length, 2);

      await controller.removeBookmarkByUrl('https://flutter.dev');

      expect(controller.state.length, 1);
      expect(controller.state.first.url, 'https://dart.dev');
    });

    test('clearAll empties state', () async {
      await controller.toggleBookmark(
        url: 'https://flutter.dev',
        title: 'Flutter',
      );
      await controller.toggleBookmark(url: 'https://dart.dev', title: 'Dart');

      await controller.clearAllBookmarks();

      expect(controller.state, isEmpty);
    });
  });
}
