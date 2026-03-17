import 'package:flutter/material.dart';

import 'package:web_buddy/core/services/storage_service.dart';
import 'package:web_buddy/features/settings/domain/browser_settings.dart';

/// Keys used in SharedPreferences.
abstract final class _Keys {
  static const themeMode = 'settings.themeMode';
  static const searchEngine = 'settings.searchEngine';
  static const adBlockEnabled = 'settings.adBlockEnabled';
  static const httpsUpgradeEnabled = 'settings.httpsUpgradeEnabled';
  static const homePage = 'settings.homePage';
  static const javaScriptEnabled = 'settings.javaScriptEnabled';
  static const cacheEnabled = 'settings.cacheEnabled';
  static const scrollbarsEnabled = 'settings.scrollbarsEnabled';
  static const customUserAgent = 'settings.customUserAgent';
  static const popUpBlockingEnabled = 'settings.popUpBlockingEnabled';
  static const cookiePolicy = 'settings.cookiePolicy';
}

/// Persistence layer for [BrowserSettings].
class SettingsRepository {
  const SettingsRepository(this._storage);

  final StorageService _storage;

  BrowserSettings load() {
    return BrowserSettings(
      themeMode: ThemeMode.values[_storage.getInt(_Keys.themeMode) ?? 0],
      searchEngine:
          SearchEngine.values[_storage.getInt(_Keys.searchEngine) ?? 0],
      adBlockEnabled: _storage.getBool(_Keys.adBlockEnabled) ?? true,
      httpsUpgradeEnabled: _storage.getBool(_Keys.httpsUpgradeEnabled) ?? true,
      homePage: _storage.getString(_Keys.homePage) ?? 'https://google.com',
      javaScriptEnabled: _storage.getBool(_Keys.javaScriptEnabled) ?? true,
      cacheEnabled: _storage.getBool(_Keys.cacheEnabled) ?? true,
      scrollbarsEnabled: _storage.getBool(_Keys.scrollbarsEnabled) ?? true,
      customUserAgent: _storage.getString(_Keys.customUserAgent) ?? '',
      popUpBlockingEnabled:
          _storage.getBool(_Keys.popUpBlockingEnabled) ?? true,
      cookiePolicy:
          CookiePolicy.values[_storage.getInt(_Keys.cookiePolicy) ?? 0],
    );
  }

  Future<void> save(BrowserSettings s) async {
    await Future.wait([
      _storage.setInt(_Keys.themeMode, s.themeMode.index),
      _storage.setInt(_Keys.searchEngine, s.searchEngine.index),
      _storage.setBool(_Keys.adBlockEnabled, s.adBlockEnabled),
      _storage.setBool(_Keys.httpsUpgradeEnabled, s.httpsUpgradeEnabled),
      _storage.setString(_Keys.homePage, s.homePage),
      _storage.setBool(_Keys.javaScriptEnabled, s.javaScriptEnabled),
      _storage.setBool(_Keys.cacheEnabled, s.cacheEnabled),
      _storage.setBool(_Keys.scrollbarsEnabled, s.scrollbarsEnabled),
      _storage.setString(_Keys.customUserAgent, s.customUserAgent),
      _storage.setBool(_Keys.popUpBlockingEnabled, s.popUpBlockingEnabled),
      _storage.setInt(_Keys.cookiePolicy, s.cookiePolicy.index),
    ]);
  }
}
