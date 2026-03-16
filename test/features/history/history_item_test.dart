import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/history/domain/history_item.dart';

/// Tests for the [HistoryItem] domain model.
/// Repository and controller tests will be added in Phase 4
/// when those layers are implemented.
void main() {
  group('HistoryItem', () {
    test('creates with required fields', () {
      final h = HistoryItem(
        id: '1',
        url: 'https://flutter.dev',
        title: 'Flutter',
        visitedAt: DateTime(2025, 1, 1),
      );

      expect(h.id, '1');
      expect(h.url, 'https://flutter.dev');
      expect(h.title, 'Flutter');
      expect(h.faviconUrl, isNull);
    });

    test('equality based on id', () {
      final a = HistoryItem(
        id: '1',
        url: 'https://flutter.dev',
        title: 'Flutter',
        visitedAt: DateTime(2025, 1, 1),
      );
      final b = HistoryItem(
        id: '1',
        url: 'https://different.com',
        title: 'Different',
        visitedAt: DateTime(2025, 6, 1),
      );

      expect(a, equals(b));
    });

    test('different ids are not equal', () {
      final a = HistoryItem(
        id: '1',
        url: 'https://flutter.dev',
        title: 'Flutter',
        visitedAt: DateTime(2025, 1, 1),
      );
      final b = HistoryItem(
        id: '2',
        url: 'https://flutter.dev',
        title: 'Flutter',
        visitedAt: DateTime(2025, 1, 1),
      );

      expect(a, isNot(equals(b)));
    });

    test('toString includes id, title, url', () {
      final h = HistoryItem(
        id: '1',
        url: 'https://flutter.dev',
        title: 'Flutter',
        visitedAt: DateTime(2025, 1, 1),
      );

      expect(h.toString(), contains('Flutter'));
      expect(h.toString(), contains('flutter.dev'));
    });
  });
}
