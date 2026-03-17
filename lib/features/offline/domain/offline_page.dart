class OfflinePage {
  const OfflinePage({
    required this.id,
    required this.url,
    required this.title,
    required this.filePath,
    required this.savedAt,
  });

  final String id;
  final String url;
  final String title;
  final String filePath;
  final DateTime savedAt;

  OfflinePage copyWith({
    String? id,
    String? url,
    String? title,
    String? filePath,
    DateTime? savedAt,
  }) {
    return OfflinePage(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'url': url,
    'title': title,
    'filePath': filePath,
    'savedAt': savedAt.toIso8601String(),
  };

  factory OfflinePage.fromMap(Map<String, dynamic> map) {
    return OfflinePage(
      id: map['id'] as String,
      url: map['url'] as String,
      title: map['title'] as String,
      filePath: map['filePath'] as String,
      savedAt: DateTime.parse(map['savedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflinePage &&
          id == other.id &&
          url == other.url &&
          title == other.title &&
          filePath == other.filePath &&
          savedAt == other.savedAt;

  @override
  int get hashCode => Object.hash(id, url, title, filePath, savedAt);
}
