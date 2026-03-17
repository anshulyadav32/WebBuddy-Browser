import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/privacy/data/request_blocking_engine.dart';
import 'package:web_buddy/features/privacy/domain/filter_rule.dart';

/// Tests for third-party request detection logic.
void main() {
  group('Third-party detection', () {
    test('same-origin request is first-party (not blocked by 3p rule)', () {
      final rule = FilterRule.tryParse(r'||ads.example.com^$third-party')!;
      final engine = RequestBlockingEngine(rules: [rule]);

      // Request from example.com to ads.example.com → same site = first-party
      final decision = engine.evaluate(
        requestUrl: 'https://ads.example.com/banner.js',
        pageUrl: 'https://example.com/page',
      );

      // Should NOT be blocked — rule is third-party only, but this is
      // same-site (ads.example.com is a subdomain of example.com).
      expect(decision.shouldBlock, isFalse);
    });

    test('different domain request is third-party (blocked by 3p rule)', () {
      final rule = FilterRule.tryParse(r'||tracker.net^$third-party')!;
      final engine = RequestBlockingEngine(rules: [rule]);

      final decision = engine.evaluate(
        requestUrl: 'https://tracker.net/pixel.gif',
        pageUrl: 'https://mysite.com/page',
      );

      expect(decision.shouldBlock, isTrue);
    });

    test('subdomain of page domain is first-party', () {
      final rule = FilterRule.tryParse(r'||cdn.mysite.com^$third-party')!;
      final engine = RequestBlockingEngine(rules: [rule]);

      final decision = engine.evaluate(
        requestUrl: 'https://cdn.mysite.com/style.css',
        pageUrl: 'https://mysite.com/',
      );

      // cdn.mysite.com is a subdomain of mysite.com → first-party
      expect(decision.shouldBlock, isFalse);
    });

    test('completely different domains are third-party', () {
      final rule = FilterRule.tryParse(r'||analytics.io^$third-party')!;
      final engine = RequestBlockingEngine(rules: [rule]);

      final decision = engine.evaluate(
        requestUrl: 'https://analytics.io/track',
        pageUrl: 'https://blog.example.com/',
      );

      expect(decision.shouldBlock, isTrue);
    });

    test('non-third-party rule blocks regardless of party', () {
      final rule = FilterRule.tryParse(r'||ads.example.com^')!;
      final engine = RequestBlockingEngine(rules: [rule]);

      // First-party request
      final decision = engine.evaluate(
        requestUrl: 'https://ads.example.com/ad.js',
        pageUrl: 'https://example.com/page',
      );

      // Should be blocked — rule has no third-party restriction
      expect(decision.shouldBlock, isTrue);
    });

    test('exception rule takes precedence over block', () {
      final rules = [
        FilterRule.tryParse(r'||doubleclick.net^')!,
        FilterRule.tryParse(r'@@||doubleclick.net/safe^')!,
      ];
      final engine = RequestBlockingEngine(rules: rules);

      final blocked = engine.evaluate(
        requestUrl: 'https://doubleclick.net/ad.js',
        pageUrl: 'https://example.com',
      );
      expect(blocked.shouldBlock, isTrue);

      final allowed = engine.evaluate(
        requestUrl: 'https://doubleclick.net/safe/api',
        pageUrl: 'https://example.com',
      );
      expect(allowed.shouldBlock, isFalse);
    });
  });
}
