import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/privacy/domain/filter_rule.dart';
import 'package:web_buddy/features/privacy/data/filter_list_repository.dart';

void main() {
  group('FilterRule.tryParse', () {
    test('returns null for empty line', () {
      expect(FilterRule.tryParse(''), isNull);
    });

    test('returns null for comment line', () {
      expect(FilterRule.tryParse('! This is a comment'), isNull);
    });

    test('parses domain anchor rule', () {
      final rule = FilterRule.tryParse('||doubleclick.net^');
      expect(rule, isNotNull);
      expect(rule!.pattern, 'doubleclick.net');
      expect(rule.isException, isFalse);
      expect(rule.isCosmetic, isFalse);
      expect(rule.thirdPartyOnly, isFalse);
    });

    test('parses exception rule', () {
      final rule = FilterRule.tryParse('@@||accounts.google.com^');
      expect(rule, isNotNull);
      expect(rule!.pattern, 'accounts.google.com');
      expect(rule.isException, isTrue);
    });

    test('parses third-party option', () {
      final rule = FilterRule.tryParse('||google-analytics.com^\$third-party');
      expect(rule, isNotNull);
      expect(rule!.pattern, 'google-analytics.com');
      expect(rule.thirdPartyOnly, isTrue);
    });

    test('parses cosmetic filter', () {
      final rule = FilterRule.tryParse('##.ad-banner');
      expect(rule, isNotNull);
      expect(rule!.isCosmetic, isTrue);
      expect(rule.cosmeticSelector, '.ad-banner');
      expect(rule.domains, isEmpty);
    });

    test('parses domain-specific cosmetic filter', () {
      final rule = FilterRule.tryParse('example.com##.ad-banner');
      expect(rule, isNotNull);
      expect(rule!.isCosmetic, isTrue);
      expect(rule.cosmeticSelector, '.ad-banner');
      expect(rule.domains, ['example.com']);
    });

    test('parses rule with domain option', () {
      final rule = FilterRule.tryParse(
        '||tracker.com^\$third-party,domain=news.com',
      );
      expect(rule, isNotNull);
      expect(rule!.thirdPartyOnly, isTrue);
      expect(rule.domains, ['news.com']);
    });

    test('lowercases pattern', () {
      final rule = FilterRule.tryParse('||DoubleClick.Net^');
      expect(rule, isNotNull);
      expect(rule!.pattern, 'doubleclick.net');
    });

    test('handles attribute selector cosmetic', () {
      final rule = FilterRule.tryParse('##[id^="google_ads"]');
      expect(rule, isNotNull);
      expect(rule!.isCosmetic, isTrue);
      expect(rule.cosmeticSelector, '[id^="google_ads"]');
    });
  });

  group('FilterListRepository.parseRules', () {
    test('parses basic filter list text', () {
      const raw = '''
! Comment line
||doubleclick.net^
||googlesyndication.com^
@@||accounts.google.com^
##.ad-banner
''';
      final rules = FilterListRepository.parseRules(raw);
      expect(rules.length, 4);
      expect(rules[0].pattern, 'doubleclick.net');
      expect(rules[1].pattern, 'googlesyndication.com');
      expect(rules[2].isException, isTrue);
      expect(rules[3].isCosmetic, isTrue);
    });

    test('skips empty and comment lines', () {
      const raw = '''
! Title line
! Another comment

||example.com^
''';
      final rules = FilterListRepository.parseRules(raw);
      expect(rules.length, 1);
      expect(rules[0].pattern, 'example.com');
    });

    test('handles multiline cosmetic and blocking rules', () {
      const raw = '''
||ads.example.com^
##.sponsored-content
@@||cdn.jsdelivr.net^
||tracker.com^\$third-party
''';
      final rules = FilterListRepository.parseRules(raw);
      expect(rules.length, 4);
      expect(rules[0].pattern, 'ads.example.com');
      expect(rules[1].isCosmetic, isTrue);
      expect(rules[2].isException, isTrue);
      expect(rules[3].thirdPartyOnly, isTrue);
    });
  });

  group('FilterRule equality', () {
    test('rules with same raw text are equal', () {
      final a = FilterRule.tryParse('||example.com^');
      final b = FilterRule.tryParse('||example.com^');
      expect(a, equals(b));
    });

    test('rules with different raw text are not equal', () {
      final a = FilterRule.tryParse('||example.com^');
      final b = FilterRule.tryParse('||other.com^');
      expect(a, isNot(equals(b)));
    });
  });
}
