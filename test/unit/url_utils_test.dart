import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/core/utils/url_utils.dart';

/// Unit tests for [UrlUtils] — URL detection and normalisation logic.
void main() {
  // ── looksLikeUrl (isUrl) ─────────────────────────────────────────

  group('UrlUtils.isUrl — URL detection', () {
    test('accepts full https URL', () {
      expect(UrlUtils.isUrl('https://example.com'), isTrue);
    });

    test('accepts full http URL', () {
      expect(UrlUtils.isUrl('http://example.com'), isTrue);
    });

    test('accepts bare domain with TLD', () {
      expect(UrlUtils.isUrl('example.com'), isTrue);
    });

    test('accepts subdomain', () {
      expect(UrlUtils.isUrl('www.example.com'), isTrue);
    });

    test('accepts multi-level subdomain', () {
      expect(UrlUtils.isUrl('mail.google.com'), isTrue);
    });

    test('accepts localhost', () {
      expect(UrlUtils.isUrl('localhost'), isTrue);
    });

    test('accepts localhost with port', () {
      expect(UrlUtils.isUrl('localhost:3000'), isTrue);
    });

    test('accepts localhost with port and path', () {
      expect(UrlUtils.isUrl('localhost:8080/api'), isTrue);
    });

    test('accepts IPv4 address', () {
      expect(UrlUtils.isUrl('192.168.1.1'), isTrue);
    });

    test('accepts domain with path', () {
      expect(UrlUtils.isUrl('example.com/path'), isTrue);
    });

    test('accepts domain with country-code TLD', () {
      expect(UrlUtils.isUrl('example.co.uk'), isTrue);
    });

    test('rejects plain search query with spaces', () {
      expect(UrlUtils.isUrl('flutter tutorials'), isFalse);
    });

    test('rejects single word without TLD', () {
      expect(UrlUtils.isUrl('hello'), isFalse);
    });

    test('rejects empty string', () {
      expect(UrlUtils.isUrl(''), isFalse);
    });

    test('rejects whitespace only', () {
      expect(UrlUtils.isUrl('   '), isFalse);
    });

    test('rejects sentence-like input', () {
      expect(UrlUtils.isUrl('how to cook pasta'), isFalse);
    });
  });

  // ── normalizeInputToUrl (normalise) ──────────────────────────────

  group('UrlUtils.normalise — URL normalisation', () {
    test('preserves existing https scheme', () {
      expect(UrlUtils.normalise('https://example.com'), 'https://example.com');
    });

    test('preserves existing http scheme', () {
      expect(UrlUtils.normalise('http://example.com'), 'http://example.com');
    });

    test('prepends https to bare domain', () {
      expect(UrlUtils.normalise('example.com'), 'https://example.com');
    });

    test('prepends https to domain with port', () {
      expect(
        UrlUtils.normalise('example.com:8080'),
        'https://example.com:8080',
      );
    });

    test('prepends https to domain with path', () {
      expect(
        UrlUtils.normalise('example.com/foo/bar'),
        'https://example.com/foo/bar',
      );
    });

    test('preserves URL with query parameters', () {
      expect(
        UrlUtils.normalise('https://example.com/search?q=test'),
        'https://example.com/search?q=test',
      );
    });

    test('trims leading whitespace', () {
      expect(UrlUtils.normalise('  example.com'), 'https://example.com');
    });

    test('trims trailing whitespace', () {
      expect(UrlUtils.normalise('example.com  '), 'https://example.com');
    });

    test('trims surrounding whitespace', () {
      expect(UrlUtils.normalise('  example.com  '), 'https://example.com');
    });
  });

  // ── extractDomain ────────────────────────────────────────────────

  group('UrlUtils.extractDomain', () {
    test('extracts domain stripping www', () {
      expect(
        UrlUtils.extractDomain('https://www.example.com/path'),
        'example.com',
      );
    });

    test('preserves domain without www', () {
      expect(
        UrlUtils.extractDomain('https://example.co.uk/page'),
        'example.co.uk',
      );
    });

    test('works with bare domain input', () {
      expect(UrlUtils.extractDomain('github.com'), 'github.com');
    });

    test('returns null for empty string', () {
      expect(UrlUtils.extractDomain(''), isNull);
    });
  });

  // ── buildSearchUrl ───────────────────────────────────────────────

  group('UrlUtils.buildSearchUrl', () {
    test('encodes query into search URL', () {
      expect(
        UrlUtils.buildSearchUrl(
          'dart lang',
          searchUrl: 'https://www.google.com/search?q=',
        ),
        'https://www.google.com/search?q=dart+lang',
      );
    });

    test('encodes special characters', () {
      expect(
        UrlUtils.buildSearchUrl(
          'c++ tutorial',
          searchUrl: 'https://www.google.com/search?q=',
        ),
        contains('c%2B%2B'),
      );
    });
  });
}
