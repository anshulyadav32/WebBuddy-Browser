import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/privacy/data/request_blocking_engine.dart';
import 'package:web_buddy/features/privacy/domain/filter_rule.dart';

void main() {
  late RequestBlockingEngine engine;

  setUp(() {
    final rules = [
      FilterRule.tryParse('||doubleclick.net^'),
      FilterRule.tryParse('||googlesyndication.com^'),
      FilterRule.tryParse('||google-analytics.com^\$third-party'),
      FilterRule.tryParse('@@||accounts.google.com^'),
      FilterRule.tryParse('@@||fonts.googleapis.com^'),
      FilterRule.tryParse('##.ad-banner'),
      FilterRule.tryParse('||facebook.net/tr^'),
      FilterRule.tryParse('||hotjar.com^\$third-party'),
    ].whereType<FilterRule>().toList();

    engine = RequestBlockingEngine(rules: rules);
  });

  group('RequestBlockingEngine — blocking', () {
    test('blocks request to ad domain', () {
      final decision = engine.evaluate(
        requestUrl: 'https://ad.doubleclick.net/something',
        pageUrl: 'https://news.example.com',
      );
      expect(decision.shouldBlock, isTrue);
    });

    test('blocks request matching domain pattern', () {
      final decision = engine.evaluate(
        requestUrl: 'https://pagead2.googlesyndication.com/ads',
        pageUrl: 'https://example.com',
      );
      expect(decision.shouldBlock, isTrue);
    });

    test('allows request to non-matching domain', () {
      final decision = engine.evaluate(
        requestUrl: 'https://www.flutter.dev/docs',
        pageUrl: 'https://example.com',
      );
      expect(decision.shouldBlock, isFalse);
    });

    test('classifies tracker patterns correctly', () {
      final decision = engine.evaluate(
        requestUrl: 'https://www.google-analytics.com/analytics.js',
        pageUrl: 'https://example.com',
      );
      expect(decision.shouldBlock, isTrue);
      expect(decision.isTracker, isTrue);
    });

    test('classifies ad patterns as non-tracker', () {
      final decision = engine.evaluate(
        requestUrl: 'https://ad.doubleclick.net/ad.js',
        pageUrl: 'https://example.com',
      );
      expect(decision.shouldBlock, isTrue);
      expect(decision.isTracker, isFalse);
    });
  });

  group('RequestBlockingEngine — exceptions', () {
    test('allows excepted domain', () {
      final decision = engine.evaluate(
        requestUrl: 'https://accounts.google.com/login',
        pageUrl: 'https://example.com',
      );
      expect(decision.shouldBlock, isFalse);
    });

    test('allows excepted CDN domain', () {
      final decision = engine.evaluate(
        requestUrl: 'https://fonts.googleapis.com/css',
        pageUrl: 'https://example.com',
      );
      expect(decision.shouldBlock, isFalse);
    });
  });

  group('RequestBlockingEngine — third-party detection', () {
    test('blocks third-party tracker request', () {
      final decision = engine.evaluate(
        requestUrl: 'https://www.google-analytics.com/analytics.js',
        pageUrl: 'https://example.com',
      );
      expect(decision.shouldBlock, isTrue);
    });

    test('allows first-party request for third-party-only rule', () {
      final decision = engine.evaluate(
        requestUrl: 'https://www.google-analytics.com/analytics.js',
        pageUrl: 'https://google-analytics.com/dashboard',
      );
      expect(decision.shouldBlock, isFalse);
    });
  });

  group('RequestBlockingEngine — cosmetic selectors', () {
    test('returns global cosmetic selectors', () {
      final selectors = engine.cosmeticSelectorsFor('https://example.com');
      expect(selectors, contains('.ad-banner'));
    });

    test('returns selectors for specific domain', () {
      // Build engine with domain-specific cosmetic rule.
      final rules = [
        FilterRule.tryParse('example.com##.site-ad'),
        FilterRule.tryParse('##.global-ad'),
      ].whereType<FilterRule>().toList();
      final localEngine = RequestBlockingEngine(rules: rules);

      final selectors = localEngine.cosmeticSelectorsFor(
        'https://example.com/page',
      );
      expect(selectors, contains('.global-ad'));
      expect(selectors, contains('.site-ad'));
    });

    test('does not return domain-specific selector for other domain', () {
      final rules = [
        FilterRule.tryParse('example.com##.site-ad'),
      ].whereType<FilterRule>().toList();
      final localEngine = RequestBlockingEngine(rules: rules);

      final selectors = localEngine.cosmeticSelectorsFor('https://other.com');
      expect(selectors, isNot(contains('.site-ad')));
    });
  });

  group('RequestBlockingEngine — toBlockedRequest', () {
    test('creates BlockedRequest from decision', () {
      final decision = engine.evaluate(
        requestUrl: 'https://ad.doubleclick.net/test',
        pageUrl: 'https://example.com',
      );
      final blocked = RequestBlockingEngine.toBlockedRequest(
        decision,
        'https://ad.doubleclick.net/test',
      );
      expect(blocked.domain, 'ad.doubleclick.net');
      expect(blocked.matchedFilter, isNotEmpty);
    });
  });

  group('RequestBlockingEngine — empty rules', () {
    test('allows all requests with no rules', () {
      final emptyEngine = RequestBlockingEngine(rules: []);
      final decision = emptyEngine.evaluate(
        requestUrl: 'https://ad.doubleclick.net/ad',
        pageUrl: 'https://example.com',
      );
      expect(decision.shouldBlock, isFalse);
    });
  });
}
