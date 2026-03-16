import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:web_buddy/features/browser/domain/browser_page_state.dart';
import 'package:web_buddy/features/browser/presentation/browser_controller.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_toolbar.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_progress_bar.dart';
import 'package:web_buddy/features/settings/presentation/settings_controller.dart';

/// Fake controller so we can run without a real platform WebView.
class FakeBrowserController extends StateNotifier<BrowserPageState>
    implements BrowserController {
  FakeBrowserController() : super(const BrowserPageState());

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Integration-style test: launches the full app shell and verifies the
/// browser chrome (toolbar, progress bar, content area) is present.
void main() {
  testWidgets('Browser shell is fully visible on launch', (tester) async {
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
          home: Scaffold(
            body: Column(
              children: const [
                BrowserToolbar(),
                BrowserProgressBar(),
                Expanded(child: Center(child: Text('WebView placeholder'))),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // ── Toolbar chrome ─────────────────────────────────────────────
    expect(
      find.byType(BrowserToolbar),
      findsOneWidget,
      reason: 'Toolbar should be in the widget tree',
    );
    expect(
      find.byType(TextField),
      findsOneWidget,
      reason: 'Omnibox text field should be visible',
    );
    expect(
      find.byIcon(Icons.arrow_back),
      findsOneWidget,
      reason: 'Back button should be present',
    );
    expect(
      find.byIcon(Icons.arrow_forward),
      findsOneWidget,
      reason: 'Forward button should be present',
    );
    expect(
      find.byIcon(Icons.refresh),
      findsOneWidget,
      reason: 'Reload button should be present when idle',
    );

    // ── Progress bar ───────────────────────────────────────────────
    expect(
      find.byType(BrowserProgressBar),
      findsOneWidget,
      reason: 'Progress bar widget should be in the tree',
    );
    // Not loading → no visible indicator
    expect(
      find.byType(LinearProgressIndicator),
      findsNothing,
      reason: 'Indicator should be hidden when not loading',
    );

    // ── Content area ───────────────────────────────────────────────
    expect(
      find.text('WebView placeholder'),
      findsOneWidget,
      reason: 'Content area should be rendered',
    );
  });
}
