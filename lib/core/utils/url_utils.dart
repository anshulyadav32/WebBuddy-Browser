/// URL detection and manipulation utilities.
abstract final class UrlUtils {
  /// Pattern that matches strings that look like URLs.
  static final _urlPattern = RegExp(
    r'^(https?://)' // explicit scheme
    r'|^(localhost(:\d+)?(/.*)?$)' // localhost
    r'|^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})' // IPv4
    r'|^([a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}', // domain
    caseSensitive: false,
  );

  /// Returns `true` if [input] looks like a URL rather than a search query.
  static bool isUrl(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.contains(' ')) return false;
    return _urlPattern.hasMatch(trimmed);
  }

  /// Ensures [input] has a scheme. Prepends `https://` when missing.
  static String normalise(String input) {
    final trimmed = input.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'https://$trimmed';
  }

  /// Extracts the registrable domain from a URL string.
  /// `https://www.example.co.uk/path` → `example.co.uk`
  static String? extractDomain(String url) {
    try {
      final uri = Uri.parse(normalise(url));
      final host = uri.host;
      if (host.isEmpty) return null;
      // Strip leading "www."
      return host.startsWith('www.') ? host.substring(4) : host;
    } catch (_) {
      return null;
    }
  }

  /// Builds a search URL for the given [query] using [searchUrl] prefix.
  static String buildSearchUrl(String query, {required String searchUrl}) {
    return '$searchUrl${Uri.encodeQueryComponent(query)}';
  }
}
