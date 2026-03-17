import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:web_buddy/features/browser/presentation/first_run_screen.dart';
import 'package:web_buddy/features/settings/presentation/settings_controller.dart';

void main() {
  group('FirstRunScreen', () {
    testWidgets('renders onboarding carousel', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            home: FirstRunScreen(onComplete: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // First page title
      expect(find.text('Welcome to WebBuddy'), findsOneWidget);
    });

    testWidgets('shows Skip and Next buttons', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            home: FirstRunScreen(onComplete: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('can navigate to next page', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            home: FirstRunScreen(onComplete: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Built-in Privacy'), findsOneWidget);
    });

    testWidgets('skip calls onComplete and persists state', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      bool completed = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            home: FirstRunScreen(onComplete: () => completed = true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
      expect(
        prefs.getBool(FirstRunScreen.onboardingCompleteKey),
        isTrue,
      );
    });

    testWidgets('last page shows Get Started button', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            home: FirstRunScreen(onComplete: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Swipe to the last page (5 pages, swipe 4 times)
      for (int i = 0; i < 4; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('Get Started persists and calls onComplete', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      bool completed = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            home: FirstRunScreen(onComplete: () => completed = true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to last page
      for (int i = 0; i < 4; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
      expect(
        prefs.getBool(FirstRunScreen.onboardingCompleteKey),
        isTrue,
      );
    });
  });
}
