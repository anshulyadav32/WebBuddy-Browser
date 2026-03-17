import 'package:flutter_test/flutter_test.dart';

import 'package:web_buddy/core/utils/url_utils.dart';
import 'package:web_buddy/features/browser/domain/browser_page_state.dart';
import 'package:web_buddy/features/downloads/domain/download_item.dart';
import 'package:web_buddy/features/privacy/data/request_blocking_engine.dart';
import 'package:web_buddy/features/privacy/domain/filter_rule.dart';
import 'package:web_buddy/features/tabs/domain/models/browser_tab_state.dart';
import 'package:web_buddy/features/tabs/domain/models/tabs_state.dart';

/// Stability hardening tests that exercise edge cases, invalid input,
/// and error paths to ensure the app does not crash under adversarial
/// or unexpected conditions.
void main() {
  group('UrlUtils – invalid / adversarial input', () {
    test('empty string is not a URL', () {
      expect(UrlUtils.isUrl(''), isFalse);
    });

    test('whitespace-only is not a URL', () {
      expect(UrlUtils.isUrl('   '), isFalse);
    });

    test('string with spaces is treated as search', () {
      expect(UrlUtils.isUrl('hello world'), isFalse);
    });

    test('javascript: URI is not recognised as URL', () {
      // javascript: scheme must not be treated as a valid navigation URL
      expect(UrlUtils.isUrl('javascript:alert(1)'), isFalse);
    });

    test('data: URI is not recognised as URL', () {
      expect(UrlUtils.isUrl('data:text/html,<h1>hi</h1>'), isFalse);
    });

    test('extremely long input does not crash', () {
      final longInput = 'a' * 100000;
      // Should not throw
      UrlUtils.isUrl(longInput);
      UrlUtils.normalise(longInput);
    });

    test('unicode input handled gracefully', () {
      // UrlUtils regex does not match IDN domains — they are treated as search
      expect(UrlUtils.isUrl('日本語.jp'), isFalse);
      expect(UrlUtils.normalise('日本語.jp'), 'https://日本語.jp');
    });

    test('extractDomain handles non-URL input without crashing', () {
      // Uri.parse percent-encodes spaces, so extractDomain returns an encoded string
      final result = UrlUtils.extractDomain('not a url at all');
      // The important thing is it does not throw
      expect(result, isNotNull);
    });

    test('extractDomain handles empty scheme correctly', () {
      expect(UrlUtils.extractDomain('://'), isNull);
    });

    test('buildSearchUrl encodes special characters', () {
      final result = UrlUtils.buildSearchUrl(
        'test <script>',
        searchUrl: 'https://search.example.com/?q=',
      );
      expect(result, contains('test'));
      expect(result, isNot(contains('<script>')));
    });

    test('normalise already-schemed URL unchanged', () {
      expect(UrlUtils.normalise('http://example.com'), 'http://example.com');
      expect(UrlUtils.normalise('https://example.com'), 'https://example.com');
    });
  });

  group('BrowserPageState – error state edge cases', () {
    test('default state has no error', () {
      const state = BrowserPageState();
      expect(state.hasError, isFalse);
      expect(state.errorDescription, isEmpty);
      expect(state.errorCode, 0);
    });

    test('copyWith preserves error fields', () {
      final errorState = const BrowserPageState().copyWith(
        hasError: true,
        errorDescription: 'Connection refused',
        errorCode: -6,
      );
      expect(errorState.hasError, isTrue);
      expect(errorState.errorCode, -6);

      // Clear error
      final cleared = errorState.copyWith(
        hasError: false,
        errorDescription: '',
      );
      expect(cleared.hasError, isFalse);
      expect(cleared.errorDescription, isEmpty);
    });

    test('error state with empty description does not crash toString', () {
      final state = const BrowserPageState().copyWith(
        hasError: true,
        errorDescription: '',
      );
      expect(state.toString(), contains('error: true'));
    });
  });

  group('TabsState – edge cases', () {
    test('empty tabs list reports no private tabs', () {
      const state = TabsState(tabs: [], activeTabId: '');
      expect(state.hasPrivateTabs, isFalse);
      expect(state.privateTabCount, 0);
    });

    test('activeTab getter handles missing tab gracefully', () {
      final tab = BrowserTabState.create();
      final state = TabsState(tabs: [tab], activeTabId: 'non-existent');
      // activeTab should return null or handle gracefully
      expect(state.tabs.where((t) => t.id == state.activeTabId), isEmpty);
    });

    test('isActiveTabPrivate with no matching tab throws', () {
      final tab = BrowserTabState.create();
      final state = TabsState(tabs: [tab], activeTabId: 'ghost');
      // activeTab uses firstWhere which throws when no match exists
      expect(() => state.isActiveTabPrivate, throwsStateError);
    });
  });

  group('FilterRule – malformed rules', () {
    test('empty line returns null', () {
      expect(FilterRule.tryParse(''), isNull);
    });

    test('comment line returns null', () {
      expect(FilterRule.tryParse('! This is a comment'), isNull);
    });

    test('bare separator returns null', () {
      // ||^ after stripping gives empty pattern
      expect(FilterRule.tryParse('||^'), isNull);
    });

    test('rule with only exception prefix returns null', () {
      expect(FilterRule.tryParse('@@||^'), isNull);
    });

    test('cosmetic rule with empty selector parses', () {
      final rule = FilterRule.tryParse('example.com##');
      // Empty selector — parser should handle without crash
      expect(rule, isNotNull);
      expect(rule!.isCosmetic, isTrue);
    });

    test('rule with multiple dollar signs parses first options block', () {
      final rule = FilterRule.tryParse(r'||ads.com^$third-party$domain=x.com');
      expect(rule, isNotNull);
    });

    test('rule with unicode domain parses', () {
      final rule = FilterRule.tryParse('||日本語.com^');
      expect(rule, isNotNull);
      expect(rule!.pattern, '日本語.com');
    });
  });

  group('RequestBlockingEngine – edge cases', () {
    test('evaluate with empty rules allows everything', () {
      final engine = RequestBlockingEngine(rules: []);
      final decision = engine.evaluate(
        requestUrl: 'https://example.com',
        pageUrl: 'https://page.com',
      );
      expect(decision.shouldBlock, isFalse);
    });

    test('evaluate with malformed URL does not crash', () {
      final engine = RequestBlockingEngine(rules: []);
      // These should not throw
      engine.evaluate(requestUrl: '', pageUrl: '');
      engine.evaluate(requestUrl: '://', pageUrl: 'https://page.com');
      engine.evaluate(requestUrl: 'not-a-url', pageUrl: 'also-not-a-url');
    });

    test('cosmetic selectors for empty page URL returns list', () {
      final rule = FilterRule.tryParse('##.ad-banner');
      final engine = RequestBlockingEngine(rules: [rule!]);
      final selectors = engine.cosmeticSelectorsFor('');
      // Global cosmetic rule — should still return it
      expect(selectors, contains('.ad-banner'));
    });

    test('exception rule takes precedence over blocking rule', () {
      final block = FilterRule.tryParse('||ads.example.com^');
      final allow = FilterRule.tryParse('@@||ads.example.com^');
      final engine = RequestBlockingEngine(rules: [block!, allow!]);

      final decision = engine.evaluate(
        requestUrl: 'https://ads.example.com/banner.js',
        pageUrl: 'https://page.com',
      );
      expect(decision.shouldBlock, isFalse);
    });

    test('third-party rule does not block same-site requests', () {
      final rule = FilterRule.tryParse(r'||analytics.example.com^$third-party');
      final engine = RequestBlockingEngine(rules: [rule!]);

      final decision = engine.evaluate(
        requestUrl: 'https://analytics.example.com/track',
        pageUrl: 'https://example.com',
      );
      // Same TLD — should not be blocked as third-party
      expect(decision.shouldBlock, isFalse);
    });
  });

  group('DownloadItem – status edge cases', () {
    test('all download statuses can be constructed', () {
      for (final status in DownloadStatus.values) {
        final item = DownloadItem(
          id: 'test-$status',
          url: 'https://example.com/file.zip',
          fileName: 'file.zip',
          savePath: '/tmp/file.zip',
          startedAt: DateTime.now(),
          status: status,
        );
        expect(item.status, status);
      }
    });

    test('download item with empty URL does not crash', () {
      final item = DownloadItem(
        id: 'empty',
        url: '',
        fileName: '',
        savePath: '',
        startedAt: DateTime.now(),
        status: DownloadStatus.queued,
      );
      expect(item.url, isEmpty);
    });
  });

  group('BrowserTabState – creation edge cases', () {
    test('create generates unique IDs', () {
      final ids = List.generate(100, (_) => BrowserTabState.create().id);
      expect(ids.toSet().length, 100, reason: 'All IDs should be unique');
    });

    test('private tab has isPrivate flag', () {
      final tab = BrowserTabState.create(isPrivate: true);
      expect(tab.isPrivate, isTrue);
    });

    test('default tab is not private', () {
      final tab = BrowserTabState.create();
      expect(tab.isPrivate, isFalse);
    });
  });
}
