import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/core/utils/url_utils.dart';

void main() {
  group('UrlUtils.isUrl', () {
    test('detects full https URL', () {
      expect(UrlUtils.isUrl('https://example.com'), isTrue);
    });

    test('detects full http URL', () {
      expect(UrlUtils.isUrl('http://example.com'), isTrue);
    });

    test('detects domain without scheme', () {
      expect(UrlUtils.isUrl('example.com'), isTrue);
    });

    test('detects subdomain', () {
      expect(UrlUtils.isUrl('www.example.com'), isTrue);
    });

    test('detects localhost', () {
      expect(UrlUtils.isUrl('localhost'), isTrue);
    });

    test('detects localhost with port', () {
      expect(UrlUtils.isUrl('localhost:8080'), isTrue);
    });

    test('detects IPv4 address', () {
      expect(UrlUtils.isUrl('192.168.1.1'), isTrue);
    });

    test('rejects plain search query', () {
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
  });

  group('UrlUtils.normalise', () {
    test('preserves existing https scheme', () {
      expect(
        UrlUtils.normalise('https://example.com'),
        equals('https://example.com'),
      );
    });

    test('preserves existing http scheme', () {
      expect(
        UrlUtils.normalise('http://example.com'),
        equals('http://example.com'),
      );
    });

    test('prepends https to bare domain', () {
      expect(UrlUtils.normalise('example.com'), equals('https://example.com'));
    });

    test('trims whitespace', () {
      expect(
        UrlUtils.normalise('  example.com  '),
        equals('https://example.com'),
      );
    });
  });

  group('UrlUtils.extractDomain', () {
    test('extracts domain from full URL', () {
      expect(
        UrlUtils.extractDomain('https://www.example.com/path'),
        equals('example.com'),
      );
    });

    test('extracts domain when no www', () {
      expect(
        UrlUtils.extractDomain('https://example.co.uk/page'),
        equals('example.co.uk'),
      );
    });

    test('extracts domain from bare input', () {
      expect(UrlUtils.extractDomain('github.com'), equals('github.com'));
    });

    test('returns null for empty input', () {
      expect(UrlUtils.extractDomain(''), isNull);
    });
  });

  group('UrlUtils.buildSearchUrl', () {
    test('encodes query into search URL', () {
      final result = UrlUtils.buildSearchUrl(
        'dart lang',
        searchUrl: 'https://www.google.com/search?q=',
      );
      expect(result, equals('https://www.google.com/search?q=dart+lang'));
    });
  });
}
