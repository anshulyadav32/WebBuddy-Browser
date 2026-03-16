/// A visited page entry.
class HistoryItem {
  const HistoryItem({
    required this.id,
    required this.url,
    required this.title,
    this.faviconUrl,
    required this.visitedAt,
  });

  final String id;
  final String url;
  final String title;
  final String? faviconUrl;
  final DateTime visitedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is HistoryItem && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'HistoryItem(id: $id, title: $title, url: $url)';
}
