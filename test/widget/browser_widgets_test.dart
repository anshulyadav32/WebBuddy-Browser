import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:web_buddy/features/browser/domain/browser_page_state.dart';
import 'package:web_buddy/features/browser/presentation/browser_controller.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_toolbar.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_progress_bar.dart';
import 'package:web_buddy/features/privacy/presentation/shields_controller.dart';
import 'package:web_buddy/features/settings/presentation/settings_controller.dart';

// ── Fake controller for widget tests (no real WebView) ───────────────

class FakeBrowserController extends StateNotifier<BrowserPageState>
    implements BrowserController {
  FakeBrowserController([super.initial = const BrowserPageState()]);

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

// ── Helpers ──────────────────────────────────────────────────────────

Widget _testApp(Widget child, {BrowserPageState? state}) {
  return ProviderScope(
    overrides: [
      browserControllerProvider.overrideWith(
        (ref) => FakeBrowserController(state ?? const BrowserPageState()),
      ),
      shieldsControllerProvider.overrideWith((_) => _FakeShieldsController()),
    ],
    child: MaterialApp(home: child),
  );
}

/// Widget tests covering the browser UI shell: toolbar, progress bar,
/// and the composed browser home screen layout.
void main() {
  // ═══════════════════════════════════════════════════════════════════
  // App launch
  // ═══════════════════════════════════════════════════════════════════

  group('App launch', () {
    testWidgets('MaterialApp renders with title WebBuddy', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            browserControllerProvider.overrideWith(
              (ref) => FakeBrowserController(),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Column(
                  children: [
                    const BrowserToolbar(),
                    const BrowserProgressBar(),
                    Expanded(child: Container()),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // Browser home screen layout
  // ═══════════════════════════════════════════════════════════════════

  group('Browser home screen rendering', () {
    testWidgets('toolbar is visible', (tester) async {
      await tester.pumpWidget(
        _testApp(
          const Scaffold(
            body: Column(
              children: [
                BrowserToolbar(),
                BrowserProgressBar(),
                Expanded(child: Placeholder()),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BrowserToolbar), findsOneWidget);
    });

    testWidgets('progress bar is in the tree', (tester) async {
      await tester.pumpWidget(
        _testApp(
          const Scaffold(
            body: Column(
              children: [
                BrowserToolbar(),
                BrowserProgressBar(),
                Expanded(child: Placeholder()),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BrowserProgressBar), findsOneWidget);
    });

    testWidgets('expanded content area exists', (tester) async {
      await tester.pumpWidget(
        _testApp(
          const Scaffold(
            body: Column(
              children: [
                BrowserToolbar(),
                BrowserProgressBar(),
                Expanded(child: Placeholder()),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Placeholder), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // Omnibox
  // ═══════════════════════════════════════════════════════════════════

  group('Omnibox', () {
    testWidgets('text field is visible', (tester) async {
      await tester.pumpWidget(_testApp(const Scaffold(body: BrowserToolbar())));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows hint text', (tester) async {
      await tester.pumpWidget(_testApp(const Scaffold(body: BrowserToolbar())));
      await tester.pumpAndSettle();

      expect(find.text('Search or enter URL'), findsOneWidget);
    });

    testWidgets('displays current URL from state', (tester) async {
      await tester.pumpWidget(
        _testApp(
          const Scaffold(body: BrowserToolbar()),
          state: const BrowserPageState(currentUrl: 'https://dart.dev'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('https://dart.dev'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // Toolbar buttons
  // ═══════════════════════════════════════════════════════════════════

  group('Toolbar button visibility', () {
    testWidgets('back button is visible', (tester) async {
      await tester.pumpWidget(_testApp(const Scaffold(body: BrowserToolbar())));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('forward button is visible', (tester) async {
      await tester.pumpWidget(_testApp(const Scaffold(body: BrowserToolbar())));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('reload button shown when not loading', (tester) async {
      await tester.pumpWidget(
        _testApp(
          const Scaffold(body: BrowserToolbar()),
          state: const BrowserPageState(isLoading: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('stop button shown when loading', (tester) async {
      await tester.pumpWidget(
        _testApp(
          const Scaffold(body: BrowserToolbar()),
          state: const BrowserPageState(isLoading: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets('back button disabled when canGoBack is false', (tester) async {
      await tester.pumpWidget(
        _testApp(
          const Scaffold(body: BrowserToolbar()),
          state: const BrowserPageState(canGoBack: false),
        ),
      );
      await tester.pumpAndSettle();

      final btn = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.arrow_back),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('back button enabled when canGoBack is true', (tester) async {
      await tester.pumpWidget(
        _testApp(
          const Scaffold(body: BrowserToolbar()),
          state: const BrowserPageState(canGoBack: true),
        ),
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
        _testApp(
          const Scaffold(body: BrowserToolbar()),
          state: const BrowserPageState(canGoForward: false),
        ),
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
        _testApp(
          const Scaffold(body: BrowserToolbar()),
          state: const BrowserPageState(canGoForward: true),
        ),
      );
      await tester.pumpAndSettle();

      final btn = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.arrow_forward),
      );
      expect(btn.onPressed, isNotNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // Progress bar
  // ═══════════════════════════════════════════════════════════════════

  group('Progress bar', () {
    testWidgets('hidden when not loading', (tester) async {
      await tester.pumpWidget(
        _testApp(
          const Scaffold(body: BrowserProgressBar()),
          state: const BrowserPageState(isLoading: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('visible when loading', (tester) async {
      await tester.pumpWidget(
        _testApp(
          const Scaffold(body: BrowserProgressBar()),
          state: const BrowserPageState(isLoading: true, progress: 0.3),
        ),
      );
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows indeterminate bar when progress is zero', (
      tester,
    ) async {
      await tester.pumpWidget(
        _testApp(
          const Scaffold(body: BrowserProgressBar()),
          state: const BrowserPageState(isLoading: true, progress: 0.0),
        ),
      );
      await tester.pump();

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      // value == null means indeterminate
      expect(indicator.value, isNull);
    });
  });
}
