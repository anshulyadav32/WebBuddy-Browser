import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/downloads/domain/file_name_utils.dart';

void main() {
  // ── deriveFromUrl ────────────────────────────────────────────────

  group('FileNameUtils.deriveFromUrl', () {
    test('extracts filename from simple URL', () {
      expect(
        FileNameUtils.deriveFromUrl('https://example.com/report.pdf'),
        'report.pdf',
      );
    });

    test('extracts filename from URL with query params', () {
      expect(
        FileNameUtils.deriveFromUrl(
          'https://example.com/data.csv?v=2&token=abc',
        ),
        'data.csv',
      );
    });

    test('extracts filename from deep path', () {
      expect(
        FileNameUtils.deriveFromUrl(
          'https://cdn.example.com/assets/images/logo.png',
        ),
        'logo.png',
      );
    });

    test('returns fallback for URL with no path', () {
      expect(FileNameUtils.deriveFromUrl('https://example.com'), 'download');
    });

    test('returns fallback for empty string', () {
      expect(FileNameUtils.deriveFromUrl(''), 'download');
    });

    test('uses custom fallback', () {
      expect(
        FileNameUtils.deriveFromUrl(
          'https://example.com',
          fallback: 'file.bin',
        ),
        'file.bin',
      );
    });
  });

  // ── deriveFromContentDisposition ─────────────────────────────────

  group('FileNameUtils.deriveFromContentDisposition', () {
    test('extracts quoted filename', () {
      expect(
        FileNameUtils.deriveFromContentDisposition(
          'attachment; filename="report.pdf"',
        ),
        'report.pdf',
      );
    });

    test('extracts unquoted filename', () {
      expect(
        FileNameUtils.deriveFromContentDisposition(
          'attachment; filename=data.csv',
        ),
        'data.csv',
      );
    });

    test('extracts filename* (RFC 5987)', () {
      expect(
        FileNameUtils.deriveFromContentDisposition(
          "attachment; filename*=UTF-8''r%C3%A9sum%C3%A9.pdf",
        ),
        'résumé.pdf',
      );
    });

    test('returns null for null header', () {
      expect(FileNameUtils.deriveFromContentDisposition(null), isNull);
    });

    test('returns null for empty header', () {
      expect(FileNameUtils.deriveFromContentDisposition(''), isNull);
    });

    test('returns null for header without filename', () {
      expect(FileNameUtils.deriveFromContentDisposition('inline'), isNull);
    });
  });

  // ── sanitize ─────────────────────────────────────────────────────

  group('FileNameUtils.sanitize', () {
    test('passes through clean filename', () {
      expect(FileNameUtils.sanitize('report.pdf'), 'report.pdf');
    });

    test('replaces invalid characters with underscore', () {
      expect(FileNameUtils.sanitize('file<>name.txt'), 'file_name.txt');
    });

    test('collapses consecutive underscores', () {
      expect(FileNameUtils.sanitize('a???b.txt'), 'a_b.txt');
    });

    test('trims leading/trailing dots and spaces', () {
      expect(FileNameUtils.sanitize('...file.txt...'), 'file.txt');
    });

    test('truncates to 200 characters', () {
      final long = 'a' * 250;
      expect(FileNameUtils.sanitize(long).length, 200);
    });
  });

  // ── formatBytes ──────────────────────────────────────────────────

  group('FileNameUtils.formatBytes', () {
    test('formats zero bytes', () {
      expect(FileNameUtils.formatBytes(0), '0 B');
    });

    test('formats bytes', () {
      expect(FileNameUtils.formatBytes(512), '512 B');
    });

    test('formats kilobytes', () {
      expect(FileNameUtils.formatBytes(1536), '1.5 KB');
    });

    test('formats megabytes', () {
      expect(FileNameUtils.formatBytes(2 * 1024 * 1024), '2.0 MB');
    });

    test('formats gigabytes', () {
      expect(FileNameUtils.formatBytes(3 * 1024 * 1024 * 1024), '3.0 GB');
    });
  });
}
