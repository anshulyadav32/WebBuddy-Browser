import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:web_buddy/features/browser/domain/browser_page_state.dart';
import 'package:web_buddy/features/browser/presentation/browser_controller.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_toolbar.dart';
import 'package:web_buddy/features/privacy/presentation/shields_controller.dart';

class _FakeBrowserController extends StateNotifier<BrowserPageState>
    implements BrowserController {
  _FakeBrowserController([super.initial = const BrowserPageState()]);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeShieldsController extends StateNotifier<ShieldsState>
    implements ShieldsController {
  _FakeShieldsController()
    : super(const ShieldsState(isInitialised: true, globalEnabled: true));

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Widget _testApp({BrowserPageState? state, bool isPrivateMode = false}) {
  return ProviderScope(
    overrides: [
      browserControllerProvider.overrideWith(
        (ref) => _FakeBrowserController(state ?? const BrowserPageState()),
      ),
      shieldsControllerProvider.overrideWith((_) => _FakeShieldsController()),
    ],
    child: MaterialApp(
      home: Scaffold(body: BrowserToolbar(isPrivateMode: isPrivateMode)),
    ),
  );
}

/// Dedicated widget tests for [BrowserToolbar].
void main() {
  group('BrowserToolbar', () {
    testWidgets('address field is visible', (tester) async {
      await tester.pumpWidget(_testApp());
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('back button disabled when canGoBack is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        _testApp(state: const BrowserPageState(canGoBack: false)),
      );
      await tester.pumpAndSettle();

      final btn = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.arrow_back),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('back button enabled when canGoBack is true', (tester) async {
      await tester.pumpWidget(
        _testApp(state: const BrowserPageState(canGoBack: true)),
      );
      await tester.pumpAndSettle();

      final btn = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.arrow_back),
      );
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('forward button disabled when canGoForward is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        _testApp(state: const BrowserPageState(canGoForward: false)),
      );
      await tester.pumpAndSettle();

      final btn = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.arrow_forward),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('forward button enabled when canGoForward is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        _testApp(state: const BrowserPageState(canGoForward: true)),
      );
      await tester.pumpAndSettle();

      final btn = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.arrow_forward),
      );
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('reload shown when not loading', (tester) async {
      await tester.pumpWidget(
        _testApp(state: const BrowserPageState(isLoading: false)),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('stop shown when loading', (tester) async {
      await tester.pumpWidget(
        _testApp(state: const BrowserPageState(isLoading: true)),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });
}
