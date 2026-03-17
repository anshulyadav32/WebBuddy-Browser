import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:web_buddy/features/browser/domain/browser_page_state.dart';
import 'package:web_buddy/features/browser/presentation/browser_controller.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_progress_bar.dart';

class _FakeBrowserController extends StateNotifier<BrowserPageState>
    implements BrowserController {
  _FakeBrowserController([super.initial = const BrowserPageState()]);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Widget _testApp({BrowserPageState? state}) {
  return ProviderScope(
    overrides: [
      browserControllerProvider.overrideWith(
        (ref) =>
            _FakeBrowserController(state ?? const BrowserPageState()),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(body: BrowserProgressBar()),
    ),
  );
}

/// Dedicated widget tests for [BrowserProgressBar].
void main() {
  group('BrowserProgressBar', () {
    testWidgets('hidden when not loading', (tester) async {
      await tester.pumpWidget(
        _testApp(state: const BrowserPageState(isLoading: false)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('visible when loading', (tester) async {
      await tester.pumpWidget(
        _testApp(
          state: const BrowserPageState(isLoading: true, progress: 0.5),
        ),
      );
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('visible at start of loading (progress 0)', (tester) async {
      await tester.pumpWidget(
        _testApp(
          state: const BrowserPageState(isLoading: true, progress: 0.0),
        ),
      );
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
