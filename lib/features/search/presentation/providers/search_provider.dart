import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:web_buddy/core/constants/app_constants.dart';
import 'package:web_buddy/core/constants/search_engines.dart';
import 'package:web_buddy/core/utils/url_utils.dart';
import 'package:web_buddy/features/settings/presentation/providers/settings_provider.dart';

final _log = Logger('SearchProvider');

/// Omnibox input state.
final omniboxQueryProvider = StateProvider<String>((ref) => '');

/// Search suggestions for the current omnibox query.
final searchSuggestionsProvider =
    FutureProvider.autoDispose<List<OmniboxSuggestion>>((ref) async {
  final query = ref.watch(omniboxQueryProvider);
  if (query.trim().length < 2) return [];

  // Debounce
  await Future<void>.delayed(AppConstants.searchSuggestionDebounce);
  if (ref.state.isRefreshing) return [];

  final settings = ref.read(settingsProvider);
  final engine = SearchEngines.engines[settings.searchEngineId] ??
      SearchEngines.engines['google']!;

  final suggestions = <OmniboxSuggestion>[];

  // If it looks like a URL, add it as a top suggestion
  if (UrlUtils.isUrl(query)) {
    suggestions.add(OmniboxSuggestion(
      text: query,
      url: UrlUtils.normalizeUrl(query),
      type: SuggestionType.url,
    ));
  }

  // Fetch search suggestions
  try {
    final suggestUrl = engine.buildSuggestUrl(query);
    final response = await http
        .get(Uri.parse(suggestUrl))
        .timeout(const Duration(seconds: 3));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<String> terms = [];

      if (data is List && data.length >= 2) {
        terms = (data[1] as List).cast<String>().take(5).toList();
      }

      for (final term in terms) {
        suggestions.add(OmniboxSuggestion(
          text: term,
          url: engine.buildSearchUrl(term),
          type: SuggestionType.search,
        ));
      }
    }
  } catch (e) {
    _log.fine('Search suggestion fetch failed: $e');
  }

  return suggestions;
});

/// Resolves an omnibox input to a URL.
String resolveOmniboxInput(String input, String searchEngineId) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return 'about:blank';

  if (UrlUtils.isUrl(trimmed)) {
    return UrlUtils.normalizeUrl(trimmed);
  }

  // It's a search query
  final engine = SearchEngines.engines[searchEngineId] ??
      SearchEngines.engines['google']!;
  return engine.buildSearchUrl(trimmed);
}

class OmniboxSuggestion {
  final String text;
  final String url;
  final SuggestionType type;

  const OmniboxSuggestion({
    required this.text,
    required this.url,
    required this.type,
  });
}

enum SuggestionType { url, search, history, bookmark }
