import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:web_buddy/features/bookmarks/domain/bookmark.dart';
import 'package:web_buddy/features/bookmarks/presentation/bookmarks_controller.dart';
import 'package:web_buddy/features/bookmarks/presentation/bookmarks_screen.dart';

class _FakeBookmarksController extends StateNotifier<List<Bookmark>>
    implements BookmarksController {
  _FakeBookmarksController([super.initial = const []]);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Widget _testApp({List<Bookmark> bookmarks = const []}) {
  return ProviderScope(
    overrides: [
      bookmarksControllerProvider.overrideWith(
        (ref) => _FakeBookmarksController(bookmarks),
      ),
    ],
    child: const MaterialApp(home: BookmarksScreen()),
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('BookmarksScreen', () {
    testWidgets('empty state renders', (tester) async {
      await tester.pumpWidget(_testApp());
      await tester.pumpAndSettle();

      expect(find.text('No bookmarks yet'), findsOneWidget);
    });

    testWidgets('list renders with bookmarks', (tester) async {
      final bookmarks = [
        Bookmark(
          id: '1',
          url: 'https://flutter.dev',
          title: 'Flutter',
          createdAt: DateTime(2025, 1, 1),
        ),
        Bookmark(
          id: '2',
          url: 'https://dart.dev',
          title: 'Dart',
          createdAt: DateTime(2025, 1, 2),
        ),
      ];

      await tester.pumpWidget(_testApp(bookmarks: bookmarks));
      await tester.pumpAndSettle();

      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Dart'), findsOneWidget);
    });

    testWidgets('delete action visible for each bookmark', (tester) async {
      final bookmarks = [
        Bookmark(
          id: '1',
          url: 'https://flutter.dev',
          title: 'Flutter',
          createdAt: DateTime(2025, 1, 1),
        ),
      ];

      await tester.pumpWidget(_testApp(bookmarks: bookmarks));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('clear all action visible when bookmarks exist', (
      tester,
    ) async {
      final bookmarks = [
        Bookmark(
          id: '1',
          url: 'https://flutter.dev',
          title: 'Flutter',
          createdAt: DateTime(2025, 1, 1),
        ),
      ];

      await tester.pumpWidget(_testApp(bookmarks: bookmarks));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_sweep), findsOneWidget);
    });

    testWidgets('title says Bookmarks', (tester) async {
      await tester.pumpWidget(_testApp());
      await tester.pumpAndSettle();

      expect(find.text('Bookmarks'), findsOneWidget);
    });
  });
}
