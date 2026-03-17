import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_buddy/core/services/storage_service.dart';
import 'package:web_buddy/features/settings/data/settings_repository.dart';
import 'package:web_buddy/features/settings/domain/browser_settings.dart';

void main() {
  group('SettingsRepository', () {
    late SharedPreferences prefs;
    late SettingsRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      repo = SettingsRepository(StorageService(prefs));
    });

    test('load returns defaults when nothing saved', () {
      final settings = repo.load();
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.searchEngine, SearchEngine.google);
      expect(settings.adBlockEnabled, isTrue);
      expect(settings.javaScriptEnabled, isTrue);
      expect(settings.popUpBlockingEnabled, isTrue);
      expect(settings.cookiePolicy, CookiePolicy.acceptAll);
    });

    test('save and load round-trips', () async {
      final settings = const BrowserSettings().copyWith(
        themeMode: ThemeMode.dark,
        searchEngine: SearchEngine.duckDuckGo,
        javaScriptEnabled: false,
        cookiePolicy: CookiePolicy.blockAll,
      );
      await repo.save(settings);

      final loaded = repo.load();
      expect(loaded.themeMode, ThemeMode.dark);
      expect(loaded.searchEngine, SearchEngine.duckDuckGo);
      expect(loaded.javaScriptEnabled, isFalse);
      expect(loaded.cookiePolicy, CookiePolicy.blockAll);
    });

    test('persistence survives reload (new repo instance)', () async {
      final settings = const BrowserSettings().copyWith(
        themeMode: ThemeMode.light,
        searchEngine: SearchEngine.brave,
      );
      await repo.save(settings);

      // Simulate reload: create new repo with same prefs
      final repo2 = SettingsRepository(StorageService(prefs));
      final loaded = repo2.load();

      expect(loaded.themeMode, ThemeMode.light);
      expect(loaded.searchEngine, SearchEngine.brave);
    });

    test('save preserves all fields', () async {
      final settings = BrowserSettings(
        themeMode: ThemeMode.dark,
        searchEngine: SearchEngine.bing,
        adBlockEnabled: false,
        httpsUpgradeEnabled: false,
        homePage: 'https://custom.home',
        javaScriptEnabled: false,
        popUpBlockingEnabled: false,
        cookiePolicy: CookiePolicy.blockThirdParty,
      );
      await repo.save(settings);

      final loaded = repo.load();
      expect(loaded.themeMode, ThemeMode.dark);
      expect(loaded.searchEngine, SearchEngine.bing);
      expect(loaded.adBlockEnabled, isFalse);
      expect(loaded.httpsUpgradeEnabled, isFalse);
      expect(loaded.homePage, 'https://custom.home');
      expect(loaded.javaScriptEnabled, isFalse);
      expect(loaded.popUpBlockingEnabled, isFalse);
      expect(loaded.cookiePolicy, CookiePolicy.blockThirdParty);
    });
  });
}
