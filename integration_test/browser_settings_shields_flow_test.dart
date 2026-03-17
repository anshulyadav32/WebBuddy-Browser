import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:web_buddy/features/browser/domain/browser_page_state.dart';
import 'package:web_buddy/features/browser/presentation/browser_controller.dart';
import 'package:web_buddy/features/privacy/domain/shield_stats.dart';
import 'package:web_buddy/features/privacy/presentation/shields_controller.dart';
import 'package:web_buddy/features/privacy/presentation/widgets/shields_panel.dart';
import 'package:web_buddy/features/settings/presentation/settings_controller.dart';
import 'package:web_buddy/features/settings/presentation/settings_screen.dart';

class _FakeBrowserController extends StateNotifier<BrowserPageState>
    implements BrowserController {
  _FakeBrowserController() : super(const BrowserPageState());

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeShieldsController extends StateNotifier<ShieldsState>
    implements ShieldsController {
  _FakeShieldsController()
    : super(
        const ShieldsState(
          isInitialised: true,
          globalEnabled: true,
          currentDomain: 'example.com',
          currentSiteEnabled: true,
          stats: ShieldStats(adsBlocked: 3, trackersBlocked: 2, totalBlocked: 5),
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Integration test: settings + shields flow.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Settings + Shields flow', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    testWidgets('settings screen opens and shows options', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            browserControllerProvider.overrideWith(
              (ref) => _FakeBrowserController(),
            ),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Settings screen should show section headers
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('shields panel renders with stats', (tester) async {
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
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => ProviderScope(
                          overrides: [
                            shieldsControllerProvider.overrideWith(
                              (_) => _FakeShieldsController(),
                            ),
                          ],
                          child: const ShieldsPanel(),
                        ),
                      );
                    },
                    child: const Text('Open Shields'),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open the shields panel
      await tester.tap(find.text('Open Shields'));
      await tester.pumpAndSettle();

      // Shields panel should render
      expect(find.byType(ShieldsPanel), findsOneWidget);
    });
  });
}
