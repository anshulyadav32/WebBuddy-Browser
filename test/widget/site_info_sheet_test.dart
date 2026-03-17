import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:web_buddy/features/settings/domain/site_permission.dart';
import 'package:web_buddy/features/settings/domain/site_settings.dart';
import 'package:web_buddy/features/settings/presentation/settings_controller.dart';
import 'package:web_buddy/features/settings/presentation/site_info_sheet.dart';
import 'package:web_buddy/features/settings/presentation/site_settings_controller.dart';

class _FakeSiteSettingsController
    extends StateNotifier<Map<String, SiteSettings>>
    implements SiteSettingsController {
  _FakeSiteSettingsController(super.initial);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('SiteInfoSheet', () {
    testWidgets('origin shown', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            siteSettingsControllerProvider.overrideWith(
              (_) => _FakeSiteSettingsController({}),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SiteInfoSheet(currentUrl: 'https://example.com/page'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('example.com'), findsOneWidget);
    });

    testWidgets('site permission rows shown when present', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final settings = SiteSettings(
        domain: 'example.com',
        permissions: [
          const SitePermission(
            domain: 'example.com',
            type: SitePermissionType.camera,
            state: PermissionState.allow,
          ),
          const SitePermission(
            domain: 'example.com',
            type: SitePermissionType.microphone,
            state: PermissionState.deny,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            siteSettingsControllerProvider.overrideWith(
              (_) => _FakeSiteSettingsController({'example.com': settings}),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SiteInfoSheet(currentUrl: 'https://example.com/page'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Microphone'), findsOneWidget);
    });

    testWidgets('reset site settings action visible', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            siteSettingsControllerProvider.overrideWith(
              (_) => _FakeSiteSettingsController({}),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SiteInfoSheet(currentUrl: 'https://example.com/page'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Clear site data'), findsOneWidget);
    });

    testWidgets('shows no-site message for empty URL', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            siteSettingsControllerProvider.overrideWith(
              (_) => _FakeSiteSettingsController({}),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SiteInfoSheet(currentUrl: '')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No site loaded'), findsOneWidget);
    });
  });
}
