import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_buddy/features/settings/domain/entities/browser_settings.dart';

final settingsProvider =
    NotifierProvider<SettingsNotifier, BrowserSettings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<BrowserSettings> {
  static const _storageKey = 'browser_settings';
  final _storage = const FlutterSecureStorage();

  @override
  BrowserSettings build() {
    _loadSettings();
    return const BrowserSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final jsonStr = await _storage.read(key: _storageKey);
      if (jsonStr != null) {
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        state = BrowserSettings.fromJson(json);
      }
    } catch (_) {
      // Use defaults if storage fails
    }
  }

  Future<void> _saveSettings() async {
    try {
      await _storage.write(
        key: _storageKey,
        value: jsonEncode(state.toJson()),
      );
    } catch (_) {
      // Settings save failure is non-critical
    }
  }

  void updateSettings(BrowserSettings Function(BrowserSettings) updater) {
    state = updater(state);
    _saveSettings();
  }

  void setSearchEngine(String engineId) {
    updateSettings((s) => s.copyWith(searchEngineId: engineId));
  }

  void toggleAdBlocking() {
    updateSettings((s) => s.copyWith(adBlockingEnabled: !s.adBlockingEnabled));
  }

  void toggleTrackerBlocking() {
    updateSettings(
        (s) => s.copyWith(trackerBlockingEnabled: !s.trackerBlockingEnabled));
  }

  void toggleHttpsUpgrade() {
    updateSettings(
        (s) => s.copyWith(httpsUpgradeEnabled: !s.httpsUpgradeEnabled));
  }

  void toggleJavascript() {
    updateSettings((s) => s.copyWith(javascriptEnabled: !s.javascriptEnabled));
  }

  void togglePopupBlocking() {
    updateSettings(
        (s) => s.copyWith(popupBlockingEnabled: !s.popupBlockingEnabled));
  }

  void setCookiePolicy(CookiePolicy policy) {
    updateSettings((s) => s.copyWith(cookiePolicy: policy));
  }

  void setThemeMode(ThemeMode mode) {
    updateSettings((s) => s.copyWith(themeMode: mode));
  }

  void toggleAntiFingerprinting() {
    updateSettings(
        (s) => s.copyWith(antiFingerprinting: !s.antiFingerprinting));
  }
}
