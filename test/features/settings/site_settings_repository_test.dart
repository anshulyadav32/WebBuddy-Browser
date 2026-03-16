import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_buddy/core/services/storage_service.dart';
import 'package:web_buddy/features/settings/data/site_settings_repository.dart';
import 'package:web_buddy/features/settings/domain/site_permission.dart';
import 'package:web_buddy/features/settings/domain/site_settings.dart';

void main() {
  group('SiteSettingsRepository', () {
    late SharedPreferences prefs;
    late SiteSettingsRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      repo = SiteSettingsRepository(StorageService(prefs));
    });

    test('loadAll returns empty map initially', () {
      expect(repo.loadAll(), isEmpty);
    });

    test('save and loadAll round-trips', () async {
      final settings = SiteSettings(
        domain: 'example.com',
        javaScriptEnabled: false,
        permissions: [
          const SitePermission(
            domain: 'example.com',
            type: SitePermissionType.camera,
            state: PermissionState.deny,
          ),
        ],
      );

      await repo.save(settings);
      final loaded = repo.loadAll();

      expect(loaded.length, 1);
      expect(loaded['example.com']!.domain, 'example.com');
      expect(loaded['example.com']!.javaScriptEnabled, false);
      expect(loaded['example.com']!.permissions.length, 1);
      expect(
        loaded['example.com']!.permissions.first.state,
        PermissionState.deny,
      );
    });

    test('loadForDomain returns null for unknown domain', () {
      expect(repo.loadForDomain('unknown.com'), isNull);
    });

    test('loadForDomain returns saved settings', () async {
      await repo.save(
        const SiteSettings(domain: 'test.com', popUpBlockingEnabled: false),
      );
      final s = repo.loadForDomain('test.com');
      expect(s, isNotNull);
      expect(s!.popUpBlockingEnabled, false);
    });

    test('remove deletes site settings', () async {
      await repo.save(const SiteSettings(domain: 'a.com'));
      await repo.save(const SiteSettings(domain: 'b.com'));

      await repo.remove('a.com');
      final loaded = repo.loadAll();

      expect(loaded.length, 1);
      expect(loaded.containsKey('a.com'), false);
      expect(loaded.containsKey('b.com'), true);
    });

    test('clearAll removes everything', () async {
      await repo.save(const SiteSettings(domain: 'a.com'));
      await repo.save(const SiteSettings(domain: 'b.com'));

      await repo.clearAll();
      expect(repo.loadAll(), isEmpty);
    });

    test('loadAll handles corrupt JSON gracefully', () async {
      await prefs.setString('site_settings.all', 'not-json');
      expect(repo.loadAll(), isEmpty);
    });
  });
}
