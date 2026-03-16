import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/bookmarks/domain/bookmark.dart';

/// Tests for the [Bookmark] domain model.
/// Repository and controller tests will be added in Phase 4
/// when those layers are implemented.
void main() {
  group('Bookmark', () {
    test('creates with required fields', () {
      final b = Bookmark(
        id: '1',
        url: 'https://flutter.dev',
        title: 'Flutter',
        createdAt: DateTime(2025, 1, 1),
      );

      expect(b.id, '1');
      expect(b.url, 'https://flutter.dev');
      expect(b.title, 'Flutter');
      expect(b.faviconUrl, isNull);
      expect(b.folder, isNull);
    });

    test('copyWith updates title only', () {
      final b = Bookmark(
        id: '1',
        url: 'https://flutter.dev',
        title: 'Flutter',
        createdAt: DateTime(2025, 1, 1),
      );

      final updated = b.copyWith(title: 'Flutter SDK');

      expect(updated.title, 'Flutter SDK');
      expect(updated.url, 'https://flutter.dev');
      expect(updated.id, '1');
    });

    test('copyWith updates url', () {
      final b = Bookmark(
        id: '1',
        url: 'https://flutter.dev',
        title: 'Flutter',
        createdAt: DateTime(2025, 1, 1),
      );

      final updated = b.copyWith(url: 'https://dart.dev');
      expect(updated.url, 'https://dart.dev');
    });

    test('equality based on id', () {
      final a = Bookmark(
        id: '1',
        url: 'https://flutter.dev',
        title: 'Flutter',
        createdAt: DateTime(2025, 1, 1),
      );
      final b = Bookmark(
        id: '1',
        url: 'https://different.com',
        title: 'Different',
        createdAt: DateTime(2025, 6, 1),
      );

      expect(a, equals(b));
    });

    test('different ids are not equal', () {
      final a = Bookmark(
        id: '1',
        url: 'https://flutter.dev',
        title: 'Flutter',
        createdAt: DateTime(2025, 1, 1),
      );
      final b = Bookmark(
        id: '2',
        url: 'https://flutter.dev',
        title: 'Flutter',
        createdAt: DateTime(2025, 1, 1),
      );

      expect(a, isNot(equals(b)));
    });

    test('toString includes id, title, url', () {
      final b = Bookmark(
        id: '1',
        url: 'https://flutter.dev',
        title: 'Flutter',
        createdAt: DateTime(2025, 1, 1),
      );

      expect(b.toString(), contains('Flutter'));
      expect(b.toString(), contains('flutter.dev'));
    });
  });
}
