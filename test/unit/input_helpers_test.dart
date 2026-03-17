import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/core/utils/url_utils.dart';
import 'package:web_buddy/features/downloads/domain/file_name_utils.dart';

void main() {
  group('Input helpers – UrlUtils', () {
    test('isUrl rejects malformed and plain input', () {
      expect(UrlUtils.isUrl(''), isFalse);
      expect(UrlUtils.isUrl('hello world'), isFalse);
      expect(UrlUtils.isUrl('not_a_url'), isFalse);
    });

    test('isUrl accepts domain/localhost/ip', () {
      expect(UrlUtils.isUrl('example.com'), isTrue);
      expect(UrlUtils.isUrl('localhost:3000'), isTrue);
      expect(UrlUtils.isUrl('192.168.1.10'), isTrue);
    });

    test('normalise preserves known schemes and adds https otherwise', () {
      expect(UrlUtils.normalise('https://example.com'), 'https://example.com');
      expect(UrlUtils.normalise('about:blank'), 'about:blank');
      expect(UrlUtils.normalise('example.com'), 'https://example.com');
    });

    test('buildSearchUrl encodes user input safely', () {
      final url = UrlUtils.buildSearchUrl(
        'c++ guide',
        searchUrl: 'https://www.google.com/search?q=',
      );
      expect(url, contains('c%2B%2B'));
    });
  });

  group('Input helpers – FileNameUtils', () {
    test('deriveFromUrl returns fallback for malformed/empty urls', () {
      expect(FileNameUtils.deriveFromUrl(''), 'download');
      expect(FileNameUtils.deriveFromUrl(':::'), 'download');
    });

    test('deriveFromUrl extracts last path segment', () {
      expect(
        FileNameUtils.deriveFromUrl('https://example.com/files/report.pdf'),
        'report.pdf',
      );
    });

    test('sanitize removes invalid characters and trims', () {
      expect(FileNameUtils.sanitize(' ..bad<>name?.txt '), 'bad_name_.txt');
    });

    test('formatBytes produces readable output', () {
      expect(FileNameUtils.formatBytes(0), '0 B');
      expect(FileNameUtils.formatBytes(1536), '1.5 KB');
    });
  });
}
