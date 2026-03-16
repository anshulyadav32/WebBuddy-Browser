import 'package:logging/logging.dart';
import 'package:web_buddy/features/privacy/domain/entities/filter_rule.dart';

final _log = Logger('FilterEngine');

/// The core filter matching engine.
///
/// Maintains a set of parsed filter rules and can quickly test whether a
/// request URL should be blocked. Uses a two-pass approach:
/// 1. Check exception rules (@@) — if any match, the request is allowed.
/// 2. Check blocking rules — if any match, the request is blocked.
///
/// Performance note: For very large lists (>50k rules), the linear scan
/// becomes a bottleneck. A production engine would use a trie or bloom filter.
/// This implementation is sufficient for typical EasyList sizes on mobile.
class FilterEngine {
  final List<FilterRule> _blockingRules = [];
  final List<FilterRule> _exceptionRules = [];
  final List<FilterRule> _cosmeticRules = [];

  int get blockingRuleCount => _blockingRules.length;
  int get exceptionRuleCount => _exceptionRules.length;
  int get cosmeticRuleCount => _cosmeticRules.length;
  int get totalRuleCount =>
      _blockingRules.length + _exceptionRules.length + _cosmeticRules.length;

  /// Loads rules from a filter list string (e.g., EasyList content).
  void loadRules(String filterListContent) {
    final lines = filterListContent.split('\n');
    var loaded = 0;

    for (final line in lines) {
      final rule = FilterRule.parse(line);
      if (rule.isComment) continue;

      if (rule.isCosmeticRule) {
        _cosmeticRules.add(rule);
      } else if (rule.isException) {
        _exceptionRules.add(rule);
      } else {
        _blockingRules.add(rule);
      }
      loaded++;
    }

    _log.info('Loaded $loaded rules '
        '(${_blockingRules.length} blocking, '
        '${_exceptionRules.length} exceptions, '
        '${_cosmeticRules.length} cosmetic)');
  }

  /// Clears all loaded rules.
  void clearRules() {
    _blockingRules.clear();
    _exceptionRules.clear();
    _cosmeticRules.clear();
  }

  /// Checks if a request URL should be blocked.
  ///
  /// Returns a [FilterResult] indicating whether the URL is blocked
  /// and which rule matched.
  FilterResult shouldBlock(String requestUrl, {String? pageHost}) {
    // Exception rules take priority
    for (final rule in _exceptionRules) {
      if (rule.matches(requestUrl, pageHost: pageHost)) {
        return FilterResult(
          blocked: false,
          matchedRule: rule.raw,
          isException: true,
        );
      }
    }

    // Check blocking rules
    for (final rule in _blockingRules) {
      if (rule.matches(requestUrl, pageHost: pageHost)) {
        return FilterResult(
          blocked: true,
          matchedRule: rule.raw,
          isException: false,
        );
      }
    }

    return const FilterResult(blocked: false);
  }

  /// Returns cosmetic rules applicable to a given domain.
  ///
  /// TODO: Cosmetic filtering requires injecting CSS into the page via
  /// JavaScript. This is platform-limited — iOS WKWebView userScripts
  /// support this well, Android WebView less so. Only basic element
  /// hiding is supported, not procedural cosmetic filters.
  List<String> getCosmeticSelectorsForDomain(String domain) {
    final selectors = <String>[];
    for (final rule in _cosmeticRules) {
      final raw = rule.raw;
      final hashIndex = raw.indexOf('##');
      if (hashIndex == -1) continue;

      final domains = hashIndex == 0 ? '' : raw.substring(0, hashIndex);
      final selector = raw.substring(hashIndex + 2);

      if (domains.isEmpty) {
        // Global cosmetic rule
        selectors.add(selector);
      } else {
        // Domain-specific
        final domainList = domains.split(',');
        for (final d in domainList) {
          if (d.startsWith('~')) continue;
          if (domain.endsWith(d)) {
            selectors.add(selector);
            break;
          }
        }
      }
    }
    return selectors;
  }
}

/// Result of a filter check.
class FilterResult {
  final bool blocked;
  final String? matchedRule;
  final bool isException;

  const FilterResult({
    required this.blocked,
    this.matchedRule,
    this.isException = false,
  });
}
