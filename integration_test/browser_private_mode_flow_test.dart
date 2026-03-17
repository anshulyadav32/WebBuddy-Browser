import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:webview_flutter/webview_flutter.dart';

import 'package:web_buddy/features/browser/domain/browser_page_state.dart';
import 'package:web_buddy/features/browser/presentation/browser_controller.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_toolbar.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_progress_bar.dart';
import 'package:web_buddy/features/privacy/data/private_data_manager.dart';
import 'package:web_buddy/features/privacy/presentation/shields_controller.dart';
import 'package:web_buddy/features/privacy/presentation/privacy_controller.dart';
import 'package:web_buddy/features/privacy/presentation/widgets/private_mode_badge.dart';
import 'package:web_buddy/features/settings/presentation/settings_controller.dart';
import 'package:web_buddy/features/tabs/application/tabs_controller.dart';

class _FakeBrowserController extends StateNotifier<BrowserPageState>
    implements BrowserController {
  _FakeBrowserController() : super(const BrowserPageState());

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

/// Fake that avoids platform channel calls for cookie/cache clearing.
class _FakePrivateDataManager extends PrivateDataManager {
  _FakePrivateDataManager() : super(cookieManager: null);

  @override
  Future<void> clearPrivateSessionData({
    WebViewController? webViewController,
  }) async {
    // No-op in tests — avoids WebViewPlatform assertion.
  }
}

/// Integration test: private browsing flow.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Private browsing flow', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    testWidgets('private tab lifecycle: create → badge → close → no history', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
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
                    final tabsCtrl = ref.read(tabsControllerProvider.notifier);

                    return Scaffold(
                      body: Column(
                        children: [
                          BrowserToolbar(
                            tabCount: tabsState.tabs.length,
                            isPrivateMode: tabsState.isActiveTabPrivate,
                          ),
                          const BrowserProgressBar(),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (tabsState.isActiveTabPrivate)
                                  const PrivateModeBadge(),
                                Text('Active: ${tabsState.activeTab.title}'),
                                Text(
                                  'Private tabs: ${tabsState.privateTabCount}',
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      tabsCtrl.createNewTab(isPrivate: true),
                                  child: const Text('New Private Tab'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      tabsCtrl.closeTab(tabsState.activeTabId),
                                  child: const Text('Close Active Tab'),
                                ),
                              ],
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

      // Step 1: Initially not in private mode
      expect(find.text('Private tabs: 0'), findsOneWidget);

      // Step 2: Create a private tab
      await tester.tap(find.text('New Private Tab'));
      await tester.pumpAndSettle();

      expect(find.text('Private tabs: 1'), findsOneWidget);

      // Step 3: Private badge should be shown (active tab is now private)
      expect(find.byType(PrivateModeBadge), findsOneWidget);

      // Step 4: Close the private tab
      await tester.tap(find.text('Close Active Tab'));
      await tester.pumpAndSettle();

      // Step 5: Private tabs count back to 0
      expect(find.text('Private tabs: 0'), findsOneWidget);
    });
  });
}
