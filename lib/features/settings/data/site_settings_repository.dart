import 'dart:convert';

import 'package:web_buddy/core/services/storage_service.dart';
import 'package:web_buddy/features/settings/domain/site_settings.dart';

/// Persists per-site settings to SharedPreferences as JSON.
class SiteSettingsRepository {
  const SiteSettingsRepository(this._storage);

  final StorageService _storage;

  static const _key = 'site_settings.all';

  /// Loads all stored site settings.
  Map<String, SiteSettings> loadAll() {
    final raw = _storage.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map(
        (k, v) => MapEntry(k, SiteSettings.fromMap(v as Map<String, dynamic>)),
      );
    } catch (_) {
      return {};
    }
  }

  /// Returns site settings for [domain], or `null` if not stored.
  SiteSettings? loadForDomain(String domain) => loadAll()[domain];

  /// Saves or updates settings for a single domain.
  Future<void> save(SiteSettings settings) async {
    final all = loadAll();
    all[settings.domain] = settings;
    await _persist(all);
  }

  /// Removes settings for [domain].
  Future<void> remove(String domain) async {
    final all = loadAll();
    all.remove(domain);
    await _persist(all);
  }

  /// Clears all site settings.
  Future<void> clearAll() async {
    await _storage.remove(_key);
  }

  Future<void> _persist(Map<String, SiteSettings> all) async {
    final encoded = jsonEncode(all.map((k, v) => MapEntry(k, v.toMap())));
    await _storage.setString(_key, encoded);
  }
}
