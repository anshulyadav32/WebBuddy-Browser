import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/core/utils/url_utils.dart';

/// Tests for domain extraction and handling in [UrlUtils].
void main() {
  group('UrlUtils.extractDomain — extended', () {
    test('strips www prefix', () {
      expect(
        UrlUtils.extractDomain('https://www.example.com/path'),
        'example.com',
      );
    });

    test('returns domain without www when no www present', () {
      expect(UrlUtils.extractDomain('https://example.com'), 'example.com');
    });

    test('handles subdomain correctly', () {
      expect(
        UrlUtils.extractDomain('https://blog.example.com'),
        'blog.example.com',
      );
    });

    test('handles multi-level TLD', () {
      expect(
        UrlUtils.extractDomain('https://www.example.co.uk/path'),
        'example.co.uk',
      );
    });

    test('returns null for empty string', () {
      expect(UrlUtils.extractDomain(''), isNull);
    });

    test('returns null for whitespace-only string', () {
      expect(UrlUtils.extractDomain('   '), isNull);
    });

    test('handles URL with port', () {
      expect(
        UrlUtils.extractDomain('https://example.com:8080/path'),
        'example.com',
      );
    });

    test('handles URL with query string', () {
      expect(
        UrlUtils.extractDomain('https://example.com/page?q=test'),
        'example.com',
      );
    });

    test('handles URL with fragment', () {
      expect(
        UrlUtils.extractDomain('https://example.com/page#section'),
        'example.com',
      );
    });

    test('handles bare domain input', () {
      // normalise prepends https://, extractDomain parses it
      expect(UrlUtils.extractDomain('example.com'), 'example.com');
    });

    test('handles URL with query and fragment', () {
      expect(
        UrlUtils.extractDomain('https://example.com/p?q=1#top'),
        'example.com',
      );
    });

    test('handles malformed URL gracefully', () {
      // Should not throw
      final result = UrlUtils.extractDomain('not a url at all');
      // extractDomain tries to normalise, so it may or may not return null
      expect(result, isNotNull); // normalise will create https://not a url...
    });
  });
}
