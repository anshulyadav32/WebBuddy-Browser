import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/site_settings_repository.dart';
import '../domain/site_permission.dart';
import '../domain/site_settings.dart';
import 'settings_controller.dart';

// ── Providers ────────────────────────────────────────────────────────

final siteSettingsRepositoryProvider = Provider<SiteSettingsRepository>((ref) {
  return SiteSettingsRepository(ref.watch(storageServiceProvider));
});

final siteSettingsControllerProvider =
    StateNotifierProvider<SiteSettingsController, Map<String, SiteSettings>>((
      ref,
    ) {
      final repo = ref.watch(siteSettingsRepositoryProvider);
      return SiteSettingsController(repo);
    });

// ── Controller ───────────────────────────────────────────────────────

/// Manages per-site settings and permissions.
class SiteSettingsController extends StateNotifier<Map<String, SiteSettings>> {
  SiteSettingsController(this._repo) : super(_repo.loadAll());

  final SiteSettingsRepository _repo;

  /// Returns the settings for [domain], or a default-constructed instance.
  SiteSettings forDomain(String domain) {
    return state[domain] ?? SiteSettings(domain: domain);
  }

  /// Updates a per-site JavaScript override.
  Future<void> setJavaScript(String domain, bool? enabled) async {
    final current = forDomain(domain);
    final updated = current.copyWith(javaScriptEnabled: () => enabled);
    state = {...state, domain: updated};
    await _repo.save(updated);
  }

  /// Updates a per-site pop-up blocking override.
  Future<void> setPopUpBlocking(String domain, bool? enabled) async {
    final current = forDomain(domain);
    final updated = current.copyWith(popUpBlockingEnabled: () => enabled);
    state = {...state, domain: updated};
    await _repo.save(updated);
  }

  /// Sets or updates a permission for [domain].
  Future<void> setPermission(
    String domain,
    SitePermissionType type,
    PermissionState permState,
  ) async {
    final current = forDomain(domain);
    final existing = current.permissions.toList();
    final idx = existing.indexWhere((p) => p.type == type);

    final perm = SitePermission(domain: domain, type: type, state: permState);

    if (idx >= 0) {
      existing[idx] = perm;
    } else {
      existing.add(perm);
    }

    final updated = current.copyWith(permissions: existing);
    state = {...state, domain: updated};
    await _repo.save(updated);
  }

  /// Removes all settings for [domain].
  Future<void> removeDomain(String domain) async {
    state = Map.from(state)..remove(domain);
    await _repo.remove(domain);
  }

  /// Clears all site settings.
  Future<void> clearAll() async {
    state = {};
    await _repo.clearAll();
  }
}
