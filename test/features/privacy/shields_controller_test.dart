import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_buddy/core/services/storage_service.dart';
import 'package:web_buddy/features/privacy/data/filter_list_repository.dart';
import 'package:web_buddy/features/privacy/data/shields_repository.dart';
import 'package:web_buddy/features/privacy/domain/filter_rule.dart';
import 'package:web_buddy/features/privacy/presentation/shields_controller.dart';

/// A test-friendly [FilterListRepository] that returns in-memory rules.
class _FakeFilterListRepository extends FilterListRepository {
  final List<FilterRule> fakeRules;
  _FakeFilterListRepository(this.fakeRules);

  @override
  Future<List<FilterRule>> loadRules() async => fakeRules;
}

void main() {
  late ShieldsController controller;
  late ShieldsRepository shieldsRepo;
  late _FakeFilterListRepository filterRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs);
    shieldsRepo = ShieldsRepository(storage);

    final rules = [
      FilterRule.tryParse('||doubleclick.net^'),
      FilterRule.tryParse('||google-analytics.com^\$third-party'),
      FilterRule.tryParse('@@||accounts.google.com^'),
      FilterRule.tryParse('##.ad-banner'),
    ].whereType<FilterRule>().toList();

    filterRepo = _FakeFilterListRepository(rules);

    controller = ShieldsController(
      shieldsRepo: shieldsRepo,
      filterListRepo: filterRepo,
      globalAdBlockEnabled: true,
    );

    // Wait for async init to complete.
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  });

  group('ShieldsController — initialisation', () {
    test('is initialised after creation', () {
      expect(controller.state.isInitialised, isTrue);
    });

    test('global enabled reflects constructor parameter', () {
      expect(controller.state.globalEnabled, isTrue);
    });

    test('engine is available after init', () {
      expect(controller.engine, isNotNull);
    });
  });

  group('ShieldsController — page navigation', () {
    test('setCurrentPage sets domain and resets stats', () {
      controller.evaluateRequest(
        requestUrl: 'https://ad.doubleclick.net/ad.js',
        pageUrl: 'https://example.com',
      );
      expect(controller.state.stats.totalBlocked, greaterThan(0));

      controller.setCurrentPage('https://newsite.com/page');
      expect(controller.state.currentDomain, 'newsite.com');
      expect(controller.state.stats.totalBlocked, 0);
      expect(controller.state.blockedRequests, isEmpty);
    });

    test('setCurrentPage enables shields by default', () {
      controller.setCurrentPage('https://example.com');
      expect(controller.state.currentSiteEnabled, isTrue);
    });
  });

  group('ShieldsController — request evaluation', () {
    test('blocks ad domain request', () {
      controller.setCurrentPage('https://example.com');
      final decision = controller.evaluateRequest(
        requestUrl: 'https://ad.doubleclick.net/ad.js',
        pageUrl: 'https://example.com',
      );
      expect(decision.shouldBlock, isTrue);
      expect(controller.state.stats.totalBlocked, 1);
      expect(controller.state.blockedRequests.length, 1);
    });

    test('allows excepted domain', () {
      controller.setCurrentPage('https://example.com');
      final decision = controller.evaluateRequest(
        requestUrl: 'https://accounts.google.com/login',
        pageUrl: 'https://example.com',
      );
      expect(decision.shouldBlock, isFalse);
      expect(controller.state.stats.totalBlocked, 0);
    });

    test('allows all requests when globally disabled', () async {
      final disabledController = ShieldsController(
        shieldsRepo: shieldsRepo,
        filterListRepo: filterRepo,
        globalAdBlockEnabled: false,
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      disabledController.setCurrentPage('https://example.com');
      final decision = disabledController.evaluateRequest(
        requestUrl: 'https://ad.doubleclick.net/ad.js',
        pageUrl: 'https://example.com',
      );
      expect(decision.shouldBlock, isFalse);
    });

    test('tracker classification is tracked in stats', () {
      controller.setCurrentPage('https://example.com');
      controller.evaluateRequest(
        requestUrl: 'https://www.google-analytics.com/analytics.js',
        pageUrl: 'https://example.com',
      );
      expect(controller.state.stats.trackersBlocked, 1);
      expect(controller.state.stats.adsBlocked, 0);
    });
  });

  group('ShieldsController — per-site toggle', () {
    test('toggleCurrentSiteShield disables shields for site', () async {
      controller.setCurrentPage('https://example.com');
      final shouldReload = await controller.toggleCurrentSiteShield();
      expect(shouldReload, isTrue);
      expect(controller.state.currentSiteEnabled, isFalse);
    });

    test('requests are allowed when site shields are off', () async {
      controller.setCurrentPage('https://example.com');
      await controller.toggleCurrentSiteShield();

      final decision = controller.evaluateRequest(
        requestUrl: 'https://ad.doubleclick.net/ad.js',
        pageUrl: 'https://example.com',
      );
      expect(decision.shouldBlock, isFalse);
    });

    test('toggle persists to repository', () async {
      controller.setCurrentPage('https://example.com');
      await controller.toggleCurrentSiteShield();

      expect(shieldsRepo.isShieldEnabled('example.com'), isFalse);
    });

    test('toggle back re-enables shields', () async {
      controller.setCurrentPage('https://example.com');
      await controller.toggleCurrentSiteShield(); // off
      await controller.toggleCurrentSiteShield(); // on
      expect(controller.state.currentSiteEnabled, isTrue);
    });
  });

  group('ShieldsController — cosmetic selectors', () {
    test('returns cosmetic selectors when enabled', () {
      controller.setCurrentPage('https://example.com');
      final selectors = controller.getCosmeticSelectors('https://example.com');
      expect(selectors, contains('.ad-banner'));
    });

    test('builds injection script', () {
      controller.setCurrentPage('https://example.com');
      final script = controller.buildCosmeticInjectionScript(
        'https://example.com',
      );
      expect(script, isNotNull);
      expect(script, contains('.ad-banner'));
      expect(script, contains('display: none'));
    });
  });
}
