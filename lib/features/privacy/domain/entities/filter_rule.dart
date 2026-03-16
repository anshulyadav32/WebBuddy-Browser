/// Represents a single parsed filter rule from an EasyList-style filter list.
///
/// Supports basic network request blocking rules. Does NOT support:
/// - Full ABP/uBlock extended CSS selectors (cosmetic filtering is limited)
/// - Complex regex filters
/// - Scriptlet injection
///
/// This handles the most common rule patterns which cover ~80% of blocking:
/// - Domain blocking: ||example.com^
/// - Path blocking: /ads/banner
/// - Wildcard rules: ||ads*.example.com^
/// - Exception rules: @@||example.com^
/// - Third-party modifiers: $third-party
/// - Domain restrictions: $domain=example.com
class FilterRule {
  final String raw;
  final String pattern;
  final bool isException;
  final bool isThirdParty;
  final Set<String> applicableDomains;
  final Set<String> excludedDomains;
  final bool isComment;
  final bool isCosmeticRule;
  final RegExp? _compiledPattern;

  FilterRule._({
    required this.raw,
    required this.pattern,
    required this.isException,
    required this.isThirdParty,
    required this.applicableDomains,
    required this.excludedDomains,
    required this.isComment,
    required this.isCosmeticRule,
    RegExp? compiledPattern,
  }) : _compiledPattern = compiledPattern;

  /// Parses a single filter rule line.
  factory FilterRule.parse(String line) {
    final trimmed = line.trim();

    // Comments
    if (trimmed.isEmpty ||
        trimmed.startsWith('!') ||
        trimmed.startsWith('[')) {
      return FilterRule._(
        raw: trimmed,
        pattern: '',
        isException: false,
        isThirdParty: false,
        applicableDomains: const {},
        excludedDomains: const {},
        isComment: true,
        isCosmeticRule: false,
      );
    }

    // Cosmetic filters (##, #@#, #?#)
    if (trimmed.contains('##') ||
        trimmed.contains('#@#') ||
        trimmed.contains('#?#')) {
      return FilterRule._(
        raw: trimmed,
        pattern: trimmed,
        isException: false,
        isThirdParty: false,
        applicableDomains: const {},
        excludedDomains: const {},
        isComment: false,
        isCosmeticRule: true,
      );
    }

    var rule = trimmed;
    var isException = false;
    var isThirdParty = false;
    Set<String> applicableDomains = {};
    Set<String> excludedDomains = {};

    // Exception rules
    if (rule.startsWith('@@')) {
      isException = true;
      rule = rule.substring(2);
    }

    // Parse options after $
    final dollarIndex = rule.lastIndexOf('\$');
    if (dollarIndex != -1) {
      final options = rule.substring(dollarIndex + 1).split(',');
      rule = rule.substring(0, dollarIndex);

      for (final opt in options) {
        final trimOpt = opt.trim().toLowerCase();
        if (trimOpt == 'third-party' || trimOpt == '3p') {
          isThirdParty = true;
        } else if (trimOpt.startsWith('domain=')) {
          final domains = trimOpt.substring(7).split('|');
          for (final d in domains) {
            if (d.startsWith('~')) {
              excludedDomains.add(d.substring(1));
            } else {
              applicableDomains.add(d);
            }
          }
        }
        // Other options (script, image, etc.) are noted but our interception
        // layer has limited ability to distinguish resource types.
      }
    }

    // Convert filter pattern to regex
    final regexPattern = _patternToRegex(rule);
    RegExp? compiled;
    try {
      compiled = RegExp(regexPattern, caseSensitive: false);
    } catch (_) {
      // Invalid regex — rule will never match
    }

    return FilterRule._(
      raw: trimmed,
      pattern: rule,
      isException: isException,
      isThirdParty: isThirdParty,
      applicableDomains: applicableDomains,
      excludedDomains: excludedDomains,
      isComment: false,
      isCosmeticRule: false,
      compiledPattern: compiled,
    );
  }

  /// Tests if a URL matches this filter rule.
  bool matches(String url, {String? pageHost}) {
    if (isComment || isCosmeticRule || _compiledPattern == null) return false;

    // Domain restrictions check
    if (applicableDomains.isNotEmpty && pageHost != null) {
      if (!applicableDomains.any((d) => pageHost.endsWith(d))) return false;
    }
    if (excludedDomains.isNotEmpty && pageHost != null) {
      if (excludedDomains.any((d) => pageHost.endsWith(d))) return false;
    }

    // Third-party check
    if (isThirdParty && pageHost != null) {
      try {
        final requestHost = Uri.parse(url).host;
        if (_isSameSite(requestHost, pageHost)) return false;
      } catch (_) {}
    }

    return _compiledPattern!.hasMatch(url);
  }

  static bool _isSameSite(String host1, String host2) {
    // Simple same-site check based on eTLD+1 approximation.
    final parts1 = host1.split('.');
    final parts2 = host2.split('.');
    if (parts1.length < 2 || parts2.length < 2) return host1 == host2;
    final domain1 = parts1.sublist(parts1.length - 2).join('.');
    final domain2 = parts2.sublist(parts2.length - 2).join('.');
    return domain1 == domain2;
  }

  /// Converts a filter pattern to a regular expression string.
  static String _patternToRegex(String pattern) {
    var p = pattern;

    // Handle ||domain anchors
    if (p.startsWith('||')) {
      p = p.substring(2);
      p = '^https?://([a-z0-9-]+\\.)*${RegExp.escape(p)}';
    } else if (p.startsWith('|')) {
      p = '^${RegExp.escape(p.substring(1))}';
    } else {
      p = RegExp.escape(p);
    }

    // Trailing |
    if (p.endsWith('|')) {
      p = '${p.substring(0, p.length - 1)}\$';
    }

    // ^ = separator (anything except alphanumeric, -, ., %)
    p = p.replaceAll(RegExp.escape('^'), r'([^a-zA-Z0-9\-\.%]|$)');

    // * = wildcard
    p = p.replaceAll(RegExp.escape('*'), '.*');

    return p;
  }
}
