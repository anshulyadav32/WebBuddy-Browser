extension StringExtensions on String {
  /// Truncates string to [maxLength] with an optional [ellipsis].
  String truncate(int maxLength, {String ellipsis = '…'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Returns null if the string is empty, otherwise returns the string.
  String? get nullIfEmpty => isEmpty ? null : this;
}

extension UriExtensions on Uri {
  /// Returns a shortened display string.
  String get displayHost {
    final h = host;
    if (h.startsWith('www.')) return h.substring(4);
    return h;
  }
}
