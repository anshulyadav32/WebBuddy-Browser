import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:web_buddy/features/history/domain/history_item.dart';
import 'package:web_buddy/features/history/presentation/history_controller.dart';
import 'package:web_buddy/features/history/presentation/history_screen.dart';

class _FakeHistoryController extends StateNotifier<List<HistoryItem>>
    implements HistoryController {
  _FakeHistoryController([super.initial = const []]);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Widget _testApp({required List<HistoryItem> history}) {
  return ProviderScope(
    overrides: [
      historyControllerProvider.overrideWith(
        (ref) => _FakeHistoryController(history),
      ),
    ],
    child: const MaterialApp(home: HistoryScreen()),
  );
}

/// Widget tests for history list tile rendering within HistoryScreen.
void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('History tile rendering', () {
    testWidgets('title is shown', (tester) async {
      await tester.pumpWidget(
        _testApp(
          history: [
            HistoryItem(
              id: '1',
              url: 'https://flutter.dev',
              title: 'Flutter',
              visitedAt: DateTime(2025, 1, 1, 10, 30),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Flutter'), findsOneWidget);
    });

    testWidgets('URL is shown in subtitle', (tester) async {
      await tester.pumpWidget(
        _testApp(
          history: [
            HistoryItem(
              id: '1',
              url: 'https://flutter.dev',
              title: 'Flutter',
              visitedAt: DateTime(2025, 1, 1, 10, 30),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // URL is part of the subtitle along with the date
      expect(find.textContaining('https://flutter.dev'), findsOneWidget);
    });

    testWidgets('timestamp is shown', (tester) async {
      await tester.pumpWidget(
        _testApp(
          history: [
            HistoryItem(
              id: '1',
              url: 'https://flutter.dev',
              title: 'Flutter',
              visitedAt: DateTime(2025, 1, 1, 10, 30),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // HistoryScreen uses intl to format the date — look for a date fragment
      expect(find.textContaining('2025'), findsWidgets);
    });

    testWidgets('delete icon visible', (tester) async {
      await tester.pumpWidget(
        _testApp(
          history: [
            HistoryItem(
              id: '1',
              url: 'https://flutter.dev',
              title: 'Flutter',
              visitedAt: DateTime(2025, 1, 1),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('multiple items all render', (tester) async {
      await tester.pumpWidget(
        _testApp(
          history: [
            HistoryItem(
              id: '1',
              url: 'https://flutter.dev',
              title: 'Flutter',
              visitedAt: DateTime(2025, 1, 1),
            ),
            HistoryItem(
              id: '2',
              url: 'https://dart.dev',
              title: 'Dart',
              visitedAt: DateTime(2025, 1, 2),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Dart'), findsOneWidget);
    });
  });
}
