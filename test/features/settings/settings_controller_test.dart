import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_buddy/features/settings/domain/browser_settings.dart';
import 'package:web_buddy/features/settings/presentation/settings_controller.dart';

void main() {
  group('SettingsController', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('loads defaults on first access', () {
      final settings = container.read(settingsControllerProvider);
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.searchEngine, SearchEngine.google);
      expect(settings.javaScriptEnabled, isTrue);
    });

    test('update theme mode', () async {
      final notifier = container.read(settingsControllerProvider.notifier);
      await notifier.setThemeMode(ThemeMode.dark);

      final settings = container.read(settingsControllerProvider);
      expect(settings.themeMode, ThemeMode.dark);
    });

    test('update search engine', () async {
      final notifier = container.read(settingsControllerProvider.notifier);
      await notifier.setSearchEngine(SearchEngine.duckDuckGo);

      final settings = container.read(settingsControllerProvider);
      expect(settings.searchEngine, SearchEngine.duckDuckGo);
    });

    test('toggle JavaScript', () async {
      final notifier = container.read(settingsControllerProvider.notifier);
      await notifier.setJavaScriptEnabled(false);

      final settings = container.read(settingsControllerProvider);
      expect(settings.javaScriptEnabled, isFalse);
    });

    test('toggle pop-up blocking', () async {
      final notifier = container.read(settingsControllerProvider.notifier);
      await notifier.setPopUpBlockingEnabled(false);

      final settings = container.read(settingsControllerProvider);
      expect(settings.popUpBlockingEnabled, isFalse);
    });

    test('update cookie policy', () async {
      final notifier = container.read(settingsControllerProvider.notifier);
      await notifier.setCookiePolicy(CookiePolicy.blockAll);

      final settings = container.read(settingsControllerProvider);
      expect(settings.cookiePolicy, CookiePolicy.blockAll);
    });

    test('settings persist across reads', () async {
      final notifier = container.read(settingsControllerProvider.notifier);
      await notifier.setThemeMode(ThemeMode.light);
      await notifier.setSearchEngine(SearchEngine.brave);

      final settings = container.read(settingsControllerProvider);
      expect(settings.themeMode, ThemeMode.light);
      expect(settings.searchEngine, SearchEngine.brave);
    });
  });
}
