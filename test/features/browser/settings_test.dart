import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/settings/domain/entities/browser_settings.dart';

void main() {
  group('BrowserSettings', () {
    test('has sensible defaults', () {
      const settings = BrowserSettings();
      expect(settings.searchEngineId, 'google');
      expect(settings.adBlockingEnabled, isTrue);
      expect(settings.trackerBlockingEnabled, isTrue);
      expect(settings.httpsUpgradeEnabled, isTrue);
      expect(settings.javascriptEnabled, isTrue);
      expect(settings.popupBlockingEnabled, isTrue);
      expect(settings.doNotTrackEnabled, isTrue);
      expect(settings.cookiePolicy, CookiePolicy.blockThirdParty);
      expect(settings.antiFingerprinting, isFalse);
    });

    test('copyWith creates modified copy', () {
      const settings = BrowserSettings();
      final updated = settings.copyWith(
        searchEngineId: 'duckduckgo',
        adBlockingEnabled: false,
      );
      expect(updated.searchEngineId, 'duckduckgo');
      expect(updated.adBlockingEnabled, isFalse);
      // Unchanged fields preserved
      expect(updated.trackerBlockingEnabled, isTrue);
      expect(updated.javascriptEnabled, isTrue);
    });

    test('JSON serialization round-trips', () {
      const settings = BrowserSettings(
        searchEngineId: 'brave',
        adBlockingEnabled: false,
        cookiePolicy: CookiePolicy.blockAll,
        themeMode: ThemeMode.dark,
      );

      final json = settings.toJson();
      final restored = BrowserSettings.fromJson(json);

      expect(restored.searchEngineId, settings.searchEngineId);
      expect(restored.adBlockingEnabled, settings.adBlockingEnabled);
      expect(restored.cookiePolicy, settings.cookiePolicy);
      expect(restored.themeMode, settings.themeMode);
    });

    test('fromJson handles missing fields gracefully', () {
      final settings = BrowserSettings.fromJson({});
      expect(settings.searchEngineId, 'google');
      expect(settings.adBlockingEnabled, isTrue);
    });
  });
}
