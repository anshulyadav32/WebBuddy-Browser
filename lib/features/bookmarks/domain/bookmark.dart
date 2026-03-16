/// A saved bookmark.
class Bookmark {
  const Bookmark({
    required this.id,
    required this.url,
    required this.title,
    this.faviconUrl,
    this.folder,
    required this.createdAt,
  });

  final String id;
  final String url;
  final String title;
  final String? faviconUrl;
  final String? folder;
  final DateTime createdAt;

  Bookmark copyWith({
    String? url,
    String? title,
    String? faviconUrl,
    String? folder,
  }) {
    return Bookmark(
      id: id,
      url: url ?? this.url,
      title: title ?? this.title,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      folder: folder ?? this.folder,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Bookmark && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Bookmark(id: $id, title: $title, url: $url)';
}
