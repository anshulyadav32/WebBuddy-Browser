/// URL-related utility functions.
class UrlUtils {
  UrlUtils._();

  /// Common URL schemes that should be handled by external apps.
  static const _externalSchemes = {'tel', 'mailto', 'sms', 'geo', 'intent', 'market'};

  /// Determines if raw input is a URL or a search query.
  static bool isUrl(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return false;

    // Has explicit scheme
    if (RegExp(r'^[a-zA-Z][a-zA-Z0-9+\-.]*://').hasMatch(trimmed)) {
      return true;
    }

    // Looks like a domain (contains dot, no spaces, valid pattern)
    if (!trimmed.contains(' ') && trimmed.contains('.')) {
      final domainPattern = RegExp(
        r'^([a-zA-Z0-9]([a-zA-Z0-9\-]*[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}(:\d+)?(/.*)?$',
      );
      if (domainPattern.hasMatch(trimmed)) return true;
    }

    // localhost with optional port
    if (RegExp(r'^localhost(:\d+)?(/.*)?$').hasMatch(trimmed)) return true;

    // IPv4
    if (RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(:\d+)?(/.*)?$').hasMatch(trimmed)) {
      return true;
    }

    return false;
  }

  /// Normalizes a URL by adding scheme if needed.
  static String normalizeUrl(String input) {
    final trimmed = input.trim();

    if (RegExp(r'^[a-zA-Z][a-zA-Z0-9+\-.]*://').hasMatch(trimmed)) {
      return trimmed;
    }

    // Default to https
    return 'https://$trimmed';
  }

  /// Checks if a URL scheme should be handled by an external app.
  static bool isExternalScheme(String url) {
    try {
      final uri = Uri.parse(url);
      return _externalSchemes.contains(uri.scheme.toLowerCase());
    } catch (_) {
      return false;
    }
  }

  /// Extracts the display-friendly domain from a URL.
  static String extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.isEmpty ? url : uri.host;
    } catch (_) {
      return url;
    }
  }

  /// Checks if a URL is a special internal page.
  static bool isInternalPage(String url) {
    return url.startsWith('about:') || url.startsWith('webbuddy:');
  }

  /// Attempts to upgrade HTTP URL to HTTPS.
  static String tryUpgradeToHttps(String url) {
    if (url.startsWith('http://')) {
      return url.replaceFirst('http://', 'https://');
    }
    return url;
  }

  /// Extracts a clean title from a URL for display purposes.
  static String titleFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.host.isNotEmpty) return uri.host;
    } catch (_) {}
    return url;
  }
}
