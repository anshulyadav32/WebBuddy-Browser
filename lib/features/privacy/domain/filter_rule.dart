/// A parsed filter rule from an Adblock Plus-style filter list.
///
/// Supports a practical subset of the ABP filter syntax:
/// - `||domain.com^` — domain anchor rules
/// - `@@||domain.com^` — exception (allowlist) rules
/// - `$third-party` — third-party request option
/// - `$domain=` — domain restriction option
/// - `##.class` — cosmetic (element hiding) rules (stored but not enforced
///   via network blocking; applied via JS injection where possible)
///
/// Full EasyList specification parity is **not** attempted. This is an MVP
/// subset sufficient for blocking the most common ad and tracker domains.
class FilterRule {
  const FilterRule({
    required this.raw,
    required this.pattern,
    this.isException = false,
    this.isCosmetic = false,
    this.thirdPartyOnly = false,
    this.domains = const [],
    this.cosmeticSelector,
  });

  /// The original filter text as it appears in the list.
  final String raw;

  /// The normalised pattern used for matching (domain or URL fragment).
  /// For domain-anchor rules (`||domain.com^`) this is `domain.com`.
  final String pattern;

  /// `true` for `@@` exception / allowlist rules.
  final bool isException;

  /// `true` for `##` cosmetic / element-hiding rules.
  final bool isCosmetic;

  /// `true` when the rule includes `$third-party`.
  final bool thirdPartyOnly;

  /// Optional domain restrictions from `$domain=...`.
  final List<String> domains;

  /// The CSS selector for cosmetic rules (e.g. `.ad-banner`).
  final String? cosmeticSelector;

  /// Parses a single filter line into a [FilterRule], or returns `null`
  /// for comments and empty lines.
  static FilterRule? tryParse(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('!')) return null;

    // — Cosmetic filter: `##.selector` or `domain##.selector`
    final cosmeticIdx = trimmed.indexOf('##');
    if (cosmeticIdx >= 0) {
      final selector = trimmed.substring(cosmeticIdx + 2);
      final domainPart = cosmeticIdx > 0
          ? trimmed.substring(0, cosmeticIdx)
          : '';
      return FilterRule(
        raw: trimmed,
        pattern: domainPart,
        isCosmetic: true,
        cosmeticSelector: selector,
        domains: domainPart.isNotEmpty
            ? domainPart.split(',').map((d) => d.trim()).toList()
            : const [],
      );
    }

    var working = trimmed;
    var isException = false;

    // — Exception rule prefix `@@`
    if (working.startsWith('@@')) {
      isException = true;
      working = working.substring(2);
    }

    // — Parse options after `$`
    var thirdParty = false;
    List<String> domains = [];

    final dollarIdx = working.indexOf(r'$');
    if (dollarIdx >= 0) {
      final optionsPart = working.substring(dollarIdx + 1);
      working = working.substring(0, dollarIdx);

      for (final opt in optionsPart.split(',')) {
        final o = opt.trim().toLowerCase();
        if (o == 'third-party') {
          thirdParty = true;
        } else if (o.startsWith('domain=')) {
          domains = o.substring(7).split('|').map((d) => d.trim()).toList();
        }
      }
    }

    // — Domain anchor `||domain.com^`
    if (working.startsWith('||')) {
      working = working.substring(2);
    }

    // — Strip trailing separator `^`
    if (working.endsWith('^')) {
      working = working.substring(0, working.length - 1);
    }

    if (working.isEmpty) return null;

    return FilterRule(
      raw: trimmed,
      pattern: working.toLowerCase(),
      isException: isException,
      thirdPartyOnly: thirdParty,
      domains: domains,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FilterRule && raw == other.raw;

  @override
  int get hashCode => raw.hashCode;

  @override
  String toString() => 'FilterRule($raw)';
}
