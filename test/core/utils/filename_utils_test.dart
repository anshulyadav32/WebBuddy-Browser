import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/downloads/domain/file_name_utils.dart';

/// Comprehensive unit tests for [FileNameUtils].
void main() {
  // ── deriveFromUrl ──────────────────────────────────────────────────

  group('FileNameUtils.deriveFromUrl', () {
    test('derives filename from simple URL', () {
      expect(
        FileNameUtils.deriveFromUrl('https://example.com/report.pdf'),
        'report.pdf',
      );
    });

    test('preserves extension', () {
      final name = FileNameUtils.deriveFromUrl(
        'https://cdn.example.com/image.png',
      );
      expect(name, endsWith('.png'));
    });

    test('strips query parameters from filename', () {
      // deriveFromUrl uses Uri.pathSegments which strips query
      expect(
        FileNameUtils.deriveFromUrl('https://example.com/file.zip?v=2'),
        'file.zip',
      );
    });

    test('returns fallback for URL ending with slash', () {
      expect(
        FileNameUtils.deriveFromUrl('https://example.com/'),
        'download',
      );
    });

    test('returns fallback for URL with no path segments', () {
      expect(
        FileNameUtils.deriveFromUrl('https://example.com'),
        'download',
      );
    });

    test('returns custom fallback when provided', () {
      expect(
        FileNameUtils.deriveFromUrl(
          'https://example.com/',
          fallback: 'untitled',
        ),
        'untitled',
      );
    });

    test('handles deeply nested path', () {
      expect(
        FileNameUtils.deriveFromUrl(
          'https://cdn.example.com/a/b/c/d/archive.tar.gz',
        ),
        'archive.tar.gz',
      );
    });

    test('sanitizes invalid characters in URL path segment', () {
      // Invalid characters should be replaced with underscore
      final name = FileNameUtils.deriveFromUrl(
        'https://example.com/file<name>.txt',
      );
      expect(name, isNotEmpty);
      expect(name.contains('<'), isFalse);
      expect(name.contains('>'), isFalse);
    });

    test('handles pathless malformed URL gracefully', () {
      // Uri.parse is very lenient, so a plain string becomes a path segment.
      // The function should still return a non-empty sanitized name.
      final name = FileNameUtils.deriveFromUrl('not a url at all');
      expect(name, isNotEmpty);
    });
  });

  // ── deriveFromContentDisposition ───────────────────────────────────

  group('FileNameUtils.deriveFromContentDisposition', () {
    test('parses quoted filename', () {
      expect(
        FileNameUtils.deriveFromContentDisposition(
          'attachment; filename="report.pdf"',
        ),
        'report.pdf',
      );
    });

    test('parses unquoted filename', () {
      expect(
        FileNameUtils.deriveFromContentDisposition(
          'attachment; filename=report.pdf',
        ),
        'report.pdf',
      );
    });

    test('parses UTF-8 filename* header', () {
      expect(
        FileNameUtils.deriveFromContentDisposition(
          "attachment; filename*=UTF-8''my%20file.pdf",
        ),
        'my file.pdf',
      );
    });

    test('returns null for null input', () {
      expect(FileNameUtils.deriveFromContentDisposition(null), isNull);
    });

    test('returns null for empty input', () {
      expect(FileNameUtils.deriveFromContentDisposition(''), isNull);
    });

    test('returns null for header without filename', () {
      expect(
        FileNameUtils.deriveFromContentDisposition('attachment'),
        isNull,
      );
    });
  });

  // ── sanitize ───────────────────────────────────────────────────────

  group('FileNameUtils.sanitize', () {
    test('replaces invalid characters with underscore', () {
      final result = FileNameUtils.sanitize('file<name>:test.txt');
      expect(result.contains('<'), isFalse);
      expect(result.contains('>'), isFalse);
      expect(result.contains(':'), isFalse);
    });

    test('collapses consecutive underscores', () {
      final result = FileNameUtils.sanitize('a<<<b');
      expect(result.contains('___'), isFalse);
    });

    test('trims leading dots and spaces', () {
      final result = FileNameUtils.sanitize('...file.txt');
      expect(result, 'file.txt');
    });

    test('trims trailing dots and spaces', () {
      final result = FileNameUtils.sanitize('file.txt...');
      expect(result, 'file.txt');
    });

    test('limits length to 200 characters', () {
      final longName = 'a' * 300;
      expect(FileNameUtils.sanitize(longName).length, 200);
    });

    test('returns empty for all-invalid input', () {
      final result = FileNameUtils.sanitize('...');
      expect(result, isEmpty);
    });
  });

  // ── formatBytes ────────────────────────────────────────────────────

  group('FileNameUtils.formatBytes', () {
    test('formats zero bytes', () {
      expect(FileNameUtils.formatBytes(0), '0 B');
    });

    test('formats bytes', () {
      expect(FileNameUtils.formatBytes(500), '500 B');
    });

    test('formats kilobytes', () {
      expect(FileNameUtils.formatBytes(1024), '1.0 KB');
    });

    test('formats megabytes', () {
      expect(FileNameUtils.formatBytes(1048576), '1.0 MB');
    });

    test('formats gigabytes', () {
      expect(FileNameUtils.formatBytes(1073741824), '1.0 GB');
    });

    test('negative bytes returns 0 B', () {
      expect(FileNameUtils.formatBytes(-1), '0 B');
    });
  });
}
