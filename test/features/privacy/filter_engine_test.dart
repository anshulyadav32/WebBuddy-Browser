import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/privacy/domain/services/filter_engine.dart';

void main() {
  late FilterEngine engine;

  setUp(() {
    engine = FilterEngine();
  });

  group('FilterEngine.loadRules', () {
    test('loads rules from filter list content', () {
      engine.loadRules('''
! Title: Test filters
||ads.example.com^
||tracker.example.com^\$third-party
@@||safe.example.com^
##.ad-banner
''');

      expect(engine.blockingRuleCount, 2);
      expect(engine.exceptionRuleCount, 1);
      expect(engine.cosmeticRuleCount, 1);
    });

    test('skips comments and empty lines', () {
      engine.loadRules('''
! Comment
[Adblock Plus 2.0]

! Another comment
||ads.com^
''');

      expect(engine.totalRuleCount, 1);
    });
  });

  group('FilterEngine.shouldBlock', () {
    setUp(() {
      engine.loadRules('''
||ads.example.com^
||tracker.net^\$third-party
@@||safe.tracker.net^
''');
    });

    test('blocks matching URLs', () {
      final result = engine.shouldBlock('https://ads.example.com/banner.js');
      expect(result.blocked, isTrue);
      expect(result.matchedRule, isNotNull);
    });

    test('allows non-matching URLs', () {
      final result = engine.shouldBlock('https://example.com/page.html');
      expect(result.blocked, isFalse);
    });

    test('exception rules override blocking', () {
      final result = engine.shouldBlock('https://safe.tracker.net/api');
      expect(result.blocked, isFalse);
      expect(result.isException, isTrue);
    });

    test('third-party rules only block cross-site requests', () {
      // Same-site: should NOT block
      final sameSite = engine.shouldBlock(
        'https://tracker.net/script.js',
        pageHost: 'tracker.net',
      );
      expect(sameSite.blocked, isFalse);

      // Cross-site: SHOULD block
      final crossSite = engine.shouldBlock(
        'https://tracker.net/script.js',
        pageHost: 'example.com',
      );
      expect(crossSite.blocked, isTrue);
    });
  });

  group('FilterEngine.getCosmeticSelectorsForDomain', () {
    test('returns global cosmetic selectors', () {
      engine.loadRules('''
##.ad-banner
##.advertisement
''');

      final selectors = engine.getCosmeticSelectorsForDomain('example.com');
      expect(selectors, contains('.ad-banner'));
      expect(selectors, contains('.advertisement'));
    });

    test('returns domain-specific selectors', () {
      engine.loadRules('''
example.com##.site-specific-ad
other.com##.other-ad
''');

      final selectors = engine.getCosmeticSelectorsForDomain('example.com');
      expect(selectors, contains('.site-specific-ad'));
      expect(selectors.length, 1);
    });
  });

  group('FilterEngine.clearRules', () {
    test('removes all rules', () {
      engine.loadRules('||ads.com^\n##.ad\n@@||safe.com^');
      expect(engine.totalRuleCount, greaterThan(0));

      engine.clearRules();
      expect(engine.totalRuleCount, 0);
    });
  });
}
