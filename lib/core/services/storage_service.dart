import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences] so it can be injected / mocked.
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  // ── String ─────────────────────────────────────────────────────────
  String? getString(String key) => _prefs.getString(key);
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  // ── Int ────────────────────────────────────────────────────────────
  int? getInt(String key) => _prefs.getInt(key);
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  // ── Bool ───────────────────────────────────────────────────────────
  bool? getBool(String key) => _prefs.getBool(key);
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  // ── Remove / Clear ─────────────────────────────────────────────────
  Future<bool> remove(String key) => _prefs.remove(key);
  Future<bool> clear() => _prefs.clear();
}
