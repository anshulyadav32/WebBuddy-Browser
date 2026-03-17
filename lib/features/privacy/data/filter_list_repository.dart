import 'package:flutter/services.dart' show rootBundle;

import '../domain/filter_rule.dart';

/// Loads and caches filter lists from bundled assets.
///
/// Currently ships a single built-in list (`basic_filters.txt`).
/// The design allows adding remote list support in the future.
class FilterListRepository {
  FilterListRepository();

  List<FilterRule>? _cachedRules;

  static const _assetPath = 'assets/filter_lists/basic_filters.txt';

  /// Returns all parsed filter rules from the built-in list.
  ///
  /// Results are cached after the first load.
  Future<List<FilterRule>> loadRules() async {
    if (_cachedRules != null) return _cachedRules!;
    _cachedRules = await _parseAsset();
    return _cachedRules!;
  }

  /// Parses rules synchronously from already-loaded text.
  ///
  /// Useful for testing or when the raw text is available.
  static List<FilterRule> parseRules(String rawText) {
    return rawText
        .split('\n')
        .map(FilterRule.tryParse)
        .whereType<FilterRule>()
        .toList();
  }

  /// Forces a reload on the next [loadRules] call.
  void invalidateCache() {
    _cachedRules = null;
  }

  Future<List<FilterRule>> _parseAsset() async {
    final raw = await rootBundle.loadString(_assetPath);
    return parseRules(raw);
  }
}
