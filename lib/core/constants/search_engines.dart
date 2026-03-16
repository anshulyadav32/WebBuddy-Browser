/// Search engine configuration.
class SearchEngines {
  SearchEngines._();

  static const Map<String, SearchEngine> engines = {
    'google': SearchEngine(
      id: 'google',
      name: 'Google',
      searchUrl: 'https://www.google.com/search?q=%s',
      suggestUrl: 'https://suggestqueries.google.com/complete/search?client=firefox&q=%s',
      iconUrl: 'https://www.google.com/favicon.ico',
    ),
    'duckduckgo': SearchEngine(
      id: 'duckduckgo',
      name: 'DuckDuckGo',
      searchUrl: 'https://duckduckgo.com/?q=%s',
      suggestUrl: 'https://duckduckgo.com/ac/?q=%s&type=list',
      iconUrl: 'https://duckduckgo.com/favicon.ico',
    ),
    'bing': SearchEngine(
      id: 'bing',
      name: 'Bing',
      searchUrl: 'https://www.bing.com/search?q=%s',
      suggestUrl: 'https://api.bing.com/osjson.aspx?query=%s',
      iconUrl: 'https://www.bing.com/favicon.ico',
    ),
    'brave': SearchEngine(
      id: 'brave',
      name: 'Brave Search',
      searchUrl: 'https://search.brave.com/search?q=%s',
      suggestUrl: 'https://search.brave.com/api/suggest?q=%s',
      iconUrl: 'https://brave.com/favicon.ico',
    ),
  };
}

class SearchEngine {
  final String id;
  final String name;
  final String searchUrl;
  final String suggestUrl;
  final String iconUrl;

  const SearchEngine({
    required this.id,
    required this.name,
    required this.searchUrl,
    required this.suggestUrl,
    required this.iconUrl,
  });

  String buildSearchUrl(String query) {
    return searchUrl.replaceAll('%s', Uri.encodeComponent(query));
  }

  String buildSuggestUrl(String query) {
    return suggestUrl.replaceAll('%s', Uri.encodeComponent(query));
  }
}
