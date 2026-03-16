/// Status of a file download.
enum DownloadStatus { queued, downloading, completed, failed, cancelled }

/// A tracked download.
class DownloadItem {
  const DownloadItem({
    required this.id,
    required this.url,
    required this.fileName,
    this.savePath,
    this.mimeType,
    this.totalBytes = 0,
    this.receivedBytes = 0,
    this.status = DownloadStatus.queued,
    required this.startedAt,
  });

  final String id;
  final String url;
  final String fileName;
  final String? savePath;
  final String? mimeType;
  final int totalBytes;
  final int receivedBytes;
  final DownloadStatus status;
  final DateTime startedAt;

  double get progress =>
      totalBytes > 0 ? (receivedBytes / totalBytes).clamp(0.0, 1.0) : 0.0;

  DownloadItem copyWith({
    String? savePath,
    String? mimeType,
    int? totalBytes,
    int? receivedBytes,
    DownloadStatus? status,
  }) {
    return DownloadItem(
      id: id,
      url: url,
      fileName: fileName,
      savePath: savePath ?? this.savePath,
      mimeType: mimeType ?? this.mimeType,
      totalBytes: totalBytes ?? this.totalBytes,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      status: status ?? this.status,
      startedAt: startedAt,
    );
  }

  /// Serialize to a flat map for persistence.
  Map<String, dynamic> toMap() => {
        'id': id,
        'url': url,
        'fileName': fileName,
        'savePath': savePath,
        'mimeType': mimeType,
        'totalBytes': totalBytes,
        'receivedBytes': receivedBytes,
        'status': status.index,
        'startedAt': startedAt.toIso8601String(),
      };

  /// Deserialize from a flat map.
  factory DownloadItem.fromMap(Map<String, dynamic> map) {
    return DownloadItem(
      id: map['id'] as String,
      url: map['url'] as String,
      fileName: map['fileName'] as String,
      savePath: map['savePath'] as String?,
      mimeType: map['mimeType'] as String?,
      totalBytes: map['totalBytes'] as int? ?? 0,
      receivedBytes: map['receivedBytes'] as int? ?? 0,
      status: DownloadStatus.values[map['status'] as int? ?? 0],
      startedAt: DateTime.parse(map['startedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DownloadItem && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'DownloadItem(id: $id, fileName: $fileName, status: $status)';
}
