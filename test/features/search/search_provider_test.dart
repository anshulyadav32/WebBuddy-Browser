import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/search/presentation/providers/search_provider.dart';

void main() {
  group('resolveOmniboxInput', () {
    test('resolves URLs directly', () {
      expect(
        resolveOmniboxInput('https://example.com', 'google'),
        'https://example.com',
      );
    });

    test('resolves bare domains with https', () {
      expect(
        resolveOmniboxInput('example.com', 'google'),
        'https://example.com',
      );
    });

    test('resolves search queries to Google', () {
      final result = resolveOmniboxInput('flutter tutorial', 'google');
      expect(result, startsWith('https://www.google.com/search?q='));
      expect(result, contains('flutter'));
    });

    test('resolves search queries to DuckDuckGo', () {
      final result = resolveOmniboxInput('flutter tutorial', 'duckduckgo');
      expect(result, startsWith('https://duckduckgo.com/?q='));
    });

    test('handles empty input', () {
      expect(resolveOmniboxInput('', 'google'), 'about:blank');
      expect(resolveOmniboxInput('   ', 'google'), 'about:blank');
    });

    test('falls back to Google for unknown engine', () {
      final result = resolveOmniboxInput('test query', 'unknown_engine');
      expect(result, startsWith('https://www.google.com/search?q='));
    });
  });
}
