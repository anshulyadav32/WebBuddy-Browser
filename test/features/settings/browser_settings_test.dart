import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/settings/domain/browser_settings.dart';

void main() {
  group('BrowserSettings — defaults', () {
    test('has system theme mode', () {
      const s = BrowserSettings();
      expect(s.themeMode, ThemeMode.system);
    });

    test('has Google as default search engine', () {
      const s = BrowserSettings();
      expect(s.searchEngine, SearchEngine.google);
    });

    test('has ad-block enabled', () {
      const s = BrowserSettings();
      expect(s.adBlockEnabled, isTrue);
    });

    test('has HTTPS upgrade enabled', () {
      const s = BrowserSettings();
      expect(s.httpsUpgradeEnabled, isTrue);
    });

    test('has about:blank as home page', () {
      const s = BrowserSettings();
      expect(s.homePage, 'about:blank');
    });

    test('has JavaScript enabled', () {
      const s = BrowserSettings();
      expect(s.javaScriptEnabled, isTrue);
    });

    test('has pop-up blocking enabled', () {
      const s = BrowserSettings();
      expect(s.popUpBlockingEnabled, isTrue);
    });

    test('has acceptAll cookie policy', () {
      const s = BrowserSettings();
      expect(s.cookiePolicy, CookiePolicy.acceptAll);
    });
  });

  group('BrowserSettings — copyWith', () {
    test('updates only changed fields', () {
      const original = BrowserSettings();
      final updated = original.copyWith(themeMode: ThemeMode.dark);

      expect(updated.themeMode, ThemeMode.dark);
      expect(updated.searchEngine, original.searchEngine);
      expect(updated.adBlockEnabled, original.adBlockEnabled);
    });

    test('keeps unchanged values', () {
      const original = BrowserSettings();
      final updated = original.copyWith(searchEngine: SearchEngine.duckDuckGo);

      expect(updated.themeMode, ThemeMode.system);
      expect(updated.adBlockEnabled, true);
      expect(updated.httpsUpgradeEnabled, true);
      expect(updated.homePage, 'about:blank');
      expect(updated.javaScriptEnabled, true);
      expect(updated.popUpBlockingEnabled, true);
      expect(updated.cookiePolicy, CookiePolicy.acceptAll);
    });

    test('updates new Phase 7 fields', () {
      const original = BrowserSettings();
      final updated = original.copyWith(
        javaScriptEnabled: false,
        popUpBlockingEnabled: false,
        cookiePolicy: CookiePolicy.blockAll,
      );

      expect(updated.javaScriptEnabled, false);
      expect(updated.popUpBlockingEnabled, false);
      expect(updated.cookiePolicy, CookiePolicy.blockAll);
      // originals untouched
      expect(updated.themeMode, ThemeMode.system);
      expect(updated.searchEngine, SearchEngine.google);
    });
  });

  group('BrowserSettings — serialization', () {
    test('round-trips through toMap/fromMap', () {
      final original = const BrowserSettings().copyWith(
        themeMode: ThemeMode.dark,
        searchEngine: SearchEngine.brave,
        adBlockEnabled: false,
      );
      final restored = BrowserSettings.fromMap(original.toMap());
      expect(restored, equals(original));
    });

    test('round-trips new fields through toMap/fromMap', () {
      final original = const BrowserSettings().copyWith(
        javaScriptEnabled: false,
        popUpBlockingEnabled: false,
        cookiePolicy: CookiePolicy.blockThirdParty,
      );
      final restored = BrowserSettings.fromMap(original.toMap());
      expect(restored.javaScriptEnabled, false);
      expect(restored.popUpBlockingEnabled, false);
      expect(restored.cookiePolicy, CookiePolicy.blockThirdParty);
      expect(restored, equals(original));
    });

    test('fromMap handles empty map gracefully', () {
      final s = BrowserSettings.fromMap({});
      expect(s, equals(const BrowserSettings()));
    });
  });

  group('BrowserSettings — equality', () {
    test('identical defaults are equal', () {
      expect(const BrowserSettings(), equals(const BrowserSettings()));
    });

    test('different settings are not equal', () {
      const a = BrowserSettings();
      final b = a.copyWith(themeMode: ThemeMode.light);
      expect(a, isNot(equals(b)));
    });

    test('different new fields are not equal', () {
      const a = BrowserSettings();
      final b = a.copyWith(javaScriptEnabled: false);
      expect(a, isNot(equals(b)));
    });
  });
}
