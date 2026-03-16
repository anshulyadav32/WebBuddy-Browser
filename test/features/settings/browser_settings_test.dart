import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/settings/domain/browser_settings.dart';

void main() {
  group('BrowserSettings defaults', () {
    test('has expected default values', () {
      const s = BrowserSettings();
      expect(s.themeMode, ThemeMode.system);
      expect(s.searchEngine, SearchEngine.google);
      expect(s.adBlockEnabled, isTrue);
      expect(s.httpsUpgradeEnabled, isTrue);
      expect(s.homePage, 'about:blank');
    });
  });

  group('BrowserSettings.copyWith', () {
    test('changes only specified fields', () {
      const original = BrowserSettings();
      final updated = original.copyWith(themeMode: ThemeMode.dark);

      expect(updated.themeMode, ThemeMode.dark);
      // Everything else unchanged.
      expect(updated.searchEngine, original.searchEngine);
      expect(updated.adBlockEnabled, original.adBlockEnabled);
      expect(updated.httpsUpgradeEnabled, original.httpsUpgradeEnabled);
      expect(updated.homePage, original.homePage);
    });

    test('can change multiple fields at once', () {
      const original = BrowserSettings();
      final updated = original.copyWith(
        searchEngine: SearchEngine.duckDuckGo,
        adBlockEnabled: false,
        homePage: 'https://example.com',
      );

      expect(updated.searchEngine, SearchEngine.duckDuckGo);
      expect(updated.adBlockEnabled, isFalse);
      expect(updated.homePage, 'https://example.com');
      // Unchanged fields.
      expect(updated.themeMode, ThemeMode.system);
      expect(updated.httpsUpgradeEnabled, isTrue);
    });
  });

  group('BrowserSettings serialization', () {
    test('round-trips through toMap/fromMap', () {
      final original = const BrowserSettings().copyWith(
        themeMode: ThemeMode.dark,
        searchEngine: SearchEngine.brave,
        adBlockEnabled: false,
      );

      final restored = BrowserSettings.fromMap(original.toMap());

      expect(restored, equals(original));
    });

    test('fromMap handles missing keys gracefully', () {
      final s = BrowserSettings.fromMap({});
      expect(s, equals(const BrowserSettings()));
    });
  });

  group('BrowserSettings equality', () {
    test('identical defaults are equal', () {
      expect(const BrowserSettings(), equals(const BrowserSettings()));
    });

    test('different settings are not equal', () {
      const a = BrowserSettings();
      final b = a.copyWith(themeMode: ThemeMode.light);
      expect(a, isNot(equals(b)));
    });
  });
}
