import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/storage_service.dart';
import '../data/settings_repository.dart';
import '../domain/browser_settings.dart';

// ── Providers wiring ─────────────────────────────────────────────────
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // Overridden in main.dart before runApp.
  throw UnimplementedError('SharedPreferences not initialised');
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(ref.watch(sharedPreferencesProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(storageServiceProvider));
});

// ── Settings controller ──────────────────────────────────────────────
final settingsControllerProvider =
    NotifierProvider<SettingsController, BrowserSettings>(
      SettingsController.new,
    );

class SettingsController extends Notifier<BrowserSettings> {
  late final SettingsRepository _repo;

  @override
  BrowserSettings build() {
    _repo = ref.watch(settingsRepositoryProvider);
    return _repo.load();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _repo.save(state);
  }

  Future<void> setSearchEngine(SearchEngine engine) async {
    state = state.copyWith(searchEngine: engine);
    await _repo.save(state);
  }

  Future<void> setAdBlockEnabled(bool enabled) async {
    state = state.copyWith(adBlockEnabled: enabled);
    await _repo.save(state);
  }

  Future<void> setHttpsUpgradeEnabled(bool enabled) async {
    state = state.copyWith(httpsUpgradeEnabled: enabled);
    await _repo.save(state);
  }

  Future<void> setHomePage(String url) async {
    state = state.copyWith(homePage: url);
    await _repo.save(state);
  }
}
