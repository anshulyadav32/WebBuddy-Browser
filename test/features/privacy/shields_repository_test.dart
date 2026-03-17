import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_buddy/core/services/storage_service.dart';
import 'package:web_buddy/features/privacy/data/shields_repository.dart';
import 'package:web_buddy/features/privacy/domain/site_shield_settings.dart';

void main() {
  late ShieldsRepository repo;
  late StorageService storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storage = StorageService(prefs);
    repo = ShieldsRepository(storage);
  });

  group('ShieldsRepository — basic operations', () {
    test('loadAll returns empty map initially', () {
      expect(repo.loadAll(), isEmpty);
    });

    test('save and load round-trips correctly', () async {
      const settings = SiteShieldSettings(
        domain: 'example.com',
        enabled: false,
      );
      await repo.save(settings);

      final loaded = repo.loadForDomain('example.com');
      expect(loaded, isNotNull);
      expect(loaded!.domain, 'example.com');
      expect(loaded.enabled, isFalse);
    });

    test('isShieldEnabled returns true by default', () {
      expect(repo.isShieldEnabled('unknown.com'), isTrue);
    });

    test('isShieldEnabled returns false after disabling', () async {
      await repo.save(
        const SiteShieldSettings(domain: 'noads.com', enabled: false),
      );
      expect(repo.isShieldEnabled('noads.com'), isFalse);
    });

    test('remove restores default behaviour', () async {
      await repo.save(
        const SiteShieldSettings(domain: 'test.com', enabled: false),
      );
      expect(repo.isShieldEnabled('test.com'), isFalse);

      await repo.remove('test.com');
      expect(repo.isShieldEnabled('test.com'), isTrue);
    });

    test('clearAll removes all overrides', () async {
      await repo.save(
        const SiteShieldSettings(domain: 'a.com', enabled: false),
      );
      await repo.save(
        const SiteShieldSettings(domain: 'b.com', enabled: false),
      );
      expect(repo.loadAll().length, 2);

      await repo.clearAll();
      expect(repo.loadAll(), isEmpty);
    });
  });

  group('ShieldsRepository — multiple domains', () {
    test('stores settings for multiple domains independently', () async {
      await repo.save(
        const SiteShieldSettings(domain: 'ads.com', enabled: false),
      );
      await repo.save(
        const SiteShieldSettings(domain: 'safe.com', enabled: true),
      );

      expect(repo.isShieldEnabled('ads.com'), isFalse);
      expect(repo.isShieldEnabled('safe.com'), isTrue);
      expect(repo.loadAll().length, 2);
    });

    test('overwriting a domain updates the setting', () async {
      await repo.save(
        const SiteShieldSettings(domain: 'flip.com', enabled: false),
      );
      expect(repo.isShieldEnabled('flip.com'), isFalse);

      await repo.save(
        const SiteShieldSettings(domain: 'flip.com', enabled: true),
      );
      expect(repo.isShieldEnabled('flip.com'), isTrue);
    });
  });
}
