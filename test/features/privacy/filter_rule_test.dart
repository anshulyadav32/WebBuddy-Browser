import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/privacy/domain/entities/filter_rule.dart';

void main() {
  group('FilterRule.parse', () {
    test('parses comment lines', () {
      final rule = FilterRule.parse('! This is a comment');
      expect(rule.isComment, isTrue);
    });

    test('parses empty lines as comments', () {
      final rule = FilterRule.parse('');
      expect(rule.isComment, isTrue);
    });

    test('parses header lines as comments', () {
      final rule = FilterRule.parse('[Adblock Plus 2.0]');
      expect(rule.isComment, isTrue);
    });

    test('parses basic domain blocking rules', () {
      final rule = FilterRule.parse('||doubleclick.net^');
      expect(rule.isComment, isFalse);
      expect(rule.isException, isFalse);
      expect(rule.isCosmeticRule, isFalse);
    });

    test('parses exception rules', () {
      final rule = FilterRule.parse('@@||accounts.google.com^');
      expect(rule.isException, isTrue);
    });

    test('parses third-party option', () {
      final rule = FilterRule.parse('||analytics.com^\$third-party');
      expect(rule.isThirdParty, isTrue);
    });

    test('parses domain option', () {
      final rule = FilterRule.parse('||ads.com^\$domain=example.com|test.com');
      expect(rule.applicableDomains, contains('example.com'));
      expect(rule.applicableDomains, contains('test.com'));
    });

    test('parses excluded domains', () {
      final rule = FilterRule.parse('||ads.com^\$domain=~safe.com');
      expect(rule.excludedDomains, contains('safe.com'));
    });

    test('parses cosmetic rules', () {
      final rule = FilterRule.parse('##.ad-banner');
      expect(rule.isCosmeticRule, isTrue);
    });

    test('parses domain-specific cosmetic rules', () {
      final rule = FilterRule.parse('example.com##.ad-wrapper');
      expect(rule.isCosmeticRule, isTrue);
    });
  });

  group('FilterRule.matches', () {
    test('matches domain blocking rules', () {
      final rule = FilterRule.parse('||doubleclick.net^');
      expect(
        rule.matches('https://doubleclick.net/ads/show'),
        isTrue,
      );
      expect(
        rule.matches('https://sub.doubleclick.net/pixel'),
        isTrue,
      );
    });

    test('does not match unrelated URLs', () {
      final rule = FilterRule.parse('||doubleclick.net^');
      expect(
        rule.matches('https://example.com/page'),
        isFalse,
      );
    });

    test('respects third-party restriction', () {
      final rule = FilterRule.parse('||tracker.com^\$third-party');
      // Same-site request should NOT match
      expect(
        rule.matches('https://tracker.com/script.js', pageHost: 'tracker.com'),
        isFalse,
      );
      // Third-party request SHOULD match
      expect(
        rule.matches('https://tracker.com/script.js', pageHost: 'example.com'),
        isTrue,
      );
    });

    test('respects domain restrictions', () {
      final rule = FilterRule.parse('||ads.com^\$domain=example.com');
      expect(
        rule.matches('https://ads.com/banner', pageHost: 'example.com'),
        isTrue,
      );
      expect(
        rule.matches('https://ads.com/banner', pageHost: 'other.com'),
        isFalse,
      );
    });

    test('respects excluded domains', () {
      final rule = FilterRule.parse('||ads.com^\$domain=~safe.com');
      expect(
        rule.matches('https://ads.com/banner', pageHost: 'safe.com'),
        isFalse,
      );
      expect(
        rule.matches('https://ads.com/banner', pageHost: 'other.com'),
        isTrue,
      );
    });

    test('comments never match', () {
      final rule = FilterRule.parse('! comment');
      expect(rule.matches('https://anything.com'), isFalse);
    });

    test('cosmetic rules never match URLs', () {
      final rule = FilterRule.parse('##.ad-banner');
      expect(rule.matches('https://anything.com'), isFalse);
    });
  });
}
