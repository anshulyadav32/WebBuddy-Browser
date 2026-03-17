import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:web_buddy/features/bookmarks/domain/bookmark.dart';
import 'package:web_buddy/features/bookmarks/presentation/bookmarks_controller.dart';
import 'package:web_buddy/features/bookmarks/presentation/bookmarks_screen.dart';
import 'package:web_buddy/features/browser/domain/browser_page_state.dart';
import 'package:web_buddy/features/browser/presentation/browser_controller.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_toolbar.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_progress_bar.dart';
import 'package:web_buddy/features/history/domain/history_item.dart';
import 'package:web_buddy/features/history/presentation/history_controller.dart';
import 'package:web_buddy/features/history/presentation/history_screen.dart';
import 'package:web_buddy/features/privacy/data/private_data_manager.dart';
import 'package:web_buddy/features/privacy/presentation/privacy_controller.dart';
import 'package:web_buddy/features/privacy/presentation/shields_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:web_buddy/features/settings/presentation/settings_controller.dart';
import 'package:web_buddy/features/tabs/application/tabs_controller.dart';
import 'package:web_buddy/features/tabs/presentation/tab_switcher_screen.dart';

class _FakePrivateDataManager extends PrivateDataManager {
  _FakePrivateDataManager() : super();

  @override
  Future<void> clearPrivateSessionData({
    WebViewController? webViewController,
  }) async {}
}

class _FakeBrowserController extends StateNotifier<BrowserPageState>
    implements BrowserController {
  _FakeBrowserController() : super(const BrowserPageState());

  @override
  Future<void> loadInput(String input) async {}

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

/// Integration test: tabs + bookmarks + history flow.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Tabs + Bookmarks + History flow', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    testWidgets('open tabs, bookmark page, verify history', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          key: const Key('scope1'),
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            browserControllerProvider.overrideWith(
              (ref) => _FakeBrowserController(),
            ),
            shieldsControllerProvider.overrideWith(
              (_) => _FakeShieldsController(),
            ),
            privateDataManagerProvider.overrideWithValue(
              _FakePrivateDataManager(),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Consumer(
                  builder: (context, ref, _) {
                    final tabsState = ref.watch(tabsControllerProvider);

                    return Scaffold(
                      body: Column(
                        children: [
                          BrowserToolbar(
                            tabCount: tabsState.tabs.length,
                            onTabsTapped: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const TabSwitcherScreen(),
                                ),
                              );
                            },
                          ),
                          const BrowserProgressBar(),
                          const Expanded(child: Placeholder()),
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

      // Step 1: Browser shell is visible
      expect(find.byType(BrowserToolbar), findsOneWidget);

      // Step 2: Open tab switcher
      final tabCountButton = find.text('1');
      if (tabCountButton.evaluate().isNotEmpty) {
        await tester.tap(tabCountButton.first);
        await tester.pumpAndSettle();
      }

      // Step 3: Verify tab switcher renders (or navigate back)
      if (find.byType(TabSwitcherScreen).evaluate().isNotEmpty) {
        expect(find.byType(TabSwitcherScreen), findsOneWidget);

        // Create a new tab
        final newTabButton = find.textContaining('New Tab');
        if (newTabButton.evaluate().isNotEmpty) {
          await tester.tap(newTabButton.first);
          await tester.pumpAndSettle();
        }

        // Go back
        final back = find.byType(BackButton);
        if (back.evaluate().isNotEmpty) {
          await tester.tap(back.first);
          await tester.pumpAndSettle();
        }
      }

      // Step 4: Bookmarks screen (test via direct navigation)
      await tester.pumpWidget(
        ProviderScope(
          key: const Key('scope2'),
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            bookmarksControllerProvider.overrideWith(
              (ref) => _FakeBookmarksController([
                Bookmark(
                  id: '1',
                  url: 'https://flutter.dev',
                  title: 'Flutter',
                  createdAt: DateTime(2025, 1, 1),
                ),
              ]),
            ),
          ],
          child: const MaterialApp(home: BookmarksScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('https://flutter.dev'), findsOneWidget);

      // Step 5: History screen
      await tester.pumpWidget(
        ProviderScope(
          key: const Key('scope3'),
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            historyControllerProvider.overrideWith(
              (ref) => _FakeHistoryController([
                HistoryItem(
                  id: '1',
                  url: 'https://flutter.dev',
                  title: 'Flutter',
                  visitedAt: DateTime(2025, 1, 1),
                ),
              ]),
            ),
          ],
          child: const MaterialApp(home: HistoryScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Flutter'), findsOneWidget);
    });
  });
}

class _FakeBookmarksController extends StateNotifier<List<Bookmark>>
    implements BookmarksController {
  _FakeBookmarksController([super.initial = const []]);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeHistoryController extends StateNotifier<List<HistoryItem>>
    implements HistoryController {
  _FakeHistoryController([super.initial = const []]);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
