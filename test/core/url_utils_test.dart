import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/core/utils/url_utils.dart';

void main() {
  group('UrlUtils.isUrl', () {
    test('detects standard URLs', () {
      expect(UrlUtils.isUrl('https://example.com'), isTrue);
      expect(UrlUtils.isUrl('http://example.com'), isTrue);
      expect(UrlUtils.isUrl('ftp://files.example.com'), isTrue);
    });

    test('detects domain-like inputs', () {
      expect(UrlUtils.isUrl('example.com'), isTrue);
      expect(UrlUtils.isUrl('sub.example.com'), isTrue);
      expect(UrlUtils.isUrl('example.co.uk'), isTrue);
      expect(UrlUtils.isUrl('my-site.org'), isTrue);
    });

    test('detects localhost', () {
      expect(UrlUtils.isUrl('localhost'), isTrue);
      expect(UrlUtils.isUrl('localhost:3000'), isTrue);
      expect(UrlUtils.isUrl('localhost:8080/api'), isTrue);
    });

    test('detects IP addresses', () {
      expect(UrlUtils.isUrl('192.168.1.1'), isTrue);
      expect(UrlUtils.isUrl('10.0.0.1:8080'), isTrue);
      expect(UrlUtils.isUrl('127.0.0.1/path'), isTrue);
    });

    test('rejects search queries', () {
      expect(UrlUtils.isUrl('flutter tutorial'), isFalse);
      expect(UrlUtils.isUrl('how to code'), isFalse);
      expect(UrlUtils.isUrl('what is dart'), isFalse);
      expect(UrlUtils.isUrl(''), isFalse);
    });

    test('rejects ambiguous single words without dots', () {
      expect(UrlUtils.isUrl('flutter'), isFalse);
      expect(UrlUtils.isUrl('hello'), isFalse);
    });
  });

  group('UrlUtils.normalizeUrl', () {
    test('adds https:// to bare domains', () {
      expect(UrlUtils.normalizeUrl('example.com'), 'https://example.com');
    });

    test('preserves existing scheme', () {
      expect(UrlUtils.normalizeUrl('http://example.com'), 'http://example.com');
      expect(UrlUtils.normalizeUrl('https://example.com'), 'https://example.com');
    });

    test('trims whitespace', () {
      expect(UrlUtils.normalizeUrl('  example.com  '), 'https://example.com');
    });
  });

  group('UrlUtils.extractDomain', () {
    test('extracts domain from URL', () {
      expect(UrlUtils.extractDomain('https://www.example.com/path'), 'www.example.com');
      expect(UrlUtils.extractDomain('http://sub.domain.org:8080/'), 'sub.domain.org');
    });

    test('returns input for invalid URLs', () {
      expect(UrlUtils.extractDomain('not-a-url'), 'not-a-url');
    });
  });

  group('UrlUtils.isExternalScheme', () {
    test('detects external schemes', () {
      expect(UrlUtils.isExternalScheme('tel:+1234567890'), isTrue);
      expect(UrlUtils.isExternalScheme('mailto:user@example.com'), isTrue);
      expect(UrlUtils.isExternalScheme('sms:+1234567890'), isTrue);
    });

    test('rejects web schemes', () {
      expect(UrlUtils.isExternalScheme('https://example.com'), isFalse);
      expect(UrlUtils.isExternalScheme('http://example.com'), isFalse);
    });
  });

  group('UrlUtils.tryUpgradeToHttps', () {
    test('upgrades http to https', () {
      expect(UrlUtils.tryUpgradeToHttps('http://example.com'), 'https://example.com');
    });

    test('leaves https unchanged', () {
      expect(UrlUtils.tryUpgradeToHttps('https://example.com'), 'https://example.com');
    });

    test('leaves other schemes unchanged', () {
      expect(UrlUtils.tryUpgradeToHttps('ftp://files.example.com'), 'ftp://files.example.com');
    });
  });

  group('UrlUtils.isInternalPage', () {
    test('detects internal pages', () {
      expect(UrlUtils.isInternalPage('about:blank'), isTrue);
      expect(UrlUtils.isInternalPage('about:newtab'), isTrue);
      expect(UrlUtils.isInternalPage('webbuddy:settings'), isTrue);
    });

    test('rejects regular URLs', () {
      expect(UrlUtils.isInternalPage('https://example.com'), isFalse);
    });
  });
}
