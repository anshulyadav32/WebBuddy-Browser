import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:web_buddy/features/settings/domain/site_settings.dart';
import 'package:web_buddy/features/settings/presentation/settings_controller.dart';
import 'package:web_buddy/features/settings/presentation/settings_screen.dart';
import 'package:web_buddy/features/settings/presentation/site_settings_controller.dart';

class _FakeSiteSettingsController
    extends StateNotifier<Map<String, SiteSettings>>
    implements SiteSettingsController {
  _FakeSiteSettingsController() : super({});

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsScreen', () {
    testWidgets('settings sections render', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            siteSettingsControllerProvider.overrideWith(
              (_) => _FakeSiteSettingsController(),
            ),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);

      // Scroll to Security (pushed down by additional Content items)
      await tester.scrollUntilVisible(
        find.text('Security'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Security'), findsOneWidget);

      // Scroll down to reveal the Privacy & Data section
      await tester.scrollUntilVisible(
        find.text('Privacy & Data'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Privacy & Data'), findsOneWidget);
    });

    testWidgets('theme selector visible', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            siteSettingsControllerProvider.overrideWith(
              (_) => _FakeSiteSettingsController(),
            ),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Theme'), findsOneWidget);
    });

    testWidgets('search engine selector visible', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            siteSettingsControllerProvider.overrideWith(
              (_) => _FakeSiteSettingsController(),
            ),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Search engine'), findsOneWidget);
    });

    testWidgets('JavaScript toggle visible', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            siteSettingsControllerProvider.overrideWith(
              (_) => _FakeSiteSettingsController(),
            ),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('JavaScript'), findsOneWidget);
    });

    testWidgets('pop-up toggle visible', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            siteSettingsControllerProvider.overrideWith(
              (_) => _FakeSiteSettingsController(),
            ),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Block pop-ups'), findsOneWidget);
    });

    testWidgets('cookie policy selector visible', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            siteSettingsControllerProvider.overrideWith(
              (_) => _FakeSiteSettingsController(),
            ),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cookie policy'), findsOneWidget);
    });

    testWidgets('clear browsing data action visible', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            siteSettingsControllerProvider.overrideWith(
              (_) => _FakeSiteSettingsController(),
            ),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll down to reveal the Clear browsing data action
      await tester.scrollUntilVisible(
        find.text('Clear browsing data'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Clear browsing data'), findsOneWidget);
    });
  });
}
