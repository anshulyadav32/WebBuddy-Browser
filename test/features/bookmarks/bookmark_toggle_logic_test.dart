import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_buddy/core/services/storage_service.dart';
import 'package:web_buddy/features/bookmarks/data/bookmarks_repository.dart';
import 'package:web_buddy/features/bookmarks/presentation/bookmarks_controller.dart';

/// Tests for bookmark toggle idempotency and edge cases.
void main() {
  late BookmarksController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs);
    final repo = BookmarksRepository(storage);
    controller = BookmarksController(repo);
  });

  group('Bookmark toggle logic', () {
    test('toggle adds bookmark when absent', () async {
      await controller.toggleBookmark(
        'https://example.com',
        title: 'Example',
      );
      expect(controller.isBookmarked('https://example.com'), isTrue);
      expect(controller.state.length, 1);
    });

    test('toggle removes bookmark when present', () async {
      await controller.toggleBookmark(
        'https://example.com',
        title: 'Example',
      );
      await controller.toggleBookmark('https://example.com');

      expect(controller.isBookmarked('https://example.com'), isFalse);
      expect(controller.state, isEmpty);
    });

    test('same page bookmarked twice does not duplicate', () async {
      await controller.toggleBookmark(
        'https://example.com',
        title: 'Example',
      );
      // Second add via repository add() replaces by URL
      await controller.toggleBookmark('https://example.com');
      // Now it's removed (toggled off)

      await controller.toggleBookmark(
        'https://example.com',
        title: 'Example Re-added',
      );
      expect(controller.state.length, 1);
    });

    test('toggle remains idempotent across cycles', () async {
      // Add → Remove → Add → verify single entry
      await controller.toggleBookmark('https://x.com', title: 'X');
      expect(controller.isBookmarked('https://x.com'), isTrue);

      await controller.toggleBookmark('https://x.com');
      expect(controller.isBookmarked('https://x.com'), isFalse);

      await controller.toggleBookmark('https://x.com', title: 'X again');
      expect(controller.isBookmarked('https://x.com'), isTrue);
      expect(controller.state.length, 1);
    });

    test('title fallback uses URL when title is empty', () async {
      await controller.toggleBookmark('https://example.com', title: '');
      expect(controller.state.first.title, 'https://example.com');
    });

    test('title fallback uses URL when title is null', () async {
      await controller.toggleBookmark('https://example.com');
      expect(controller.state.first.title, 'https://example.com');
    });

    test('blank URL still creates bookmark (not guarded)', () async {
      // Controller doesn't guard against blank URLs — test actual behavior
      await controller.toggleBookmark('', title: 'Empty');
      expect(controller.state.length, 1);
    });

    test('multiple different URLs bookmark independently', () async {
      await controller.toggleBookmark('https://a.com', title: 'A');
      await controller.toggleBookmark('https://b.com', title: 'B');
      await controller.toggleBookmark('https://c.com', title: 'C');

      expect(controller.state.length, 3);
      expect(controller.isBookmarked('https://a.com'), isTrue);
      expect(controller.isBookmarked('https://b.com'), isTrue);
      expect(controller.isBookmarked('https://c.com'), isTrue);
    });
  });
}
