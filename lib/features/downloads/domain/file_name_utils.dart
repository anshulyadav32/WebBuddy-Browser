/// Utilities for deriving and sanitizing download filenames.
abstract final class FileNameUtils {
  /// Characters not allowed in filenames across platforms.
  static final _invalidChars = RegExp(r'[<>:"/\\|?*\x00-\x1F]');

  /// Derives a filename from a URL.
  ///
  /// Extracts the last path segment, strips query params, and falls back
  /// to a default name if the URL has no useful filename.
  static String deriveFromUrl(String url, {String fallback = 'download'}) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments.where((s) => s.isNotEmpty).toList();

      if (pathSegments.isNotEmpty) {
        final last = pathSegments.last;
        final sanitized = sanitize(last);
        if (sanitized.isNotEmpty) return sanitized;
      }
    } catch (_) {
      // Fall through to default.
    }
    return fallback;
  }

  /// Derives a filename from a Content-Disposition header value.
  ///
  /// Supports both `filename="name.ext"` and `filename*=UTF-8''name.ext`.
  static String? deriveFromContentDisposition(String? header) {
    if (header == null || header.isEmpty) return null;

    // Try filename*= (RFC 5987) first.
    final starMatch = RegExp(
      r'''filename\*\s*=\s*(?:UTF-8|utf-8)?'[^']*'(.+)''',
      caseSensitive: false,
    ).firstMatch(header);
    if (starMatch != null) {
      final decoded = Uri.decodeComponent(starMatch.group(1)!.trim());
      final sanitized = sanitize(decoded);
      if (sanitized.isNotEmpty) return sanitized;
    }

    // Try filename= (quoted or unquoted).
    final match = RegExp(
      r'filename\s*=\s*"?([^";]+)"?',
      caseSensitive: false,
    ).firstMatch(header);
    if (match != null) {
      final sanitized = sanitize(match.group(1)!.trim());
      if (sanitized.isNotEmpty) return sanitized;
    }

    return null;
  }

  /// Sanitizes a string for use as a filename.
  ///
  /// Removes invalid characters, collapses dots/spaces, and trims.
  static String sanitize(String name) {
    var result = name.replaceAll(_invalidChars, '_');
    // Collapse consecutive underscores.
    result = result.replaceAll(RegExp(r'_{2,}'), '_');
    // Trim leading/trailing dots, spaces, underscores.
    result = result.replaceAll(RegExp(r'^[.\s_]+|[.\s_]+$'), '');
    // Limit length to 200 characters.
    if (result.length > 200) result = result.substring(0, 200);
    return result;
  }

  /// Formats bytes into a human-readable string.
  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    var size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(i == 0 ? 0 : 1)} ${suffixes[i]}';
  }
}
