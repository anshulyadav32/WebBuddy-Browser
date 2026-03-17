import '../domain/blocked_request.dart';
import '../domain/filter_rule.dart';

/// The result of evaluating a request URL against the filter rules.
class BlockDecision {
  const BlockDecision({
    required this.shouldBlock,
    this.matchedRule,
    this.isTracker = false,
  });

  /// Whether the request should be blocked.
  final bool shouldBlock;

  /// The filter rule that matched, if any.
  final FilterRule? matchedRule;

  /// Whether the matched rule is classified as a tracker rule.
  final bool isTracker;

  static const allowed = BlockDecision(shouldBlock: false);
}

/// Evaluates URLs against a set of parsed [FilterRule]s.
///
/// ## Design
///
/// This is an MVP blocking engine that performs simple domain/substring
/// matching. It does **not** implement the full ABP specification — there
/// is no regex compilation, no `$script`/`$image` resource-type filtering,
/// and no separator-character expansion.
///
/// The matching strategy:
/// 1. Check exception rules first — if a URL matches an exception, allow.
/// 2. Check blocking rules — if a URL matches, block.
/// 3. For `$third-party` rules, require that the request domain differs
///    from the page domain.
///
/// ## Known tracker domains
///
/// A small set of well-known tracker domains is used for the
/// `isTracker` heuristic. This is intentionally simple — a production
/// browser would use a separate tracker list (e.g. EasyPrivacy).
class RequestBlockingEngine {
  RequestBlockingEngine({required this.rules}) {
    for (final rule in rules) {
      if (rule.isCosmetic) {
        _cosmeticRules.add(rule);
      } else if (rule.isException) {
        _exceptionRules.add(rule);
      } else {
        _blockingRules.add(rule);
      }
    }
  }

  /// All loaded rules.
  final List<FilterRule> rules;

  final List<FilterRule> _blockingRules = [];
  final List<FilterRule> _exceptionRules = [];
  final List<FilterRule> _cosmeticRules = [];

  /// Well-known tracker-related patterns used for the `isTracker` heuristic.
  static const _trackerPatterns = {
    'google-analytics.com',
    'googletagmanager.com',
    'facebook.net/tr',
    'facebook.com/tr',
    'connect.facebook.net',
    'analytics.google.com',
    'scorecardresearch.com',
    'quantserve.com',
    'bluekai.com',
    'krxd.net',
    'exelator.com',
    'tapad.com',
    'demdex.net',
    'chartbeat.net',
    'hotjar.com',
    'mixpanel.com',
    'segment.io',
    'amplitude.com',
    'pixel.facebook.com',
    'pixel.quantserve.com',
    'analytics.twitter.com',
  };

  /// Evaluates whether [requestUrl] should be blocked.
  ///
  /// [pageUrl] is the URL of the page making the request, used for
  /// third-party detection.
  BlockDecision evaluate({
    required String requestUrl,
    required String pageUrl,
  }) {
    final requestLower = requestUrl.toLowerCase();
    final requestDomain = _extractDomain(requestLower);
    final pageDomain = _extractDomain(pageUrl.toLowerCase());
    final isThirdParty =
        requestDomain != null &&
        pageDomain != null &&
        !_isSameSite(requestDomain, pageDomain);

    // 1. Check exceptions first.
    for (final rule in _exceptionRules) {
      if (_matches(rule, requestLower, requestDomain, isThirdParty)) {
        return BlockDecision.allowed;
      }
    }

    // 2. Check blocking rules.
    for (final rule in _blockingRules) {
      if (_matches(rule, requestLower, requestDomain, isThirdParty)) {
        final isTracker = _isTrackerPattern(rule.pattern);
        return BlockDecision(
          shouldBlock: true,
          matchedRule: rule,
          isTracker: isTracker,
        );
      }
    }

    return BlockDecision.allowed;
  }

  /// Returns cosmetic selectors applicable to the given [pageUrl].
  List<String> cosmeticSelectorsFor(String pageUrl) {
    final pageDomain = _extractDomain(pageUrl.toLowerCase());
    final selectors = <String>[];

    for (final rule in _cosmeticRules) {
      if (rule.cosmeticSelector == null) continue;

      // Global cosmetic rule (no domain restriction).
      if (rule.domains.isEmpty) {
        selectors.add(rule.cosmeticSelector!);
        continue;
      }

      // Domain-specific cosmetic rule.
      if (pageDomain != null &&
          rule.domains.any((d) => _isSameSite(pageDomain, d))) {
        selectors.add(rule.cosmeticSelector!);
      }
    }

    return selectors;
  }

  /// Converts a [BlockDecision] into a [BlockedRequest] record.
  static BlockedRequest toBlockedRequest(
    BlockDecision decision,
    String requestUrl,
  ) {
    return BlockedRequest(
      url: requestUrl,
      domain: _extractDomain(requestUrl.toLowerCase()) ?? requestUrl,
      matchedFilter: decision.matchedRule?.raw ?? '',
      blockedAt: DateTime.now(),
      isTracker: decision.isTracker,
    );
  }

  // ── Private helpers ──────────────────────────────────────────────

  bool _matches(
    FilterRule rule,
    String requestLower,
    String? requestDomain,
    bool isThirdParty,
  ) {
    // Third-party check.
    if (rule.thirdPartyOnly && !isThirdParty) return false;

    // Domain restriction check.
    if (rule.domains.isNotEmpty && requestDomain != null) {
      final matchesDomain = rule.domains.any(
        (d) => _isSameSite(requestDomain, d),
      );
      if (!matchesDomain) {
        // For domain-restricted rules, the domain list applies to the
        // *page* domain, not the request domain. However for our simple
        // MVP we check if the request itself matches the pattern.
      }
    }

    // Pattern matching: check if the request URL contains the pattern.
    if (requestLower.contains(rule.pattern)) return true;

    // Also check domain match for domain-anchor rules.
    if (requestDomain != null && _isSameSite(requestDomain, rule.pattern)) {
      return true;
    }

    return false;
  }

  bool _isTrackerPattern(String pattern) {
    return _trackerPatterns.any(
      (t) => pattern.contains(t) || t.contains(pattern),
    );
  }

  static bool _isSameSite(String domain1, String domain2) {
    if (domain1 == domain2) return true;
    // Check if one is a subdomain of the other.
    return domain1.endsWith('.$domain2') || domain2.endsWith('.$domain1');
  }

  static String? _extractDomain(String url) {
    try {
      var working = url;
      // Strip scheme.
      final schemeEnd = working.indexOf('://');
      if (schemeEnd >= 0) {
        working = working.substring(schemeEnd + 3);
      }
      // Strip path.
      final pathStart = working.indexOf('/');
      if (pathStart >= 0) {
        working = working.substring(0, pathStart);
      }
      // Strip port.
      final portStart = working.indexOf(':');
      if (portStart >= 0) {
        working = working.substring(0, portStart);
      }
      // Strip www.
      if (working.startsWith('www.')) {
        working = working.substring(4);
      }
      return working.isEmpty ? null : working;
    } catch (_) {
      return null;
    }
  }
}
