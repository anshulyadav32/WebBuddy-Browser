/// Status of a file download.
enum DownloadStatus { pending, downloading, completed, failed, cancelled }

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
    this.status = DownloadStatus.pending,
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DownloadItem && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'DownloadItem(id: $id, fileName: $fileName, status: $status)';
}
