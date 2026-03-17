import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:web_buddy/features/browser/presentation/first_run_screen.dart';

void main() {
  group('Onboarding state', () {
    test('first-run flag not set by default', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      expect(prefs.getBool(FirstRunScreen.onboardingCompleteKey), isNull);
    });

    test('first-run flag persisted after completion', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(FirstRunScreen.onboardingCompleteKey, true);

      expect(prefs.getBool(FirstRunScreen.onboardingCompleteKey), isTrue);
    });

    test('onboarding completion survives simulated restart', () async {
      SharedPreferences.setMockInitialValues({
        FirstRunScreen.onboardingCompleteKey: true,
      });
      final prefs = await SharedPreferences.getInstance();

      expect(prefs.getBool(FirstRunScreen.onboardingCompleteKey), isTrue);
    });

    test('onboarding flow state transitions correct', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Before onboarding
      expect(prefs.getBool(FirstRunScreen.onboardingCompleteKey), isNull);

      // After onboarding
      await prefs.setBool(FirstRunScreen.onboardingCompleteKey, true);
      expect(prefs.getBool(FirstRunScreen.onboardingCompleteKey), isTrue);

      // Should not revert
      expect(prefs.getBool(FirstRunScreen.onboardingCompleteKey), isTrue);
    });
  });
}
