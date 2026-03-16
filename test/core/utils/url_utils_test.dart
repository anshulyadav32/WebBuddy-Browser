import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/core/utils/url_utils.dart';

/// Unit tests for [UrlUtils] — URL detection, normalisation, and helpers.
void main() {
  // ── isUrl ────────────────────────────────────────────────────────

  group('UrlUtils.isUrl', () {
    test('returns true for full https URL', () {
      expect(UrlUtils.isUrl('https://example.com'), isTrue);
    });

    test('returns true for full http URL', () {
      expect(UrlUtils.isUrl('http://example.com'), isTrue);
    });

    test('returns true for bare domain with TLD', () {
      expect(UrlUtils.isUrl('example.com'), isTrue);
    });

    test('returns true for subdomain', () {
      expect(UrlUtils.isUrl('www.example.com'), isTrue);
    });

    test('returns true for localhost', () {
      expect(UrlUtils.isUrl('localhost'), isTrue);
    });

    test('returns true for localhost with port', () {
      expect(UrlUtils.isUrl('localhost:3000'), isTrue);
    });

    test('returns true for IPv4 address', () {
      expect(UrlUtils.isUrl('192.168.1.1'), isTrue);
    });

    test('returns false for search query with spaces', () {
      expect(UrlUtils.isUrl('flutter tutorials'), isFalse);
    });

    test('returns false for single word without TLD', () {
      expect(UrlUtils.isUrl('hello'), isFalse);
    });

    test('returns false for empty string', () {
      expect(UrlUtils.isUrl(''), isFalse);
    });

    test('returns false for whitespace only', () {
      expect(UrlUtils.isUrl('   '), isFalse);
    });
  });

  // ── normalise ────────────────────────────────────────────────────

  group('UrlUtils.normalise', () {
    test('preserves existing https scheme', () {
      expect(UrlUtils.normalise('https://example.com'), 'https://example.com');
    });

    test('preserves existing http scheme', () {
      expect(UrlUtils.normalise('http://example.com'), 'http://example.com');
    });

    test('prepends https to bare domain', () {
      expect(UrlUtils.normalise('example.com'), 'https://example.com');
    });

    test('handles blank input (just returns https://)', () {
      expect(UrlUtils.normalise(''), 'https://');
    });
  });

  // ── extractDomain ────────────────────────────────────────────────

  group('UrlUtils.extractDomain', () {
    test('extracts domain from full URL', () {
      expect(
        UrlUtils.extractDomain('https://www.example.com/path'),
        'example.com',
      );
    });

    test('extracts domain without www', () {
      expect(UrlUtils.extractDomain('https://example.com'), 'example.com');
    });

    test('returns null for empty string', () {
      expect(UrlUtils.extractDomain(''), isNull);
    });
  });

  // ── buildSearchUrl ───────────────────────────────────────────────

  group('UrlUtils.buildSearchUrl', () {
    test('builds Google search URL', () {
      final url = UrlUtils.buildSearchUrl(
        'flutter tutorials',
        searchUrl: 'https://www.google.com/search?q=',
      );
      expect(url, contains('flutter+tutorials'));
      expect(url, startsWith('https://www.google.com/search?q='));
    });

    test('encodes special characters', () {
      final url = UrlUtils.buildSearchUrl(
        'hello world & more',
        searchUrl: 'https://search.example.com?q=',
      );
      expect(url, contains('%26'));
    });
  });
}
