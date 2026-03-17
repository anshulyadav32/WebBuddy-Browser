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

Widget _testApp({List<HistoryItem> history = const []}) {
  return ProviderScope(
    overrides: [
      historyControllerProvider.overrideWith(
        (ref) => _FakeHistoryController(history),
      ),
    ],
    child: const MaterialApp(home: HistoryScreen()),
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('HistoryScreen', () {
    testWidgets('empty state renders', (tester) async {
      await tester.pumpWidget(_testApp());
      await tester.pumpAndSettle();

      expect(find.text('No history yet'), findsOneWidget);
    });

    testWidgets('list renders with history items', (tester) async {
      final history = [
        HistoryItem(
          id: '1',
          url: 'https://flutter.dev',
          title: 'Flutter',
          visitedAt: DateTime(2025, 1, 1, 10, 30),
        ),
        HistoryItem(
          id: '2',
          url: 'https://dart.dev',
          title: 'Dart',
          visitedAt: DateTime(2025, 1, 2, 11, 0),
        ),
      ];

      await tester.pumpWidget(_testApp(history: history));
      await tester.pumpAndSettle();

      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Dart'), findsOneWidget);
    });

    testWidgets('delete button visible for each item', (tester) async {
      final history = [
        HistoryItem(
          id: '1',
          url: 'https://flutter.dev',
          title: 'Flutter',
          visitedAt: DateTime(2025, 1, 1),
        ),
      ];

      await tester.pumpWidget(_testApp(history: history));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('clear all visible when items exist', (tester) async {
      final history = [
        HistoryItem(
          id: '1',
          url: 'https://flutter.dev',
          title: 'Flutter',
          visitedAt: DateTime(2025, 1, 1),
        ),
      ];

      await tester.pumpWidget(_testApp(history: history));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_sweep), findsOneWidget);
    });

    testWidgets('title says History', (tester) async {
      await tester.pumpWidget(_testApp());
      await tester.pumpAndSettle();

      expect(find.text('History'), findsOneWidget);
    });
  });
}
