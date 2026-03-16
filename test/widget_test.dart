import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:web_buddy/app.dart';
import 'package:web_buddy/features/settings/presentation/settings_controller.dart';

void main() {
  testWidgets('App launches and shows BrowserHomeScreen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const WebBuddyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify home screen content renders.
    expect(find.text('WebBuddy'), findsOneWidget);
    expect(find.text('Phase 1 Foundation Ready'), findsOneWidget);
  });

  testWidgets('Home screen shows technology chips', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const WebBuddyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Riverpod'), findsOneWidget);
    expect(find.text('GoRouter'), findsOneWidget);
    expect(find.text('SharedPrefs'), findsOneWidget);
    expect(find.text('Light / Dark'), findsOneWidget);
  });
}
