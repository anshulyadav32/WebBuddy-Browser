import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:web_buddy/features/browser/domain/browser_page_state.dart';
import 'package:web_buddy/features/browser/presentation/browser_controller.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_toolbar.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_progress_bar.dart';
import 'package:web_buddy/features/downloads/presentation/downloads_screen.dart';
import 'package:web_buddy/features/privacy/presentation/widgets/private_mode_badge.dart';
import 'package:web_buddy/features/settings/presentation/settings_controller.dart';
import 'package:web_buddy/features/tabs/application/tabs_controller.dart';
import 'package:web_buddy/features/tabs/domain/models/browser_tab_state.dart';
import 'package:web_buddy/features/tabs/domain/models/tabs_state.dart';
import 'package:web_buddy/features/tabs/presentation/tab_switcher_screen.dart';

/// Fake controller so tests run without a real platform WebView.
class FakeBrowserController extends StateNotifier<BrowserPageState>
    implements BrowserController {
  FakeBrowserController() : super(const BrowserPageState());

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// End-to-end flow test covering the major features from Phases 1–6.
///
/// This test exercises the browser shell, tab management, downloads screen
/// navigation, and private tab flow — all without requiring a real WebView
/// or platform channels.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Browser Phase 1–6 flow', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    testWidgets('full browser flow: launch → tabs → private → cleanup', (
      tester,
    ) async {
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
              builder: (context) {
                return Consumer(
                  builder: (context, ref, _) {
                    final tabsState = ref.watch(tabsControllerProvider);
                    final controller = ref.read(
                      tabsControllerProvider.notifier,
                    );

                    return Scaffold(
                      body: Column(
                        children: [
                          BrowserToolbar(
                            tabCount: tabsState.tabs.length,
                            isPrivateMode: tabsState.isActiveTabPrivate,
                            onTabsTapped: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const TabSwitcherScreen(),
                                ),
                              );
                            },
                            onDownloadsTapped: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const DownloadsScreen(),
                                ),
                              );
                            },
                          ),
                          const BrowserProgressBar(),
                          Expanded(
                            child: tabsState.isActiveTabPrivate
                                ? const Center(child: PrivateModeBadge())
                                : const Center(
                                    child: Text('WebView placeholder'),
                                  ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // ── Phase 1: Browser shell visible ───────────────────────────
      expect(
        find.byType(BrowserToolbar),
        findsOneWidget,
        reason: 'Toolbar should render',
      );
      expect(
        find.byType(TextField),
        findsOneWidget,
        reason: 'Omnibox should be present',
      );
      expect(
        find.byIcon(Icons.arrow_back),
        findsOneWidget,
        reason: 'Back button',
      );
      expect(
        find.byIcon(Icons.arrow_forward),
        findsOneWidget,
        reason: 'Forward button',
      );
      expect(
        find.byIcon(Icons.refresh),
        findsOneWidget,
        reason: 'Reload button',
      );

      // ── Phase 2: Omnibox present, progress bar hidden ────────────
      expect(find.byType(BrowserProgressBar), findsOneWidget);
      expect(
        find.byType(LinearProgressIndicator),
        findsNothing,
        reason: 'Not loading → no progress bar',
      );
      expect(find.text('WebView placeholder'), findsOneWidget);

      // ── Phase 3: Open tab switcher ───────────────────────────────
      // Tab count badge should show "1".
      expect(find.text('1'), findsOneWidget);

      // Tap the tab count to open the switcher.
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      expect(find.byType(TabSwitcherScreen), findsOneWidget);
      expect(find.text('Tabs'), findsOneWidget);
      expect(
        find.byIcon(Icons.add),
        findsOneWidget,
        reason: 'New tab button in switcher',
      );

      // ── Phase 3: Create new tab ──────────────────────────────────
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Should have popped back to home with 2 tabs now.
      expect(find.text('2'), findsOneWidget, reason: 'Tab count should be 2');

      // ── Phase 5: Navigate to downloads screen ────────────────────
      await tester.tap(find.byIcon(Icons.download));
      await tester.pumpAndSettle();

      expect(find.byType(DownloadsScreen), findsOneWidget);
      expect(find.text('Downloads'), findsOneWidget);
      expect(find.text('No downloads yet'), findsOneWidget);

      // Go back to home via the AppBar back button.
      final navState = tester.state<NavigatorState>(
        find.byType(Navigator).last,
      );
      navState.pop();
      await tester.pumpAndSettle();

      // ── Phase 6: Open tab switcher, create private tab ───────────
      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();

      // Shield icon for new private tab.
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.shield_outlined));
      await tester.pumpAndSettle();

      // Should pop back to home; now active tab is private.
      // Private badge should be visible.
      expect(
        find.byType(PrivateModeBadge),
        findsOneWidget,
        reason: 'Private badge should appear for private tab',
      );
      expect(
        find.byIcon(Icons.shield),
        findsWidgets,
        reason: 'Shield icon in toolbar and/or badge',
      );

      // Tab count should now be 3.
      expect(find.text('3'), findsOneWidget);

      // ── Phase 6: Close private tab via switcher ──────────────────
      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();

      // Find close buttons on tab cards.
      final closeButtons = find.byIcon(Icons.close);
      expect(closeButtons, findsWidgets);

      // Close the last tab (private one) — it should be the third card.
      // We tap the last close button.
      await tester.tap(closeButtons.last);
      await tester.pumpAndSettle();

      // Go back to home from tab switcher.
      final navState2 = tester.state<NavigatorState>(
        find.byType(Navigator).last,
      );
      navState2.pop();
      await tester.pumpAndSettle();

      // No private badge anymore if active tab is regular.
      expect(
        find.byType(PrivateModeBadge),
        findsNothing,
        reason: 'Private badge should be gone after closing private tab',
      );
    });
  });
}
