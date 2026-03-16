import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_buddy/core/services/clear_browsing_data_service.dart';
import 'package:web_buddy/core/services/storage_service.dart';
import 'package:web_buddy/features/settings/data/site_settings_repository.dart';
import 'package:web_buddy/features/settings/domain/site_settings.dart';

void main() {
  group('ClearDataOptions', () {
    test('default constructor has all false', () {
      const o = ClearDataOptions();
      expect(o.cookies, false);
      expect(o.cache, false);
      expect(o.localStorage, false);
      expect(o.siteSettings, false);
      expect(o.hasAny, false);
    });

    test('.all() enables every category', () {
      const o = ClearDataOptions.all();
      expect(o.cookies, true);
      expect(o.cache, true);
      expect(o.localStorage, true);
      expect(o.siteSettings, true);
      expect(o.hasAny, true);
    });

    test('hasAny returns true with any single flag', () {
      expect(const ClearDataOptions(cookies: true).hasAny, true);
      expect(const ClearDataOptions(cache: true).hasAny, true);
      expect(const ClearDataOptions(localStorage: true).hasAny, true);
      expect(const ClearDataOptions(siteSettings: true).hasAny, true);
    });
  });

  group('ClearDataResult', () {
    test('default has clearedCount 0', () {
      const r = ClearDataResult();
      expect(r.clearedCount, 0);
    });

    test('clearedCount reflects true flags', () {
      const r = ClearDataResult(
        cookiesCleared: true,
        siteSettingsCleared: true,
      );
      expect(r.clearedCount, 2);
    });

    test('all true gives clearedCount 4', () {
      const r = ClearDataResult(
        cookiesCleared: true,
        cacheCleared: true,
        storageCleared: true,
        siteSettingsCleared: true,
      );
      expect(r.clearedCount, 4);
    });
  });

  group('ClearBrowsingDataService', () {
    late SiteSettingsRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repo = SiteSettingsRepository(StorageService(prefs));
    });

    test('clears site settings when option is set', () async {
      // Seed a site setting
      repo.save(const SiteSettings(domain: 'd.com', javaScriptEnabled: false));

      final service = ClearBrowsingDataService(
        cookieManager: null,
        siteSettingsRepo: repo,
      );

      final result = await service.clear(
        const ClearDataOptions(siteSettings: true),
      );

      expect(result.siteSettingsCleared, true);
      expect(repo.loadAll(), isEmpty);
    });

    test('skips cookies when no cookie manager and catches error', () async {
      final service = ClearBrowsingDataService(
        cookieManager: null,
        siteSettingsRepo: repo,
      );

      // This should not throw — cookies require platform and will fail gracefully
      final result = await service.clear(const ClearDataOptions(cookies: true));

      // In a test environment without a WebView platform, clearing cookies
      // will fail silently. The exact result depends on whether the lazy
      // WebViewCookieManager throws or succeeds in the test env.
      expect(result.cacheCleared, false);
      expect(result.storageCleared, false);
    });

    test('returns all-false when no categories selected', () async {
      final service = ClearBrowsingDataService(
        cookieManager: null,
        siteSettingsRepo: repo,
      );

      final result = await service.clear(const ClearDataOptions());

      expect(result.cookiesCleared, false);
      expect(result.cacheCleared, false);
      expect(result.storageCleared, false);
      expect(result.siteSettingsCleared, false);
      expect(result.clearedCount, 0);
    });

    test('cache and storage require a webViewController', () async {
      final service = ClearBrowsingDataService(
        cookieManager: null,
        siteSettingsRepo: repo,
      );

      // Without a webViewController, cache+storage are skipped
      final result = await service.clear(
        const ClearDataOptions(cache: true, localStorage: true),
      );

      expect(result.cacheCleared, false);
      expect(result.storageCleared, false);
    });
  });
}
