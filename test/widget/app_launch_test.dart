import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:web_buddy/features/browser/domain/browser_page_state.dart';
import 'package:web_buddy/features/browser/presentation/browser_controller.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_toolbar.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_progress_bar.dart';
import 'package:web_buddy/features/settings/presentation/settings_controller.dart';

class _FakeBrowserController extends StateNotifier<BrowserPageState>
    implements BrowserController {
  _FakeBrowserController() : super(const BrowserPageState());

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('App launch', () {
    testWidgets('app launches with browser shell', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            browserControllerProvider.overrideWith(
              (ref) => _FakeBrowserController(),
            ),
          ],
          child: MaterialApp(
            title: 'WebBuddy',
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

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(BrowserToolbar), findsOneWidget);
    });

    testWidgets('browser shell contains toolbar and omnibox', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            browserControllerProvider.overrideWith(
              (ref) => _FakeBrowserController(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: const [
                  BrowserToolbar(),
                  BrowserProgressBar(),
                  Expanded(child: Placeholder()),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
