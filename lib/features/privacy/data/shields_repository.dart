import 'dart:convert';

import '../../../core/services/storage_service.dart';
import '../domain/site_shield_settings.dart';

/// Persists per-site shield settings to SharedPreferences.
class ShieldsRepository {
  const ShieldsRepository(this._storage);

  final StorageService _storage;

  static const _key = 'shields.site_settings';

  /// Loads all persisted per-site shield settings.
  Map<String, SiteShieldSettings> loadAll() {
    final raw = _storage.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map(
        (k, v) =>
            MapEntry(k, SiteShieldSettings.fromMap(v as Map<String, dynamic>)),
      );
    } catch (_) {
      return {};
    }
  }

  /// Returns shield settings for [domain], or `null`.
  SiteShieldSettings? loadForDomain(String domain) => loadAll()[domain];

  /// Whether shields are enabled for [domain].
  ///
  /// Returns `true` (shields on) by default when no override exists.
  bool isShieldEnabled(String domain) {
    return loadForDomain(domain)?.enabled ?? true;
  }

  /// Saves or updates shield settings for a single domain.
  Future<void> save(SiteShieldSettings settings) async {
    final all = loadAll();
    all[settings.domain] = settings;
    await _persist(all);
  }

  /// Removes shield settings for [domain] (reverts to default: shields on).
  Future<void> remove(String domain) async {
    final all = loadAll();
    all.remove(domain);
    await _persist(all);
  }

  /// Clears all per-site shield overrides.
  Future<void> clearAll() async {
    await _storage.remove(_key);
  }

  Future<void> _persist(Map<String, SiteShieldSettings> all) async {
    final encoded = jsonEncode(all.map((k, v) => MapEntry(k, v.toMap())));
    await _storage.setString(_key, encoded);
  }
}
